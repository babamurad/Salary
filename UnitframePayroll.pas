unit UnitframePayroll;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Data.DB, Vcl.Grids,
  Vcl.DBGrids, Vcl.ExtCtrls, Vcl.DBCtrls, Vcl.StdCtrls,
  FireDAC.Comp.Client, FireDAC.Comp.DataSet, FireDAC.Stan.Param;

type
  TframePayroll = class(TFrame)
    PanelTop: TPanel;
    DBNavigator1: TDBNavigator;
    DBGrid1: TDBGrid;
    btnCalc: TButton;
  private
    qryPayroll: TFDQuery;
    dsPayroll: TDataSource;
    procedure btnCalcClick(Sender: TObject);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;

implementation

{$R *.dfm}

uses
  UnitdmMain;

constructor TframePayroll.Create(AOwner: TComponent);
begin
  inherited;

  // Привязываем событие клика к нашей кнопке
  btnCalc.OnClick := btnCalcClick;

  if Assigned(dmMain) then
  begin

    // --- УДАЛЯЕМ СЛОМАННЫЕ ДАТЫ ИЗ ПРОШЛЫХ ПОПЫТОК ---
    dmMain.conn.ExecSQL('DELETE FROM payroll_journal');

    // 1. Создаем запрос программно
    qryPayroll := TFDQuery.Create(Self);
    qryPayroll.Connection := dmMain.conn;

    // 2. Пишем SQL с объединением таблиц (Журнал + Сотрудники)
    qryPayroll.SQL.Text :=
      'SELECT p.*, e.fio, e.base_salary ' +
      'FROM payroll_journal p ' +
      'JOIN employees e ON p.emp_id = e.id ' +
      'ORDER BY p.period_date DESC, e.fio';

    // 3. Создаем датасорс
    dsPayroll := TDataSource.Create(Self);
    dsPayroll.DataSet := qryPayroll;

    // 4. Подключаем интерфейс
    DBGrid1.DataSource := dsPayroll;
    DBNavigator1.DataSource := dsPayroll;

    qryPayroll.Open;

    // 5. Настраиваем колонки и переводим на русский
    if DBGrid1.Columns.Count > 0 then
    begin
      DBGrid1.Columns[0].Visible := False; // Скрываем id
      DBGrid1.Columns[1].Visible := False; // Скрываем emp_id

      DBGrid1.Columns[2].Title.Caption := 'Период (Дата)';
      DBGrid1.Columns[2].Width := 120;

      DBGrid1.Columns[3].Title.Caption := 'Начислено (Грязными)';
      DBGrid1.Columns[3].Width := 180;

      DBGrid1.Columns[4].Title.Caption := 'Подоходный налог';
      DBGrid1.Columns[4].Width := 140;

      DBGrid1.Columns[5].Title.Caption := 'Пенсионный фонд';
      DBGrid1.Columns[5].Width := 140;

      DBGrid1.Columns[6].Title.Caption := 'К выплате (Чистыми)';
      DBGrid1.Columns[6].Width := 180;

      // Поля из таблицы сотрудников (подтянутые через JOIN)
      if DBGrid1.Columns.Count > 7 then
      begin
        DBGrid1.Columns[7].Title.Caption := 'Сотрудник';
        DBGrid1.Columns[7].Width := 200;
        DBGrid1.Columns[7].ReadOnly := True;
        DBGrid1.Columns[7].Index := 0; // Перемещаем ФИО в самое начало таблицы!
      end;

      if DBGrid1.Columns.Count > 8 then
      begin
        DBGrid1.Columns[8].Title.Caption := 'Оклад';
        DBGrid1.Columns[8].Width := 100;
        DBGrid1.Columns[8].ReadOnly := True;
        DBGrid1.Columns[8].Index := 1; // Оклад ставим сразу после ФИО
      end;
    end;
  end;
end;

destructor TframePayroll.Destroy;
begin
  // Убираем за собой мусор из памяти при закрытии вкладки
  if Assigned(qryPayroll) then qryPayroll.Free;
  if Assigned(dsPayroll) then dsPayroll.Free;
  inherited;
end;

//  ShowMessage('Здесь будет магия автоматического расчета зарплаты со всеми налогами!');

procedure TframePayroll.btnCalcClick(Sender: TObject);
var
  QryEmp, QrySet, QryExec: TFDQuery;
  TaxRate, PensionRate: Double;
  EmpId: Integer;
  Gross, Tax, Pension, Net: Currency;
  CalcDateStr: string; // <-- Теперь дата это просто текст
begin
  if MessageDlg('Рассчитать зарплату за текущий месяц для всех активных сотрудников?',
     mtConfirmation, [mbYes, mbNo], 0) <> mrYes then Exit;

  // ЖЕСТКИЙ ФОРМАТ SQLITE: Год-Месяц-День (например, 2026-02-28)
  CalcDateStr := FormatDateTime('yyyy-mm-dd', Date);

  QryEmp := TFDQuery.Create(nil);
  QrySet := TFDQuery.Create(nil);
  QryExec := TFDQuery.Create(nil);
  try
    QryEmp.Connection := dmMain.conn;
    QrySet.Connection := dmMain.conn;
    QryExec.Connection := dmMain.conn;

    TaxRate := 10.0;
    PensionRate := 2.0;

    QrySet.SQL.Text := 'SELECT key_name, key_value FROM settings';
    QrySet.Open;
    while not QrySet.Eof do
    begin
      if QrySet.FieldByName('key_name').AsString = 'income_tax' then
        TaxRate := QrySet.FieldByName('key_value').AsFloat
      else if QrySet.FieldByName('key_name').AsString = 'pension_fund' then
        PensionRate := QrySet.FieldByName('key_value').AsFloat;
      QrySet.Next;
    end;

    QryEmp.SQL.Text := 'SELECT id, base_salary FROM employees WHERE status = 1';
    QryEmp.Open;

    if QryEmp.IsEmpty then
    begin
      ShowMessage('Нет активных сотрудников для расчета!');
      Exit;
    end;

    dmMain.conn.StartTransaction;
    try
      // Удаляем старые расчеты за этот месяц (передаем как строку)
      QryExec.SQL.Text := 'DELETE FROM payroll_journal WHERE strftime(''%Y-%m'', period_date) = strftime(''%Y-%m'', :D)';
      QryExec.ParamByName('D').AsString := CalcDateStr;
      QryExec.ExecSQL;

      // Готовим запрос на вставку
      QryExec.SQL.Text := 'INSERT INTO payroll_journal (emp_id, period_date, gross_amount, tax_amount, pension_amount, net_amount) ' +
                          'VALUES (:emp, :dt, :gross, :tax, :pens, :net)';

      while not QryEmp.Eof do
      begin
        EmpId := QryEmp.FieldByName('id').AsInteger;
        Gross := QryEmp.FieldByName('base_salary').AsCurrency;

        Tax := (Gross * TaxRate) / 100;
        Pension := (Gross * PensionRate) / 100;
        Net := Gross - Tax - Pension;

        QryExec.ParamByName('emp').AsInteger := EmpId;
        QryExec.ParamByName('dt').AsString := CalcDateStr; // <-- ПЕРЕДАЕМ КАК ТЕКСТ
        QryExec.ParamByName('gross').AsCurrency := Gross;
        QryExec.ParamByName('tax').AsCurrency := Tax;
        QryExec.ParamByName('pens').AsCurrency := Pension;
        QryExec.ParamByName('net').AsCurrency := Net;

        QryExec.ExecSQL;
        QryEmp.Next;
      end;

      dmMain.conn.Commit;
      qryPayroll.Refresh;
      ShowMessage('Расчет зарплаты успешно завершен!');

    except
      on E: Exception do
      begin
        dmMain.conn.Rollback;
        ShowMessage('Ошибка при расчете: ' + E.Message);
      end;
    end;

  finally
    QryEmp.Free;
    QrySet.Free;
    QryExec.Free;
  end;
end;



end.

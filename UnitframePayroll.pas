unit UnitframePayroll;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Data.DB, Vcl.Grids,
  Vcl.DBGrids, Vcl.ExtCtrls, Vcl.DBCtrls, Vcl.StdCtrls, System.Math, System.DateUtils,
  FireDAC.Comp.Client, FireDAC.Comp.DataSet, FireDAC.Stan.Param;

type
  TframePayroll = class(TFrame)
    PanelTop: TPanel;
    DBNavigator1: TDBNavigator;
    DBGrid1: TDBGrid;
    btnCalc: TButton;
    cmbMonth: TComboBox;
    cmbYear: TComboBox;
    btnCloseMonth: TButton;
    procedure btnCalcClick(Sender: TObject);
    procedure btnCloseMonthClick(Sender: TObject);
    procedure FilterChange(Sender: TObject); // Общий обработчик для смены фильтра
  private
    qryPayroll: TFDQuery;
    dsPayroll: TDataSource;
    procedure qryPayrollAfterOpen(DataSet: TDataSet);
    procedure RefreshData; // Метод для пересборки SQL с учетом фильтра
    function IsPeriodClosed(APeriod: string): Boolean; // Проверка замка
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function GetWorkingDaysNorm(AYear, AMonth: Integer): Integer;
  end;

implementation

{$R *.dfm}

uses UnitdmMain;

{ TframePayroll }

constructor TframePayroll.Create(AOwner: TComponent);
var
  i, CurrentYear: Integer;
begin
  inherited;

  // 1. Заполняем месяцы
  cmbMonth.Items.CommaText := 'Январь,Февраль,Март,Апрель,Май,Июнь,Июль,Август,Сентябрь,Октябрь,Ноябрь,Декабрь';

  // 2. Заполняем годы (текущий +/- 2 года)
  CurrentYear := YearOf(Date);
  for i := CurrentYear - 2 to CurrentYear + 2 do
    cmbYear.Items.Add(IntToStr(i));

  // 3. Ставим текущие значения
  cmbMonth.ItemIndex := MonthOf(Date) - 1;
  cmbYear.Text := IntToStr(CurrentYear);

  if Assigned(dmMain) then
  begin
    qryPayroll := TFDQuery.Create(Self);
    qryPayroll.Connection := dmMain.conn;
    qryPayroll.AfterOpen := qryPayrollAfterOpen;
    qryPayroll.UpdateOptions.UpdateTableName := 'payroll_journal';
    qryPayroll.UpdateOptions.KeyFields := 'id';

    dsPayroll := TDataSource.Create(Self);
    dsPayroll.DataSet := qryPayroll;

    DBGrid1.DataSource := dsPayroll;
    DBNavigator1.DataSource := dsPayroll;

    RefreshData; // Загружаем данные с учетом фильтра
  end;

  // Привязываем события
  cmbMonth.OnChange := FilterChange;
  cmbYear.OnChange := FilterChange;
end;

procedure TframePayroll.RefreshData;
var
  SelectedPeriod: string;
begin
  // Формируем строку периода 'YYYY-MM' (например, '2026-03')
  SelectedPeriod := cmbYear.Text + '-' + Format('%.2d', [cmbMonth.ItemIndex + 1]);

  qryPayroll.Close;
  qryPayroll.SQL.Text :=
    'SELECT p.*, e.fio, e.base_salary ' +
    'FROM payroll_journal p ' +
    'JOIN employees e ON p.emp_id = e.id ' +
    'WHERE strftime(''%Y-%m'', p.period_date) = :period ' +
    'ORDER BY e.fio';
  qryPayroll.ParamByName('period').AsString := SelectedPeriod;
  qryPayroll.Open;
end;

procedure TframePayroll.FilterChange(Sender: TObject);
begin
  RefreshData;
end;

function TframePayroll.GetWorkingDaysNorm(AYear, AMonth: Integer): Integer;
var
  i, DaysCount: Integer;
  D: TDateTime;
begin
  Result := 0;
  DaysCount := DaysInAMonth(AYear, AMonth);
  for i := 1 to DaysCount do
  begin
    D := EncodeDate(AYear, AMonth, i);
    // Считаем все дни, кроме 6 (Суббота) и 7 (Воскресенье)
    if not (DayOfTheWeek(D) in [6, 7]) then
      Inc(Result);
  end;
end;

function TframePayroll.IsPeriodClosed(APeriod: string): Boolean;
var
  Q: TFDQuery;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := dmMain.conn;
    Q.SQL.Text := 'SELECT 1 FROM closed_periods WHERE period_str = :p';
    Q.ParamByName('p').AsString := APeriod;
    Q.Open;
    Result := not Q.IsEmpty;
  finally
    Q.Free;
  end;
end;

procedure TframePayroll.btnCalcClick(Sender: TObject);
var
  QryEmp, QrySet, QryExec: TFDQuery;
  TaxRate, PensionRate, DepDeduction: Double;
  EmpId, DepCount, NormDays, FactDays: Integer;
  BaseSal, Gross, Tax, Pension, Net, TaxBase: Double;
  SelectedPeriod, CalcDateStr: string;
begin
  SelectedPeriod := cmbYear.Text + '-' + Format('%.2d', [cmbMonth.ItemIndex + 1]);

  // ПРОВЕРКА ЗАМКА
  if IsPeriodClosed(SelectedPeriod) then
  begin
    ShowMessage('Этот месяц уже закрыт для редактирования!');
    Exit;
  end;

  if MessageDlg('Рассчитать зарплату за ' + cmbMonth.Text + ' ' + cmbYear.Text + '?',
     mtConfirmation, [mbYes, mbNo], 0) <> mrYes then Exit;

  // Узнаем НОРМУ рабочих дней в этом месяце
  NormDays := GetWorkingDaysNorm(StrToIntDef(cmbYear.Text, YearOf(Now)), cmbMonth.ItemIndex + 1);
  if NormDays = 0 then NormDays := 1; // Защита от деления на ноль

  CalcDateStr := SelectedPeriod + '-01';

  QryEmp := TFDQuery.Create(nil);
  QrySet := TFDQuery.Create(nil);
  QryExec := TFDQuery.Create(nil);
  try
    QryEmp.Connection := dmMain.conn;
    QrySet.Connection := dmMain.conn;
    QryExec.Connection := dmMain.conn;

    // Читаем налоги
    QrySet.SQL.Text := 'SELECT key_name, key_value FROM settings';
    QrySet.Open;
    TaxRate := 10.0; PensionRate := 2.0; DepDeduction := 50.0;
    while not QrySet.Eof do
    begin
      if QrySet.FieldByName('key_name').AsString = 'income_tax' then TaxRate := QrySet.FieldByName('key_value').AsFloat
      else if QrySet.FieldByName('key_name').AsString = 'pension_fund' then PensionRate := QrySet.FieldByName('key_value').AsFloat
      else if QrySet.FieldByName('key_name').AsString = 'dependent_deduction' then DepDeduction := QrySet.FieldByName('key_value').AsFloat;
      QrySet.Next;
    end;

    // --- МАГИЯ SQL: Достаем сотрудников и их ФАКТИЧЕСКИ отработанные дни из ТАБЕЛЯ ---
    QryEmp.SQL.Text :=
      'SELECT e.id, e.base_salary, IFNULL(e.dependents_count, 0) as dep_count, ' +
      ' (SELECT COUNT(*) FROM timesheet t WHERE t.emp_id = e.id AND strftime(''%Y-%m'', t.work_date) = :p AND t.hours_worked > 0) as fact_days ' +
      'FROM employees e WHERE e.status = 1';
    QryEmp.ParamByName('p').AsString := SelectedPeriod;
    QryEmp.Open;

    dmMain.conn.StartTransaction;
    try
      QryExec.SQL.Text := 'DELETE FROM payroll_journal WHERE strftime(''%Y-%m'', period_date) = :P';
      QryExec.ParamByName('P').AsString := SelectedPeriod;
      QryExec.ExecSQL;

      QryExec.SQL.Text := 'INSERT INTO payroll_journal (emp_id, period_date, gross_amount, tax_amount, pension_amount, net_amount) ' +
                          'VALUES (:emp, :dt, :gross, :tax, :pens, :net)';

      while not QryEmp.Eof do
      begin
        BaseSal := QryEmp.FieldByName('base_salary').AsFloat;
        DepCount := QryEmp.FieldByName('dep_count').AsInteger;
        FactDays := QryEmp.FieldByName('fact_days').AsInteger; // Дни из табеля

        // --- НОВАЯ СПРАВЕДЛИВАЯ ФОРМУЛА НАЧИСЛЕНИЯ ---
        Gross := SimpleRoundTo((BaseSal / NormDays) * FactDays, -2);

        Pension := SimpleRoundTo((Gross * PensionRate) / 100.0, -2);
        TaxBase := Gross - (DepCount * DepDeduction);
        Tax := SimpleRoundTo(Max(0, TaxBase * TaxRate / 100.0), -2);
        Net := SimpleRoundTo(Gross - Tax - Pension, -2);

        QryExec.ParamByName('emp').AsInteger := QryEmp.FieldByName('id').AsInteger;
        QryExec.ParamByName('dt').AsString := CalcDateStr;
        QryExec.ParamByName('gross').AsFloat := Gross;
        QryExec.ParamByName('tax').AsFloat := Tax;
        QryExec.ParamByName('pens').AsFloat := Pension;
        QryExec.ParamByName('net').AsFloat := Net;
        QryExec.ExecSQL;

        QryEmp.Next;
      end;
      dmMain.conn.Commit;
      RefreshData;
      ShowMessage('Расчет успешно завершен! Зарплата начислена пропорционально табелю.');
    except
      on E: Exception do begin dmMain.conn.Rollback; ShowMessage('Ошибка: ' + E.Message); end;
    end;
  finally
    QryEmp.Free; QrySet.Free; QryExec.Free;
  end;
end;

procedure TframePayroll.btnCloseMonthClick(Sender: TObject);
var
  Period: string;
begin
  Period := cmbYear.Text + '-' + Format('%.2d', [cmbMonth.ItemIndex + 1]);
  if MessageDlg('Вы уверены, что хотите ЗАКРЫТЬ ' + cmbMonth.Text + ' для редактирования? Это действие нельзя отменить.',
     mtWarning, [mbYes, mbNo], 0) = mrYes then
  begin
    try
      dmMain.conn.ExecSQL('INSERT INTO closed_periods (period_str) VALUES (:p)', [Period]);
      ShowMessage('Период заблокирован!');
    except
      ShowMessage('Этот период уже был закрыт ранее.');
    end;
  end;
end;

procedure TframePayroll.qryPayrollAfterOpen(DataSet: TDataSet);
begin
  if DBGrid1.Columns.Count > 0 then
  begin
    DBGrid1.Columns[0].Visible := False; // id
    DBGrid1.Columns[1].Visible := False; // emp_id
    DBGrid1.Columns[2].Title.Caption := 'Дата';
    DBGrid1.Columns[3].Title.Caption := 'Начислено';
    DBGrid1.Columns[3].Width := 150;
    DBGrid1.Columns[4].Title.Caption := 'Налог';
    DBGrid1.Columns[4].Width := 150;
    DBGrid1.Columns[5].Title.Caption := 'Пенс. фонд';
    DBGrid1.Columns[6].Title.Caption := 'На руки';
    DBGrid1.Columns[7].Title.Caption := 'Сотрудник';
    DBGrid1.Columns[7].Width := 220;
    DBGrid1.Columns[7].Index := 0;
    DBGrid1.Columns[8].Title.Caption := 'Оклад';
    DBGrid1.Columns[8].Width := 180;
    DBGrid1.Columns[8].Index := 1;
  end;
  // Красивое форматирование денег (с пробелами тысячных и TMT)
  if DataSet.FindField('gross_amount') <> nil then
    TFloatField(DataSet.FieldByName('gross_amount')).DisplayFormat := '#,##0.00 TMT';

  if DataSet.FindField('tax_amount') <> nil then
    TFloatField(DataSet.FieldByName('tax_amount')).DisplayFormat := '#,##0.00 TMT';

  if DataSet.FindField('pension_amount') <> nil then
    TFloatField(DataSet.FieldByName('pension_amount')).DisplayFormat := '#,##0.00 TMT';

  if DataSet.FindField('net_amount') <> nil then
    TFloatField(DataSet.FieldByName('net_amount')).DisplayFormat := '#,##0.00 TMT';

  if DataSet.FindField('base_salary') <> nil then
    TFloatField(DataSet.FieldByName('base_salary')).DisplayFormat := '#,##0.00 TMT';
end;

destructor TframePayroll.Destroy;
begin
  if Assigned(qryPayroll) then qryPayroll.Free;
  if Assigned(dsPayroll) then dsPayroll.Free;
  inherited;
end;

end.

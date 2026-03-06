unit UnitVacationCalc;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.DBCtrls,
  Vcl.ComCtrls, Vcl.Mask, System.UITypes; // Добавлен UITypes для MessageDlg

type
  TFormVacationCalc = class(TForm)
    dtpStart: TDateTimePicker;
    dtpEnd: TDateTimePicker;
    Button1: TButton;
    ButtonSave: TButton;
    cmbEmployee: TComboBox;
    lbResult: TLabel;
    GroupBox1: TGroupBox;
    procedure FormShow(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure ButtonSaveClick(Sender: TObject);
  private
    // Переменные для хранения рассчитанных данных, чтобы не считать дважды
    FSelectedEmpID: Integer;
    FDaysCount: Integer;
    FAvgMonthly: Double;
    FAvgDaily: Double;
    FTotalAmount: Double;
    FIsCalculated: Boolean; // Флаг: был ли произведен расчет

    procedure DoCalculate; // Вынесли логику расчета в отдельную процедуру
  public
    { Public declarations }
  end;

var
  FormVacationCalc: TFormVacationCalc;

implementation

{$R *.dfm}

uses UnitdmMain, System.DateUtils, Data.DB;

{ TFormVacationCalc }

procedure TFormVacationCalc.FormShow(Sender: TObject);
begin
  cmbEmployee.Items.Clear;
  lbResult.Caption := '';
  FIsCalculated := False;

  if not Assigned(dmMain) then Exit;

  if not dmMain.qryEmployees.Active then
    dmMain.qryEmployees.Open;

  dmMain.qryEmployees.First;
  while not dmMain.qryEmployees.Eof do
  begin
    cmbEmployee.Items.AddObject(
      dmMain.qryEmployees.FieldByName('fio').AsString,
      TObject(dmMain.qryEmployees.FieldByName('id').AsInteger)
    );
    dmMain.qryEmployees.Next;
  end;

  if cmbEmployee.Items.Count > 0 then
    cmbEmployee.ItemIndex := 0;
end;

procedure TFormVacationCalc.DoCalculate;
var
  StartDate, EndDate: TDate;
  CurrentBaseSalary: Double;
begin
  if cmbEmployee.ItemIndex = -1 then
  begin
    ShowMessage('Выберите сотрудника!');
    Exit;
  end;

  FSelectedEmpID := Integer(cmbEmployee.Items.Objects[cmbEmployee.ItemIndex]);
  StartDate := dtpStart.Date;
  EndDate := dtpEnd.Date;

  if EndDate < StartDate then
  begin
    ShowMessage('Ошибка: Дата окончания не может быть раньше даты начала!');
    Exit;
  end;

  FDaysCount := DaysBetween(EndDate, StartDate) + 1;

  // Получаем средний доход за 12 месяцев из базы
  FAvgMonthly := dmMain.GetAverageYearlySalary(FSelectedEmpID, StartDate);

  // --- ЗАЩИТА ОТ ПУСТОЙ ИСТОРИИ ---
  if FAvgMonthly <= 0 then
  begin
    if MessageDlg('У сотрудника пустая история начислений за последние 12 месяцев!' + sLineBreak +
                  'Рассчитать отпускные исходя из текущего оклада?',
                  mtWarning, [mbYes, mbNo], 0) = mrYes then
    begin
      // Ищем оклад прямо в наборе данных сотрудников
      if dmMain.qryEmployees.Locate('id', FSelectedEmpID, []) then
        FAvgMonthly := dmMain.qryEmployees.FieldByName('base_salary').AsFloat
      else
        FAvgMonthly := 0;
    end
    else
    begin
      FIsCalculated := False;
      Exit; // Пользователь отказался, прерываем расчет
    end;
  end;

  // Считаем суммы
  if FAvgMonthly > 0 then
    FAvgDaily := FAvgMonthly / 29.7
  else
    FAvgDaily := 0;

  FTotalAmount := FAvgDaily * FDaysCount;
  FIsCalculated := True; // Успешно рассчитано

  // Выводим результат
  lbResult.Caption :=
    'Дней отпуска: ' + IntToStr(FDaysCount) + sLineBreak +
    'Среднемесячный: ' + FormatFloat('#,##0.00', FAvgMonthly) + ' TMT' + sLineBreak +
    'Среднедневной: ' + FormatFloat('#,##0.00', FAvgDaily) + ' TMT' + sLineBreak +
    sLineBreak +
    'ИТОГО К ВЫПЛАТЕ: ' + FormatFloat('#,##0.00', FTotalAmount) + ' TMT';
end;

procedure TFormVacationCalc.Button1Click(Sender: TObject);
begin
  DoCalculate;
end;

procedure TFormVacationCalc.ButtonSaveClick(Sender: TObject);
var
  CalcDate: TDate;
begin
  // Если кадровик сразу нажал "Сохранить", не нажав "Рассчитать", считаем за него
  if not FIsCalculated then
    DoCalculate;

  // Если после расчета всё равно ошибка (например, отказался считать из оклада)
  if not FIsCalculated then Exit;

  CalcDate := Date;

  try
    dmMain.conn.ExecSQL(
      'INSERT INTO vacation_journal (emp_id, calc_date, start_date, end_date, ' +
      'days_count, avg_monthly_salary, avg_daily_salary, total_amount) ' +
      'VALUES (:emp_id, :calc_date, :start_date, :end_date, :days, :avg_m, :avg_d, :total)',
      [
        FSelectedEmpID,
        FormatDateTime('yyyy-mm-dd', CalcDate),
        FormatDateTime('yyyy-mm-dd', dtpStart.Date),
        FormatDateTime('yyyy-mm-dd', dtpEnd.Date),
        FDaysCount,
        FAvgMonthly,
        FAvgDaily,
        FTotalAmount
      ]
    );

    // --- ОБНОВЛЯЕМ ГЛАВНУЮ ТАБЛИЦУ ОТПУСКОВ ---
    if dmMain.qryVacation.Active then
    begin
      dmMain.qryVacation.Close;
      dmMain.qryVacation.Open;
    end;

    ShowMessage('Расчет отпускных успешно сохранен!');
    ModalResult := mrOk;

  except
    on E: Exception do
      ShowMessage('Ошибка при сохранении в базу: ' + E.Message);
  end;
end;

end.

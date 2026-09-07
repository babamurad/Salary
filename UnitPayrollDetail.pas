unit UnitPayrollDetail;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  Vcl.Grids, Data.DB, System.DateUtils, FireDAC.Comp.Client,
  UnitPayrollCalc;

type
  TfrmPayrollDetail = class(TForm)
    PanelTop: TPanel;
    lblFio: TLabel;
    lblDeptPos: TLabel;
    lblPeriod: TLabel;
    GroupBox1: TGroupBox;
    lblWorkDays: TLabel;
    lblWorkHours: TLabel;
    lblBaseSalary: TLabel;
    lblHourlyRateCaption: TLabel;
    lblHourlyRate: TLabel;
    lblRotationRate: TLabel;
    lblClassRank: TLabel;
    lblClassRate: TLabel;
    lblPensionRate: TLabel;
    lblUnionRate: TLabel;
    lblTaxRate: TLabel;
    lblDepCount: TLabel;
    lblDepDeduction: TLabel;
    lblAlimonyPct: TLabel;
    edtWorkDays: TEdit;
    edtWorkHours: TEdit;
    edtBaseSalary: TEdit;
    chkIsRotation: TCheckBox;
    edtRotationRate: TEdit;
    cbClassRank: TComboBox;
    edtClassRate: TEdit;
    edtPensionRate: TEdit;
    chkIsTradeUnion: TCheckBox;
    edtUnionRate: TEdit;
    chkIsTaxExempt: TCheckBox;
    edtTaxRate: TEdit;
    edtDepCount: TEdit;
    edtDepDeduction: TEdit;
    edtAlimonyPct: TEdit;
    StringGrid1: TStringGrid;
    PanelBottom: TPanel;
    lblTotalGross: TLabel;
    lblTotalDeductions: TLabel;
    lblNet: TLabel;
    btnRecalc: TButton;
    btnPrint: TButton;
    btnSave: TButton;
    btnCancel: TButton;
    procedure InputChange(Sender: TObject);
    procedure btnRecalcClick(Sender: TObject);
    procedure btnSaveClick(Sender: TObject);
    procedure btnPrintClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
  private
    FPayrollId: Integer;
    FEmpId: Integer;
    FPeriodDate: TDate;
    FLoading: Boolean;
    // Не редактируются на форме напрямую, но нужны формуле расчёта
    FNormHours: Double;
    FWageType: Integer;
    FHourlyRateDB: Double;
    FWorkFraction: Double;

    function ComputeNormHours(APeriodDate: TDate): Double;
    procedure LoadDefaultsFromEmployee;
    function ReadInputsFromForm: TPayrollCalcInputs;
    procedure UpdatePreview(const Inp: TPayrollCalcInputs; const R: TPayrollCalcResult);
    procedure DoRecalc;
  public
    procedure LoadForPayroll(APayrollId: Integer);
  end;

var
  frmPayrollDetail: TfrmPayrollDetail;

implementation

{$R *.dfm}

uses UnitdmMain, UnitPaySlip;

{ TfrmPayrollDetail }

function TfrmPayrollDetail.ComputeNormHours(APeriodDate: TDate): Double;
var
  Q: TFDQuery;
  Y, M, D: Word;
  i, DaysCount, WorkDays: Integer;
  Dt: TDateTime;
begin
  DecodeDate(APeriodDate, Y, M, D);
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := dmMain.conn;
    Q.SQL.Text := 'SELECT working_days FROM production_calendar WHERE year = :y AND month = :m';
    Q.ParamByName('y').AsInteger := Y;
    Q.ParamByName('m').AsInteger := M;
    Q.Open;
    if not Q.IsEmpty and (Q.FieldByName('working_days').AsInteger > 0) then
    begin
      Result := Q.FieldByName('working_days').AsInteger * 8.0;
      Exit;
    end;
  finally
    Q.Free;
  end;

  WorkDays := 0;
  DaysCount := DaysInAMonth(Y, M);
  for i := 1 to DaysCount do
  begin
    Dt := EncodeDate(Y, M, i);
    if not (DayOfTheWeek(Dt) in [6, 7]) then Inc(WorkDays);
  end;
  Result := WorkDays * 8.0;
end;

procedure TfrmPayrollDetail.LoadForPayroll(APayrollId: Integer);
var
  Qry: TFDQuery;
  Loaded: Boolean;
begin
  FPayrollId := APayrollId;
  FLoading := True;
  try
    Qry := TFDQuery.Create(nil);
    try
      Qry.Connection := dmMain.conn;
      Qry.SQL.Text :=
        'SELECT p.emp_id, p.period_date, e.fio, d.dept_name, pos.name as pos_name ' +
        'FROM payroll_journal p ' +
        'JOIN employees e ON p.emp_id = e.id ' +
        'LEFT JOIN departments d ON e.dept_id = d.id ' +
        'LEFT JOIN positions pos ON e.pos_id = pos.id ' +
        'WHERE p.id = :pid';
      Qry.ParamByName('pid').AsInteger := APayrollId;
      Qry.Open;
      if Qry.IsEmpty then
      begin
        ShowMessage('Запись не найдена.');
        Exit;
      end;
      FEmpId := Qry.FieldByName('emp_id').AsInteger;
      FPeriodDate := Qry.FieldByName('period_date').AsDateTime;
      lblFio.Caption := Qry.FieldByName('fio').AsString;
      lblDeptPos.Caption := Qry.FieldByName('dept_name').AsString + ' | ' + Qry.FieldByName('pos_name').AsString;
      lblPeriod.Caption := 'Период: ' + FormatDateTime('mmmm yyyy', FPeriodDate);
      Qry.Close;

      Qry.SQL.Text := 'SELECT * FROM payroll_calc_inputs WHERE payroll_id = :pid';
      Qry.ParamByName('pid').AsInteger := APayrollId;
      Qry.Open;
      Loaded := not Qry.IsEmpty;
      if Loaded then
      begin
        edtWorkDays.Text := FormatFloat('0.##', Qry.FieldByName('work_days').AsFloat);
        edtWorkHours.Text := FormatFloat('0.##', Qry.FieldByName('work_hours').AsFloat);
        edtBaseSalary.Text := FormatFloat('0.##', Qry.FieldByName('base_salary').AsFloat);
        chkIsRotation.Checked := Qry.FieldByName('is_rotation').AsInteger = 1;
        edtRotationRate.Text := FormatFloat('0.##', Qry.FieldByName('rotation_rate').AsFloat);
        cbClassRank.ItemIndex := Qry.FieldByName('class_rank').AsInteger;
        edtClassRate.Text := FormatFloat('0.##', Qry.FieldByName('class_rate').AsFloat);
        edtPensionRate.Text := FormatFloat('0.##', Qry.FieldByName('pension_rate').AsFloat);
        chkIsTradeUnion.Checked := Qry.FieldByName('is_trade_union').AsInteger = 1;
        edtUnionRate.Text := FormatFloat('0.##', Qry.FieldByName('union_rate').AsFloat);
        chkIsTaxExempt.Checked := Qry.FieldByName('is_tax_exempt').AsInteger = 1;
        edtTaxRate.Text := FormatFloat('0.##', Qry.FieldByName('tax_rate').AsFloat);
        edtDepCount.Text := IntToStr(Qry.FieldByName('dep_count').AsInteger);
        edtDepDeduction.Text := FormatFloat('0.##', Qry.FieldByName('dep_deduction').AsFloat);
        edtAlimonyPct.Text := FormatFloat('0.##', Qry.FieldByName('alimony_pct').AsFloat);
        FNormHours := Qry.FieldByName('norm_hours').AsFloat;
        FWageType := Qry.FieldByName('wage_type').AsInteger;
        FHourlyRateDB := Qry.FieldByName('hourly_rate_db').AsFloat;
        FWorkFraction := Qry.FieldByName('work_fraction').AsFloat;
      end;
      Qry.Close;

      if not Loaded then
        LoadDefaultsFromEmployee;
    finally
      Qry.Free;
    end;
  finally
    FLoading := False;
  end;
  DoRecalc;
end;

// Запасной вариант для строк, рассчитанных ДО появления этой формы — там
// ещё нет сохранённых входных данных. Подставляем текущие данные сотрудника
// и настроек (как при обычном расчёте), чтобы форму всё равно можно было
// использовать — поправить и сохранить.
procedure TfrmPayrollDetail.LoadDefaultsFromEmployee;
var
  QEmp, QSet: TFDQuery;
  SysName, PeriodStr: string;
  TaxRate, DepDeduction, UnionRate, RotationRate: Double;
  Class1Rate, Class2Rate, Class3Rate: Double;
  ClassRank: Integer;
  FactHours: Double;
begin
  ShowMessage('Для этой записи ещё нет сохранённых входных данных расчёта ' +
    '(она рассчитана до появления этой формы). Показаны текущие данные ' +
    'сотрудника и настроек — проверьте их и нажмите "Сохранить".');

  QSet := TFDQuery.Create(nil);
  QEmp := TFDQuery.Create(nil);
  try
    QSet.Connection := dmMain.conn;
    QSet.SQL.Text := 'SELECT sys_name, key_value, is_active FROM settings';
    QSet.Open;

    TaxRate := 10.0; DepDeduction := 50.0; UnionRate := 1.0; RotationRate := 75.0;
    Class1Rate := 25.0; Class2Rate := 10.0; Class3Rate := 5.0;

    while not QSet.Eof do
    begin
      SysName := UpperCase(QSet.FieldByName('sys_name').AsString);
      if QSet.FieldByName('is_active').AsInteger = 1 then
      begin
        if SysName = 'TAX_INCOME' then TaxRate := QSet.FieldByName('key_value').AsFloat
        else if SysName = 'DEP_DEDUCTION' then DepDeduction := QSet.FieldByName('key_value').AsFloat
        else if SysName = 'TRADE_UNION' then UnionRate := QSet.FieldByName('key_value').AsFloat
        else if SysName = 'BONUS_ROTATION' then RotationRate := QSet.FieldByName('key_value').AsFloat
        else if SysName = 'BONUS_CLASS_1' then Class1Rate := QSet.FieldByName('key_value').AsFloat
        else if SysName = 'BONUS_CLASS_2' then Class2Rate := QSet.FieldByName('key_value').AsFloat
        else if SysName = 'BONUS_CLASS_3' then Class3Rate := QSet.FieldByName('key_value').AsFloat;
      end;
      QSet.Next;
    end;

    QEmp.Connection := dmMain.conn;
    PeriodStr := FormatDateTime('yyyy-mm', FPeriodDate);
    QEmp.SQL.Text :=
      'SELECT e.*, (SELECT IFNULL(SUM(t.hours_worked), 0) FROM timesheet t ' +
      ' WHERE t.emp_id = e.id AND strftime(''%Y-%m'', t.work_date) = :p) as fact_hours ' +
      'FROM employees e WHERE e.id = :emp';
    QEmp.ParamByName('p').AsString := PeriodStr;
    QEmp.ParamByName('emp').AsInteger := FEmpId;
    QEmp.Open;
    if QEmp.IsEmpty then Exit;

    FNormHours := ComputeNormHours(FPeriodDate);
    FWageType := QEmp.FieldByName('wage_type').AsInteger;
    FHourlyRateDB := QEmp.FieldByName('hourly_rate').AsFloat;
    FWorkFraction := QEmp.FieldByName('work_fraction').AsFloat;

    FactHours := QEmp.FieldByName('fact_hours').AsFloat;
    edtWorkHours.Text := FormatFloat('0.##', FactHours);
    edtWorkDays.Text := FormatFloat('0.##', FactHours / 8.0);
    edtBaseSalary.Text := FormatFloat('0.##', QEmp.FieldByName('base_salary').AsFloat);
    chkIsRotation.Checked := QEmp.FieldByName('is_rotation').AsInteger = 1;
    edtRotationRate.Text := FormatFloat('0.##', RotationRate);

    ClassRank := QEmp.FieldByName('class_rank').AsInteger;
    if ClassRank in [1, 2, 3] then cbClassRank.ItemIndex := ClassRank else cbClassRank.ItemIndex := 0;
    case ClassRank of
      1: edtClassRate.Text := FormatFloat('0.##', Class1Rate);
      2: edtClassRate.Text := FormatFloat('0.##', Class2Rate);
      3: edtClassRate.Text := FormatFloat('0.##', Class3Rate);
    else
      edtClassRate.Text := '0';
    end;

    edtPensionRate.Text := FormatFloat('0.##', QEmp.FieldByName('pension_rate').AsFloat);
    chkIsTradeUnion.Checked := QEmp.FieldByName('trade_union').AsInteger = 1;
    edtUnionRate.Text := FormatFloat('0.##', UnionRate);
    chkIsTaxExempt.Checked := QEmp.FieldByName('is_tax_exempt').AsInteger = 1;
    edtTaxRate.Text := FormatFloat('0.##', TaxRate);
    edtDepCount.Text := IntToStr(QEmp.FieldByName('dependents_count').AsInteger);
    edtDepDeduction.Text := FormatFloat('0.##', DepDeduction);
    edtAlimonyPct.Text := FormatFloat('0.##', QEmp.FieldByName('alimony_percent').AsFloat);
  finally
    QEmp.Free;
    QSet.Free;
  end;
end;

function TfrmPayrollDetail.ReadInputsFromForm: TPayrollCalcInputs;
begin
  Result.WorkDays := StrToFloatDef(edtWorkDays.Text, 0);
  Result.WorkHours := StrToFloatDef(edtWorkHours.Text, 0);
  Result.NormHours := FNormHours;
  Result.WageType := FWageType;
  Result.WorkFraction := FWorkFraction;
  Result.HourlyRateDB := FHourlyRateDB;
  Result.BaseSalary := StrToFloatDef(edtBaseSalary.Text, 0);
  Result.IsRotation := Ord(chkIsRotation.Checked);
  Result.RotationRate := StrToFloatDef(edtRotationRate.Text, 0);
  Result.ClassRank := cbClassRank.ItemIndex;
  Result.ClassRate := StrToFloatDef(edtClassRate.Text, 0);
  Result.PensionRate := StrToFloatDef(edtPensionRate.Text, 0);
  Result.IsTradeUnion := Ord(chkIsTradeUnion.Checked);
  Result.UnionRate := StrToFloatDef(edtUnionRate.Text, 0);
  Result.IsTaxExempt := Ord(chkIsTaxExempt.Checked);
  Result.TaxRate := StrToFloatDef(edtTaxRate.Text, 0);
  Result.DepCount := StrToIntDef(edtDepCount.Text, 0);
  Result.DepDeduction := StrToFloatDef(edtDepDeduction.Text, 0);
  Result.AlimonyPct := StrToFloatDef(edtAlimonyPct.Text, 0);
end;

procedure TfrmPayrollDetail.UpdatePreview(const Inp: TPayrollCalcInputs; const R: TPayrollCalcResult);
var
  Row: Integer;
  TotalDeductions: Double;

  procedure SetRow(const AName: string; AAmount: Double);
  begin
    if Row >= StringGrid1.RowCount then
      StringGrid1.RowCount := Row + 1;
    StringGrid1.Cells[0, Row] := AName;
    StringGrid1.Cells[1, Row] := FormatFloat('#,##0.00', AAmount);
    Inc(Row);
  end;

begin
  Row := 0;
  SetRow('Оплата за отработанное время', R.BaseGross);
  if R.RotationBonus > 0 then SetRow('Надбавка за вахтовый метод', R.RotationBonus);
  if R.ClassBonus > 0 then SetRow('Надбавка за классность', R.ClassBonus);
  SetRow('— Итого начислено —', R.TotalGross);
  SetRow('Подоходный налог', -R.Tax);
  SetRow('Пенсионный взнос', -R.Pension);
  if R.UnionAmount > 0 then SetRow('Профсоюзный взнос', -R.UnionAmount);
  if R.AlimonyAmount > 0 then SetRow('Алименты', -R.AlimonyAmount);

  while Row < StringGrid1.RowCount do
  begin
    StringGrid1.Cells[0, Row] := '';
    StringGrid1.Cells[1, Row] := '';
    Inc(Row);
  end;

  lblHourlyRate.Caption := FormatFloat('0.00', R.HourlyRate);

  TotalDeductions := R.Tax + R.Pension + R.UnionAmount + R.AlimonyAmount;
  lblTotalGross.Caption := 'Итого начислено: ' + FormatFloat('#,##0.00', R.TotalGross);
  lblTotalDeductions.Caption := 'Итого удержано: ' + FormatFloat('#,##0.00', TotalDeductions);
  lblNet.Caption := 'К ВЫДАЧЕ: ' + FormatFloat('#,##0.00', R.Net);
end;

procedure TfrmPayrollDetail.DoRecalc;
var
  Inp: TPayrollCalcInputs;
  R: TPayrollCalcResult;
begin
  if FLoading then Exit;
  Inp := ReadInputsFromForm;
  R := CalcPayroll(Inp);
  UpdatePreview(Inp, R);
end;

procedure TfrmPayrollDetail.InputChange(Sender: TObject);
begin
  DoRecalc;
end;

procedure TfrmPayrollDetail.btnRecalcClick(Sender: TObject);
begin
  DoRecalc;
end;

procedure TfrmPayrollDetail.btnSaveClick(Sender: TObject);
var
  Inp: TPayrollCalcInputs;
  R: TPayrollCalcResult;
  PeriodStr: string;
  Qry, QryDetail: TFDQuery;

  procedure AddDetail(const AItemType, AItemName, ADetails: string;
    ABase, ARate, AAmount: Double; ASortOrder: Integer);
  begin
    QryDetail.ParamByName('pid').AsInteger := FPayrollId;
    QryDetail.ParamByName('itype').AsString := AItemType;
    QryDetail.ParamByName('iname').AsString := AItemName;
    QryDetail.ParamByName('idet').AsString := ADetails;
    QryDetail.ParamByName('ibase').AsFloat := ABase;
    QryDetail.ParamByName('irate').AsFloat := ARate;
    QryDetail.ParamByName('iamt').AsFloat := AAmount;
    QryDetail.ParamByName('isort').AsInteger := ASortOrder;
    QryDetail.ExecSQL;
  end;

begin
  PeriodStr := FormatDateTime('yyyy-mm', FPeriodDate);

  Qry := TFDQuery.Create(nil);
  try
    Qry.Connection := dmMain.conn;
    Qry.SQL.Text := 'SELECT 1 FROM closed_periods WHERE period_str = :p';
    Qry.ParamByName('p').AsString := PeriodStr;
    Qry.Open;
    if not Qry.IsEmpty then
    begin
      ShowMessage('Этот месяц уже закрыт для редактирования!');
      Exit;
    end;
  finally
    Qry.Free;
  end;

  Inp := ReadInputsFromForm;
  R := CalcPayroll(Inp);

  Qry := TFDQuery.Create(nil);
  QryDetail := TFDQuery.Create(nil);
  try
    Qry.Connection := dmMain.conn;
    QryDetail.Connection := dmMain.conn;
    QryDetail.SQL.Text :=
      'INSERT INTO payroll_details (payroll_id, item_type, item_name, details, base_amount, rate_percent, amount, sort_order) ' +
      'VALUES (:pid, :itype, :iname, :idet, :ibase, :irate, :iamt, :isort)';

    dmMain.conn.StartTransaction;
    try
      Qry.SQL.Text := 'UPDATE payroll_journal SET gross_amount = :gross, tax_amount = :tax, ' +
        'pension_amount = :pens, union_amount = :union_amt, alimony_amount = :alim_amt, net_amount = :net ' +
        'WHERE id = :pid';
      Qry.ParamByName('gross').AsFloat := R.TotalGross;
      Qry.ParamByName('tax').AsFloat := R.Tax;
      Qry.ParamByName('pens').AsFloat := R.Pension;
      Qry.ParamByName('union_amt').AsFloat := R.UnionAmount;
      Qry.ParamByName('alim_amt').AsFloat := R.AlimonyAmount;
      Qry.ParamByName('net').AsFloat := R.Net;
      Qry.ParamByName('pid').AsInteger := FPayrollId;
      Qry.ExecSQL;

      Qry.SQL.Text := 'DELETE FROM payroll_details WHERE payroll_id = :pid';
      Qry.ParamByName('pid').AsInteger := FPayrollId;
      Qry.ExecSQL;

      Qry.SQL.Text := 'DELETE FROM payroll_calc_inputs WHERE payroll_id = :pid';
      Qry.ParamByName('pid').AsInteger := FPayrollId;
      Qry.ExecSQL;

      Qry.SQL.Text :=
        'INSERT INTO payroll_calc_inputs (payroll_id, work_days, work_hours, norm_days, norm_hours, ' +
        'wage_type, work_fraction, hourly_rate_db, base_salary, is_rotation, rotation_rate, ' +
        'class_rank, class_rate, pension_rate, is_trade_union, union_rate, is_tax_exempt, tax_rate, ' +
        'dep_count, dep_deduction, alimony_pct) VALUES (:pid, :wdays, :whours, :ndays, :nhours, ' +
        ':wtype, :wfrac, :hrdb, :bsal, :isrot, :rotrate, :crank, :crate, :penrate, :istu, :unrate, ' +
        ':istaxex, :taxrate, :depcnt, :depded, :alimpct)';
      Qry.ParamByName('pid').AsInteger := FPayrollId;
      Qry.ParamByName('wdays').AsFloat := Inp.WorkDays;
      Qry.ParamByName('whours').AsFloat := Inp.WorkHours;
      Qry.ParamByName('ndays').AsInteger := Round(FNormHours / 8.0);
      Qry.ParamByName('nhours').AsFloat := Inp.NormHours;
      Qry.ParamByName('wtype').AsInteger := Inp.WageType;
      Qry.ParamByName('wfrac').AsFloat := Inp.WorkFraction;
      Qry.ParamByName('hrdb').AsFloat := Inp.HourlyRateDB;
      Qry.ParamByName('bsal').AsFloat := Inp.BaseSalary;
      Qry.ParamByName('isrot').AsInteger := Inp.IsRotation;
      Qry.ParamByName('rotrate').AsFloat := Inp.RotationRate;
      Qry.ParamByName('crank').AsInteger := Inp.ClassRank;
      Qry.ParamByName('crate').AsFloat := Inp.ClassRate;
      Qry.ParamByName('penrate').AsFloat := Inp.PensionRate;
      Qry.ParamByName('istu').AsInteger := Inp.IsTradeUnion;
      Qry.ParamByName('unrate').AsFloat := Inp.UnionRate;
      Qry.ParamByName('istaxex').AsInteger := Inp.IsTaxExempt;
      Qry.ParamByName('taxrate').AsFloat := Inp.TaxRate;
      Qry.ParamByName('depcnt').AsInteger := Inp.DepCount;
      Qry.ParamByName('depded').AsFloat := Inp.DepDeduction;
      Qry.ParamByName('alimpct').AsFloat := Inp.AlimonyPct;
      Qry.ExecSQL;

      AddDetail('accrual', 'Оплата за отработанное время',
        Format('Обычные часы: %.2f, сверхурочные: %.2f, ставка часа: %.2f',
               [R.RegularHours, R.OvertimeHours, R.HourlyRate]),
        0, 0, R.BaseGross, 1);

      if R.RotationBonus > 0 then
        AddDetail('accrual', 'Надбавка за вахтовый метод',
          'От оплаты за отработанное время', R.BaseGross, Inp.RotationRate, R.RotationBonus, 2);

      if R.ClassBonus > 0 then
        AddDetail('accrual', 'Надбавка за классность',
          Format('Класс %d, от оплаты за отработанное время', [Inp.ClassRank]),
          R.BaseGross, Inp.ClassRate, R.ClassBonus, 3);

      if Inp.IsTaxExempt = 1 then
        AddDetail('deduction', 'Подоходный налог', 'Сотрудник освобождён от налога', 0, 0, 0, 10)
      else
        AddDetail('deduction', 'Подоходный налог',
          Format('Вычет на %d иждивенца(ев) по %.2f из базы начисления', [Inp.DepCount, Inp.DepDeduction]),
          R.TaxBase, Inp.TaxRate, R.Tax, 10);

      AddDetail('deduction', 'Пенсионный взнос', 'От суммы начисленного (с надбавками)',
        R.TotalGross, Inp.PensionRate, R.Pension, 11);

      if Inp.IsTradeUnion = 1 then
        AddDetail('deduction', 'Профсоюзный взнос', 'От суммы начисленного (с надбавками)',
          R.TotalGross, Inp.UnionRate, R.UnionAmount, 12);

      if Inp.AlimonyPct > 0 then
        AddDetail('deduction', 'Алименты', 'Удержаны после налога, пенсионного и профсоюза',
          R.NetBeforeAlimony, Inp.AlimonyPct, R.AlimonyAmount, 13);

      dmMain.conn.Commit;
      ShowMessage('Сохранено. Месяц не закрыт — можно править дальше.');
      ModalResult := mrOk;
    except
      on E: Exception do
      begin
        dmMain.conn.Rollback;
        ShowMessage('Ошибка при сохранении: ' + E.Message);
      end;
    end;
  finally
    Qry.Free;
    QryDetail.Free;
  end;
end;

procedure TfrmPayrollDetail.btnPrintClick(Sender: TObject);
var
  Qry: TFDQuery;
  SlipForm: TfrmPaySlip;
  Period: string;
begin
  Qry := TFDQuery.Create(nil);
  try
    Qry.Connection := dmMain.conn;
    Qry.SQL.Text :=
      'SELECT p.*, e.fio, e.base_salary, d.dept_name, pos.name as pos_name ' +
      'FROM payroll_journal p ' +
      'JOIN employees e ON p.emp_id = e.id ' +
      'LEFT JOIN departments d ON e.dept_id = d.id ' +
      'LEFT JOIN positions pos ON e.pos_id = pos.id ' +
      'WHERE p.id = :pid';
    Qry.ParamByName('pid').AsInteger := FPayrollId;
    Qry.Open;
    if Qry.IsEmpty then Exit;

    Period := FormatDateTime('mmmm yyyy', Qry.FieldByName('period_date').AsDateTime);

    SlipForm := TfrmPaySlip.Create(Self);
    try
      SlipForm.ShowSinglePayslip(Qry, Period);
      SlipForm.ShowModal;
    finally
      SlipForm.Free;
    end;
  finally
    Qry.Free;
  end;
end;

procedure TfrmPayrollDetail.btnCancelClick(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

end.

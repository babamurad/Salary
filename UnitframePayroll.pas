unit UnitframePayroll;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Data.DB, Vcl.Grids,
  Vcl.DBGrids, Vcl.ExtCtrls, Vcl.DBCtrls, Vcl.StdCtrls, System.Math, System.DateUtils,
  ComObj,
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
    btnExport: TButton;
    cmbDept: TComboBox;
    btnPrintAllSlips: TButton;
    procedure btnCalcClick(Sender: TObject);
    procedure btnCloseMonthClick(Sender: TObject);
    procedure FilterChange(Sender: TObject);
    procedure DBGrid1DblClick(Sender: TObject);
    procedure btnExportClick(Sender: TObject);
    procedure btnPrintAllSlipsClick(Sender: TObject);
  private
    qryPayroll: TFDQuery;
    dsPayroll: TDataSource;
    procedure qryPayrollAfterOpen(DataSet: TDataSet);
    procedure RefreshData;
    function IsPeriodClosed(APeriod: string): Boolean;
    procedure LoadDepartments;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function GetWorkingDaysNorm(AYear, AMonth: Integer): Integer;
  end;

implementation

{$R *.dfm}

uses UnitdmMain, UnitPaySlip;

{ TframePayroll }

constructor TframePayroll.Create(AOwner: TComponent);
var
  i, CurrentYear: Integer;
begin
  inherited;

  cmbMonth.Items.CommaText := 'Январь,Февраль,Март,Апрель,Май,Июнь,Июль,Август,Сентябрь,Октябрь,Ноябрь,Декабрь';
  CurrentYear := YearOf(Date);
  for i := CurrentYear - 2 to CurrentYear + 2 do
    cmbYear.Items.Add(IntToStr(i));

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

    LoadDepartments;
    RefreshData;
  end;

  cmbMonth.OnChange := FilterChange;
  cmbYear.OnChange := FilterChange;
  cmbDept.OnChange := FilterChange;
end;

procedure TframePayroll.RefreshData;
var
  SelectedPeriod: string;
  DeptID: Integer;
begin
  SelectedPeriod := cmbYear.Text + '-' + Format('%.2d', [cmbMonth.ItemIndex + 1]);
  DeptID := 0;
  if (cmbDept.ItemIndex <> -1) and (cmbDept.Items.Count > 0) then
    DeptID := Integer(cmbDept.Items.Objects[cmbDept.ItemIndex]);

  qryPayroll.Close;
  qryPayroll.SQL.Text :=
    'SELECT p.*, e.fio, e.base_salary, ' +
    '       d.dept_name, pos.name as pos_name ' +
    'FROM payroll_journal p ' +
    'JOIN employees e ON p.emp_id = e.id ' +
    'LEFT JOIN departments d ON e.dept_id = d.id ' +
    'LEFT JOIN positions pos ON e.pos_id = pos.id ' +
    'WHERE strftime(''%Y-%m'', p.period_date) = :period ';

  if DeptID > 0 then
    qryPayroll.SQL.Text := qryPayroll.SQL.Text + ' AND e.dept_id = ' + IntToStr(DeptID);

  qryPayroll.SQL.Text := qryPayroll.SQL.Text + ' ORDER BY e.fio';
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

procedure TframePayroll.LoadDepartments;
begin
  if not Assigned(dmMain) then Exit;
  cmbDept.Items.Clear;
  cmbDept.Items.AddObject('--- Все отделы ---', TObject(0));
  if not dmMain.qryDepts.Active then dmMain.qryDepts.Open;
  dmMain.qryDepts.First;
  while not dmMain.qryDepts.Eof do
  begin
    cmbDept.Items.AddObject(dmMain.qryDepts.FieldByName('dept_name').AsString,
                            TObject(dmMain.qryDepts.FieldByName('id').AsInteger));
    dmMain.qryDepts.Next;
  end;
  cmbDept.ItemIndex := 0;
end;

procedure TframePayroll.btnCalcClick(Sender: TObject);
var
  QryEmp, QrySet, QryExec: TFDQuery;
  // Настройки
  TaxRate, DepDeduction, UnionRate, RotationRate: Double;
  Class1Rate, Class2Rate, Class3Rate: Double;

  // Данные сотрудника
  EmpId, DepCount, NormDays: Integer;
  WageType, IsRotation, IsTaxExempt, ClassRank, IsTradeUnion: Integer;
  FactHours, NormHours, HourlyRateDB, WorkFrac, AlimonyPct, EmpPensionRate: Double;

  // Расчетные переменные
  HourlyRate, RegularHours, OvertimeHours, BaseSal: Double;
  BaseGross, RotationBonus, ClassBonus, TotalGross: Double;
  TaxBase, Tax, Pension, UnionAmount, AlimonyAmount, NetBeforeAlimony, Net: Double;

  SelectedPeriod, CalcDateStr, SysName: string;
  DeptID: Integer;
begin
  SelectedPeriod := cmbYear.Text + '-' + Format('%.2d', [cmbMonth.ItemIndex + 1]);

  if IsPeriodClosed(SelectedPeriod) then
  begin
    ShowMessage('Этот месяц уже закрыт для редактирования!');
    Exit;
  end;

  if MessageDlg('Рассчитать зарплату за ' + cmbMonth.Text + ' ' + cmbYear.Text + '?',
     mtConfirmation, [mbYes, mbNo], 0) <> mrYes then Exit;

  NormDays := GetWorkingDaysNorm(StrToIntDef(cmbYear.Text, YearOf(Now)), cmbMonth.ItemIndex + 1);
  if NormDays = 0 then NormDays := 1;
  NormHours := NormDays * 8.0;

  CalcDateStr := SelectedPeriod + '-01';

  DeptID := 0;
  if (cmbDept.ItemIndex <> -1) and (cmbDept.Items.Count > 0) then
    DeptID := Integer(cmbDept.Items.Objects[cmbDept.ItemIndex]);

  QryEmp := TFDQuery.Create(nil);
  QrySet := TFDQuery.Create(nil);
  QryExec := TFDQuery.Create(nil);
  try
    QryEmp.Connection := dmMain.conn;
    QrySet.Connection := dmMain.conn;
    QryExec.Connection := dmMain.conn;

    // --- ЧИТАЕМ ГЛОБАЛЬНЫЕ НАСТРОЙКИ ---
    QrySet.SQL.Text := 'SELECT sys_name, key_value, is_active FROM settings';
    QrySet.Open;

    // Значения по умолчанию (на случай если их нет в базе)
    TaxRate := 10.0; DepDeduction := 50.0; UnionRate := 1.0; RotationRate := 75.0;
    Class1Rate := 25.0; Class2Rate := 10.0; Class3Rate := 5.0;

    while not QrySet.Eof do
    begin
      SysName := UpperCase(QrySet.FieldByName('sys_name').AsString);
      if QrySet.FieldByName('is_active').AsInteger = 1 then
      begin
        if SysName = 'TAX_INCOME' then TaxRate := QrySet.FieldByName('key_value').AsFloat
        else if SysName = 'DEP_DEDUCTION' then DepDeduction := QrySet.FieldByName('key_value').AsFloat
        else if SysName = 'TRADE_UNION' then UnionRate := QrySet.FieldByName('key_value').AsFloat
        else if SysName = 'BONUS_ROTATION' then RotationRate := QrySet.FieldByName('key_value').AsFloat
        else if SysName = 'BONUS_CLASS_1' then Class1Rate := QrySet.FieldByName('key_value').AsFloat
        else if SysName = 'BONUS_CLASS_2' then Class2Rate := QrySet.FieldByName('key_value').AsFloat
        else if SysName = 'BONUS_CLASS_3' then Class3Rate := QrySet.FieldByName('key_value').AsFloat;
      end;
      QrySet.Next;
    end;

    // --- ДОСТАЕМ СОТРУДНИКОВ ---
    QryEmp.SQL.Text :=
      'SELECT e.*, ' +
      ' (SELECT IFNULL(SUM(t.hours_worked), 0) FROM timesheet t WHERE t.emp_id = e.id AND strftime(''%Y-%m'', t.work_date) = :p) as fact_hours ' +
      'FROM employees e WHERE e.status = 1';

    if DeptID > 0 then
      QryEmp.SQL.Text := QryEmp.SQL.Text + ' AND e.dept_id = ' + IntToStr(DeptID);

    QryEmp.ParamByName('p').AsString := SelectedPeriod;
    QryEmp.Open;

    dmMain.conn.StartTransaction;
    try
      // Очищаем старые начисления
      if DeptID > 0 then
        QryExec.SQL.Text := 'DELETE FROM payroll_journal WHERE strftime(''%Y-%m'', period_date) = :P AND emp_id IN (SELECT id FROM employees WHERE dept_id = ' + IntToStr(DeptID) + ')'
      else
        QryExec.SQL.Text := 'DELETE FROM payroll_journal WHERE strftime(''%Y-%m'', period_date) = :P';
      QryExec.ParamByName('P').AsString := SelectedPeriod;
      QryExec.ExecSQL;

      QryExec.SQL.Text := 'INSERT INTO payroll_journal (emp_id, period_date, gross_amount, tax_amount, pension_amount, union_amount, alimony_amount, net_amount) ' +
                          'VALUES (:emp, :dt, :gross, :tax, :pens, :union_amt, :alim_amt, :net)';

      while not QryEmp.Eof do
      begin
        // Читаем все параметры сотрудника
        BaseSal := QryEmp.FieldByName('base_salary').AsFloat;
        HourlyRateDB := QryEmp.FieldByName('hourly_rate').AsFloat;
        WorkFrac := QryEmp.FieldByName('work_fraction').AsFloat;
        if WorkFrac <= 0 then WorkFrac := 1.0; // Защита

        DepCount := QryEmp.FieldByName('dependents_count').AsInteger;
        FactHours := QryEmp.FieldByName('fact_hours').AsFloat;
        WageType := QryEmp.FieldByName('wage_type').AsInteger;
        IsRotation := QryEmp.FieldByName('is_rotation').AsInteger;
        IsTaxExempt := QryEmp.FieldByName('is_tax_exempt').AsInteger;
        ClassRank := QryEmp.FieldByName('class_rank').AsInteger;
        IsTradeUnion := QryEmp.FieldByName('trade_union').AsInteger;
        AlimonyPct := QryEmp.FieldByName('alimony_percent').AsFloat;
        EmpPensionRate := QryEmp.FieldByName('pension_rate').AsFloat;

        // --- 1. СТОИМОСТЬ ЧАСА ---
        if WageType = 1 then
          HourlyRate := HourlyRateDB
        else
          HourlyRate := (BaseSal * WorkFrac) / NormHours; // Оклад делится пропорционально ставке!

        // --- 2. ЧАСЫ ---
        if FactHours > NormHours then
        begin
          RegularHours := NormHours;
          OvertimeHours := FactHours - NormHours;
        end
        else
        begin
          RegularHours := FactHours;
          OvertimeHours := 0;
        end;

        // --- 3. БАЗА ---
        BaseGross := SimpleRoundTo((RegularHours * HourlyRate) + (OvertimeHours * HourlyRate * 2.0), -2);

        // --- 4. НАДБАВКИ ---
        RotationBonus := 0;
        if IsRotation = 1 then RotationBonus := SimpleRoundTo(BaseGross * (RotationRate / 100.0), -2);

        ClassBonus := 0;
        if ClassRank = 1 then ClassBonus := SimpleRoundTo(BaseGross * (Class1Rate / 100.0), -2)
        else if ClassRank = 2 then ClassBonus := SimpleRoundTo(BaseGross * (Class2Rate / 100.0), -2)
        else if ClassRank = 3 then ClassBonus := SimpleRoundTo(BaseGross * (Class3Rate / 100.0), -2);

        TotalGross := BaseGross + RotationBonus + ClassBonus;

        // --- 5. УДЕРЖАНИЯ (До вычета алиментов) ---
        Pension := SimpleRoundTo((TotalGross * EmpPensionRate) / 100.0, -2);

        UnionAmount := 0;
        if IsTradeUnion = 1 then
          UnionAmount := SimpleRoundTo(TotalGross * (UnionRate / 100.0), -2);

        if IsTaxExempt = 1 then
          Tax := 0
        else
        begin
          TaxBase := BaseGross - (DepCount * DepDeduction);
          Tax := SimpleRoundTo(Max(0, TaxBase * TaxRate / 100.0), -2);
        end;

        // --- 6. АЛИМЕНТЫ (Строго после налогов!) ---
        NetBeforeAlimony := TotalGross - Tax - Pension - UnionAmount;
        AlimonyAmount := 0;
        if AlimonyPct > 0 then
          AlimonyAmount := SimpleRoundTo(NetBeforeAlimony * (AlimonyPct / 100.0), -2);

        // --- 7. К ВЫПЛАТЕ ---
        Net := SimpleRoundTo(NetBeforeAlimony - AlimonyAmount, -2);

        // --- СОХРАНЕНИЕ ---
        QryExec.ParamByName('emp').AsInteger := QryEmp.FieldByName('id').AsInteger;
        QryExec.ParamByName('dt').AsString := CalcDateStr;
        QryExec.ParamByName('gross').AsFloat := TotalGross;
        QryExec.ParamByName('tax').AsFloat := Tax;
        QryExec.ParamByName('pens').AsFloat := Pension;
        QryExec.ParamByName('union_amt').AsFloat := UnionAmount;
        QryExec.ParamByName('alim_amt').AsFloat := AlimonyAmount;
        QryExec.ParamByName('net').AsFloat := Net;
        QryExec.ExecSQL;

        QryEmp.Next;
      end;

      dmMain.conn.Commit;
      RefreshData;
      ShowMessage('Расчет успешно завершен! Учтены ставки, профсоюз, льготы и алименты.');

    except
      on E: Exception do
      begin
        dmMain.conn.Rollback;
        ShowMessage('Ошибка при расчете: ' + E.Message);
      end;
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
  if MessageDlg('Вы уверены, что хотите ЗАКРЫТЬ ' + cmbMonth.Text + ' для редактирования?',
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

procedure TframePayroll.btnExportClick(Sender: TObject);
var
  ExcelApp, Sheet: Variant;
  Row: Integer;
  TotalGross, TotalTax, TotalPension, TotalUnion, TotalAlimony, TotalNet: Double;
  Bookmark: TBookmark;
begin
  if not Assigned(qryPayroll) or not qryPayroll.Active or qryPayroll.IsEmpty then
  begin
    ShowMessage('Нет данных для выгрузки!');
    Exit;
  end;

  try
    ExcelApp := CreateOleObject('Excel.Application');
  except
    ShowMessage('Не удалось запустить Excel.');
    Exit;
  end;

  qryPayroll.DisableControls;
  Bookmark := qryPayroll.GetBookmark;
  try
    ExcelApp.Workbooks.Add;
    Sheet := ExcelApp.ActiveSheet;
    Sheet.Name := 'Зарплата ' + cmbMonth.Text;

    Sheet.Cells[1, 1].Value := 'Сотрудник';
    Sheet.Cells[1, 2].Value := 'Отдел';
    Sheet.Cells[1, 3].Value := 'Оклад/Тариф';
    Sheet.Cells[1, 4].Value := 'Начислено (Грязными)';
    Sheet.Cells[1, 5].Value := 'Подоходный';
    Sheet.Cells[1, 6].Value := 'Пенсионный';
    Sheet.Cells[1, 7].Value := 'Профсоюз';
    Sheet.Cells[1, 8].Value := 'Алименты';
    Sheet.Cells[1, 9].Value := 'На руки (Чистыми)';

    Sheet.Range['A1:I1'].Font.Bold := True;

    Row := 2;
    TotalGross := 0; TotalTax := 0; TotalPension := 0;
    TotalUnion := 0; TotalAlimony := 0; TotalNet := 0;

    qryPayroll.First;
    while not qryPayroll.Eof do
    begin
      Sheet.Cells[Row, 1].Value := qryPayroll.FieldByName('fio').AsString;
      Sheet.Cells[Row, 2].Value := qryPayroll.FieldByName('dept_name').AsString;
      Sheet.Cells[Row, 3].Value := qryPayroll.FieldByName('base_salary').AsFloat;

      Sheet.Cells[Row, 4].Value := qryPayroll.FieldByName('gross_amount').AsFloat;
      Sheet.Cells[Row, 5].Value := qryPayroll.FieldByName('tax_amount').AsFloat;
      Sheet.Cells[Row, 6].Value := qryPayroll.FieldByName('pension_amount').AsFloat;
      Sheet.Cells[Row, 7].Value := qryPayroll.FieldByName('union_amount').AsFloat;
      Sheet.Cells[Row, 8].Value := qryPayroll.FieldByName('alimony_amount').AsFloat;
      Sheet.Cells[Row, 9].Value := qryPayroll.FieldByName('net_amount').AsFloat;

      TotalGross := TotalGross + qryPayroll.FieldByName('gross_amount').AsFloat;
      TotalTax := TotalTax + qryPayroll.FieldByName('tax_amount').AsFloat;
      TotalPension := TotalPension + qryPayroll.FieldByName('pension_amount').AsFloat;
      TotalUnion := TotalUnion + qryPayroll.FieldByName('union_amount').AsFloat;
      TotalAlimony := TotalAlimony + qryPayroll.FieldByName('alimony_amount').AsFloat;
      TotalNet := TotalNet + qryPayroll.FieldByName('net_amount').AsFloat;

      Inc(Row);
      qryPayroll.Next;
    end;

    Sheet.Cells[Row, 1].Value := 'ИТОГО ПО ВЕДОМОСТИ:';
    Sheet.Cells[Row, 4].Value := TotalGross;
    Sheet.Cells[Row, 5].Value := TotalTax;
    Sheet.Cells[Row, 6].Value := TotalPension;
    Sheet.Cells[Row, 7].Value := TotalUnion;
    Sheet.Cells[Row, 8].Value := TotalAlimony;
    Sheet.Cells[Row, 9].Value := TotalNet;

    Sheet.Range['A' + IntToStr(Row) + ':I' + IntToStr(Row)].Font.Bold := True;
    Sheet.Range['E' + IntToStr(Row) + ':H' + IntToStr(Row)].Font.Color := $0000FF;

    Sheet.Columns.AutoFit;

  finally
    if qryPayroll.BookmarkValid(Bookmark) then
    begin
      qryPayroll.GotoBookmark(Bookmark);
      qryPayroll.FreeBookmark(Bookmark);
    end;
    qryPayroll.EnableControls;
  end;

  ExcelApp.Visible := True;
end;

procedure TframePayroll.btnPrintAllSlipsClick(Sender: TObject);
var
  SlipForm: TfrmPaySlip;
  Period: string;
begin
  if qryPayroll.IsEmpty then Exit;
  Period := cmbMonth.Text + ' ' + cmbYear.Text;
  SlipForm := TfrmPaySlip.Create(Self);
  try
    SlipForm.ShowAllPayslips(qryPayroll, Period); // ВЫЗЫВАЕМ ALL
    SlipForm.ShowModal;
  finally
    SlipForm.Free;
  end;
end;

procedure TframePayroll.qryPayrollAfterOpen(DataSet: TDataSet);
var
i: Integer;
begin
  if DBGrid1.Columns.Count > 0 then
  begin
    DBGrid1.Columns[0].Visible := False; // id
    DBGrid1.Columns[1].Visible := False; // emp_id
    DBGrid1.Columns[2].Title.Caption := 'Дата';

    DBGrid1.Columns[3].Title.Caption := 'Начислено';
    DBGrid1.Columns[3].Width := 120;

    DBGrid1.Columns[4].Title.Caption := 'Подоходный';
    DBGrid1.Columns[4].Width := 100;

    DBGrid1.Columns[5].Title.Caption := 'Пенсионный';
    DBGrid1.Columns[5].Width := 100;

    // Новые колонки в гриде
    if DBGrid1.Columns.Count > 6 then
    begin
      DBGrid1.Columns[6].Title.Caption := 'Профсоюз';
      DBGrid1.Columns[6].Width := 90;

      DBGrid1.Columns[7].Title.Caption := 'Алименты';
      DBGrid1.Columns[7].Width := 90;

      DBGrid1.Columns[8].Title.Caption := 'На руки';
      DBGrid1.Columns[8].Width := 120;

      DBGrid1.Columns[9].Title.Caption := 'Сотрудник';
      DBGrid1.Columns[9].Width := 200;
      DBGrid1.Columns[9].Index := 0; // Двигаем ФИО влево
    end;
  end;

  for i := 0 to DBGrid1.Columns.Count - 1 do
  begin
    // Настраиваем ширину Отдела
    if DBGrid1.Columns[i].FieldName = 'dept_name' then
      DBGrid1.Columns[i].Width := 170

    // Настраиваем ширину Должности
    else if DBGrid1.Columns[i].FieldName = 'pos_name' then
      DBGrid1.Columns[i].Width := 170

    // Заодно аккуратно сожмем Оклад, если он слишком широкий
    else if DBGrid1.Columns[i].FieldName = 'base_salary' then
      DBGrid1.Columns[i].Width := 110;
  end;

  if DataSet.FindField('gross_amount') <> nil then TFloatField(DataSet.FieldByName('gross_amount')).DisplayFormat := '#,##0.00 TMT';
  if DataSet.FindField('tax_amount') <> nil then TFloatField(DataSet.FieldByName('tax_amount')).DisplayFormat := '#,##0.00 TMT';
  if DataSet.FindField('pension_amount') <> nil then TFloatField(DataSet.FieldByName('pension_amount')).DisplayFormat := '#,##0.00 TMT';
  if DataSet.FindField('union_amount') <> nil then TFloatField(DataSet.FieldByName('union_amount')).DisplayFormat := '#,##0.00 TMT';
  if DataSet.FindField('alimony_amount') <> nil then TFloatField(DataSet.FieldByName('alimony_amount')).DisplayFormat := '#,##0.00 TMT';
  if DataSet.FindField('net_amount') <> nil then TFloatField(DataSet.FieldByName('net_amount')).DisplayFormat := '#,##0.00 TMT';

  if DataSet.FindField('base_salary') <> nil then
    TFloatField(DataSet.FieldByName('base_salary')).DisplayFormat := '#,##0.00 TMT';

  // --- ДОБАВЛЯЕМ ЭТОТ БЛОК ДЛЯ ПЕРЕВОДА "ХВОСТОВ" ---
  if DataSet.FindField('base_salary') <> nil then DataSet.FieldByName('base_salary').DisplayLabel := 'Базовый оклад';
  if DataSet.FindField('dept_name') <> nil then DataSet.FieldByName('dept_name').DisplayLabel := 'Отдел';
  if DataSet.FindField('pos_name') <> nil then DataSet.FieldByName('pos_name').DisplayLabel := 'Должность';
end;

procedure TframePayroll.DBGrid1DblClick(Sender: TObject);
var
  SlipForm: TfrmPaySlip;
  Period: string;
begin
  if qryPayroll.IsEmpty then Exit;
  Period := cmbMonth.Text + ' ' + cmbYear.Text;
  SlipForm := TfrmPaySlip.Create(Self);
  try
    SlipForm.ShowSinglePayslip(qryPayroll, Period); // ВЫЗЫВАЕМ SINGLE
    SlipForm.ShowModal;
  finally
    SlipForm.Free;
  end;
end;

destructor TframePayroll.Destroy;
begin
  if Assigned(qryPayroll) then qryPayroll.Free;
  if Assigned(dsPayroll) then dsPayroll.Free;
  inherited;
end;

end.

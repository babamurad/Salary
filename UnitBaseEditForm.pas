unit UnitBaseEditForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls, Vcl.StdCtrls,
  Data.DB, Vcl.ExtCtrls, Vcl.Samples.Spin,
  Vcl.Grids, Vcl.DBGrids, Vcl.DBCtrls, FireDAC.Comp.Client;

type
  TfrmBaseEdit = class(TForm)
    PageControl1: TPageControl;
    tsMain: TTabSheet;
    tsHistory: TTabSheet;
    PanelHistory: TPanel;
    btnAutoGenerate: TButton;
    DBNavHistory: TDBNavigator;
    DBGridHistory: TDBGrid;

    edtFIO: TEdit;
    edtTabNo: TEdit;
    dtpHireDate: TDateTimePicker;
    cmbDept: TComboBox;
    cmbPos: TComboBox;
    edtSalary: TEdit;
    seExpYears: TSpinEdit;
    seExpMonths: TSpinEdit;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    GroupBox3: TGroupBox;
    chkActive: TCheckBox;
    seDependents: TSpinEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    Label10: TLabel;
    Panel1: TPanel;
    Button1: TButton; // Теперь это "Сохранить и закрыть"
    Button2: TButton;
    btnSaveOnly: TButton; // <--- НАША НОВАЯ КНОПКА "Сохранить"
    sePension: TSpinEdit;
    Label11: TLabel;
    Label13: TLabel;
    Label14: TLabel;
    Label15: TLabel;
    Label16: TLabel;

    rgWageType: TRadioGroup;
    edtHourlyRate: TEdit;
    Label12: TLabel;
    chkRotation: TCheckBox;

    edtBankAccount: TEdit;
    cmbWorkFraction: TComboBox;
    cmbClassRank: TComboBox;
    chkTaxExempt: TCheckBox;
    chkTradeUnion: TCheckBox;
    seAlimony: TSpinEdit;
    seSickLeavePercent: TSpinEdit;
    Label17: TLabel;

    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure rgWageTypeClick(Sender: TObject);
    procedure btnAutoGenerateClick(Sender: TObject);
    procedure PageControl1Change(Sender: TObject);
    procedure btnSaveOnlyClick(Sender: TObject); // Обработчик новой кнопки
  private
    FTargetDataSet: TDataSet; // Переменная для хранения ссылки на датасет
    procedure UpdateWageInputs;
    procedure SetupHistoryGrid;
    function ParseMoney(const S: string): Double; // Умная функция для денег
  public
    procedure LoadLists;
    procedure LoadFromDataset(DataSet: TDataSet);
    procedure SaveToDataset(DataSet: TDataSet);
  end;

var
  frmBaseEdit: TfrmBaseEdit;

implementation

{$R *.dfm}

uses UnitdmMain, System.DateUtils;

{ TfrmBaseEdit }

procedure TfrmBaseEdit.FormCreate(Sender: TObject);
begin
  // Инициализация
end;

// --- УМНАЯ ФУНКЦИЯ ПРЕОБРАЗОВАНИЯ СУММ ---
function TfrmBaseEdit.ParseMoney(const S: string): Double;
var
  CleanStr: string;
begin
  CleanStr := StringReplace(S, ' ', '', [rfReplaceAll]);
  CleanStr := StringReplace(CleanStr, #160, '', [rfReplaceAll]); // Удаляем неразрывные пробелы
  // Подстраиваемся под систему (точки/запятые)
  CleanStr := StringReplace(CleanStr, '.', FormatSettings.DecimalSeparator, [rfReplaceAll]);
  CleanStr := StringReplace(CleanStr, ',', FormatSettings.DecimalSeparator, [rfReplaceAll]);
  Result := StrToFloatDef(CleanStr, 0);
end;

procedure TfrmBaseEdit.FormShow(Sender: TObject);
var
  par: Integer;
begin
  LoadLists;
  UpdateWageInputs;

  PageControl1.ActivePage := tsMain;

  if Assigned(dmMain) then
  begin
    dmMain.qryEmpHistory.Close;
    par := dmMain.qryEmployees.FieldByName('id').AsInteger;
    dmMain.qryEmpHistory.ParamByName('emp_id').AsInteger := par;
    dmMain.qryEmpHistory.Open;
  end;

  SetupHistoryGrid;
end;

procedure TfrmBaseEdit.SetupHistoryGrid;
var
  FldDate, FldAmount: TField;
begin
  if dmMain.qryEmpHistory.Active and (dmMain.qryEmpHistory.FieldCount > 0) then
  begin
    FldDate := dmMain.qryEmpHistory.FindField('period_date');
    if Assigned(FldDate) then
    begin
      if FldDate is TDateTimeField then
        (FldDate as TDateTimeField).DisplayFormat := 'mm.yyyy'
      else if FldDate is TSQLTimeStampField then
        (FldDate as TSQLTimeStampField).DisplayFormat := 'mm.yyyy';
    end;

    FldAmount := dmMain.qryEmpHistory.FindField('amount');
    if Assigned(FldAmount) and (FldAmount is TNumericField) then
      (FldAmount as TNumericField).DisplayFormat := '#,##0.00';
  end;
end;

procedure TfrmBaseEdit.btnAutoGenerateClick(Sender: TObject);
var
  i: Integer;
  EmpID: Integer;
  BaseSalary: Double;
  TargetDate: TDate;
  QryExec: TFDQuery;
  CleanStr: string;
begin
  if not dmMain.qryEmployees.Active then Exit;

  EmpID := dmMain.qryEmployees.FieldByName('id').AsInteger;

  if EmpID = 0 then
  begin
    ShowMessage('Сначала сохраните нового сотрудника (нажмите Сохранить), а затем вернитесь к истории!');
    Exit;
  end;

  if rgWageType.ItemIndex = 0 then CleanStr := edtSalary.Text else CleanStr := edtHourlyRate.Text;
  BaseSalary := ParseMoney(CleanStr); // Используем нашу новую функцию

  if BaseSalary <= 0 then
  begin
    ShowMessage('У сотрудника не указан оклад или тариф (сумма равна 0)! Проверьте поле ввода.');
    Exit;
  end;

  if MessageDlg('Заполнить историю сотрудника суммой (' + FormatFloat('#,##0.00', BaseSalary) + ') за последние 12 месяцев?',
                mtConfirmation, [mbYes, mbNo], 0) <> mrYes then
    Exit;

  QryExec := TFDQuery.Create(nil);
  try
    QryExec.Connection := dmMain.conn;

    for i := 1 to 12 do
    begin
      TargetDate := StartOfTheMonth(IncMonth(Date, -i));

      QryExec.Close;
      QryExec.SQL.Text := 'SELECT id FROM salary_history WHERE emp_id = :e_id AND period_date = :p_date';
      QryExec.ParamByName('e_id').AsInteger := EmpID;
      QryExec.ParamByName('p_date').AsDate := TargetDate;
      QryExec.Open;

      if QryExec.IsEmpty then
      begin
        QryExec.Close;
        QryExec.SQL.Text := 'INSERT INTO salary_history (emp_id, period_date, amount) VALUES (:e_id, :p_date, :amt)';
        QryExec.ParamByName('e_id').AsInteger := EmpID;
        QryExec.ParamByName('p_date').AsDate := TargetDate;
        QryExec.ParamByName('amt').AsFloat := BaseSalary;
        QryExec.ExecSQL;
      end;
    end;

    dmMain.qryEmpHistory.Close;
    dmMain.qryEmpHistory.ParamByName('emp_id').AsInteger := EmpID;
    dmMain.qryEmpHistory.Open;

    if dmMain.qryEmpHistory.FindField('amount') <> nil then
      (dmMain.qryEmpHistory.FieldByName('amount') as TNumericField).DisplayFormat := '#,##0.00';
    if dmMain.qryEmpHistory.FindField('period_date') <> nil then
      (dmMain.qryEmpHistory.FieldByName('period_date') as TDateTimeField).DisplayFormat := 'mm.yyyy';

    ShowMessage('История успешно заполнена!');

  finally
    QryExec.Free;
  end;
end;

procedure TfrmBaseEdit.UpdateWageInputs;
begin
  if rgWageType.ItemIndex = 0 then
  begin
    edtSalary.Enabled := True;
    edtHourlyRate.Enabled := False;
    edtHourlyRate.Text := '0';
  end
  else
  begin
    edtSalary.Enabled := False;
    edtSalary.Text := '0';
    edtHourlyRate.Enabled := True;
  end;
end;

procedure TfrmBaseEdit.rgWageTypeClick(Sender: TObject);
begin
  UpdateWageInputs;
end;

procedure TfrmBaseEdit.LoadFromDataset(DataSet: TDataSet);
var
  i, TargetID: Integer;
  WorkFrac: Double;
begin
  FTargetDataSet := DataSet; // Запоминаем датасет для кнопки "Просто сохранить"
  LoadLists;

  edtFIO.Text := DataSet.FieldByName('fio').AsString;
  edtTabNo.Text := DataSet.FieldByName('tabno').AsString;
  dtpHireDate.Date := DataSet.FieldByName('hire_date').AsDateTime;
  chkActive.Checked := DataSet.FieldByName('status').AsInteger = 1;
  edtBankAccount.Text := DataSet.FieldByName('bank_account').AsString;

  rgWageType.ItemIndex := DataSet.FieldByName('wage_type').AsInteger;
  edtSalary.Text := FormatFloat('#,##0.00', DataSet.FieldByName('base_salary').AsFloat); // Форматируем при загрузке
  edtHourlyRate.Text := FormatFloat('#,##0.00', DataSet.FieldByName('hourly_rate').AsFloat);

  seExpYears.Value := DataSet.FieldByName('prior_exp_years').AsInteger;
  seExpMonths.Value := DataSet.FieldByName('prior_exp_months').AsInteger;

  WorkFrac := DataSet.FieldByName('work_fraction').AsFloat;
  if WorkFrac = 0.75 then cmbWorkFraction.ItemIndex := 1
  else if WorkFrac = 0.50 then cmbWorkFraction.ItemIndex := 2
  else if WorkFrac = 0.25 then cmbWorkFraction.ItemIndex := 3
  else cmbWorkFraction.ItemIndex := 0;

  cmbClassRank.ItemIndex := DataSet.FieldByName('class_rank').AsInteger;

  UpdateWageInputs;

  seDependents.Value := DataSet.FieldByName('dependents_count').AsInteger;
  sePension.Value := DataSet.FieldByName('pension_rate').AsInteger;
  chkRotation.Checked := DataSet.FieldByName('is_rotation').AsInteger = 1;
  chkTaxExempt.Checked := DataSet.FieldByName('is_tax_exempt').AsInteger = 1;
  chkTradeUnion.Checked := DataSet.FieldByName('trade_union').AsInteger = 1;
  seAlimony.Value := DataSet.FieldByName('alimony_percent').AsInteger;
  seSickLeavePercent.Value := DataSet.FieldByName('sick_leave_percent').AsInteger;

  TargetID := DataSet.FieldByName('dept_id').AsInteger;
  cmbDept.ItemIndex := -1;
  for i := 0 to cmbDept.Items.Count - 1 do
    if Integer(cmbDept.Items.Objects[i]) = TargetID then
    begin
      cmbDept.ItemIndex := i;
      Break;
    end;

  TargetID := DataSet.FieldByName('pos_id').AsInteger;
  cmbPos.ItemIndex := -1;
  for i := 0 to cmbPos.Items.Count - 1 do
    if Integer(cmbPos.Items.Objects[i]) = TargetID then
    begin
      cmbPos.ItemIndex := i;
      Break;
    end;
end;

procedure TfrmBaseEdit.LoadLists;
begin
  cmbDept.Items.Clear;
  dmMain.qryDepts.Open;
  dmMain.qryDepts.First;
  while not dmMain.qryDepts.Eof do
  begin
    cmbDept.Items.AddObject(dmMain.qryDepts.FieldByName('dept_name').AsString,
                            TObject(dmMain.qryDepts.FieldByName('id').AsInteger));
    dmMain.qryDepts.Next;
  end;

  cmbPos.Items.Clear;
  dmMain.qryPositions.Open;
  dmMain.qryPositions.First;
  while not dmMain.qryPositions.Eof do
  begin
    cmbPos.Items.AddObject(dmMain.qryPositions.FieldByName('name').AsString,
                           TObject(dmMain.qryPositions.FieldByName('id').AsInteger));
    dmMain.qryPositions.Next;
  end;
end;

procedure TfrmBaseEdit.PageControl1Change(Sender: TObject);
begin
  if PageControl1.ActivePageIndex = 1 then
  begin
      with dmMain do
        begin
          if qryEmployees.Active then
          begin
            qryEmpHistory.Close;
            qryEmpHistory.ParamByName('emp_id').AsInteger := qryEmployees.FieldByName('id').AsInteger;
            qryEmpHistory.Open;

            if qryEmpHistory.FindField('amount') <> nil then
              (qryEmpHistory.FieldByName('amount') as TNumericField).DisplayFormat := '#,##0.00';

            if qryEmpHistory.FindField('period_date') <> nil then
              (qryEmpHistory.FieldByName('period_date') as TDateTimeField).DisplayFormat := 'mm.yyyy';
          end;
        end;

        DBGridHistory.DataSource := dmMain.dsEmpHistory;
        DBNavHistory.DataSource := dmMain.dsEmpHistory;
  end;
end;

procedure TfrmBaseEdit.SaveToDataset(DataSet: TDataSet);
begin
  DataSet.FieldByName('fio').AsString := edtFIO.Text;
  DataSet.FieldByName('tabno').AsString := edtTabNo.Text;
  DataSet.FieldByName('hire_date').AsDateTime := dtpHireDate.Date;
  DataSet.FieldByName('bank_account').AsString := edtBankAccount.Text;

  if chkActive.Checked then DataSet.FieldByName('status').AsInteger := 1
  else DataSet.FieldByName('status').AsInteger := 0;

  DataSet.FieldByName('wage_type').AsInteger := rgWageType.ItemIndex;

  // ИСПОЛЬЗУЕМ НАШУ УМНУЮ ФУНКЦИЮ
  DataSet.FieldByName('base_salary').AsFloat := ParseMoney(edtSalary.Text);
  DataSet.FieldByName('hourly_rate').AsFloat := ParseMoney(edtHourlyRate.Text);

  DataSet.FieldByName('prior_exp_years').AsInteger := seExpYears.Value;
  DataSet.FieldByName('prior_exp_months').AsInteger := seExpMonths.Value;

  if cmbClassRank.ItemIndex <> -1 then
    DataSet.FieldByName('class_rank').AsInteger := cmbClassRank.ItemIndex
  else
    DataSet.FieldByName('class_rank').AsInteger := 0;

  case cmbWorkFraction.ItemIndex of
    0: DataSet.FieldByName('work_fraction').AsFloat := 1.0;
    1: DataSet.FieldByName('work_fraction').AsFloat := 0.75;
    2: DataSet.FieldByName('work_fraction').AsFloat := 0.50;
    3: DataSet.FieldByName('work_fraction').AsFloat := 0.25;
  else
    DataSet.FieldByName('work_fraction').AsFloat := 1.0;
  end;

  DataSet.FieldByName('dependents_count').AsInteger := seDependents.Value;
  DataSet.FieldByName('pension_rate').AsFloat := sePension.Value;
  DataSet.FieldByName('alimony_percent').AsFloat := seAlimony.Value;
  DataSet.FieldByName('sick_leave_percent').AsInteger := seSickLeavePercent.Value;

  if chkRotation.Checked then DataSet.FieldByName('is_rotation').AsInteger := 1 else DataSet.FieldByName('is_rotation').AsInteger := 0;
  if chkTaxExempt.Checked then DataSet.FieldByName('is_tax_exempt').AsInteger := 1 else DataSet.FieldByName('is_tax_exempt').AsInteger := 0;
  if chkTradeUnion.Checked then DataSet.FieldByName('trade_union').AsInteger := 1 else DataSet.FieldByName('trade_union').AsInteger := 0;

  if cmbDept.ItemIndex <> -1 then
    DataSet.FieldByName('dept_id').AsInteger := Integer(cmbDept.Items.Objects[cmbDept.ItemIndex]);

  if cmbPos.ItemIndex <> -1 then
    DataSet.FieldByName('pos_id').AsInteger := Integer(cmbPos.Items.Objects[cmbPos.ItemIndex]);
end;

// --- КОД ДЛЯ НОВОЙ КНОПКИ "ПРОСТО СОХРАНИТЬ" ---
procedure TfrmBaseEdit.btnSaveOnlyClick(Sender: TObject);
begin
  if Assigned(FTargetDataSet)  then
  begin
    // Переводим датасет в режим редактирования (если он еще не там)
    if not (FTargetDataSet.State in [dsEdit, dsInsert]) then
      FTargetDataSet.Edit;

    // Сохраняем значения из полей формы в DataSet
    SaveToDataset(FTargetDataSet);

    // Фиксируем изменения в базе данных
    FTargetDataSet.Post;

    // После Post датасет переходит в режим просмотра.
    // Снова переводим его в Edit, чтобы пользователь мог продолжать вводить данные
    FTargetDataSet.Edit;

    ShowMessage('Данные сотрудника успешно сохранены!');
  end;
end;

end.

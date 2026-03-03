unit UnitBaseEditForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls, Vcl.StdCtrls,
  Data.DB,
  Vcl.ExtCtrls, Vcl.Samples.Spin;

type
  TfrmBaseEdit = class(TForm)
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
    Button1: TButton;
    Button2: TButton;
    sePension: TSpinEdit;
    Label11: TLabel;

    // Поля для Оплаты и Вахты
    rgWageType: TRadioGroup;
    edtHourlyRate: TEdit;
    Label12: TLabel;
    chkRotation: TCheckBox;

    // --- НАШИ НОВЫЕ ПОЛЯ ИЗ ПОСЛЕДНЕГО АПГРЕЙДА ---
    edtBankAccount: TEdit;        // Банковский счет
    cmbWorkFraction: TComboBox;   // Доля ставки (0.25 - 1.0)
    cmbClassRank: TComboBox;      // Классность
    chkTaxExempt: TCheckBox;      // Освобождение от налогов
    chkTradeUnion: TCheckBox;     // Профсоюз
    seAlimony: TSpinEdit;         // Алименты (%)

    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure rgWageTypeClick(Sender: TObject);
  private
    procedure UpdateWageInputs;
  public
    procedure LoadLists;
    procedure LoadFromDataset(DataSet: TDataSet);
    procedure SaveToDataset(DataSet: TDataSet);
  end;

var
  frmBaseEdit: TfrmBaseEdit;

implementation

{$R *.dfm}

uses UnitdmMain;

{ TfrmBaseEdit }

procedure TfrmBaseEdit.FormCreate(Sender: TObject);
begin
  // Инициализация (если понадобится)
end;

procedure TfrmBaseEdit.FormShow(Sender: TObject);
begin
  LoadLists;
  UpdateWageInputs;
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
  LoadLists;

  // --- Вкладка Основное ---
  edtFIO.Text := DataSet.FieldByName('fio').AsString;
  edtTabNo.Text := DataSet.FieldByName('tabno').AsString;
  dtpHireDate.Date := DataSet.FieldByName('hire_date').AsDateTime;
  chkActive.Checked := DataSet.FieldByName('status').AsInteger = 1;
  edtBankAccount.Text := DataSet.FieldByName('bank_account').AsString; // Банковский счет

  // --- Вкладка Оплата и Стаж ---
  rgWageType.ItemIndex := DataSet.FieldByName('wage_type').AsInteger;
  edtSalary.Text := FormatFloat('0.00', DataSet.FieldByName('base_salary').AsFloat);
  edtHourlyRate.Text := FormatFloat('0.00', DataSet.FieldByName('hourly_rate').AsFloat);
  seExpYears.Value := DataSet.FieldByName('prior_exp_years').AsInteger;
  seExpMonths.Value := DataSet.FieldByName('prior_exp_months').AsInteger;

  // Доля ставки (Переводим дробь в ItemIndex для ComboBox)
  WorkFrac := DataSet.FieldByName('work_fraction').AsFloat;
  if WorkFrac = 0.75 then cmbWorkFraction.ItemIndex := 1
  else if WorkFrac = 0.50 then cmbWorkFraction.ItemIndex := 2
  else if WorkFrac = 0.25 then cmbWorkFraction.ItemIndex := 3
  else cmbWorkFraction.ItemIndex := 0; // 1.0 по умолчанию

  // Классность (прямая привязка: 0-Без класса, 1-1ый, 2-2ой, 3-3ий)
  cmbClassRank.ItemIndex := DataSet.FieldByName('class_rank').AsInteger;

  UpdateWageInputs;

  // --- Вкладка Налоги и льготы ---
  seDependents.Value := DataSet.FieldByName('dependents_count').AsInteger;
  sePension.Value := DataSet.FieldByName('pension_rate').AsInteger;
  chkRotation.Checked := DataSet.FieldByName('is_rotation').AsInteger = 1;
  chkTaxExempt.Checked := DataSet.FieldByName('is_tax_exempt').AsInteger = 1; // Освобождение
  chkTradeUnion.Checked := DataSet.FieldByName('trade_union').AsInteger = 1;  // Профсоюз
  seAlimony.Value := DataSet.FieldByName('alimony_percent').AsInteger;        // Алименты

  // --- Логика для ComboBox (Отдел) ---
  TargetID := DataSet.FieldByName('dept_id').AsInteger;
  cmbDept.ItemIndex := -1;
  for i := 0 to cmbDept.Items.Count - 1 do
    if Integer(cmbDept.Items.Objects[i]) = TargetID then
    begin
      cmbDept.ItemIndex := i;
      Break;
    end;

  // --- Логика для ComboBox (Должность) ---
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
  // Заполняем Отделы
  cmbDept.Items.Clear;
  dmMain.qryDepts.Open;
  dmMain.qryDepts.First;
  while not dmMain.qryDepts.Eof do
  begin
    cmbDept.Items.AddObject(dmMain.qryDepts.FieldByName('dept_name').AsString,
                            TObject(dmMain.qryDepts.FieldByName('id').AsInteger));
    dmMain.qryDepts.Next;
  end;

  // Заполняем Должности
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

procedure TfrmBaseEdit.SaveToDataset(DataSet: TDataSet);
begin
  // Основное
  DataSet.FieldByName('fio').AsString := edtFIO.Text;
  DataSet.FieldByName('tabno').AsString := edtTabNo.Text;
  DataSet.FieldByName('hire_date').AsDateTime := dtpHireDate.Date;
  DataSet.FieldByName('bank_account').AsString := edtBankAccount.Text; // Сохраняем счет

  if chkActive.Checked then DataSet.FieldByName('status').AsInteger := 1
  else DataSet.FieldByName('status').AsInteger := 0;

  // Оплата и Стаж
  DataSet.FieldByName('wage_type').AsInteger := rgWageType.ItemIndex;
  DataSet.FieldByName('base_salary').AsFloat := StrToFloatDef(StringReplace(edtSalary.Text, ',', '.', [rfReplaceAll]), 0);
  DataSet.FieldByName('hourly_rate').AsFloat := StrToFloatDef(StringReplace(edtHourlyRate.Text, ',', '.', [rfReplaceAll]), 0);
  DataSet.FieldByName('prior_exp_years').AsInteger := seExpYears.Value;
  DataSet.FieldByName('prior_exp_months').AsInteger := seExpMonths.Value;

  // Сохраняем классность
  if cmbClassRank.ItemIndex <> -1 then
    DataSet.FieldByName('class_rank').AsInteger := cmbClassRank.ItemIndex
  else
    DataSet.FieldByName('class_rank').AsInteger := 0;

  // Сохраняем долю ставки
  case cmbWorkFraction.ItemIndex of
    0: DataSet.FieldByName('work_fraction').AsFloat := 1.0;
    1: DataSet.FieldByName('work_fraction').AsFloat := 0.75;
    2: DataSet.FieldByName('work_fraction').AsFloat := 0.50;
    3: DataSet.FieldByName('work_fraction').AsFloat := 0.25;
  else
    DataSet.FieldByName('work_fraction').AsFloat := 1.0;
  end;

  // Налоги и льготы
  DataSet.FieldByName('dependents_count').AsInteger := seDependents.Value;
  DataSet.FieldByName('pension_rate').AsFloat := sePension.Value;
  DataSet.FieldByName('alimony_percent').AsFloat := seAlimony.Value; // Сохраняем алименты

  // Галочки: Вахта, Налоговая льгота, Профсоюз
  if chkRotation.Checked then DataSet.FieldByName('is_rotation').AsInteger := 1 else DataSet.FieldByName('is_rotation').AsInteger := 0;
  if chkTaxExempt.Checked then DataSet.FieldByName('is_tax_exempt').AsInteger := 1 else DataSet.FieldByName('is_tax_exempt').AsInteger := 0;
  if chkTradeUnion.Checked then DataSet.FieldByName('trade_union').AsInteger := 1 else DataSet.FieldByName('trade_union').AsInteger := 0;

  // Списки (ID из объектов)
  if cmbDept.ItemIndex <> -1 then
    DataSet.FieldByName('dept_id').AsInteger := Integer(cmbDept.Items.Objects[cmbDept.ItemIndex]);

  if cmbPos.ItemIndex <> -1 then
    DataSet.FieldByName('pos_id').AsInteger := Integer(cmbPos.Items.Objects[cmbPos.ItemIndex]);
end;

end.

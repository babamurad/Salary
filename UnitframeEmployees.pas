unit UnitframeEmployees;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Data.DB, Vcl.Grids,
  Vcl.DBGrids, Vcl.ExtCtrls, Vcl.DBCtrls, Vcl.StdCtrls, Vcl.Mask,
  Vcl.ComCtrls, FireDAC.Comp.DataSet;

type
  TframeEmployees = class(TFrame)
    PanelTop: TPanel;
    DBNavigator1: TDBNavigator;
    DBGrid1: TDBGrid;
    edtSearch: TEdit;
    Label1: TLabel;
    procedure DBGrid1DblClick(Sender: TObject);
    procedure edtSearchChange(Sender: TObject);
    procedure DBGrid1DrawColumnCell(Sender: TObject; const Rect: TRect;
      DataCol: Integer; Column: TColumn; State: TGridDrawState);
  private
    dsLocal: TDataSource;
    procedure DBGrid1TitleClick(Column: TColumn);
    procedure SetupGrid;
  public
    constructor Create(AOwner: TComponent); override;
  end;

implementation

{$R *.dfm}

uses
  UnitdmMain, UnitBaseEditForm;

constructor TframeEmployees.Create(AOwner: TComponent);
var
  FldTab: TField;
begin
  inherited;

  if not Assigned(dmMain) then Exit;

  if not dmMain.qryDepts.Active then dmMain.qryDepts.Open;
  if not dmMain.qryPositions.Active then dmMain.qryPositions.Open;
  if not dmMain.qryEmployees.Active then dmMain.qryEmployees.Open;

  // Формат табельного номера
  FldTab := dmMain.qryEmployees.FindField('tabno');
  if (FldTab <> nil) and (FldTab is TIntegerField) then
    TIntegerField(FldTab).DisplayFormat := '000';

  // Локальный DataSource для синхронизации даты
  dsLocal := TDataSource.Create(Self);
  dsLocal.DataSet := dmMain.qryEmployees;



  // Привязки
  DBGrid1.DataSource := dmMain.dsEmployees;
  DBNavigator1.DataSource := dmMain.dsEmployees;


  SetupGrid;

  DBGrid1.OnTitleClick := DBGrid1TitleClick;

end;

procedure TframeEmployees.SetupGrid;
var
  DS: TDataSet;
begin
  DS := DBGrid1.DataSource.DataSet;
  if not Assigned(DS) or not DS.Active then Exit;

  // --- Скрываем технические поля ---
  if DS.FindField('id') <> nil then DS.FieldByName('id').Visible := False;
  if DS.FindField('dept_id') <> nil then DS.FieldByName('dept_id').Visible := False;
  if DS.FindField('pos_id') <> nil then DS.FieldByName('pos_id').Visible := False;
  if DS.FindField('status') <> nil then DS.FieldByName('status').Visible := False;

  // --- Настраиваем отображение существующих полей ---
  if DS.FindField('tabno') <> nil then
  begin
    DS.FieldByName('tabno').DisplayLabel := 'Таб. №';
    DS.FieldByName('tabno').DisplayWidth := 6;
  end;

  if DS.FindField('fio') <> nil then
  begin
    DS.FieldByName('fio').DisplayLabel := 'Ф.И.О.';
    DS.FieldByName('fio').DisplayWidth := 25;
  end;

  if DS.FindField('hire_date') <> nil then
  begin
    DS.FieldByName('hire_date').DisplayLabel := 'Дата приема';
    DS.FieldByName('hire_date').DisplayWidth := 12;
  end;

  if DS.FindField('base_salary') <> nil then
  begin
    DS.FieldByName('base_salary').DisplayLabel := 'Оклад';
    // Возвращаем форматирование валюты для единообразия
    if DS.FieldByName('base_salary') is TFloatField then
      TFloatField(DS.FieldByName('base_salary')).DisplayFormat := '#,##0.00 TMT';
    DS.FieldByName('base_salary').DisplayWidth := 12;
  end;

  // --- ПЕРЕВОДИМ НОВЫЕ ПОЛЯ (Стаж и Иждивенцы) ---
  if DS.FindField('prior_exp_years') <> nil then
  begin
    DS.FieldByName('prior_exp_years').DisplayLabel := 'Стаж (лет)';
    DS.FieldByName('prior_exp_years').DisplayWidth := 10;
  end;

  if DS.FindField('prior_exp_months') <> nil then
  begin
    DS.FieldByName('prior_exp_months').DisplayLabel := 'Стаж (мес.)';
    DS.FieldByName('prior_exp_months').DisplayWidth := 10;
  end;

  if DS.FindField('dependents_count') <> nil then
  begin
    DS.FieldByName('dependents_count').DisplayLabel := 'Иждивенцы';
    DS.FieldByName('dependents_count').DisplayWidth := 10;
  end;

  // --- Отделы и Должности (из JOIN) ---
  if DS.FindField('dept_name') <> nil then
  begin
    DS.FieldByName('dept_name').DisplayLabel := 'Отдел';
    DS.FieldByName('dept_name').DisplayWidth := 20;
  end;

  if DS.FindField('pos_name') <> nil then
  begin
    DS.FieldByName('pos_name').DisplayLabel := 'Должность';
    DS.FieldByName('pos_name').DisplayWidth := 20;
  end;
end;



procedure TframeEmployees.edtSearchChange(Sender: TObject);
begin
  if Trim(edtSearch.Text) = '' then
  begin
    dmMain.qryEmployees.Filtered := False;
  end
  else
  begin
    // Фильтруем на лету (без учета регистра)
    dmMain.qryEmployees.Filter := 'fio LIKE ' + QuotedStr('%' + edtSearch.Text + '%');
    dmMain.qryEmployees.Filtered := True;
  end;
end;

procedure TframeEmployees.DBGrid1DblClick(Sender: TObject);
var
  Frm: TfrmBaseEdit;
begin
  Frm := TfrmBaseEdit.Create(Self);
  try
    // 1. Передаем данные из текущей строки базы в форму
    Frm.LoadFromDataset(dmMain.qryEmployees);
    // 2. Показываем форму модально
    if Frm.ShowModal = mrOk then
    begin
      dmMain.qryEmployees.Edit; // Переводим базу в режим правки
      Frm.SaveToDataset(dmMain.qryEmployees); // Забираем данные из формы
      dmMain.qryEmployees.Post; // Сохраняем
    end;
  finally
    Frm.Free;
  end;
end;

procedure TframeEmployees.DBGrid1DrawColumnCell(Sender: TObject;
  const Rect: TRect; DataCol: Integer; Column: TColumn; State: TGridDrawState);
begin
  if not dmMain.qryEmployees.IsEmpty then
  begin
    // 1. Если сотрудник уволен (status = 0) -> серый цвет
    if dmMain.qryEmployees.FieldByName('status').AsInteger = 0 then
    begin
      DBGrid1.Canvas.Brush.Color := $00F0F0F0; // Светло-серый фон
      DBGrid1.Canvas.Font.Color := clGray;      // Серый текст
    end
    // 2. Если оклад >= 7000 -> выделяем жирным
    else if dmMain.qryEmployees.FieldByName('base_salary').AsFloat >= 7000 then
    begin
      DBGrid1.Canvas.Font.Style := [fsBold];
      DBGrid1.Canvas.Font.Color := clNavy; // Темно-синий текст
    end;
  end;
  // Отрисовываем ячейку с новыми цветами
  DBGrid1.DefaultDrawColumnCell(Rect, DataCol, Column, State);
end;

procedure TframeEmployees.DBGrid1TitleClick(Column: TColumn);
var
  FDDataSet: TFDDataSet;
  i: Integer;
  CleanTitle: string;
begin
  if not Assigned(Column.Field) then Exit;

  FDDataSet := DBGrid1.DataSource.DataSet as TFDDataSet;

  if FDDataSet.IndexFieldNames = Column.FieldName then
    FDDataSet.IndexFieldNames := Column.FieldName + ':D'
  else
    FDDataSet.IndexFieldNames := Column.FieldName;

  for i := 0 to DBGrid1.Columns.Count - 1 do
  begin
    CleanTitle := StringReplace(DBGrid1.Columns[i].Title.Caption, ' ▲', '', [rfReplaceAll]);
    CleanTitle := StringReplace(CleanTitle, ' ▼', '', [rfReplaceAll]);
    DBGrid1.Columns[i].Title.Caption := CleanTitle;
  end;

  if Pos(':D', FDDataSet.IndexFieldNames) > 0 then
    Column.Title.Caption := Column.Title.Caption + ' ▼'
  else
    Column.Title.Caption := Column.Title.Caption + ' ▲';
end;

end.

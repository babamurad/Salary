unit UnitFrameVacations;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  System.DateUtils,
  Vcl.Grids, Vcl.DBGrids, Data.DB, System.UITypes;

type
  TframeVacations = class(TFrame)
    PanelTop: TPanel;
    btnAdd: TButton;
    btnDelete: TButton;
    btnRefresh: TButton;
    DBGridVacations: TDBGrid;
    procedure btnAddClick(Sender: TObject);
    procedure btnDeleteClick(Sender: TObject);
    procedure btnRefreshClick(Sender: TObject);
  private
    procedure SetupGrid;
  public
    constructor Create(AOwner: TComponent); override;
  end;

implementation

{$R *.dfm}

uses UnitdmMain, UnitVacationCalc; // Подключаем базу и форму расчета отпускных

constructor TframeVacations.Create(AOwner: TComponent);
begin
  inherited;
  if Assigned(dmMain) then
  begin
    // Открываем запрос, если он закрыт
    if not dmMain.qryVacation.Active then
      dmMain.qryVacation.Open;

    DBGridVacations.DataSource := dmMain.dsVacation;
    SetupGrid;
  end;
end;

procedure TframeVacations.SetupGrid;
begin
  if dmMain.qryVacation.FieldCount > 0 then
  begin
    DBGridVacations.Columns.Clear;

    // Настраиваем колонки
    with DBGridVacations.Columns.Add do begin FieldName := 'calc_date'; Title.Caption := 'Дата расчета'; Width := 100; end;
    with DBGridVacations.Columns.Add do begin FieldName := 'fio'; Title.Caption := 'Сотрудник'; Width := 250; end;
    with DBGridVacations.Columns.Add do begin FieldName := 'start_date'; Title.Caption := 'С'; Width := 90; end;
    with DBGridVacations.Columns.Add do begin FieldName := 'end_date'; Title.Caption := 'По'; Width := 90; end;
    with DBGridVacations.Columns.Add do begin FieldName := 'days_count'; Title.Caption := 'Дни'; Width := 50; end;
    with DBGridVacations.Columns.Add do begin FieldName := 'total_amount'; Title.Caption := 'Начислено (TMT)'; Width := 120; end;

    // Красивые форматы для дат
    if dmMain.qryVacation.FindField('calc_date') <> nil then
      (dmMain.qryVacation.FieldByName('calc_date') as TDateTimeField).DisplayFormat := 'dd.mm.yyyy';
    if dmMain.qryVacation.FindField('start_date') <> nil then
      (dmMain.qryVacation.FieldByName('start_date') as TDateTimeField).DisplayFormat := 'dd.mm.yyyy';
    if dmMain.qryVacation.FindField('end_date') <> nil then
      (dmMain.qryVacation.FieldByName('end_date') as TDateTimeField).DisplayFormat := 'dd.mm.yyyy';

    // Формат денег
    if dmMain.qryVacation.FindField('total_amount') <> nil then
      (dmMain.qryVacation.FieldByName('total_amount') as TNumericField).DisplayFormat := '#,##0.00';
  end;
end;

// --- ВЫЗОВ ФОРМЫ РАСЧЕТА ---
procedure TframeVacations.btnAddClick(Sender: TObject);
var
  Frm: TFormVacationCalc;
begin
  Frm := TFormVacationCalc.Create(Self);
  try
    // Открываем наше красивое окно как модальное (поверх остальных)
    Frm.ShowModal;

    // Перезагружать qryVacation здесь не обязательно,
    // так как мы добавили Refresh прямо в кнопку "Сохранить" внутри FormVacationCalc!
  finally
    Frm.Free;
  end;
end;

// --- БЕЗОПАСНОЕ УДАЛЕНИЕ ---
procedure TframeVacations.btnDeleteClick(Sender: TObject);
var
  DocID: Integer;
  EmpName: string;
begin
  if dmMain.qryVacation.IsEmpty then Exit;

  DocID := dmMain.qryVacation.FieldByName('id').AsInteger;
  EmpName := dmMain.qryVacation.FieldByName('fio').AsString;

  if MessageDlg('Удалить расчет отпускных для сотрудника: ' + EmpName + '?',
                mtConfirmation, [mbYes, mbNo], 0) = mrYes then
  begin
    // Безопасное удаление через SQL (т.к. запрос с JOIN часто не дает делать .Delete)
    dmMain.conn.ExecSQL('DELETE FROM vacation_journal WHERE id = :id', [DocID]);
    dmMain.qryVacation.Refresh;
  end;
end;

procedure TframeVacations.btnRefreshClick(Sender: TObject);
begin
  if dmMain.qryVacation.Active then
    dmMain.qryVacation.Refresh
  else
    dmMain.qryVacation.Open;
end;

end.

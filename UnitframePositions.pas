unit UnitframePositions;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Data.DB, Vcl.Grids,
  Vcl.DBGrids, Vcl.ExtCtrls, Vcl.DBCtrls,
  FireDAC.Comp.DataSet;

type
  TframePositions = class(TFrame)
    PanelTop: TPanel;
    DBNavigator1: TDBNavigator;
    DBGrid1: TDBGrid;
  private
    procedure DBGrid1TitleClick(Column: TColumn);
  public
    constructor Create(AOwner: TComponent); override;
  end;

implementation

{$R *.dfm}

uses
  UnitdmMain;

constructor TframePositions.Create(AOwner: TComponent);
begin
  inherited;

  if Assigned(dmMain) then
  begin
    // Подключаем к DataModule (Справочник должностей)
    DBGrid1.DataSource := dmMain.dsPositions;
    DBNavigator1.DataSource := dmMain.dsPositions;

    if not dmMain.qryPositions.Active then
      dmMain.qryPositions.Open;

    // Настраиваем колонки
    if DBGrid1.Columns.Count > 0 then
    begin
      DBGrid1.Columns[0].Title.Caption := 'ID';
      DBGrid1.Columns[0].Width := 50;
      DBGrid1.Columns[0].ReadOnly := True;

      DBGrid1.Columns[1].Title.Caption := 'Название должности';
      DBGrid1.Columns[1].Width := 250;

      // Третья колонка - Категория (АУП, Производство и т.д.)
      if DBGrid1.Columns.Count > 2 then
      begin
        DBGrid1.Columns[2].Title.Caption := 'Категория';
        DBGrid1.Columns[2].Width := 150;
      end;
    end;

    // Подключаем сортировку
    DBGrid1.OnTitleClick := DBGrid1TitleClick;
  end;
end;

procedure TframePositions.DBGrid1TitleClick(Column: TColumn);
var
  FDDataSet: TFDDataSet;
  i: Integer;
  CleanTitle: string;
begin
  if not Assigned(Column.Field) then Exit;
  if not Assigned(DBGrid1.DataSource) or not Assigned(DBGrid1.DataSource.DataSet) then Exit;

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

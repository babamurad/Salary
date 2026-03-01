unit UnitframeDepts;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Data.DB, Vcl.Grids,
  Vcl.DBGrids, Vcl.ExtCtrls, Vcl.DBCtrls,
  FireDAC.Comp.DataSet;

type
  TframeDepts = class(TFrame)
    PanelTop: TPanel;
    DBNavigator1: TDBNavigator;
    DBGrid1: TDBGrid;
  private
    { Private declarations }
    procedure DBGrid1TitleClick(Column: TColumn); // Наш метод сортировки
  public
    constructor Create(AOwner: TComponent); override;
  end;

implementation

{$R *.dfm}

uses
  UnitdmMain; // Подключаем наш DataModule

constructor TframeDepts.Create(AOwner: TComponent);
begin
  inherited;

  // Безопасно привязываем компоненты к DataModule
  if Assigned(dmMain) then
  begin
    DBGrid1.DataSource := dmMain.dsDepts;
    DBNavigator1.DataSource := dmMain.dsDepts;

    // Автоматически открываем таблицу при создании фрейма, если она закрыта
    if not dmMain.qryDepts.Active then
      dmMain.qryDepts.Open;

    // Делаем заголовки колонок красивыми и понятными
    if DBGrid1.Columns.Count > 0 then
    begin
      DBGrid1.Columns[0].Title.Caption := 'ID';
      DBGrid1.Columns[0].Width := 50;
      DBGrid1.Columns[0].ReadOnly := True; // ID генерируется базой данных

      DBGrid1.Columns[1].Title.Caption := 'Название отдела';
      DBGrid1.Columns[1].Width := 300;
    end;
    // Динамически подключаем событие клика по заголовку
    DBGrid1.OnTitleClick := DBGrid1TitleClick;
  end;
end;

procedure TframeDepts.DBGrid1TitleClick(Column: TColumn);
var
  FDDataSet: TFDDataSet;
  i: Integer;
  CleanTitle: string;
begin
  // Проверяем, есть ли поле и подключен ли DataSet
  if not Assigned(Column.Field) then Exit;
  if not Assigned(DBGrid1.DataSource) or not Assigned(DBGrid1.DataSource.DataSet) then Exit;

  // Приводим текущий DataSet к типу FireDAC
  FDDataSet := DBGrid1.DataSource.DataSet as TFDDataSet;

  // 1. ПЕРЕКЛЮЧАЕМ СОРТИРОВКУ В ПАМЯТИ
  // В FireDAC суффикс ':D' означает Descending (по убыванию)
  if FDDataSet.IndexFieldNames = Column.FieldName then
    FDDataSet.IndexFieldNames := Column.FieldName + ':D' // Если кликнули второй раз - по убыванию
  else
    FDDataSet.IndexFieldNames := Column.FieldName;       // По умолчанию по возрастанию

  // 2. РИСУЕМ СТРЕЛОЧКИ ДЛЯ КРАСОТЫ
  // Сначала очищаем старые стрелочки у всех колонок
  for i := 0 to DBGrid1.Columns.Count - 1 do
  begin
    CleanTitle := StringReplace(DBGrid1.Columns[i].Title.Caption, ' ▲', '', [rfReplaceAll]);
    CleanTitle := StringReplace(CleanTitle, ' ▼', '', [rfReplaceAll]);
    DBGrid1.Columns[i].Title.Caption := CleanTitle;
  end;

  // Добавляем нужную стрелочку к той колонке, по которой кликнули
  if Pos(':D', FDDataSet.IndexFieldNames) > 0 then
    Column.Title.Caption := Column.Title.Caption + ' ▼'
  else
    Column.Title.Caption := Column.Title.Caption + ' ▲';
end;

end.

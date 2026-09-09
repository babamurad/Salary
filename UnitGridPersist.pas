unit UnitGridPersist;

// Сохранение/восстановление ширины столбцов TDBGrid между запусками программы.
// Ширина хранится в config.ini (том же файле, где лежит путь к базе данных)
// в отдельных секциях вида [GridWidths.<GridKey>], по одному ключу на поле.

interface

uses
  System.SysUtils, System.IniFiles, Vcl.DBGrids;

// Вызывать после того, как у грида появились столбцы (обычно в AfterOpen
// датасета) — восстанавливает ранее сохранённую ширину, если она есть.
procedure LoadGridColumnWidths(Grid: TDBGrid; const GridKey: string);

// Вызывать перед закрытием формы/фрейма с гридом (например, в деструкторе) -
// запоминает текущую ширину всех столбцов.
procedure SaveGridColumnWidths(Grid: TDBGrid; const GridKey: string);

implementation

function ConfigFileName: string;
begin
  Result := ExtractFilePath(ParamStr(0)) + 'config.ini';
end;

procedure LoadGridColumnWidths(Grid: TDBGrid; const GridKey: string);
var
  Ini: TIniFile;
  i, SavedWidth: Integer;
begin
  if not Assigned(Grid) then Exit;

  Ini := TIniFile.Create(ConfigFileName);
  try
    for i := 0 to Grid.Columns.Count - 1 do
      if Grid.Columns[i].FieldName <> '' then
      begin
        SavedWidth := Ini.ReadInteger('GridWidths.' + GridKey, Grid.Columns[i].FieldName, -1);
        if SavedWidth > 0 then
          Grid.Columns[i].Width := SavedWidth;
      end;
  finally
    Ini.Free;
  end;
end;

procedure SaveGridColumnWidths(Grid: TDBGrid; const GridKey: string);
var
  Ini: TIniFile;
  i: Integer;
begin
  if not Assigned(Grid) then Exit;

  Ini := TIniFile.Create(ConfigFileName);
  try
    for i := 0 to Grid.Columns.Count - 1 do
      if Grid.Columns[i].FieldName <> '' then
        Ini.WriteInteger('GridWidths.' + GridKey, Grid.Columns[i].FieldName, Grid.Columns[i].Width);
  finally
    Ini.Free;
  end;
end;

end.

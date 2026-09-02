unit UnitframeAccounts;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Data.DB, Vcl.Grids,
  Vcl.DBGrids, Vcl.ExtCtrls, Vcl.DBCtrls, Vcl.StdCtrls,
  FireDAC.Comp.DataSet;

type
  TframeAccounts = class(TFrame)
    PanelTop: TPanel;
    DBNavigator1: TDBNavigator;
    LabelFilter: TLabel;
    EditFilter: TEdit;
    DBGrid1: TDBGrid;
    procedure EditFilterChange(Sender: TObject);
  private
    { Private declarations }
    procedure SetupColumns;
  public
    constructor Create(AOwner: TComponent); override;
  end;

implementation

{$R *.dfm}

uses
  UnitdmMain;

constructor TframeAccounts.Create(AOwner: TComponent);
begin
  inherited;

  if Assigned(dmMain) then
  begin
    DBGrid1.DataSource := dmMain.dsAccounts;
    DBNavigator1.DataSource := dmMain.dsAccounts;

    if not dmMain.qryAccounts.Active then
      dmMain.qryAccounts.Open;

    dmMain.qryAccounts.FilterOptions := [foCaseInsensitive];

    SetupColumns;
  end;
end;

procedure TframeAccounts.SetupColumns;

  function AddCol(const AFieldName, ACaption: string; AWidth: Integer): TColumn;
  begin
    Result := DBGrid1.Columns.Add;
    Result.FieldName := AFieldName;
    Result.Title.Caption := ACaption;
    Result.Width := AWidth;
  end;

begin
  // Показываем только то, что реально нужно бухгалтеру — служебные
  // поля (id, category/subcategory/acct_group, code_length, created_at)
  // в сетку не выводим, они остаются просто в БД для группировки.
  DBGrid1.Columns.Clear;
  AddCol('code', 'Код', 90);
  AddCol('code_display', 'Код (формат.)', 100);
  AddCol('name', 'Наименование', 420);
  AddCol('account_type', 'Тип', 160);
  AddCol('old_code', 'Старый код', 110);
  AddCol('is_active', 'Активен', 60);
end;

procedure TframeAccounts.EditFilterChange(Sender: TObject);
var
  S: string;
begin
  if not Assigned(dmMain) then Exit;

  S := StringReplace(Trim(EditFilter.Text), '''', '''''', [rfReplaceAll]);
  if S = '' then
    dmMain.qryAccounts.Filtered := False
  else
  begin
    dmMain.qryAccounts.Filter := Format('(code LIKE ''%%%s%%'') OR (name LIKE ''%%%s%%'') OR (old_code LIKE ''%%%s%%'')', [S, S, S]);
    dmMain.qryAccounts.Filtered := True;
  end;
end;

end.

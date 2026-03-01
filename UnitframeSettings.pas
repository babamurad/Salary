unit UnitframeSettings;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls, Data.DB,
  Vcl.Grids, Vcl.DBGrids, FireDAC.Comp.DataSet, Vcl.DBCtrls, Vcl.ExtCtrls;

type
  TframeSettings = class(TFrame)
    PageControl1: TPageControl;
    tsGeneral: TTabSheet;
    tsSickLeave: TTabSheet;
    DBGrid1: TDBGrid;
    DBGrid2: TDBGrid;
    TabSheet1: TTabSheet;
    DBGridHistory: TDBGrid;
    Panel1: TPanel;
    DBNavigator1: TDBNavigator;

  private
  procedure SetupHistoryGrid;
  public
    constructor Create(AOwner: TComponent); override;
  end;

implementation

{$R *.dfm}

uses UnitdmMain;

constructor TframeSettings.Create(AOwner: TComponent);
begin
  inherited;
  if Assigned(dmMain) then
  begin
    if not dmMain.qrySettings.Active then dmMain.qrySettings.Open;
    if not dmMain.qryHistory.Active then dmMain.qryHistory.Open;
    if not dmMain.qrySickLeaveRates.Active then dmMain.qrySickLeaveRates.Open;

    // --- Настройка вкладки Глобальные настройки ---
    DBGrid1.Columns[0].FieldName := 'key_name';
    DBGrid1.Columns[0].Title.Caption := 'Параметр';
    DBGrid1.Columns[0].ReadOnly := True;
    DBGrid1.Columns[0].Width := 180;

    DBGrid1.Columns[1].FieldName := 'key_value';
    DBGrid1.Columns[1].Title.Caption := 'Значение (%)';
    DBGrid1.Columns[1].Width := 120;

    // --- Настройка вкладки Больничные ---
    DBGrid2.Columns[0].Title.Caption := 'Стаж работы';
    DBGrid2.Columns[0].Width := 180;
    DBGrid2.Columns[1].Title.Caption := '% Выплаты';
    DBGrid2.Columns[1].Width := 120;
  end;
end;

procedure TframeSettings.SetupHistoryGrid;
begin
// Подключаем сетку к источнику данных
  DBGridHistory.DataSource := dmMain.dsHistory;
  if DBGridHistory.Columns.Count > 0 then
  begin
    DBGridHistory.Columns[0].Visible := False; // Скрываем технический ID
    // Настраиваем выбор сотрудника через выпадающий список
    DBGridHistory.Columns[1].Title.Caption := 'Сотрудник';
    DBGridHistory.Columns[1].Width := 200;
    // Здесь мы используем Lookup-поле, которое вы настроили в DataSet qryHistory
    DBGridHistory.Columns[2].Title.Caption := 'Дата (01.ММ.ГГГГ)';
    DBGridHistory.Columns[2].Width := 100;
    DBGridHistory.Columns[3].Title.Caption := 'Сумма дохода';
    DBGridHistory.Columns[3].Width := 120;
  end;
end;

end.

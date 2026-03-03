unit UnitframeSettings;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls, Data.DB,
  Vcl.Grids, Vcl.DBGrids, FireDAC.Comp.DataSet, Vcl.DBCtrls, Vcl.ExtCtrls,
  Vcl.StdCtrls;

type
  TframeSettings = class(TFrame)
    PageControl1: TPageControl;
    tsGeneral: TTabSheet;
    tsSickLeave: TTabSheet;
    DBGrid1: TDBGrid;
    DBGrid2: TDBGrid;
    TabSheet1: TTabSheet;
    DBGridHistory: TDBGrid;
    Panel2: TPanel;
    DBNavigator1: TDBNavigator;
    procedure SetupSettingsGrid;

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
    // 1. Open DataSets
    if not dmMain.qrySettings.Active then dmMain.qrySettings.Open;
    if not dmMain.qryHistory.Active then dmMain.qryHistory.Open;
    if not dmMain.qrySickLeaveRates.Active then dmMain.qrySickLeaveRates.Open;

    // --- Настройка вкладки Глобальные настройки (DBGrid1) ---
    // Ensure the grid is linked to the active dataset
    DBGrid1.DataSource := dmMain.dsSettings; // Ensure this is the correct DataSource name!

    // Wait for the fields to be created
    if dmMain.qrySettings.FieldCount > 0 then
    begin
        // Clear existing columns and recreate them based on the active dataset
        DBGrid1.Columns.Clear;

        // Now it's safe to add and configure columns
        with DBGrid1.Columns.Add do begin
            FieldName := 'key_name';
            Title.Caption := 'Параметр';
            ReadOnly := True;
            Width := 180;
        end;

        with DBGrid1.Columns.Add do begin
            FieldName := 'key_value';
            Title.Caption := 'Значение (%)';
            Width := 120;
        end;
    end;

    // --- Настройка вкладки Больничные (DBGrid2) ---
    DBGrid2.DataSource := dmMain.dsSickLeaveRates; // Ensure this is the correct DataSource name!

    if dmMain.qrySickLeaveRates.FieldCount > 0 then
    begin
        DBGrid2.Columns.Clear;

        with DBGrid2.Columns.Add do begin
            FieldName := 'years_worked'; // Replace with actual field name
            Title.Caption := 'Стаж работы';
            Width := 180;
        end;

        with DBGrid2.Columns.Add do begin
            FieldName := 'payout_percentage'; // Replace with actual field name
            Title.Caption := '% Выплаты';
            Width := 120;
        end;
    end;

    // Set up the history grid
    SetupHistoryGrid;
  end;
end;

procedure TframeSettings.SetupHistoryGrid;
begin
  // Подключаем сетку к источнику данных
  DBGridHistory.DataSource := dmMain.dsHistory;

  // Ensure the dataset has fields before trying to configure columns
  if dmMain.qryHistory.FieldCount > 0 then
  begin
    DBGridHistory.Columns.Clear;

    // 0: Technical ID (Hidden) - We don't even need to add it if we want it hidden
    // but if you must add it to hide it later:
    with DBGridHistory.Columns.Add do begin
        FieldName := 'id'; // Or whatever your technical ID field is
        Visible := False;
    end;

    // 1: Employee
    with DBGridHistory.Columns.Add do begin
        FieldName := 'employee_name_lookup'; // Use your actual field name
        Title.Caption := 'Сотрудник';
        Width := 200;
    end;

    // 2: Date
    with DBGridHistory.Columns.Add do begin
        FieldName := 'record_date'; // Use your actual field name
        Title.Caption := 'Дата (01.ММ.ГГГГ)';
        Width := 100;
    end;

    // 3: Income Amount
    with DBGridHistory.Columns.Add do begin
        FieldName := 'income_amount'; // Use your actual field name
        Title.Caption := 'Сумма дохода';
        Width := 120;
    end;
  end;
end;

procedure TframeSettings.SetupSettingsGrid;
begin
  // Привязываем DataSource
  DBGrid1.DataSource := dmMain.dsSettings;

  DBGrid1.Columns.Clear;

  // Костяк настройки
  with DBGrid1.Columns.Add do
  begin
    FieldName := 'key_name';
    Title.Caption := 'Название параметра'; // Понятно для кадровика
    // УБРАЛИ ReadOnly := True; чтобы кадровик мог написать "Ночные смены"
    Width := 250;
  end;

  with DBGrid1.Columns.Add do
  begin
    FieldName := 'key_value';
    Title.Caption := 'Значение (%)';
    Width := 120;
  end;
end;

end.

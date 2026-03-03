unit UnitframeSettings;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls, Data.DB,
  Vcl.Grids, Vcl.DBGrids, FireDAC.Comp.DataSet, Vcl.DBCtrls, Vcl.ExtCtrls,
  Vcl.StdCtrls, FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  FireDAC.Stan.Async, FireDAC.DApt, FireDAC.Comp.Client;

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
    // 1. Открываем DataSets
    if not dmMain.qrySettings.Active then dmMain.qrySettings.Open;
    if not dmMain.qryHistory.Active then dmMain.qryHistory.Open;
    if not dmMain.qrySickLeaveRates.Active then dmMain.qrySickLeaveRates.Open;

    // --- Настройка вкладки Глобальные настройки (DBGrid1) ---
    DBGrid1.DataSource := dmMain.dsSettings;

    // БЛОКИРУЕМ ДОБАВЛЕНИЕ И УДАЛЕНИЕ В НАВИГАТОРЕ
    DBNavigator1.DataSource := dmMain.dsSettings;
    // Оставляем только: Первую, Предыдущую, Следующую, Последнюю, Редактировать, Сохранить, Отменить, Обновить
    DBNavigator1.VisibleButtons := [nbFirst, nbPrior, nbNext, nbLast, nbEdit, nbPost, nbCancel, nbRefresh];

    // Ждем создания полей
    if dmMain.qrySettings.FieldCount > 0 then
    begin
        DBGrid1.Columns.Clear;

        // Колонка 1: Название (Заблокирована для редактирования)
        with DBGrid1.Columns.Add do begin
            FieldName := 'display_name';
            Title.Caption := 'Название параметра';
            ReadOnly := True;
            Width := 200;
        end;

        // Колонка 2: Тип операции (Информационная)
        with DBGrid1.Columns.Add do begin
            FieldName := 'calc_type';
            Title.Caption := 'Тип (1=Плюс, 2=Минус)';
            ReadOnly := True;
            Width := 180;
        end;

        // Колонка 3: Значение (МОЖНО РЕДАКТИРОВАТЬ)
        with DBGrid1.Columns.Add do begin
            FieldName := 'key_value';
            Title.Caption := 'Ставка %';
            Width := 80;
        end;

        // Колонка 4: Активность (МОЖНО РЕДАКТИРОВАТЬ: 1 - Вкл, 0 - Выкл)
        with DBGrid1.Columns.Add do begin
            FieldName := 'is_active';
            Title.Caption := 'Активно (1/0)';
            Width := 105;
        end;
    end;

    // --- Настройка вкладки Больничные (DBGrid2) ---
    DBGrid2.DataSource := dmMain.dsSickLeaveRates;

    if dmMain.qrySickLeaveRates.FieldCount > 0 then
    begin
        DBGrid2.Columns.Clear;

        with DBGrid2.Columns.Add do begin
            FieldName := 'years_worked';
            Title.Caption := 'Стаж работы';
            Width := 180;
        end;

        with DBGrid2.Columns.Add do begin
            FieldName := 'payout_percentage';
            Title.Caption := '% Выплаты';
            Width := 120;
        end;
    end;

    // Настройка истории
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

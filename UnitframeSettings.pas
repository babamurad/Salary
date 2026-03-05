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
    procedure DBGrid1DrawColumnCell(Sender: TObject; const Rect: TRect;
      DataCol: Integer; Column: TColumn; State: TGridDrawState);

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

    // --- ПРИВЯЗЫВАЕМ НАШУ ПРОЦЕДУРУ РАСКРАСКИ ---
    DBGrid1.OnDrawColumnCell := DBGrid1DrawColumnCell;

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
            Width := 215;
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
            Title.Caption := 'Ставка/сумма';
            Width := 115;
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

procedure TframeSettings.DBGrid1DrawColumnCell(Sender: TObject;
  const Rect: TRect; DataCol: Integer; Column: TColumn; State: TGridDrawState);
var
  Grid: TDBGrid;
  IsActive, CalcType: Integer;
begin
  Grid := TDBGrid(Sender);
  // Если данных нет, ничего не делаем
  if Grid.DataSource.DataSet.IsEmpty then Exit;
  // Считываем значения ТЕКУЩЕЙ строки
  IsActive := Grid.DataSource.DataSet.FieldByName('is_active').AsInteger;
  CalcType := Grid.DataSource.DataSet.FieldByName('calc_type').AsInteger;
  // --- 1. ПРОВЕРКА АКТИВНОСТИ (Серый фон для отключенных) ---
  if IsActive = 0 then
  begin
    Grid.Canvas.Brush.Color := $00E0E0E0; // Светло-серый фон
    Grid.Canvas.Font.Color := clGray;     // Серый текст
  end
  else
  begin
    // Если строка активна, но НЕ выделена курсором - оставляем белый фон
    if not (gdSelected in State) then
    begin
      Grid.Canvas.Brush.Color := clWindow;
      Grid.Canvas.Font.Color := clWindowText;
    end;
  end;
  // --- 2. РАСКРАСКА ТИПА РАСЧЕТА (Только для активных строк) ---
  if (IsActive = 1) and (Column.FieldName = 'calc_type') then
  begin
    if CalcType = 1 then
      Grid.Canvas.Font.Color := clGreen // Начисление (1) - Зеленый
    else if CalcType = 2 then
      Grid.Canvas.Font.Color := clRed;  // Удержание (2) - Красный
    Grid.Canvas.Font.Style := [fsBold]; // Делаем цифру жирной для красоты
  end;
  // --- 3. СТАНДАРТНОЕ ВЫДЕЛЕНИЕ (Синий фон при клике) ---
  // Чтобы не сломать стандартное выделение строки курсором
  if gdSelected in State then
  begin
    Grid.Canvas.Brush.Color := clHighlight;
    Grid.Canvas.Font.Color := clHighlightText;
  end;
  // Даем команду гриду нарисовать ячейку с нашими новыми цветами!
  Grid.DefaultDrawColumnCell(Rect, DataCol, Column, State);
end;

procedure TframeSettings.SetupHistoryGrid;
begin
  DBGridHistory.DataSource := dmMain.dsHistory;

  if dmMain.qryHistory.FieldCount > 0 then
  begin
    DBGridHistory.Columns.Clear;

    // Колонка ФИО (это будет наш выпадающий список)
    with DBGridHistory.Columns.Add do begin
      FieldName := 'fio';
      Title.Caption := 'Ф.И.О. сотрудника';
      Width := 250;
    end;

    // Колонка Дата
    with DBGridHistory.Columns.Add do begin
      FieldName := 'period_date';
      Title.Caption := 'Период (01.ММ.ГГГГ)';
      Width := 130;
    end;

    // Колонка Сумма
    with DBGridHistory.Columns.Add do begin
      FieldName := 'amount';
      Title.Caption := 'Сумма дохода';
      Width := 150;
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
  // Красивое форматирование для колонки со значениями (добавляем %)
  if dmMain.qrySettings.FindField('key_value') <> nil then
    TFloatField(dmMain.qrySettings.FieldByName('key_value')).DisplayFormat := '0.00 %';
end;

end.

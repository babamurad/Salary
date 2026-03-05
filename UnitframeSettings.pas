unit UnitframeSettings;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls, Data.DB,
  Vcl.Grids, Vcl.DBGrids, FireDAC.Comp.DataSet, Vcl.DBCtrls, Vcl.ExtCtrls,
  Vcl.StdCtrls, FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  System.DateUtils, System.UITypes,
  FireDAC.Stan.Async, FireDAC.DApt, FireDAC.Comp.Client;

type
  TframeSettings = class(TFrame)
    PageControl1: TPageControl;
    tsGeneral: TTabSheet;
    tsSickLeave: TTabSheet;
    DBGrid1: TDBGrid;
    DBGrid2: TDBGrid;
    TabSheet1: TTabSheet;
    DBGridCompany: TDBGrid;
    Panel2: TPanel;
    DBNavigator1: TDBNavigator;
    procedure SetupSettingsGrid;
    procedure DBGrid1DrawColumnCell(Sender: TObject; const Rect: TRect;
      DataCol: Integer; Column: TColumn; State: TGridDrawState);
    procedure btnAutoGenerateClick(Sender: TObject);

  private
  procedure SetupCompanyInfoGrid;
  procedure DBGrid1CellClick(Column: TColumn);
  public
    constructor Create(AOwner: TComponent); override;
  end;

implementation

{$R *.dfm}

uses UnitdmMain;



procedure TframeSettings.btnAutoGenerateClick(Sender: TObject);
var
  i: Integer;
  EmpID: Integer;
  BaseSalary: Double;
  TargetDate: TDate;
  QryExec: TFDQuery;
begin
  if MessageDlg('Сгенерировать историю оплат за последние 12 месяцев на основе текущих окладов?'+#13#10+
                'Внимание: существующие записи за эти месяцы не будут перезаписаны.',
                mtConfirmation, [mbYes, mbNo], 0) <> mrYes then
    Exit;

  // Создаем временный запрос для выполнения проверок и вставок
  QryExec := TFDQuery.Create(nil);
  try
    QryExec.Connection := dmMain.conn; // Укажите ваше соединение!

    dmMain.qryEmployees.DisableControls;
    try
      // Пробегаемся по всем активным сотрудникам
      if not dmMain.qryEmployees.Active then dmMain.qryEmployees.Open;
      dmMain.qryEmployees.First;

      while not dmMain.qryEmployees.Eof do
      begin
        EmpID := dmMain.qryEmployees.FieldByName('id').AsInteger;
        BaseSalary := dmMain.qryEmployees.FieldByName('base_salary').AsFloat;

        // Идем на 12 месяцев назад от текущей даты
        for i := 1 to 12 do
        begin
          // Получаем 1-е число нужного месяца в прошлом
          TargetDate := StartOfTheMonth(IncMonth(Date, -i));

          // 1. Проверяем, есть ли уже запись за этот месяц для этого сотрудника
          QryExec.Close;
          QryExec.SQL.Text := 'SELECT id FROM salary_history WHERE emp_id = :e_id AND period_date = :p_date';
          QryExec.ParamByName('e_id').AsInteger := EmpID;
          QryExec.ParamByName('p_date').AsDate := TargetDate;
          QryExec.Open;

          // 2. Если записи нет - вставляем ее с текущим окладом
          if QryExec.IsEmpty then
          begin
            QryExec.Close;
            QryExec.SQL.Text := 'INSERT INTO salary_history (emp_id, period_date, amount) VALUES (:e_id, :p_date, :amt)';
            QryExec.ParamByName('e_id').AsInteger := EmpID;
            QryExec.ParamByName('p_date').AsDate := TargetDate;
            QryExec.ParamByName('amt').AsFloat := BaseSalary;
            QryExec.ExecSQL;
          end;
        end;

        dmMain.qryEmployees.Next;
      end;
    finally
      dmMain.qryEmployees.EnableControls;
    end;

    // Обновляем нашу таблицу на экране, чтобы увидеть результат
    dmMain.qryHistory.Close;
    dmMain.qryHistory.Open;
    ShowMessage('Автогенерация успешно завершена!');

  finally
    QryExec.Free;
  end;
end;

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

            // Колонка 1: Название
            with DBGrid1.Columns.Add do begin
                FieldName := 'display_name';
                Title.Caption := 'Название параметра';
                ReadOnly := True;
                Width := 220;
            end;

            // Колонка 2: Тип операции
            with DBGrid1.Columns.Add do begin
                FieldName := 'calc_type';
                Title.Caption := 'Тип операции';
                ReadOnly := True;
                Width := 130;
            end;

            // Колонка 3: Значение
            with DBGrid1.Columns.Add do begin
                FieldName := 'key_value';
                Title.Caption := 'Ставка (%) / Сумма';
                Width := 140;
            end;

            // Колонка 4: Активность (Чекбокс)
            with DBGrid1.Columns.Add do begin
                FieldName := 'is_active';
                Title.Caption := 'Активность';
                Width := 90;
                ReadOnly := True; // Запрещаем ввод текста, переключать будем кликом!
            end;
        end;

        // ПРИВЯЗЫВАЕМ СОБЫТИЯ ОТРИСОВКИ И КЛИКА:
        DBGrid1.OnDrawColumnCell := DBGrid1DrawColumnCell;
        DBGrid1.OnCellClick := DBGrid1CellClick;

    // --- Настройка вкладки Больничные (DBGrid2) ---
    DBGrid2.DataSource := dmMain.dsSickLeaveRates;

    if dmMain.qrySickLeaveRates.FieldCount > 0 then
    begin
        DBGrid2.Columns.Clear;

        with DBGrid2.Columns.Add do begin
            FieldName := 'min_years'; // Правильное имя из БД
            Title.Caption := 'Минимальный стаж (лет)';
            Width := 180;
        end;

        with DBGrid2.Columns.Add do begin
            FieldName := 'percent'; // Правильное имя из БД
            Title.Caption := '% Выплаты';
            Width := 120;
        end;

        // Сразу добавим красивое форматирование для процентов
        if dmMain.qrySickLeaveRates.FindField('percent') <> nil then
          TFloatField(dmMain.qrySickLeaveRates.FieldByName('percent')).DisplayFormat := '0 %';
    end;

    // Настройка истории
    SetupCompanyInfoGrid;
  end;
end;

procedure TframeSettings.DBGrid1CellClick(Column: TColumn);
begin
  // Если кликнули именно по колонке с чекбоксом
  if Column.FieldName = 'is_active' then
  begin
    if dmMain.qrySettings.IsEmpty then Exit;

    // Переводим базу в режим редактирования и инвертируем значение (1 на 0, 0 на 1)
    dmMain.qrySettings.Edit;
    if dmMain.qrySettings.FieldByName('is_active').AsInteger = 1 then
      dmMain.qrySettings.FieldByName('is_active').AsInteger := 0
    else
      dmMain.qrySettings.FieldByName('is_active').AsInteger := 1;

    dmMain.qrySettings.Post; // Сохраняем в базу
  end;
end;

procedure TframeSettings.DBGrid1DrawColumnCell(Sender: TObject;
  const Rect: TRect; DataCol: Integer; Column: TColumn; State: TGridDrawState);
var
  Grid: TDBGrid;
  IsActive, CalcType: Integer;
  TextToDraw: string;
  CheckRect: TRect;
  DrawState: Integer;
begin
  Grid := TDBGrid(Sender);
  if Grid.DataSource.DataSet.IsEmpty then Exit;

  IsActive := Grid.DataSource.DataSet.FieldByName('is_active').AsInteger;
  CalcType := Grid.DataSource.DataSet.FieldByName('calc_type').AsInteger;

  // --- 1. ПРОВЕРКА АКТИВНОСТИ (Цвет фона) ---
  if IsActive = 0 then
  begin
    Grid.Canvas.Brush.Color := $00F5F5F5; // Светло-серый
    Grid.Canvas.Font.Color := clGray;
  end
  else
  begin
    if gdSelected in State then
    begin
      Grid.Canvas.Brush.Color := clHighlight;
      Grid.Canvas.Font.Color := clHighlightText;
    end
    else
    begin
      Grid.Canvas.Brush.Color := clWindow;
      Grid.Canvas.Font.Color := clWindowText;
    end;
  end;

  // Обязательно заливаем фон ячейки перед рисованием!
  Grid.Canvas.FillRect(Rect);

  // --- 2. РАСКРАСКА ТИПА РАСЧЕТА ---
  if Column.FieldName = 'calc_type' then
  begin
    if CalcType = 1 then
    begin
      TextToDraw := 'Начисление (+)';
      if IsActive = 1 then Grid.Canvas.Font.Color := clGreen;
    end
    else if CalcType = 2 then
    begin
      TextToDraw := 'Удержание (-)';
      if IsActive = 1 then Grid.Canvas.Font.Color := clRed;
    end
    else
      TextToDraw := IntToStr(CalcType);

    Grid.Canvas.Font.Style := [fsBold];
    // Выводим текст с небольшим отступом
    Grid.Canvas.TextOut(Rect.Left + 6, Rect.Top + 2, TextToDraw);
  end

  // --- 3. ОТРИСОВКА ЧЕКБОКСА (Активность) ---
  else if Column.FieldName = 'is_active' then
  begin
    // Вычисляем центр ячейки для квадратика чекбокса (14x14 пикселей)
    CheckRect.Left := Rect.Left + (Rect.Width - 14) div 2;
    CheckRect.Top := Rect.Top + (Rect.Height - 14) div 2;
    CheckRect.Right := CheckRect.Left + 14;
    CheckRect.Bottom := CheckRect.Top + 14;

    DrawState := DFCS_BUTTONCHECK;
    if IsActive = 1 then
      DrawState := DrawState or DFCS_CHECKED; // Ставим галочку

    // Вызываем системную функцию Windows для отрисовки элемента управления
    DrawFrameControl(Grid.Canvas.Handle, CheckRect, DFC_BUTTON, DrawState);
  end

  // --- 4. СТАНДАРТНЫЙ ВЫВОД ДЛЯ ОСТАЛЬНЫХ КОЛОНОК ---
  else
  begin
    Grid.DefaultDrawColumnCell(Rect, DataCol, Column, State);
  end;
end;

procedure TframeSettings.SetupCompanyInfoGrid;
begin
  // Привязываем DataSource (на всякий случай, если не сделали в инспекторе)
  // Предварительно положите DBGridCompany на вкладку Реквизиты
  DBGridCompany.DataSource := dmMain.dsCompanyInfo;

  if not dmMain.qryCompanyInfo.Active then
    dmMain.qryCompanyInfo.Open;

  if dmMain.qryCompanyInfo.FieldCount > 0 then
  begin
    DBGridCompany.Columns.Clear;

    // Колонка 1: Красивое название (Только для чтения!)
    with DBGridCompany.Columns.Add do begin
      FieldName := 'display_name';
      Title.Caption := 'Реквизит';
      Width := 250;
      ReadOnly := True;
      Color := $00F0F0F0; // Слегка серый фон, чтобы визуально отделить
    end;

    // Колонка 2: Само значение (Тут бухгалтер вводит данные)
    with DBGridCompany.Columns.Add do begin
      FieldName := 'key_value';
      Title.Caption := 'Значение';
      Width := 400;
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

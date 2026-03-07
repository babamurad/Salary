unit UnitframeTimesheet;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Data.DB, Vcl.Grids,
  System.DateUtils,
  Vcl.DBGrids, Vcl.StdCtrls, Vcl.ExtCtrls, FireDAC.Stan.Intf,
  FireDAC.Stan.Option, FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS,
  FireDAC.Phys.Intf, FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt,
  FireDAC.Comp.DataSet, FireDAC.Comp.Client, Vcl.DBCtrls;

type
  TframeTimesheet = class(TFrame)
    Panel1: TPanel;
    cbYear: TComboBox;
    cbMonth: TComboBox;
    cmbDept: TComboBox;
    btnLoad: TButton;
    btnAutoFill: TButton;
    DBGridTimesheet: TDBGrid;
    Panel2: TPanel;
    btnSave: TButton;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    lblCurrentEmp: TLabel;
    DBGridNames: TDBGrid;
    Splitter1: TSplitter;
    procedure DBGridTimesheetDrawColumnCell(Sender: TObject; const Rect: TRect;
      DataCol: Integer; Column: TColumn; State: TGridDrawState);
    procedure btnLoadClick(Sender: TObject);
    procedure btnAutoFillClick(Sender: TObject);
    procedure btnSaveClick(Sender: TObject);
  private
    FCurYear: Integer;   // Текущий год табеля на экране
    FCurMonth: Integer;  // Текущий месяц табеля на экране
    FCurrentEmpID: Integer;
    procedure ReadPeriodFromUI;
    procedure LoadDepartments;
    procedure memTimesheetBeforePost(DataSet: TDataSet);
    procedure memTimesheetAfterScroll(DataSet: TDataSet);
  public
    procedure PrepareMemTable(AYear, AMonth: Integer);
    procedure FillEmployeesList;
    constructor Create(AOwner: TComponent); override;
  end;

implementation

{$R *.dfm}

uses UnitdmMain;

{ TframeTimesheet }

constructor TframeTimesheet.Create(AOwner: TComponent);
var
  i, CurrentYear: Integer;
begin
  inherited;

  FCurYear := YearOf(Now);
  FCurMonth := MonthOf(Now);

  cbMonth.ItemIndex := FCurMonth - 1;

  cbYear.Items.Clear;
  CurrentYear := FCurYear;
  for i := CurrentYear - 1 to CurrentYear + 2 do
    cbYear.Items.Add(IntToStr(i));
  cbYear.ItemIndex := 1;

  LoadDepartments;

  // --- МАГИЯ АВТОЗАГРУЗКИ ---
  // Привязываем пересчет ко всем выпадающим спискам.
  // Теперь, как только вы поменяете месяц, год или отдел — табель сам мгновенно перерисуется!
  cbMonth.OnChange := btnLoadClick;
  cbYear.OnChange := btnLoadClick;
  cmbDept.OnChange := btnLoadClick;

  // Имитируем нажатие кнопки "Сформировать табель" сразу при открытии вкладки
  btnLoadClick(nil);
end;

procedure TframeTimesheet.LoadDepartments;
begin
  if not Assigned(dmMain) then Exit;

  cmbDept.Items.Clear;
  cmbDept.Items.AddObject('--- Все отделы ---', TObject(0));

  if not dmMain.qryDepts.Active then dmMain.qryDepts.Open;

  dmMain.qryDepts.First;
  while not dmMain.qryDepts.Eof do
  begin
    cmbDept.Items.AddObject(dmMain.qryDepts.FieldByName('dept_name').AsString,
                            TObject(dmMain.qryDepts.FieldByName('id').AsInteger));
    dmMain.qryDepts.Next;
  end;

  cmbDept.ItemIndex := 0;
end;

procedure TframeTimesheet.memTimesheetAfterScroll(DataSet: TDataSet);
begin
  if DataSet.Active and not DataSet.IsEmpty then
  begin
    // Запоминаем текущего сотрудника
    lblCurrentEmp.Caption := DataSet.FieldByName('fio').AsString;
    FCurrentEmpID := DataSet.FieldByName('emp_id').AsInteger;
  end
  else
  begin
    lblCurrentEmp.Caption := '---';
    FCurrentEmpID := -1;
  end;

  // --- ЗАСТАВЛЯЕМ ПЕРЕРИСОВАТЬСЯ ОБА ГРИДА! ---
  if Assigned(DBGridTimesheet) then
    DBGridTimesheet.Invalidate; // Обновляем правый

  if Assigned(DBGridNames) then
    DBGridNames.Invalidate;     // Обновляем левый (ВОТ ЭТУ СТРОЧКУ МЫ ЗАБЫЛИ!)
end;

procedure TframeTimesheet.memTimesheetBeforePost(DataSet: TDataSet);
var
  i, DaysCount: Integer;
  CellVal: string;
  Hrs: Double;
  WorkDays, VacDays, SickDays, Weekends: Integer;
  TotalHrs, NightHrs, HolHrs, PayHrs: Double;
begin
  WorkDays := 0; VacDays := 0; SickDays := 0; Weekends := 0;
  TotalHrs := 0; NightHrs := 0; HolHrs := 0; PayHrs := 0;

  DaysCount := DaysInAMonth(FCurYear, FCurMonth);
  for i := 1 to DaysCount do
  begin
    CellVal := Trim(DataSet.FieldByName('day_' + IntToStr(i)).AsString);
    if CellVal = '' then Continue;
    CellVal := UpperCase(CellVal);

    Hrs := StrToFloatDef(StringReplace(CellVal, ',', '.', [rfReplaceAll]), -1);

    if Hrs >= 0 then
    begin
      Inc(WorkDays);
      TotalHrs := TotalHrs + Hrs;
      PayHrs := PayHrs + Hrs;
    end
    else
    begin
      if CellVal = 'Б' then Inc(SickDays)
      else if CellVal = 'О' then Inc(VacDays)
      else if (CellVal = 'В') or (CellVal = 'П') then Inc(Weekends)
      else if CellVal = 'Я' then
      begin
        Inc(WorkDays);
        TotalHrs := TotalHrs + 8;
        PayHrs := PayHrs + 8;
      end
      else if Pos('Н', CellVal) = 1 then
      begin
        Hrs := StrToFloatDef(StringReplace(Copy(CellVal, 2, Length(CellVal)), ',', '.', [rfReplaceAll]), 0);
        NightHrs := NightHrs + Hrs;
        TotalHrs := TotalHrs + Hrs;
        PayHrs := PayHrs + Hrs;
        if Hrs > 0 then Inc(WorkDays);
      end;
    end;
  end;

  // --- МАГИЯ: СНИМАЕМ БЛОКИРОВКУ ДЛЯ ПРОГРАММЫ ---
  DataSet.FieldByName('total_work_days').ReadOnly := False;
  DataSet.FieldByName('total_hours').ReadOnly := False;
  DataSet.FieldByName('sick_days').ReadOnly := False;
  DataSet.FieldByName('vacation_days').ReadOnly := False;
  DataSet.FieldByName('weekend_days').ReadOnly := False;
  DataSet.FieldByName('night_hours').ReadOnly := False;
  DataSet.FieldByName('holiday_hours').ReadOnly := False;
  DataSet.FieldByName('payable_hours').ReadOnly := False;

  // ЗАПИСЫВАЕМ ИТОГИ
  DataSet.FieldByName('total_work_days').AsInteger := WorkDays;
  DataSet.FieldByName('total_hours').AsFloat := TotalHrs;
  DataSet.FieldByName('sick_days').AsInteger := SickDays;
  DataSet.FieldByName('vacation_days').AsInteger := VacDays;
  DataSet.FieldByName('weekend_days').AsInteger := Weekends;
  DataSet.FieldByName('night_hours').AsFloat := NightHrs;
  DataSet.FieldByName('holiday_hours').AsFloat := 0; // Или HolHrs, если добавите логику
  DataSet.FieldByName('payable_hours').AsFloat := PayHrs;

  // --- МАГИЯ: ВЕШАЕМ БЛОКИРОВКУ ОБРАТНО ---
  DataSet.FieldByName('total_work_days').ReadOnly := True;
  DataSet.FieldByName('total_hours').ReadOnly := True;
  DataSet.FieldByName('sick_days').ReadOnly := True;
  DataSet.FieldByName('vacation_days').ReadOnly := True;
  DataSet.FieldByName('weekend_days').ReadOnly := True;
  DataSet.FieldByName('night_hours').ReadOnly := True;
  DataSet.FieldByName('holiday_hours').ReadOnly := True;
  DataSet.FieldByName('payable_hours').ReadOnly := True;
end;

procedure TframeTimesheet.ReadPeriodFromUI;
begin
  FCurYear := StrToIntDef(cbYear.Text, YearOf(Now));
  FCurMonth := cbMonth.ItemIndex + 1;
  if FCurMonth = 0 then FCurMonth := MonthOfTheYear(Now);
end;

procedure TframeTimesheet.btnLoadClick(Sender: TObject);
begin
  ReadPeriodFromUI; // 1. Читаем и ЗАПОМИНАЕМ выбор пользователя в FCurYear/FCurMonth

  // 2. Создаем сетку, передавая наши глобальные переменные
  PrepareMemTable(FCurYear, FCurMonth);

  // 3. Заполняем её сотрудниками
  FillEmployeesList;
end;

procedure TframeTimesheet.PrepareMemTable(AYear, AMonth: Integer);
var
  i, DaysCount: Integer;
begin
  if not Assigned(dmMain) then Exit;

  // Отключаем оба грида на время перестройки
  DBGridNames.DataSource := nil;
  DBGridTimesheet.DataSource := nil;

  with dmMain.memTimesheet do
  begin
    Active := False;
    BeforePost := nil;
    Fields.Clear;
    FieldDefs.Clear;

    FieldDefs.Add('emp_id', ftInteger);
    FieldDefs.Add('fio', ftString, 100);

    DaysCount := DaysInAMonth(AYear, AMonth);
    for i := 1 to DaysCount do
      FieldDefs.Add('day_' + IntToStr(i), ftString, 5);

    FieldDefs.Add('total_work_days', ftInteger);
    FieldDefs.Add('total_hours', ftFloat);
    FieldDefs.Add('sick_days', ftInteger);
    FieldDefs.Add('vacation_days', ftInteger);
    FieldDefs.Add('weekend_days', ftInteger);
    FieldDefs.Add('night_hours', ftFloat);
    FieldDefs.Add('holiday_hours', ftFloat);
    FieldDefs.Add('payable_hours', ftFloat);

    CreateDataSet;
    BeforePost := memTimesheetBeforePost;
    AfterScroll := memTimesheetAfterScroll;

    // Подключаем базу обратно к ОБОИМ гридам
    DBGridNames.DataSource := dmMain.dsTimesheet;
    DBGridTimesheet.DataSource := dmMain.dsTimesheet;

    // --- 1. НАСТРАИВАЕМ ЛЕВЫЙ ГРИД (ТОЛЬКО ФИО) ---
    DBGridNames.Columns.Clear;
    with DBGridNames.Columns.Add do
    begin
      FieldName := 'fio';
      Title.Caption := 'Сотрудник';
      Width := 220;
    end;

    // --- 2. НАСТРАИВАЕМ ПРАВЫЙ ГРИД (ДНИ И ИТОГИ) ---
    DBGridTimesheet.Columns.Clear;
    for i := 1 to DaysCount do
    begin
      with DBGridTimesheet.Columns.Add do
      begin
        FieldName := 'day_' + IntToStr(i);
        Title.Caption := IntToStr(i);
        Title.Alignment := taCenter;
        Alignment := taCenter;
        Width := 25; // Делаем дни компактными
      end;
    end;

    // Итоги в правом гриде
    with DBGridTimesheet.Columns.Add do begin FieldName := 'total_work_days'; Title.Caption := 'Отр. дни'; Width := 65; end;
    with DBGridTimesheet.Columns.Add do begin FieldName := 'total_hours'; Title.Caption := 'Часы'; Width := 50; end;
    with DBGridTimesheet.Columns.Add do begin FieldName := 'sick_days'; Title.Caption := 'Больн.(Б)'; Width := 65; end;
    with DBGridTimesheet.Columns.Add do begin FieldName := 'vacation_days'; Title.Caption := 'Отпуск(О)'; Width := 65; end;
    with DBGridTimesheet.Columns.Add do begin FieldName := 'weekend_days'; Title.Caption := 'Вых.(В)'; Width := 50; end;
    with DBGridTimesheet.Columns.Add do begin FieldName := 'night_hours'; Title.Caption := 'Ночн.(Н)'; Width := 60; end;
    with DBGridTimesheet.Columns.Add do begin FieldName := 'payable_hours'; Title.Caption := 'К оплате'; Width := 65; end;

    // Форматы цифр
    TFloatField(FieldByName('total_hours')).DisplayFormat := '0.##';
    TFloatField(FieldByName('night_hours')).DisplayFormat := '0.##';
    TFloatField(FieldByName('holiday_hours')).DisplayFormat := '0.##';
    TFloatField(FieldByName('payable_hours')).DisplayFormat := '0.##';

    // ВЕШАЕМ НАДЕЖНЫЙ ЗАМОК НА УРОВНЕ ДАННЫХ
    FieldByName('total_work_days').ReadOnly := True;
    FieldByName('total_hours').ReadOnly := True;
    FieldByName('sick_days').ReadOnly := True;
    FieldByName('vacation_days').ReadOnly := True;
    FieldByName('weekend_days').ReadOnly := True;
    FieldByName('night_hours').ReadOnly := True;
    FieldByName('holiday_hours').ReadOnly := True;
    FieldByName('payable_hours').ReadOnly := True;
  end;
end;

procedure TframeTimesheet.FillEmployeesList;
var
  DeptID, DayNum, EmpID: Integer;
  LoadQuery: TFDQuery;
  CellValue: string;
begin
  if not Assigned(dmMain) then Exit;

  DeptID := 0;
  if cmbDept.ItemIndex <> -1 then
    DeptID := Integer(cmbDept.Items.Objects[cmbDept.ItemIndex]);

  if not dmMain.qryEmployees.Active then dmMain.qryEmployees.Open;

  dmMain.qryEmployees.Filtered := False;
  if DeptID > 0 then
  begin
    dmMain.qryEmployees.Filter := 'dept_id = ' + IntToStr(DeptID);
    dmMain.qryEmployees.Filtered := True;
  end;

  LoadQuery := TFDQuery.Create(nil);
  dmMain.memTimesheet.DisableControls;
  try
    LoadQuery.Connection := dmMain.conn;
    LoadQuery.SQL.Text := 'SELECT strftime(''%d'', work_date) as dday, hours_worked, status_code ' +
                          'FROM timesheet WHERE emp_id = :emp_id AND strftime(''%Y-%m'', work_date) = :ym';

    dmMain.memTimesheet.FieldByName('fio').ReadOnly := False;
    dmMain.qryEmployees.First;

    if dmMain.qryEmployees.IsEmpty then
    begin
      ShowMessage('Для выбранного отдела нет сотрудников!');
      Exit;
    end;

    while not dmMain.qryEmployees.Eof do
    begin
      if (dmMain.qryEmployees.FieldByName('status').AsInteger = 1) or
         (dmMain.qryEmployees.FieldByName('status').IsNull) then
      begin
        EmpID := dmMain.qryEmployees.FieldByName('id').AsInteger;

        dmMain.memTimesheet.Append;
        dmMain.memTimesheet.FieldByName('emp_id').AsInteger := EmpID;
        dmMain.memTimesheet.FieldByName('fio').AsString := dmMain.qryEmployees.FieldByName('fio').AsString;

        LoadQuery.Close;
        LoadQuery.ParamByName('emp_id').AsInteger := EmpID;
        // Используем наши глобальные FCurYear и FCurMonth!
        LoadQuery.ParamByName('ym').AsString := Format('%.4d-%.2d', [FCurYear, FCurMonth]);
        LoadQuery.Open;

        while not LoadQuery.Eof do
        begin
          DayNum := StrToIntDef(LoadQuery.FieldByName('dday').AsString, 0);

          if DayNum > 0 then
          begin
            if LoadQuery.FieldByName('hours_worked').AsFloat > 0 then
              CellValue := FloatToStr(LoadQuery.FieldByName('hours_worked').AsFloat)
            else
              CellValue := LoadQuery.FieldByName('status_code').AsString;

            dmMain.memTimesheet.FieldByName('day_' + IntToStr(DayNum)).AsString := CellValue;
          end;
          LoadQuery.Next;
        end;

        dmMain.memTimesheet.Post;
      end;
      dmMain.qryEmployees.Next;
    end;

    dmMain.memTimesheet.First;

    memTimesheetAfterScroll(dmMain.memTimesheet);

  finally
    LoadQuery.Free;
    dmMain.memTimesheet.FieldByName('fio').ReadOnly := True;
    dmMain.memTimesheet.EnableControls;
    dmMain.qryEmployees.Filtered := False;
  end;
end;

procedure TframeTimesheet.btnAutoFillClick(Sender: TObject);
var
  i, DaysCount, EmpID: Integer;
  CurrentDate, FirstDay, LastDay: TDateTime;
  QryVac, QrySick: TFDQuery;
  IsVacation, IsSick: Boolean;
begin
  if not Assigned(dmMain) or not dmMain.memTimesheet.Active then Exit;
  if dmMain.memTimesheet.IsEmpty then Exit;

  DaysCount := DaysInAMonth(FCurYear, FCurMonth);
  // Определяем первый и последний день выбранного месяца
  FirstDay := EncodeDate(FCurYear, FCurMonth, 1);
  LastDay := EncodeDate(FCurYear, FCurMonth, DaysCount);

  QryVac := TFDQuery.Create(nil);
  QrySick := TFDQuery.Create(nil);
  try
    QryVac.Connection := dmMain.conn;
    // Запрос: ищем любые отпуска, которые пересекаются с текущим месяцем
    QryVac.SQL.Text := 'SELECT start_date, end_date FROM vacation_journal ' +
                       'WHERE emp_id = :emp AND start_date <= :end_dt AND end_date >= :start_dt';

    QrySick.Connection := dmMain.conn;
    // Запрос: ищем любые больничные, которые пересекаются с текущим месяцем
    QrySick.SQL.Text := 'SELECT start_date, end_date FROM sick_leave_journal ' +
                        'WHERE emp_id = :emp AND start_date <= :end_dt AND end_date >= :start_dt';

    dmMain.memTimesheet.DisableControls;
    try
      dmMain.memTimesheet.First;

      while not dmMain.memTimesheet.Eof do
      begin
        EmpID := dmMain.memTimesheet.FieldByName('emp_id').AsInteger;

        // 1. Загружаем отпуска сотрудника
        QryVac.Close;
        QryVac.ParamByName('emp').AsInteger := EmpID;
        QryVac.ParamByName('start_dt').AsDate := FirstDay;
        QryVac.ParamByName('end_dt').AsDate := LastDay;
        QryVac.Open;

        // 2. Загружаем больничные сотрудника
        QrySick.Close;
        QrySick.ParamByName('emp').AsInteger := EmpID;
        QrySick.ParamByName('start_dt').AsDate := FirstDay;
        QrySick.ParamByName('end_dt').AsDate := LastDay;
        QrySick.Open;

        dmMain.memTimesheet.Edit;

        // 3. Пробегаемся по каждому дню месяца
        for i := 1 to DaysCount do
        begin
          CurrentDate := EncodeDate(FCurYear, FCurMonth, i);
          IsVacation := False;
          IsSick := False;

          // Проверяем, попадает ли день на больничный
          QrySick.First;
          while not QrySick.Eof do
          begin
            if (CurrentDate >= QrySick.FieldByName('start_date').AsDateTime) and
               (CurrentDate <= QrySick.FieldByName('end_date').AsDateTime) then
            begin
              IsSick := True;
              Break;
            end;
            QrySick.Next;
          end;

          // Проверяем, попадает ли день на отпуск (если он не болел)
          if not IsSick then
          begin
            QryVac.First;
            while not QryVac.Eof do
            begin
              if (CurrentDate >= QryVac.FieldByName('start_date').AsDateTime) and
                 (CurrentDate <= QryVac.FieldByName('end_date').AsDateTime) then
              begin
                IsVacation := True;
                Break;
              end;
              QryVac.Next;
            end;
          end;

          // --- ПРОСТАВЛЯЕМ ЗНАЧЕНИЯ ---
          if IsSick then
            dmMain.memTimesheet.FieldByName('day_' + IntToStr(i)).AsString := 'Б'
          else if IsVacation then
            dmMain.memTimesheet.FieldByName('day_' + IntToStr(i)).AsString := 'О'
          else if DayOfTheWeek(CurrentDate) in [6, 7] then
            dmMain.memTimesheet.FieldByName('day_' + IntToStr(i)).AsString := 'В'
          else
            dmMain.memTimesheet.FieldByName('day_' + IntToStr(i)).AsString := '8';
        end;

        dmMain.memTimesheet.Post;
        dmMain.memTimesheet.Next;
      end;

      dmMain.memTimesheet.First;
    finally
      dmMain.memTimesheet.EnableControls;
    end;
  finally
    QryVac.Free;
    QrySick.Free;
  end;

  ShowMessage('Табель успешно заполнен! Отпуска и больничные учтены автоматически.');
end;

procedure TframeTimesheet.btnSaveClick(Sender: TObject);
var
  DaysCount, i, EmpID: Integer;
  CurrentDate: TDateTime;
  CellText: string;
  Hours: Double;
  SaveQuery: TFDQuery;
  Bookmark: TBookmark; // Для запоминания строки
begin
  if not Assigned(dmMain) or not dmMain.memTimesheet.Active then Exit;
  if dmMain.memTimesheet.IsEmpty then Exit;

  DaysCount := DaysInAMonth(FCurYear, FCurMonth);
  SaveQuery := TFDQuery.Create(nil);

  // --- ОТКЛЮЧАЕМ ПРОРИСОВКУ ГРИДА (Ускоряет в 10 раз и убирает мигание) ---
  dmMain.memTimesheet.DisableControls;
  Bookmark := dmMain.memTimesheet.GetBookmark; // Запоминаем, где стоял курсор
  try
    SaveQuery.Connection := dmMain.conn;
    dmMain.conn.StartTransaction;
    try
      dmMain.memTimesheet.First;

      while not dmMain.memTimesheet.Eof do
      begin
        EmpID := dmMain.memTimesheet.FieldByName('emp_id').AsInteger;

        SaveQuery.SQL.Text := 'DELETE FROM timesheet WHERE emp_id = :emp_id AND strftime(''%Y-%m'', work_date) = :ym';
        SaveQuery.ParamByName('emp_id').AsInteger := EmpID;
        SaveQuery.ParamByName('ym').AsString := Format('%.4d-%.2d', [FCurYear, FCurMonth]);
        SaveQuery.ExecSQL;

        SaveQuery.SQL.Text := 'INSERT INTO timesheet (emp_id, work_date, hours_worked, status_code) ' +
                              'VALUES (:emp_id, :wdate, :hrs, :code)';

        for i := 1 to DaysCount do
        begin
          CellText := Trim(dmMain.memTimesheet.FieldByName('day_' + IntToStr(i)).AsString);
          if CellText = '' then Continue;

          CurrentDate := EncodeDate(FCurYear, FCurMonth, i);

          SaveQuery.ParamByName('emp_id').AsInteger := EmpID;
          SaveQuery.ParamByName('wdate').AsDate := CurrentDate;

          Hours := StrToFloatDef(CellText, 0);

          if Hours > 0 then
          begin
            SaveQuery.ParamByName('hrs').AsFloat := Hours;
            SaveQuery.ParamByName('code').AsString := 'Я';
          end
          else
          begin
            SaveQuery.ParamByName('hrs').AsFloat := 0;
            SaveQuery.ParamByName('code').AsString := UpperCase(Copy(CellText, 1, 5));
          end;

          SaveQuery.ExecSQL;
        end;

        dmMain.memTimesheet.Next;
      end;

      dmMain.conn.Commit;
      ShowMessage('Табель успешно сохранен в базу данных!');

    except
      on E: Exception do
      begin
        dmMain.conn.Rollback;
        ShowMessage('Ошибка при сохранении табеля: ' + E.Message);
      end;
    end;
  finally
    SaveQuery.Free;

    // --- ВОЗВРАЩАЕМ КУРСОР НА МЕСТО И ВКЛЮЧАЕМ ГРИД ---
    if dmMain.memTimesheet.BookmarkValid(Bookmark) then
    begin
      dmMain.memTimesheet.GotoBookmark(Bookmark);
      dmMain.memTimesheet.FreeBookmark(Bookmark);
    end;
    dmMain.memTimesheet.EnableControls;
  end;
end;

procedure TframeTimesheet.DBGridTimesheetDrawColumnCell(Sender: TObject;
  const Rect: TRect; DataCol: Integer; Column: TColumn; State: TGridDrawState);
var
  DayNum: Integer;
  CurrentDate: TDateTime;
  IsActiveRow: Boolean;
  Grid: TDBGrid;
begin
  Grid := Sender as TDBGrid; // Магия: понимаем, какой грид себя сейчас рисует (левый или правый)
  IsActiveRow := False;

  if (dmMain.memTimesheet.Active) and (dmMain.memTimesheet.FindField('emp_id') <> nil) then
    IsActiveRow := (dmMain.memTimesheet.FieldByName('emp_id').AsInteger = FCurrentEmpID);

  // Базовый цвет активной строки
  if IsActiveRow then
  begin
    Grid.Canvas.Brush.Color := $00FFF0E0;
    Grid.Canvas.Font.Style := [fsBold];
  end;

  // Раскраска выходных дней
  if Pos('day_', Column.FieldName) = 1 then
  begin
    DayNum := StrToIntDef(Copy(Column.FieldName, 5, Length(Column.FieldName)), 1);
    if (FCurYear > 0) and (FCurMonth > 0) then
    begin
      if TryEncodeDate(Word(FCurYear), Word(FCurMonth), Word(DayNum), CurrentDate) then
      begin
        if DayOfTheWeek(CurrentDate) in [6, 7] then
        begin
          if IsActiveRow then Grid.Canvas.Brush.Color := $00FFD2D2
          else Grid.Canvas.Brush.Color := $00E1E1FF;
        end;
      end;
    end;
  end
  // Раскраска итоговых колонок
  else if (Column.FieldName = 'total_work_days') or (Column.FieldName = 'total_hours') or
          (Column.FieldName = 'sick_days') or (Column.FieldName = 'vacation_days') or
          (Column.FieldName = 'weekend_days') or (Column.FieldName = 'payable_hours') or
          (Column.FieldName = 'night_hours') or (Column.FieldName = 'holiday_hours') then
  begin
    if IsActiveRow then Grid.Canvas.Brush.Color := $00C0FFFF
    else Grid.Canvas.Brush.Color := $00E0FFFF;
    Grid.Canvas.Font.Style := [fsBold];
  end;

  // Оставляем стандартное синее выделение
  if gdSelected in State then
  begin
    Grid.Canvas.Brush.Color := clHighlight;
    Grid.Canvas.Font.Color := clHighlightText;
  end;

  Grid.DefaultDrawColumnCell(Rect, DataCol, Column, State);
end;


end.

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

const
  // Часов в одном полном рабочем дне — используется и при пересчёте
  // "дней" в "часы", и как база расчёта в UnitframePayroll.
  HOURS_PER_DAY = 8.0;

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
    FCurYear: Integer;   // Текущий год отчета из формы
    FCurMonth: Integer;  // Текущий месяц отчета из формы
    FCurrentEmpID: Integer;
    procedure ReadPeriodFromUI;
    procedure LoadDepartments;
    procedure memTimesheetAfterScroll(DataSet: TDataSet);
    procedure DaysWorkedChange(Sender: TField);
    function GetWorkingDaysNorm(AYear, AMonth: Integer): Integer;
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

  // --- Автообновление ---
  // Подключаем события на сами компоненты выбора периода.
  // Теперь, при смене года/месяца/отдела, табель перезагружается автоматически!
  cbMonth.OnChange := btnLoadClick;
  cbYear.OnChange := btnLoadClick;
  cmbDept.OnChange := btnLoadClick;

  // Выполняем первую загрузку "Текущего периода" сразу при создании фрейма
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

// Норма рабочих дней за месяц — сперва пытаемся взять из производственного
// календаря (production_calendar), если его для этого периода не заполнили —
// считаем "по старинке" (все дни кроме сб/вс). Та же логика, что и в
// UnitframePayroll.GetWorkingDaysNorm, продублирована здесь, чтобы не тянуть
// зависимость между фреймами ради одной небольшой функции.
function TframeTimesheet.GetWorkingDaysNorm(AYear, AMonth: Integer): Integer;
var
  Q: TFDQuery;
  i, DaysCount: Integer;
  D: TDateTime;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := dmMain.conn;
    Q.SQL.Text := 'SELECT working_days FROM production_calendar WHERE year = :y AND month = :m';
    Q.ParamByName('y').AsInteger := AYear;
    Q.ParamByName('m').AsInteger := AMonth;
    Q.Open;

    if not Q.IsEmpty and (Q.FieldByName('working_days').AsInteger > 0) then
    begin
      Result := Q.FieldByName('working_days').AsInteger;
      Exit;
    end;
  finally
    Q.Free;
  end;

  Result := 0;
  DaysCount := DaysInAMonth(AYear, AMonth);
  for i := 1 to DaysCount do
  begin
    D := EncodeDate(AYear, AMonth, i);
    if not (DayOfTheWeek(D) in [6, 7]) then
      Inc(Result);
  end;
end;

procedure TframeTimesheet.memTimesheetAfterScroll(DataSet: TDataSet);
begin
  if DataSet.Active and not DataSet.IsEmpty then
  begin
    // Показываем текущего сотрудника
    lblCurrentEmp.Caption := DataSet.FieldByName('fio').AsString;
    FCurrentEmpID := DataSet.FieldByName('emp_id').AsInteger;
  end
  else
  begin
    lblCurrentEmp.Caption := '---';
    FCurrentEmpID := -1;
  end;

  // --- Перерисовываем обе таблицы, чтобы подсветить строку ---
  if Assigned(DBGridTimesheet) then
    DBGridTimesheet.Invalidate;

  if Assigned(DBGridNames) then
    DBGridNames.Invalidate;
end;

// При ручном вводе "Отработано дней" сразу пересчитываем "Отработано часов"
// (дни * HOURS_PER_DAY) — так бухгалтеру не нужно вручную умножать.
// Поле "часы" при этом остаётся доступным для правки напрямую — на случай
// неполного дня или другой особой ситуации.
procedure TframeTimesheet.DaysWorkedChange(Sender: TField);
begin
  Sender.DataSet.FieldByName('hours_worked').AsFloat := Sender.AsFloat * HOURS_PER_DAY;
end;

procedure TframeTimesheet.ReadPeriodFromUI;
begin
  FCurYear := StrToIntDef(cbYear.Text, YearOf(Now));
  FCurMonth := cbMonth.ItemIndex + 1;
  if FCurMonth = 0 then FCurMonth := MonthOfTheYear(Now);
end;

procedure TframeTimesheet.btnLoadClick(Sender: TObject);
begin
  ReadPeriodFromUI; // 1. Читаем и сохраняем период редактирования в FCurYear/FCurMonth

  // 2. Готовим сетку, задаём поля структуры документа
  PrepareMemTable(FCurYear, FCurMonth);

  // 3. Заполняем сотрудниками
  FillEmployeesList;
end;

procedure TframeTimesheet.PrepareMemTable(AYear, AMonth: Integer);
begin
  if not Assigned(dmMain) then Exit;

  // Отключаем обе сетки на время перестройки структуры
  DBGridNames.DataSource := nil;
  DBGridTimesheet.DataSource := nil;

  with dmMain.memTimesheet do
  begin
    Active := False;
    Fields.Clear;
    FieldDefs.Clear;

    FieldDefs.Add('emp_id', ftInteger);
    FieldDefs.Add('fio', ftString, 100);
    FieldDefs.Add('norm_days', ftInteger);
    FieldDefs.Add('norm_hours', ftFloat);
    FieldDefs.Add('days_worked', ftFloat);
    FieldDefs.Add('hours_worked', ftFloat);

    CreateDataSet;
    AfterScroll := memTimesheetAfterScroll;

    // Подключаем обе таблицы к общему набору данных
    DBGridNames.DataSource := dmMain.dsTimesheet;
    DBGridTimesheet.DataSource := dmMain.dsTimesheet;

    // --- 1. Левая (замороженная) панель — только ФИО ---
    DBGridNames.Columns.Clear;
    with DBGridNames.Columns.Add do
    begin
      FieldName := 'fio';
      Title.Caption := 'Сотрудник';
      Width := 220;
    end;

    // --- 2. Правая панель — норма (справочно) + факт (для ввода) ---
    DBGridTimesheet.Columns.Clear;
    with DBGridTimesheet.Columns.Add do
    begin
      FieldName := 'norm_days';
      Title.Caption := 'Норма, дн.';
      Title.Alignment := taCenter;
      Alignment := taCenter;
      Width := 80;
    end;
    with DBGridTimesheet.Columns.Add do
    begin
      FieldName := 'norm_hours';
      Title.Caption := 'Норма, ч.';
      Title.Alignment := taCenter;
      Alignment := taCenter;
      Width := 80;
    end;
    with DBGridTimesheet.Columns.Add do
    begin
      FieldName := 'days_worked';
      Title.Caption := 'Отработано, дн.';
      Title.Alignment := taCenter;
      Alignment := taCenter;
      Width := 110;
    end;
    with DBGridTimesheet.Columns.Add do
    begin
      FieldName := 'hours_worked';
      Title.Caption := 'Отработано, ч.';
      Title.Alignment := taCenter;
      Alignment := taCenter;
      Width := 110;
    end;

    TFloatField(FieldByName('norm_hours')).DisplayFormat := '0.##';
    TFloatField(FieldByName('days_worked')).DisplayFormat := '0.##';
    TFloatField(FieldByName('hours_worked')).DisplayFormat := '0.##';

    // Норма — справочная, редактировать её нельзя
    FieldByName('norm_days').ReadOnly := True;
    FieldByName('norm_hours').ReadOnly := True;

    // "Дней" и "Часов" — то, что реально вводит бухгалтер
    FieldByName('days_worked').ReadOnly := False;
    FieldByName('hours_worked').ReadOnly := False;

    // Ввод дней сразу пересчитывает часы (см. DaysWorkedChange)
    FieldByName('days_worked').OnChange := DaysWorkedChange;
  end;
end;

procedure TframeTimesheet.FillEmployeesList;
var
  DeptID, EmpID, NormDays: Integer;
  LoadQuery: TFDQuery;
  TotalHours: Double;
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

  NormDays := GetWorkingDaysNorm(FCurYear, FCurMonth);

  LoadQuery := TFDQuery.Create(nil);
  dmMain.memTimesheet.DisableControls;
  try
    LoadQuery.Connection := dmMain.conn;
    LoadQuery.SQL.Text := 'SELECT SUM(hours_worked) as total_hours ' +
                          'FROM timesheet WHERE emp_id = :emp_id AND strftime(''%Y-%m'', work_date) = :ym';

    dmMain.memTimesheet.FieldByName('fio').ReadOnly := False;
    // На время загрузки отключаем автопересчёт часов из дней —
    // здесь мы, наоборот, вычисляем "дни" из уже сохранённых часов.
    dmMain.memTimesheet.FieldByName('days_worked').OnChange := nil;

    dmMain.qryEmployees.First;

    if dmMain.qryEmployees.IsEmpty then
    begin
      ShowMessage('Нет активных сотрудников для отображения!');
      Exit;
    end;

    while not dmMain.qryEmployees.Eof do
    begin
      if (dmMain.qryEmployees.FieldByName('status').AsInteger = 1) or
         (dmMain.qryEmployees.FieldByName('status').IsNull) then
      begin
        EmpID := dmMain.qryEmployees.FieldByName('id').AsInteger;

        LoadQuery.Close;
        LoadQuery.ParamByName('emp_id').AsInteger := EmpID;
        LoadQuery.ParamByName('ym').AsString := Format('%.4d-%.2d', [FCurYear, FCurMonth]);
        LoadQuery.Open;

        TotalHours := 0;
        if not LoadQuery.FieldByName('total_hours').IsNull then
          TotalHours := LoadQuery.FieldByName('total_hours').AsFloat;

        dmMain.memTimesheet.Append;
        dmMain.memTimesheet.FieldByName('emp_id').AsInteger := EmpID;
        dmMain.memTimesheet.FieldByName('fio').AsString := dmMain.qryEmployees.FieldByName('fio').AsString;
        dmMain.memTimesheet.FieldByName('norm_days').AsInteger := NormDays;
        dmMain.memTimesheet.FieldByName('norm_hours').AsFloat := NormDays * HOURS_PER_DAY;
        dmMain.memTimesheet.FieldByName('hours_worked').AsFloat := TotalHours;
        dmMain.memTimesheet.FieldByName('days_worked').AsFloat := TotalHours / HOURS_PER_DAY;
        dmMain.memTimesheet.Post;
      end;
      dmMain.qryEmployees.Next;
    end;

    dmMain.memTimesheet.First;

    memTimesheetAfterScroll(dmMain.memTimesheet);

  finally
    LoadQuery.Free;
    dmMain.memTimesheet.FieldByName('fio').ReadOnly := True;
    // Возвращаем автопересчёт "дни -> часы" для ручного ввода в гриде
    dmMain.memTimesheet.FieldByName('days_worked').OnChange := DaysWorkedChange;
    dmMain.memTimesheet.EnableControls;
    dmMain.qryEmployees.Filtered := False;
  end;
end;

procedure TframeTimesheet.btnAutoFillClick(Sender: TObject);
var
  i, DaysCount, EmpID, NormDays, WorkDaysCount: Integer;
  CurrentDate, FirstDay, LastDay: TDateTime;
  QryVac, QrySick: TFDQuery;
  IsVacation, IsSick: Boolean;
begin
  if not Assigned(dmMain) or not dmMain.memTimesheet.Active then Exit;
  if dmMain.memTimesheet.IsEmpty then Exit;

  DaysCount := DaysInAMonth(FCurYear, FCurMonth);
  FirstDay := EncodeDate(FCurYear, FCurMonth, 1);
  LastDay := EncodeDate(FCurYear, FCurMonth, DaysCount);

  QryVac := TFDQuery.Create(nil);
  QrySick := TFDQuery.Create(nil);
  try
    QryVac.Connection := dmMain.conn;
    // Ищем: есть ли отпуск, который пересекается с текущим периодом
    QryVac.SQL.Text := 'SELECT start_date, end_date FROM vacation_journal ' +
                       'WHERE emp_id = :emp AND start_date <= :end_dt AND end_date >= :start_dt';

    QrySick.Connection := dmMain.conn;
    // Ищем: есть ли больничный, который пересекается с текущим периодом
    QrySick.SQL.Text := 'SELECT start_date, end_date FROM sick_leave_journal ' +
                        'WHERE emp_id = :emp AND start_date <= :end_dt AND end_date >= :start_dt';

    dmMain.memTimesheet.DisableControls;
    dmMain.memTimesheet.FieldByName('days_worked').OnChange := nil;
    try
      dmMain.memTimesheet.First;

      while not dmMain.memTimesheet.Eof do
      begin
        EmpID := dmMain.memTimesheet.FieldByName('emp_id').AsInteger;
        NormDays := dmMain.memTimesheet.FieldByName('norm_days').AsInteger;

        // 1. Подтягиваем отпуска сотрудника
        QryVac.Close;
        QryVac.ParamByName('emp').AsInteger := EmpID;
        QryVac.ParamByName('start_dt').AsDate := FirstDay;
        QryVac.ParamByName('end_dt').AsDate := LastDay;
        QryVac.Open;

        // 2. Подтягиваем больничные сотрудника
        QrySick.Close;
        QrySick.ParamByName('emp').AsInteger := EmpID;
        QrySick.ParamByName('start_dt').AsDate := FirstDay;
        QrySick.ParamByName('end_dt').AsDate := LastDay;
        QrySick.Open;

        // 3. Проходим по каждому дню месяца и считаем итог
        WorkDaysCount := 0;
        for i := 1 to DaysCount do
        begin
          CurrentDate := EncodeDate(FCurYear, FCurMonth, i);
          IsVacation := False;
          IsSick := False;

          // Проверяем, попадает ли день в больничный
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

          // Проверяем, попадает ли день в отпуск (если он не на больничном)
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

          // Рабочий день — если не выходной, не отпуск и не больничный
          if (not IsSick) and (not IsVacation) and not (DayOfTheWeek(CurrentDate) in [6, 7]) then
            Inc(WorkDaysCount);
        end;

        dmMain.memTimesheet.Edit;
        dmMain.memTimesheet.FieldByName('days_worked').AsFloat := WorkDaysCount;
        dmMain.memTimesheet.FieldByName('hours_worked').AsFloat := WorkDaysCount * HOURS_PER_DAY;
        dmMain.memTimesheet.Post;

        dmMain.memTimesheet.Next;
      end;

      dmMain.memTimesheet.First;
    finally
      dmMain.memTimesheet.FieldByName('days_worked').OnChange := DaysWorkedChange;
      dmMain.memTimesheet.EnableControls;
    end;
  finally
    QryVac.Free;
    QrySick.Free;
  end;

  ShowMessage('Дни/часы рассчитаны по норме, отпускам и больничным. Поправьте вручную, если по бумажному табелю есть отклонения, и нажмите "Сохранить".');
end;

procedure TframeTimesheet.btnSaveClick(Sender: TObject);
var
  EmpID: Integer;
  Hours: Double;
  SaveQuery: TFDQuery;
  Bookmark: TBookmark;
begin
  if not Assigned(dmMain) or not dmMain.memTimesheet.Active then Exit;
  if dmMain.memTimesheet.IsEmpty then Exit;

  SaveQuery := TFDQuery.Create(nil);

  dmMain.memTimesheet.DisableControls;
  Bookmark := dmMain.memTimesheet.GetBookmark;
  try
    SaveQuery.Connection := dmMain.conn;
    dmMain.conn.StartTransaction;
    try
      dmMain.memTimesheet.First;

      while not dmMain.memTimesheet.Eof do
      begin
        EmpID := dmMain.memTimesheet.FieldByName('emp_id').AsInteger;
        Hours := dmMain.memTimesheet.FieldByName('hours_worked').AsFloat;

        // Удаляем всё, что раньше было сохранено на этот месяц по сотруднику
        // (в том числе старые подневные записи, если табель вёлся ранее по дням)
        SaveQuery.SQL.Text := 'DELETE FROM timesheet WHERE emp_id = :emp_id AND strftime(''%Y-%m'', work_date) = :ym';
        SaveQuery.ParamByName('emp_id').AsInteger := EmpID;
        SaveQuery.ParamByName('ym').AsString := Format('%.4d-%.2d', [FCurYear, FCurMonth]);
        SaveQuery.ExecSQL;

        // И сохраняем итог одной строкой на весь месяц —
        // именно её суммирует UnitframePayroll как факт. часы сотрудника.
        if Hours > 0 then
        begin
          SaveQuery.SQL.Text := 'INSERT INTO timesheet (emp_id, work_date, hours_worked, status_code) ' +
                                'VALUES (:emp_id, :wdate, :hrs, :code)';
          SaveQuery.ParamByName('emp_id').AsInteger := EmpID;
          SaveQuery.ParamByName('wdate').AsDate := EncodeDate(FCurYear, FCurMonth, 1);
          SaveQuery.ParamByName('hrs').AsFloat := Hours;
          SaveQuery.ParamByName('code').AsString := 'Я';
          SaveQuery.ExecSQL;
        end;

        dmMain.memTimesheet.Next;
      end;

      dmMain.conn.Commit;
      ShowMessage('Табель успешно сохранён в базу данных!');

    except
      on E: Exception do
      begin
        dmMain.conn.Rollback;
        ShowMessage('Ошибка при сохранении данных: ' + E.Message);
      end;
    end;
  finally
    SaveQuery.Free;

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
  IsActiveRow: Boolean;
  Grid: TDBGrid;
begin
  Grid := Sender as TDBGrid; // Важно: работает, когда этот хендлер общий (общий для обеих сеток)
  IsActiveRow := False;

  if (dmMain.memTimesheet.Active) and (dmMain.memTimesheet.FindField('emp_id') <> nil) then
    IsActiveRow := (dmMain.memTimesheet.FieldByName('emp_id').AsInteger = FCurrentEmpID);

  // Подсветка строки текущего сотрудника
  if IsActiveRow then
  begin
    Grid.Canvas.Brush.Color := $00FFF0E0;
    Grid.Canvas.Font.Style := [fsBold];
  end;

  // Дополнительная подсветка редактируемых колонок (факт)
  if (Column.FieldName = 'days_worked') or (Column.FieldName = 'hours_worked') then
  begin
    if IsActiveRow then Grid.Canvas.Brush.Color := $00C0FFFF
    else Grid.Canvas.Brush.Color := $00E0FFFF;
    Grid.Canvas.Font.Style := [fsBold];
  end;

  // Подсветка выделенной ячейки редактором
  if gdSelected in State then
  begin
    Grid.Canvas.Brush.Color := clHighlight;
    Grid.Canvas.Font.Color := clHighlightText;
  end;

  Grid.DefaultDrawColumnCell(Rect, DataCol, Column, State);
end;

end.

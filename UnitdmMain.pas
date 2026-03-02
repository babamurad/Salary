unit UnitdmMain;

interface

uses
  System.SysUtils, System.Classes, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, FireDAC.Phys.SQLite,
  FireDAC.Phys.SQLiteDef, FireDAC.Stan.ExprFuncs,
  FireDAC.Phys.SQLiteWrapper.Stat, FireDAC.VCLUI.Wait, FireDAC.Comp.UI, Data.DB,
  FireDAC.Comp.Client, FireDAC.Stan.Param, FireDAC.DatS, FireDAC.DApt.Intf,
  Vcl.Controls, System.IniFiles,
  FireDAC.DApt, FireDAC.Comp.DataSet, Vcl.Dialogs, FireDAC.Comp.ScriptCommands,
  FireDAC.Stan.Util, FireDAC.Comp.Script, Vcl.Menus;

type
  TdmMain = class(TDataModule)
    conn: TFDConnection;
    FDPhysSQLiteDriverLink1: TFDPhysSQLiteDriverLink;
    FDGUIxWaitCursor1: TFDGUIxWaitCursor;

    { Оперативные данные }
    qryEmployees: TFDQuery;
    dsEmployees: TDataSource;

    { Базовые справочники }
    qryDepts: TFDQuery;
    dsDepts: TDataSource;
    qryPositions: TFDQuery;
    dsPositions: TDataSource;

    { Дополнительные справочники и настройки }
    qrySettings: TFDQuery;
    dsSettings: TDataSource;
    qryConstSettings: TFDQuery;
    dsConstSettings: TDataSource;
    qryProdCalendar: TFDQuery;
    dsProdCalendar: TDataSource;
    qrySickLeaveRates: TFDQuery;
    dsSickLeaveRates: TDataSource;
    qryHistory: TFDQuery;
    dsHistory: TDataSource;
    qrySettingskey_name: TWideMemoField;
    qrySettingskey_value: TFloatField;
    qryVacation: TFDQuery;
    dsVacation: TDataSource;
    qrySickLeave: TFDQuery;
    dsSickLeave: TDataSource;
    qrySickLeaveid: TFDAutoIncField;
    qrySickLeaveemp_id: TIntegerField;
    qrySickLeavecalc_date: TDateField;
    qrySickLeavestart_date: TDateField;
    qrySickLeaveend_date: TDateField;
    qrySickLeavedays_count: TIntegerField;
    qrySickLeaveavg_daily_salary: TFMTBCDField;
    qrySickLeaveexperience_years: TIntegerField;
    qrySickLeavepayment_percent: TBCDField;
    qrySickLeavetotal_amount: TFMTBCDField;
    qrySickLeavefio: TWideStringField;
    qryEmployeesid: TFDAutoIncField;
    qryEmployeestabno: TIntegerField;
    qryEmployeesfio: TWideStringField;
    qryEmployeeshire_date: TDateField;
    qryEmployeesbase_salary: TCurrencyField;
    qryEmployeesdept_id: TIntegerField;
    qryEmployeespos_id: TIntegerField;
    qryEmployeesstatus: TIntegerField;
    qryEmployeesprior_exp_years: TIntegerField;
    qryEmployeesprior_exp_months: TIntegerField;
    qryEmployeesdept_name: TWideStringField;
    qryEmployeespos_name: TWideStringField;
    qryDeptsid: TFDAutoIncField;
    qryDeptsdept_name: TWideStringField;
    qryHistoryid: TFDAutoIncField;
    qryHistoryemp_id: TIntegerField;
    qryHistoryfio: TWideStringField;
    qryHistoryperiod_date: TDateField;
    qryHistoryamount: TFMTBCDField;
    qryVacationid: TFDAutoIncField;
    qryVacationemp_id: TIntegerField;
    qryVacationcalc_date: TDateField;
    qryVacationstart_date: TDateField;
    qryVacationend_date: TDateField;
    qryVacationdays_count: TIntegerField;
    qryVacationavg_monthly_salary: TFMTBCDField;
    qryVacationavg_daily_salary: TFMTBCDField;
    qryVacationtotal_amount: TFMTBCDField;
    qryVacationfio: TWideStringField;
    qrySickLeaveRatesmin_years: TIntegerField;
    qrySickLeaveRatespercent: TFloatField;
    qryEmployeesdependents_count: TIntegerField;
    scrCreateDb: TFDScript;
    qryEmployeespension_rate: TFloatField;
    qryEmployeespay_type: TIntegerField;
    qryEmployeesschedule_type: TIntegerField;
    qryEmployeeshourly_rate: TFloatField;

    procedure connBeforeConnect(Sender: TObject);
    procedure DataModuleCreate(Sender: TObject);
    procedure qrySettingskey_nameGetText(Sender: TField; var Text: string;
      DisplayText: Boolean);
    procedure qryVacationfioGetText(Sender: TField; var Text: string;
      DisplayText: Boolean);
    procedure qryEmployeesfioGetText(Sender: TField; var Text: string;
      DisplayText: Boolean);
    procedure qrySickLeavefioGetText(Sender: TField; var Text: string;
      DisplayText: Boolean);
    procedure qryEmployeesAfterOpen(DataSet: TDataSet);
    procedure qryEmployeesBeforeDelete(DataSet: TDataSet);
    procedure qrySickLeaveRatesmin_yearsGetText(Sender: TField;
      var Text: string; DisplayText: Boolean);
    procedure DataModuleDestroy(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    function GetAverageYearlySalary(AEmpID: Integer; ACalcDate: TDate): Double;
    procedure SwitchDatabase(const ANewPath: string);
    procedure ApplyDatabase(const APath: string);
    procedure CreateNewDb(const APath: string);
    procedure LoadConfig;
    procedure SaveConfig(const APath: string);
    procedure CloseAllQueries;
    procedure OpenAllQueries;
  end;

var
  dmMain: TdmMain;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}

uses Main;

{$R *.dfm}

procedure TdmMain.ApplyDatabase(const APath: string);
begin
  try
    CloseAllQueries;
    conn.Close;

    conn.Params.Values['Database'] := APath;
    // Для существующих баз возвращаем обычный режим
    conn.Params.Values['OpenMode'] := 'ReadWrite';

    conn.Connected := True;

    OpenAllQueries;
    SaveConfig(APath);

    // Обновляем дашборд на MainForm
    if Assigned(MainForm) then
      MainForm.RefreshDashboard;

  except
    on E: Exception do
      ShowMessage('Ошибка подключения к базе данных:' + sLineBreak + APath +
                  sLineBreak + 'Детали: ' + E.Message);
  end;
end;

procedure TdmMain.CloseAllQueries;
var
  i: Integer;
  Q: TFDQuery;
begin
  for i := 0 to ComponentCount - 1 do
  begin
    if Components[i] is TFDQuery then
    begin
      Q := TFDQuery(Components[i]);

      if Q.Active then
        Q.Close;
    end;
  end;
end;

procedure TdmMain.OpenAllQueries;
var
  i: Integer;
  Q: TFDQuery;
begin
  for i := 0 to ComponentCount - 1 do
  begin
    if Components[i] is TFDQuery then
    begin
      Q := TFDQuery(Components[i]);

      if Q.Active then
        Q.Open;
    end;
  end;
end;

procedure TdmMain.connBeforeConnect(Sender: TObject);
begin
  // Динамическая установка пути к базе (файл должен лежать рядом с .exe)
  //conn.Params.Values['Database'] := ExtractFilePath(ParamStr(0)) + 'database\salarydb.db';
end;

procedure TdmMain.CreateNewDb(const APath: string);
begin
  try
    // 1. Создаем папки, если их нет
    ForceDirectories(ExtractFilePath(APath));

    // 2. Полностью закрываем текущее подключение
    conn.Close; // Используем Close вместо Connected := False - это надежнее

    // 3. Устанавливаем новые параметры
    conn.Params.Values['Database'] := APath;

    // --- САМОЕ ГЛАВНОЕ: Разрешаем FireDAC создавать файл! ---
    conn.Params.Values['OpenMode'] := 'CreateUTF8';

    // 4. Подключаемся (в эту секунду физически создается пустой .db файл)
    conn.Connected := True;

    // 5. Запускаем скрипт создания структуры (таблицы)
    scrCreateDb.ExecuteAll;

    // 6. Открываем наши справочники
    OpenAllQueries;

    // 7. Сохраняем путь в конфигурацию
    SaveConfig(APath);

    // 8. Обновляем Дашборд на переименованной форме MainForm
    if Assigned(MainForm) then
      MainForm.RefreshDashboard;

    ShowMessage('Новая база данных успешно создана!' + sLineBreak + APath);
  except
    on E: Exception do
      ShowMessage('Ошибка при создании базы: ' + E.Message);
  end;
end;

procedure TdmMain.DataModuleCreate(Sender: TObject);
begin
  // 1. НАСТРОЙКА ОКРУЖЕНИЯ (Валюта и форматы)
  // Это нужно сделать в первую очередь, чтобы суммы в сетках сразу выглядели правильно
  FormatSettings.CurrencyString := ' TMT';
  FormatSettings.CurrencyFormat := 3; // Формат: 1 000,00 TMT

  // 2. НАСТРОЙКА ПРАВИЛ ОТОБРАЖЕНИЯ (MapRules)
  // Без этого SQLite поля TEXT будут отображаться в DBGrid как (WIDEMEMO)
  conn.FormatOptions.OwnMapRules := True;
  conn.FormatOptions.MapRules.Clear;

  with conn.FormatOptions.MapRules.Add do
  begin
    SourceDataType := dtWideMemo;
    TargetDataType := dtWideString;
  end;

  with conn.FormatOptions.MapRules.Add do
  begin
    SourceDataType := dtMemo;
    TargetDataType := dtAnsiString;
  end;

  // 3. ЗАПУСК ЛОГИКИ ПОДКЛЮЧЕНИЯ
  // Мы не пишем здесь пути, а просто командуем: "Загрузи настройки и подключись"
  LoadConfig;
end;

procedure TdmMain.DataModuleDestroy(Sender: TObject);
begin
  if conn.Connected then
  begin
    CloseAllQueries;
    conn.Connected := False;
    conn.Close;
  end;
end;

function TdmMain.GetAverageYearlySalary(AEmpID: Integer; ACalcDate: TDate): Double;
var
  Qry: TFDQuery;
  StartDate: string;
  SumTotal: Double;
  MonthsCount: Integer;
begin
  Result := 0;
  // Определяем дату "12 месяцев назад" от даты расчета
  StartDate := FormatDateTime('yyyy-mm-dd', IncMonth(ACalcDate, -12));

  Qry := TFDQuery.Create(nil);
  try
    Qry.Connection := conn;

    // Обновленный SQL-запрос: теперь он считает и сумму, и количество отработанных месяцев
    Qry.SQL.Text :=
      'SELECT ' +
      '  SUM(TotalAmount) as SumTotal, ' +
      '  COUNT(DISTINCT strftime(''%Y-%m'', period_date)) as MonthsCount ' +
      'FROM ( ' +
      '  SELECT gross_amount AS TotalAmount, period_date FROM payroll_journal ' +
      '  WHERE emp_id = :id1 AND period_date >= :dt1 ' +
      '  UNION ALL ' +
      '  SELECT amount AS TotalAmount, period_date FROM salary_history ' +
      '  WHERE emp_id = :id2 AND period_date >= :dt2 ' +
      ')';

    Qry.ParamByName('id1').AsInteger := AEmpID;
    Qry.ParamByName('id2').AsInteger := AEmpID;
    Qry.ParamByName('dt1').AsString := StartDate;
    Qry.ParamByName('dt2').AsString := StartDate;
    Qry.Open;

    if not Qry.FieldByName('SumTotal').IsNull then
    begin
      SumTotal := Qry.FieldByName('SumTotal').AsFloat;
      MonthsCount := Qry.FieldByName('MonthsCount').AsInteger;

      // Защита: делим только если есть хотя бы 1 отработанный месяц
      if MonthsCount > 0 then
        Result := SumTotal / MonthsCount // Делим на фактическое количество месяцев!
      else
        Result := 0;
    end;
  finally
    Qry.Free;
  end;
end;

procedure TdmMain.LoadConfig;
var
  Ini: TIniFile;
  SavedPath: string;
  DefaultPath: string;
begin
  // Путь к базе по умолчанию (рядом с EXE)
  DefaultPath := ExtractFilePath(ParamStr(0)) + 'salarydb.db';

  Ini := TIniFile.Create(ExtractFilePath(ParamStr(0)) + 'config.ini');
  try
    // Читаем путь из секции [Database]. Если там пусто — берем DefaultPath
    SavedPath := Ini.ReadString('Database', 'Path', DefaultPath);

    // Пытаемся применить этот путь
    ApplyDatabase(SavedPath);
  finally
    Ini.Free;
  end;
end;

procedure TdmMain.SaveConfig(const APath: string);
var Ini: TIniFile;
begin
  Ini := TIniFile.Create(ExtractFilePath(ParamStr(0)) + 'config.ini');
  try
    Ini.WriteString('Database', 'Path', APath);
  finally Ini.Free; end;
end;

procedure TdmMain.qryEmployeesAfterOpen(DataSet: TDataSet);
var
  Fld: TField;
begin
  Fld := DataSet.FieldByName('base_salary');
  if Fld is TFloatField then
    TFloatField(Fld).DisplayFormat := '#,##0.00 TMT';
end;

procedure TdmMain.qryEmployeesBeforeDelete(DataSet: TDataSet);
var
  HistoryCount: Integer;
  EmpID: Integer;
begin
  EmpID := DataSet.FieldByName('id').AsInteger;

  // 1. Проверяем, есть ли у сотрудника история начислений в журналах
  HistoryCount := conn.ExecSQLScalar(
    'SELECT COUNT(*) FROM payroll_journal WHERE emp_id = :id', [EmpID]);

  // 2. Если история есть — включаем защиту!
  if HistoryCount > 0 then
  begin
    if MessageDlg('У этого сотрудника уже есть история начислений! ' +
                  'Физическое удаление удалит и его зарплату, что нарушит учет.' + sLineBreak + sLineBreak +
                  'Хотите вместо этого перевести его в статус "Уволен" (сделать неактивным)?',
                  mtWarning, [mbYes, mbNo], 0) = mrYes then
    begin
      // Делаем мягкое удаление (меняем статус на 0)
      conn.ExecSQL('UPDATE employees SET status = 0 WHERE id = :id', [EmpID]);

      // Обновляем таблицу, чтобы сотрудник стал серым (как мы делали в OnDrawColumnCell)
      DataSet.Refresh;
    end;

    // 3. ОБЯЗАТЕЛЬНО прерываем стандартную команду DELETE, чтобы не было той самой ошибки
    Abort;
  end;

  // Если HistoryCount = 0 (это новичок, которому еще ничего не начисляли),
  // программа пойдет дальше и спокойно удалит его строку навсегда.
end;

procedure TdmMain.qryEmployeesfioGetText(Sender: TField; var Text: string;
  DisplayText: Boolean);
begin
  Text := Sender.AsString;
end;

procedure TdmMain.qrySettingskey_nameGetText(Sender: TField; var Text: string;
  DisplayText: Boolean);
begin
  // Маппинг технических имен в человеческие
  if Sender.AsString = 'income_tax' then Text := 'Подоходный налог'
  else if Sender.AsString = 'pension_fund' then Text := 'Пенсионный фонд'
  else if Sender.AsString = 'min_salary_limit' then Text := 'Минимальный оклад'
  else if Sender.AsString = 'salary_increase_pct' then Text := 'Процент индексации'
  else if Sender.AsString = 'dependent_deduction' then Text := 'Иждевенцы'
  else Text := Sender.AsString;
end;

procedure TdmMain.qrySickLeavefioGetText(Sender: TField; var Text: string;
  DisplayText: Boolean);
begin
  Text := Sender.AsString;
end;

procedure TdmMain.qrySickLeaveRatesmin_yearsGetText(Sender: TField;
  var Text: string; DisplayText: Boolean);
begin
  // Если мы кликнули по ячейке для редактирования — показываем просто цифру
  if not DisplayText then
  begin
    Text := Sender.AsString;
    Exit;
  end;

  // Наводим красоту для отображения в сетке
  if Sender.IsNull then
    Text := ''
  else if Sender.AsInteger = 0 then
    Text := 'До 5 лет'
  else if Sender.AsInteger >= 8 then // Если это максимальный порог
    Text := 'Свыше ' + Sender.AsString + ' лет'
  else
    Text := 'От ' + Sender.AsString + ' лет';
end;

procedure TdmMain.qryVacationfioGetText(Sender: TField; var Text: string;
  DisplayText: Boolean);
begin
  Text := Sender.AsString;
end;

procedure TdmMain.SwitchDatabase(const ANewPath: string);
begin
  if conn.Connected then
    conn.Connected := False;

  // Указываем новый путь к файлу базы
  conn.Params.Values['Database'] := ANewPath;

  try
    conn.Connected := True;
    // После переключения нужно переоткрыть основные справочники, если они нужны
    if qryDepts.Active then qryDepts.Open;
  except
    on E: Exception do
      ShowMessage('Ошибка при подключении к базе: ' + E.Message);
  end;
end;

end.

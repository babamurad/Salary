object dmMain: TdmMain
  OnCreate = DataModuleCreate
  OnDestroy = DataModuleDestroy
  Height = 651
  Width = 960
  PixelsPerInch = 96
  object conn: TFDConnection
    Params.Strings = (
      
        'Database=C:\Users\user\Documents\Embarcadero\Studio\Projects\Sal' +
        'ary\Win32\Debug\database\salarydb.db'
      'OpenMode=ReadWrite'
      'DriverID=SQLite')
    FormatOptions.AssignedValues = [fvMapRules]
    FormatOptions.OwnMapRules = True
    FormatOptions.MapRules = <
      item
        SourceDataType = dtWideMemo
        TargetDataType = dtWideString
      end>
    LoginPrompt = False
    BeforeConnect = connBeforeConnect
    Left = 56
    Top = 16
  end
  object FDPhysSQLiteDriverLink1: TFDPhysSQLiteDriverLink
    Left = 168
    Top = 16
  end
  object FDGUIxWaitCursor1: TFDGUIxWaitCursor
    Provider = 'Forms'
    Left = 336
    Top = 24
  end
  object qryEmployees: TFDQuery
    AfterOpen = qryEmployeesAfterOpen
    BeforeDelete = qryEmployeesBeforeDelete
    Connection = conn
    UpdateOptions.UpdateTableName = 'employees'
    UpdateOptions.KeyFields = 'id'
    SQL.Strings = (
      'SELECT e.*, '
      '       d.dept_name as dept_name, '
      '       p.name as pos_name'
      'FROM employees e'
      'LEFT JOIN departments d ON e.dept_id = d.id'
      'LEFT JOIN positions p ON e.pos_id = p.id')
    Left = 40
    Top = 168
    object qryEmployeesid: TFDAutoIncField
      FieldName = 'id'
      Origin = 'id'
      ProviderFlags = [pfInWhere, pfInKey]
    end
    object qryEmployeestabno: TIntegerField
      FieldName = 'tabno'
      Origin = 'tabno'
      Required = True
    end
    object qryEmployeesfio: TWideStringField
      FieldName = 'fio'
      Origin = 'fio'
      Required = True
      Size = 32767
    end
    object qryEmployeeshire_date: TDateField
      FieldName = 'hire_date'
      Origin = 'hire_date'
    end
    object qryEmployeesbase_salary: TCurrencyField
      FieldName = 'base_salary'
      Origin = 'base_salary'
    end
    object qryEmployeesdept_id: TIntegerField
      FieldName = 'dept_id'
      Origin = 'dept_id'
    end
    object qryEmployeespos_id: TIntegerField
      FieldName = 'pos_id'
      Origin = 'pos_id'
    end
    object qryEmployeesstatus: TIntegerField
      FieldName = 'status'
      Origin = 'status'
    end
    object qryEmployeesprior_exp_years: TIntegerField
      FieldName = 'prior_exp_years'
      Origin = 'prior_exp_years'
    end
    object qryEmployeesprior_exp_months: TIntegerField
      FieldName = 'prior_exp_months'
      Origin = 'prior_exp_months'
    end
    object qryEmployeesdependents_count: TIntegerField
      FieldName = 'dependents_count'
      Origin = 'dependents_count'
    end
    object qryEmployeespension_rate: TFloatField
      DisplayLabel = #1055#1077#1085#1089#1080#1086#1085'.'
      FieldName = 'pension_rate'
      Origin = 'pension_rate'
    end
    object qryEmployeespay_type: TIntegerField
      DisplayLabel = #1058#1080#1087' '#1074#1099#1087#1083#1072#1090#1099
      FieldName = 'pay_type'
      Origin = 'pay_type'
    end
    object qryEmployeesschedule_type: TIntegerField
      DisplayLabel = #1043#1088#1072#1092#1080#1082' '#1088#1072#1073#1086#1090#1099
      FieldName = 'schedule_type'
      Origin = 'schedule_type'
    end
    object qryEmployeeshourly_rate: TFloatField
      DisplayLabel = #1063#1072#1089#1086#1074#1072#1103' '#1089#1090#1072#1074#1082#1072
      FieldName = 'hourly_rate'
      Origin = 'hourly_rate'
    end
    object qryEmployeeswage_type: TIntegerField
      DisplayLabel = #1058#1080#1087' '#1086#1087#1083#1072#1090#1099
      FieldName = 'wage_type'
      Origin = 'wage_type'
      Required = True
    end
    object qryEmployeesis_rotation: TIntegerField
      DisplayLabel = #1042#1072#1093#1090#1072
      FieldName = 'is_rotation'
      Origin = 'is_rotation'
      Required = True
    end
    object qryEmployeeswork_fraction: TFloatField
      DisplayLabel = #1057#1090#1072#1074#1082#1072
      FieldName = 'work_fraction'
      Origin = 'work_fraction'
    end
    object qryEmployeesis_tax_exempt: TIntegerField
      DisplayLabel = #1051#1100#1075#1086#1090#1072' ('#1053#1072#1083#1086#1075')'
      FieldName = 'is_tax_exempt'
      Origin = 'is_tax_exempt'
    end
    object qryEmployeesclass_rank: TIntegerField
      DisplayLabel = #1050#1083#1072#1089#1089#1085#1086#1089#1090#1100
      FieldName = 'class_rank'
      Origin = 'class_rank'
    end
    object qryEmployeestrade_union: TIntegerField
      DisplayLabel = #1055#1088#1086#1092#1089#1086#1102#1079
      FieldName = 'trade_union'
      Origin = 'trade_union'
    end
    object qryEmployeesalimony_percent: TFloatField
      DisplayLabel = #1040#1083#1080#1084#1077#1085#1090#1099' (%)'
      FieldName = 'alimony_percent'
      Origin = 'alimony_percent'
    end
    object qryEmployeesbank_account: TWideStringField
      DisplayLabel = #1041#1072#1085#1082#1086#1074#1089#1082#1080#1081' '#1089#1095#1077#1090
      FieldName = 'bank_account'
      Origin = 'bank_account'
      Size = 32767
    end
    object qryEmployeesdept_name: TWideStringField
      AutoGenerateValue = arDefault
      FieldName = 'dept_name'
      Origin = 'dept_name'
      ProviderFlags = []
      ReadOnly = True
      Size = 32767
    end
    object qryEmployeespos_name: TWideStringField
      AutoGenerateValue = arDefault
      FieldName = 'pos_name'
      Origin = 'name'
      ProviderFlags = []
      ReadOnly = True
      Size = 32767
    end
  end
  object dsEmployees: TDataSource
    DataSet = qryEmployees
    Left = 40
    Top = 248
  end
  object qryDepts: TFDQuery
    Connection = conn
    SQL.Strings = (
      'SELECT * FROM departments ORDER BY dept_name')
    Left = 160
    Top = 168
    object qryDeptsid: TFDAutoIncField
      FieldName = 'id'
      Origin = 'id'
      ProviderFlags = [pfInWhere, pfInKey]
      ReadOnly = True
    end
    object qryDeptsdept_name: TWideStringField
      FieldName = 'dept_name'
      Origin = 'dept_name'
      Required = True
      Size = 32767
    end
  end
  object dsDepts: TDataSource
    DataSet = qryDepts
    Left = 160
    Top = 248
  end
  object qryPositions: TFDQuery
    Connection = conn
    SQL.Strings = (
      'SELECT * FROM positions ORDER BY name')
    Left = 280
    Top = 168
  end
  object dsPositions: TDataSource
    DataSet = qryPositions
    Left = 280
    Top = 248
  end
  object qryConstSettings: TFDQuery
    Connection = conn
    SQL.Strings = (
      'SELECT * FROM const_settings ORDER BY key_name')
    Left = 496
    Top = 168
  end
  object dsConstSettings: TDataSource
    DataSet = qryConstSettings
    Left = 496
    Top = 248
  end
  object qryProdCalendar: TFDQuery
    Connection = conn
    SQL.Strings = (
      'SELECT * FROM production_calendar')
    Left = 608
    Top = 168
  end
  object dsProdCalendar: TDataSource
    DataSet = qryProdCalendar
    Left = 608
    Top = 248
  end
  object qrySickLeaveRates: TFDQuery
    Connection = conn
    SQL.Strings = (
      'SELECT * FROM sick_leave_rates ORDER BY min_years')
    Left = 720
    Top = 168
    object qrySickLeaveRatesmin_years: TIntegerField
      FieldName = 'min_years'
      Origin = 'min_years'
      ProviderFlags = [pfInUpdate, pfInWhere, pfInKey]
      OnGetText = qrySickLeaveRatesmin_yearsGetText
    end
    object qrySickLeaveRatespercent: TFloatField
      FieldName = 'percent'
      Origin = 'percent'
    end
  end
  object dsSickLeaveRates: TDataSource
    DataSet = qrySickLeaveRates
    Left = 720
    Top = 248
  end
  object qryHistory: TFDQuery
    Connection = conn
    SQL.Strings = (
      'SELECT * '
      'FROM salary_history '
      'ORDER BY period_date DESC')
    Left = 32
    Top = 328
    object qryHistoryid: TFDAutoIncField
      FieldName = 'id'
      Origin = 'id'
      ProviderFlags = [pfInWhere, pfInKey]
    end
    object qryHistoryemp_id: TIntegerField
      FieldName = 'emp_id'
      Origin = 'emp_id'
      Required = True
    end
    object qryHistoryperiod_date: TDateField
      FieldName = 'period_date'
      Origin = 'period_date'
      Required = True
    end
    object qryHistoryamount: TFMTBCDField
      FieldName = 'amount'
      Origin = 'amount'
      Precision = 18
      Size = 2
    end
    object qryHistoryfio: TStringField
      FieldKind = fkLookup
      FieldName = 'fio'
      LookupDataSet = qryEmployees
      LookupKeyFields = 'id'
      LookupResultField = 'fio'
      KeyFields = 'emp_id'
      Size = 150
      Lookup = True
    end
  end
  object dsHistory: TDataSource
    DataSet = qryHistory
    Left = 32
    Top = 392
  end
  object qryVacation: TFDQuery
    ConstraintsEnabled = True
    Connection = conn
    SQL.Strings = (
      'SELECT v.*, CAST(e.fio AS VARCHAR(150)) AS fio '
      'FROM vacation_journal v '
      'JOIN employees e ON v.emp_id = e.id ORDER BY v.calc_date DESC')
    Left = 136
    Top = 328
    object qryVacationid: TFDAutoIncField
      FieldName = 'id'
      Origin = 'id'
      ProviderFlags = [pfInWhere, pfInKey]
      ReadOnly = True
    end
    object qryVacationemp_id: TIntegerField
      FieldName = 'emp_id'
      Origin = 'emp_id'
      Required = True
    end
    object qryVacationcalc_date: TDateField
      FieldName = 'calc_date'
      Origin = 'calc_date'
      Required = True
    end
    object qryVacationstart_date: TDateField
      FieldName = 'start_date'
      Origin = 'start_date'
      Required = True
    end
    object qryVacationend_date: TDateField
      FieldName = 'end_date'
      Origin = 'end_date'
      Required = True
    end
    object qryVacationdays_count: TIntegerField
      FieldName = 'days_count'
      Origin = 'days_count'
      Required = True
    end
    object qryVacationavg_monthly_salary: TFMTBCDField
      FieldName = 'avg_monthly_salary'
      Origin = 'avg_monthly_salary'
      Precision = 18
      Size = 2
    end
    object qryVacationavg_daily_salary: TFMTBCDField
      FieldName = 'avg_daily_salary'
      Origin = 'avg_daily_salary'
      Precision = 18
      Size = 2
    end
    object qryVacationtotal_amount: TFMTBCDField
      FieldName = 'total_amount'
      Origin = 'total_amount'
      Precision = 18
      Size = 2
    end
    object qryVacationfio: TWideStringField
      AutoGenerateValue = arDefault
      FieldName = 'fio'
      Origin = 'fio'
      ProviderFlags = []
      ReadOnly = True
      Size = 32767
    end
  end
  object dsVacation: TDataSource
    DataSet = qryVacation
    Left = 136
    Top = 392
  end
  object qrySickLeave: TFDQuery
    Connection = conn
    SQL.Strings = (
      'SELECT s.*, '
      '       CAST(e.fio AS VARCHAR(150)) AS fio '
      'FROM sick_leave_journal s '
      'JOIN employees e ON s.emp_id = e.id '
      'ORDER BY s.calc_date DESC')
    Left = 240
    Top = 320
    object qrySickLeaveid: TFDAutoIncField
      FieldName = 'id'
      Origin = 'id'
      ProviderFlags = [pfInWhere, pfInKey]
      ReadOnly = True
    end
    object qrySickLeaveemp_id: TIntegerField
      FieldName = 'emp_id'
      Origin = 'emp_id'
      Required = True
    end
    object qrySickLeavecalc_date: TDateField
      FieldName = 'calc_date'
      Origin = 'calc_date'
      Required = True
    end
    object qrySickLeavestart_date: TDateField
      FieldName = 'start_date'
      Origin = 'start_date'
      Required = True
    end
    object qrySickLeaveend_date: TDateField
      FieldName = 'end_date'
      Origin = 'end_date'
      Required = True
    end
    object qrySickLeavedays_count: TIntegerField
      FieldName = 'days_count'
      Origin = 'days_count'
      Required = True
    end
    object qrySickLeaveavg_daily_salary: TFMTBCDField
      FieldName = 'avg_daily_salary'
      Origin = 'avg_daily_salary'
      Precision = 18
      Size = 2
    end
    object qrySickLeaveexperience_years: TIntegerField
      FieldName = 'experience_years'
      Origin = 'experience_years'
    end
    object qrySickLeavepayment_percent: TBCDField
      FieldName = 'payment_percent'
      Origin = 'payment_percent'
      Precision = 5
      Size = 2
    end
    object qrySickLeavetotal_amount: TFMTBCDField
      FieldName = 'total_amount'
      Origin = 'total_amount'
      Precision = 18
      Size = 2
    end
    object qrySickLeavefio: TWideStringField
      AutoGenerateValue = arDefault
      FieldName = 'fio'
      Origin = 'fio'
      ProviderFlags = []
      ReadOnly = True
      OnGetText = qrySickLeavefioGetText
      Size = 32767
    end
  end
  object dsSickLeave: TDataSource
    DataSet = qrySickLeave
    Left = 240
    Top = 384
  end
  object scrCreateDb: TFDScript
    SQLScripts = <
      item
        SQL.Strings = (
          'BEGIN TRANSACTION;'
          'CREATE TABLE IF NOT EXISTS "closed_periods" ('
          #9'"period_str"'#9'TEXT,'
          #9'PRIMARY KEY("period_str")'
          ');'
          'CREATE TABLE IF NOT EXISTS "const_settings" ('
          #9'"key_name"'#9'TEXT,'
          #9'"key_value"'#9'REAL,'
          #9'PRIMARY KEY("key_name")'
          ');'
          'CREATE TABLE IF NOT EXISTS "departments" ('
          #9'"id"'#9'INTEGER,'
          #9'"dept_name"'#9'TEXT NOT NULL UNIQUE,'
          #9'PRIMARY KEY("id" AUTOINCREMENT)'
          ');'
          'CREATE TABLE IF NOT EXISTS "emp_adjustments" ('
          #9'"emp_id"'#9'INTEGER,'
          #9'"adj_name"'#9'TEXT,'
          #9'"adj_value"'#9'REAL,'
          #9'"is_percent"'#9'BOOLEAN,'
          #9'FOREIGN KEY("emp_id") REFERENCES "employees"("id")'
          ');'
          'CREATE TABLE IF NOT EXISTS "employees" ('
          #9'"id"'#9'INTEGER,'
          #9'"tabno"'#9'INTEGER NOT NULL UNIQUE,'
          #9'"fio"'#9'TEXT NOT NULL,'
          #9'"hire_date"'#9'DATE,'
          #9'"base_salary"'#9'CURRENCY DEFAULT 0,'
          #9'"dept_id"'#9'INTEGER,'
          #9'"pos_id"'#9'INTEGER,'
          #9'"status"'#9'INTEGER DEFAULT 1,'
          #9'"prior_exp_years"'#9'INTEGER DEFAULT 0,'
          #9'"prior_exp_months"'#9'INTEGER DEFAULT 0,'
          #9'"dependents_count"'#9'INTEGER DEFAULT 0,'
          #9'"pension_rate"'#9'REAL DEFAULT 2.0,'
          #9'"pay_type"'#9'INTEGER DEFAULT 0,'
          #9'"schedule_type"'#9'INTEGER DEFAULT 0,'
          #9'"hourly_rate"'#9'REAL DEFAULT 0,'
          #9'PRIMARY KEY("id" AUTOINCREMENT),'
          
            #9'FOREIGN KEY("dept_id") REFERENCES "departments"("id") ON DELETE' +
            ' SET NULL,'
          
            #9'FOREIGN KEY("pos_id") REFERENCES "positions"("id") ON DELETE SE' +
            'T NULL'
          ');'
          'CREATE TABLE IF NOT EXISTS "payroll_journal" ('
          #9'"id"'#9'INTEGER,'
          #9'"emp_id"'#9'INTEGER,'
          #9'"period_date"'#9'DATE,'
          #9'"gross_amount"'#9'CURRENCY,'
          #9'"tax_amount"'#9'CURRENCY,'
          #9'"pension_amount"'#9'CURRENCY,'
          #9'"net_amount"'#9'CURRENCY,'
          #9'PRIMARY KEY("id" AUTOINCREMENT),'
          #9'FOREIGN KEY("emp_id") REFERENCES "employees"("id")'
          ');'
          'CREATE TABLE IF NOT EXISTS "positions" ('
          #9'"id"'#9'INTEGER,'
          #9'"name"'#9'TEXT NOT NULL UNIQUE,'
          #9'"category"'#9'TEXT,'
          #9'PRIMARY KEY("id" AUTOINCREMENT)'
          ');'
          'CREATE TABLE IF NOT EXISTS "production_calendar" ('
          #9'"year"'#9'INTEGER,'
          #9'"month"'#9'INTEGER,'
          #9'"working_days"'#9'INTEGER,'
          #9'"working_hours"'#9'INTEGER,'
          #9'PRIMARY KEY("year","month")'
          ');'
          'CREATE TABLE IF NOT EXISTS "salary_history" ('
          #9'"id"'#9'INTEGER,'
          #9'"emp_id"'#9'INTEGER NOT NULL,'
          #9'"period_date"'#9'DATE NOT NULL,'
          #9'"amount"'#9'DECIMAL(18, 2) DEFAULT 0,'
          #9'PRIMARY KEY("id" AUTOINCREMENT),'
          
            #9'FOREIGN KEY("emp_id") REFERENCES "employees"("id") ON DELETE CA' +
            'SCADE'
          ');'
          'CREATE TABLE IF NOT EXISTS "settings" ('
          #9'"key_name"'#9'TEXT,'
          #9'"key_value"'#9'REAL,'
          #9'PRIMARY KEY("key_name")'
          ');'
          'CREATE TABLE IF NOT EXISTS "sick_leave_journal" ('
          #9'"id"'#9'INTEGER,'
          #9'"emp_id"'#9'INTEGER NOT NULL,'
          #9'"calc_date"'#9'DATE NOT NULL,'
          #9'"start_date"'#9'DATE NOT NULL,'
          #9'"end_date"'#9'DATE NOT NULL,'
          #9'"days_count"'#9'INTEGER NOT NULL,'
          #9'"avg_daily_salary"'#9'DECIMAL(18, 2),'
          #9'"experience_years"'#9'INTEGER,'
          #9'"payment_percent"'#9'DECIMAL(5, 2),'
          #9'"total_amount"'#9'DECIMAL(18, 2),'
          #9'PRIMARY KEY("id" AUTOINCREMENT),'
          #9'FOREIGN KEY("emp_id") REFERENCES "employees"("id")'
          ');'
          'CREATE TABLE IF NOT EXISTS "sick_leave_rates" ('
          #9'"min_years"'#9'INTEGER,'
          #9'"percent"'#9'REAL,'
          #9'PRIMARY KEY("min_years")'
          ');'
          'CREATE TABLE IF NOT EXISTS "timesheet" ('
          #9'"id"'#9'INTEGER,'
          #9'"emp_id"'#9'INTEGER NOT NULL,'
          #9'"work_date"'#9'DATE NOT NULL,'
          #9'"hours_worked"'#9'REAL DEFAULT 0,'
          #9'"status_code"'#9'TEXT(5) DEFAULT '#39#1071#39','
          #9'"notes"'#9'TEXT,'
          #9'PRIMARY KEY("id" AUTOINCREMENT),'
          #9'FOREIGN KEY("emp_id") REFERENCES "employees"("id")'
          ');'
          'CREATE TABLE IF NOT EXISTS "vacation_journal" ('
          #9'"id"'#9'INTEGER,'
          #9'"emp_id"'#9'INTEGER NOT NULL,'
          #9'"calc_date"'#9'DATE NOT NULL,'
          #9'"start_date"'#9'DATE NOT NULL,'
          #9'"end_date"'#9'DATE NOT NULL,'
          #9'"days_count"'#9'INTEGER NOT NULL,'
          #9'"avg_monthly_salary"'#9'DECIMAL(18, 2),'
          #9'"avg_daily_salary"'#9'DECIMAL(18, 2),'
          #9'"total_amount"'#9'DECIMAL(18, 2),'
          #9'PRIMARY KEY("id" AUTOINCREMENT),'
          #9'FOREIGN KEY("emp_id") REFERENCES "employees"("id")'
          ');'
          
            'CREATE UNIQUE INDEX IF NOT EXISTS "idx_salary_history_emp_period' +
            '" ON "salary_history" ('
          #9'"emp_id",'
          #9'"period_date"'
          ');'
          'CREATE INDEX IF NOT EXISTS "idx_timesheet_date" ON "timesheet" ('
          #9'"work_date"'
          ');'
          
            'CREATE INDEX IF NOT EXISTS "idx_timesheet_emp_date" ON "timeshee' +
            't" ('
          #9'"emp_id",'
          #9'"work_date"'
          ');'
          'COMMIT;')
      end>
    Connection = conn
    Params = <>
    Macros = <>
    Left = 480
    Top = 24
  end
  object memTimesheet: TFDMemTable
    FetchOptions.AssignedValues = [evMode]
    FetchOptions.Mode = fmAll
    ResourceOptions.AssignedValues = [rvSilentMode]
    ResourceOptions.SilentMode = True
    UpdateOptions.AssignedValues = [uvCheckRequired, uvAutoCommitUpdates]
    UpdateOptions.CheckRequired = False
    UpdateOptions.AutoCommitUpdates = True
    Left = 360
    Top = 328
  end
  object dsTimesheet: TDataSource
    DataSet = memTimesheet
    Left = 360
    Top = 392
  end
  object dsSettings: TDataSource
    DataSet = qrySettings
    Left = 376
    Top = 240
  end
  object qrySettings: TFDQuery
    Connection = conn
    UpdateOptions.AssignedValues = [uvRefreshMode, uvAutoCommitUpdates]
    UpdateOptions.RefreshMode = rmAll
    UpdateOptions.AutoCommitUpdates = True
    SQL.Strings = (
      'SELECT * FROM settings')
    Left = 376
    Top = 168
    object qrySettingsid: TFDAutoIncField
      FieldName = 'id'
      Origin = 'id'
      ProviderFlags = [pfInWhere, pfInKey]
    end
    object qrySettingssys_name: TWideStringField
      FieldName = 'sys_name'
      Origin = 'sys_name'
      Size = 32767
    end
    object qrySettingsdisplay_name: TWideStringField
      FieldName = 'display_name'
      Origin = 'display_name'
      Size = 32767
    end
    object qrySettingscalc_type: TIntegerField
      FieldName = 'calc_type'
      Origin = 'calc_type'
    end
    object qrySettingskey_value: TFloatField
      FieldName = 'key_value'
      Origin = 'key_value'
    end
    object qrySettingsis_active: TIntegerField
      FieldName = 'is_active'
      Origin = 'is_active'
    end
  end
  object qryCompanyInfo: TFDQuery
    Connection = conn
    SQL.Strings = (
      'SELECT * FROM company_info')
    Left = 488
    Top = 328
    object qryCompanyInfoid: TFDAutoIncField
      FieldName = 'id'
      Origin = 'id'
      ProviderFlags = [pfInWhere, pfInKey]
    end
    object qryCompanyInfokey_name: TWideStringField
      FieldName = 'key_name'
      Origin = 'key_name'
      Required = True
      Size = 32767
    end
    object qryCompanyInfodisplay_name: TWideStringField
      FieldName = 'display_name'
      Origin = 'display_name'
      Required = True
      Size = 32767
    end
    object qryCompanyInfokey_value: TWideStringField
      FieldName = 'key_value'
      Origin = 'key_value'
      Size = 32767
    end
  end
  object dsCompanyInfo: TDataSource
    DataSet = qryCompanyInfo
    Left = 488
    Top = 392
  end
end

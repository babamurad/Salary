object dmMain: TdmMain
  OnCreate = DataModuleCreate
  Height = 442
  Width = 699
  PixelsPerInch = 96
  object conn: TFDConnection
    Params.Strings = (
      'DriverID=SQLite'
      'Database=salarydb.db')
    LoginPrompt = False
    BeforeConnect = connBeforeConnect
    Left = 40
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
    Connection = conn
    SQL.Strings = (
      
        'SELECT e.*, d.dept_name, p.name as pos_name FROM employees e LEF' +
        'T JOIN departments d ON e.dept_id = d.id LEFT JOIN positions p O' +
        'N e.pos_id = p.id ORDER BY e.fio')
    Left = 40
    Top = 168
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
end

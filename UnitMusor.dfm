object Form2: TForm2
  Left = 0
  Top = 0
  Caption = 'Form2'
  ClientHeight = 511
  ClientWidth = 800
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 15
  object ListBoxNav: TListBox
    Left = 0
    Top = 0
    Width = 257
    Height = 511
    Style = lbOwnerDrawFixed
    Align = alLeft
    BorderStyle = bsNone
    ItemHeight = 20
    TabOrder = 0
    OnClick = ListBoxNavClick
    OnDrawItem = ListBoxNavDrawItem
    OnEnter = ListBoxNavEnter
    OnMouseLeave = ListBoxNavMouseLeave
    OnMouseMove = ListBoxNavMouseMove
  end
  object DBGrid1: TDBGrid
    Left = 272
    Top = 16
    Width = 497
    Height = 177
    DataSource = dmMain.dsEmployees
    TabOrder = 1
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -12
    TitleFont.Name = 'Segoe UI'
    TitleFont.Style = []
  end
  object DBGrid2: TDBGrid
    Left = 272
    Top = 280
    Width = 497
    Height = 201
    DataSource = DataSource1
    TabOrder = 2
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -12
    TitleFont.Name = 'Segoe UI'
    TitleFont.Style = []
  end
  object DataSource1: TDataSource
    DataSet = FDQuery1
    Left = 128
    Top = 224
  end
  object FDQuery1: TFDQuery
    Filtered = True
    MasterSource = dmMain.dsEmployees
    MasterFields = 'id'
    DetailFields = 'id'
    Connection = dmMain.conn
    FetchOptions.AssignedValues = [evCache]
    FetchOptions.Cache = [fiBlobs, fiMeta]
    SQL.Strings = (
      'SELECT * '
      'FROM salary_history '
      'WHERE emp_id = :id')
    Left = 128
    Top = 160
    ParamData = <
      item
        Name = 'ID'
        DataType = ftAutoInc
        ParamType = ptInput
        Value = 3
      end>
  end
end

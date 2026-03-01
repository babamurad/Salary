object frameEmployees: TframeEmployees
  Left = 0
  Top = 0
  Width = 858
  Height = 500
  Align = alClient
  TabOrder = 0
  PixelsPerInch = 96
  object PanelTop: TPanel
    Left = 0
    Top = 0
    Width = 858
    Height = 41
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 0
    object Label1: TLabel
      Left = 375
      Top = 13
      Width = 85
      Height = 15
      Caption = #1055#1086#1080#1089#1082' '#1087#1086' '#1060#1048#1054':'
    end
    object DBNavigator1: TDBNavigator
      Left = 0
      Top = 0
      Width = 240
      Height = 41
      Align = alLeft
      Flat = True
      TabOrder = 0
    end
    object edtSearch: TEdit
      Left = 514
      Top = 10
      Width = 175
      Height = 23
      TabOrder = 1
      OnChange = edtSearchChange
    end
  end
  object DBGrid1: TDBGrid
    Left = 0
    Top = 41
    Width = 858
    Height = 459
    Align = alClient
    Options = [dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgRowSelect, dgConfirmDelete, dgCancelOnExit, dgTitleClick, dgTitleHotTrack]
    ReadOnly = True
    TabOrder = 1
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -12
    TitleFont.Name = 'Segoe UI'
    TitleFont.Style = []
    OnDrawColumnCell = DBGrid1DrawColumnCell
    OnDblClick = DBGrid1DblClick
  end
end

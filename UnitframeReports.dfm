object frameReports: TframeReports
  Left = 0
  Top = 0
  Width = 800
  Height = 500
  Align = alClient
  TabOrder = 0
  PixelsPerInch = 96
  object PanelTop: TPanel
    Left = 0
    Top = 0
    Width = 800
    Height = 50
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 0
    object lblPeriod: TLabel
      Left = 16
      Top = 18
      Width = 39
      Height = 15
      Caption = #1052#1077#1089#1103#1094':'
    end
    object dtpPeriod: TDateTimePicker
      Left = 88
      Top = 10
      Width = 100
      Height = 23
      Date = 46081.000000000000000000
      Time = 0.684849583332834300
      TabOrder = 0
    end
    object btnGenerate: TButton
      Left = 224
      Top = 8
      Width = 150
      Height = 25
      Caption = #1057#1086#1079#1076#1072#1090#1100' '#1086#1090#1095#1077#1090
      TabOrder = 1
    end
    object btnExport: TButton
      Left = 418
      Top = 8
      Width = 150
      Height = 25
      Caption = #1069#1082#1089#1087#1086#1088#1090' '#1074' Excel'
      TabOrder = 2
    end
  end
  object DBGrid1: TDBGrid
    Left = 0
    Top = 50
    Width = 800
    Height = 450
    Align = alClient
    Options = [dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgRowSelect, dgConfirmDelete, dgCancelOnExit, dgTitleClick, dgTitleHotTrack]
    ReadOnly = True
    TabOrder = 1
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -12
    TitleFont.Name = 'Segoe UI'
    TitleFont.Style = []
  end
  object SaveDialog1: TSaveDialog
    DefaultExt = 'xlsx'
    Filter = 'Excel Files (*.xlsx)|*.xlsx'
    Left = 32
    Top = 120
  end
end

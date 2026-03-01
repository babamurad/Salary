object frameCalendar: TframeCalendar
  Left = 0
  Top = 0
  Width = 717
  Height = 480
  TabOrder = 0
  PixelsPerInch = 96
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 717
    Height = 41
    Align = alTop
    TabOrder = 0
    ExplicitLeft = 128
    ExplicitTop = 104
    ExplicitWidth = 185
    object Label1: TLabel
      Left = 304
      Top = 13
      Width = 19
      Height = 15
      Caption = #1043#1086#1076
    end
    object DBNavigator1: TDBNavigator
      Left = 16
      Top = 8
      Width = 240
      Height = 25
      TabOrder = 0
    end
    object cmbYear: TComboBox
      Left = 352
      Top = 10
      Width = 145
      Height = 23
      TabOrder = 1
      Text = 'cmbYear'
    end
  end
  object DBGrid1: TDBGrid
    Left = 0
    Top = 41
    Width = 717
    Height = 439
    Align = alClient
    TabOrder = 1
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -12
    TitleFont.Name = 'Segoe UI'
    TitleFont.Style = []
  end
end

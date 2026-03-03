object framePayroll: TframePayroll
  Left = 0
  Top = 0
  Width = 1103
  Height = 500
  Align = alClient
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -15
  Font.Name = 'Segoe UI'
  Font.Style = []
  ParentFont = False
  TabOrder = 0
  PixelsPerInch = 96
  object PanelTop: TPanel
    Left = 0
    Top = 0
    Width = 1103
    Height = 49
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 0
    object DBNavigator1: TDBNavigator
      Left = 0
      Top = 0
      Width = 240
      Height = 49
      Align = alLeft
      Flat = True
      TabOrder = 0
    end
    object btnCalc: TButton
      Left = 856
      Top = 18
      Width = 169
      Height = 25
      Caption = #1053#1072#1095#1080#1089#1083#1080#1090#1100' '#1079#1072#1088#1087#1083#1072#1090#1091
      TabOrder = 1
      OnClick = btnCalcClick
    end
    object cmbMonth: TComboBox
      Left = 256
      Top = 14
      Width = 145
      Height = 28
      TabOrder = 2
      Text = 'cmbMonth'
    end
    object cmbYear: TComboBox
      Left = 424
      Top = 14
      Width = 105
      Height = 28
      TabOrder = 3
      Text = 'cmbYear'
    end
    object btnCloseMonth: TButton
      Left = 736
      Top = 18
      Width = 121
      Height = 25
      Caption = #1047#1072#1082#1088#1099#1090#1100' '#1084#1077#1089#1103#1094
      TabOrder = 4
      OnClick = btnCloseMonthClick
    end
    object btnExport: TButton
      Left = 1023
      Top = 18
      Width = 106
      Height = 25
      Caption = 'Excel'
      TabOrder = 5
      OnClick = btnExportClick
    end
    object cmbDept: TComboBox
      Left = 544
      Top = 15
      Width = 145
      Height = 28
      TabOrder = 6
      Text = 'cmbDept'
    end
  end
  object DBGrid1: TDBGrid
    Left = 0
    Top = 49
    Width = 1103
    Height = 451
    Align = alClient
    DataSource = dmMain.dsVacation
    TabOrder = 1
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -15
    TitleFont.Name = 'Segoe UI'
    TitleFont.Style = []
    OnDblClick = DBGrid1DblClick
  end
end

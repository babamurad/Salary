object framePayroll: TframePayroll
  Left = 0
  Top = 0
  Width = 1221
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
    Width = 1221
    Height = 96
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 0
    object btnCalc: TButton
      Left = 503
      Top = 16
      Width = 169
      Height = 25
      Caption = #1053#1072#1095#1080#1089#1083#1080#1090#1100' '#1079#1072#1088#1087#1083#1072#1090#1091
      TabOrder = 0
      OnClick = btnCalcClick
    end
    object cmbMonth: TComboBox
      Left = 16
      Top = 14
      Width = 145
      Height = 28
      TabOrder = 1
      Text = 'cmbMonth'
    end
    object cmbYear: TComboBox
      Left = 167
      Top = 14
      Width = 105
      Height = 28
      TabOrder = 2
      Text = 'cmbYear'
    end
    object btnCloseMonth: TButton
      Left = 1090
      Top = 16
      Width = 121
      Height = 25
      Caption = #1047#1072#1082#1088#1099#1090#1100' '#1084#1077#1089#1103#1094
      TabOrder = 3
      OnClick = btnCloseMonthClick
    end
    object btnExport: TButton
      Left = 678
      Top = 16
      Width = 106
      Height = 25
      Caption = 'Excel'
      TabOrder = 4
      OnClick = btnExportClick
    end
    object cmbDept: TComboBox
      Left = 278
      Top = 14
      Width = 219
      Height = 28
      TabOrder = 5
      Text = 'cmbDept'
    end
    object btnPrintAllSlips: TButton
      Left = 958
      Top = 16
      Width = 126
      Height = 25
      Caption = #1055#1077#1095#1072#1090#1100' '#1082#1074#1080#1090#1082#1086#1074
      TabOrder = 6
      OnClick = btnPrintAllSlipsClick
    end
    object btnSummaryReport: TButton
      Left = 790
      Top = 16
      Width = 162
      Height = 25
      Caption = #1057#1074#1086#1076#1085#1072#1103' '#1074#1077#1076#1086#1084#1086#1089#1090#1100
      TabOrder = 7
      OnClick = btnSummaryReportClick
    end
    object btnPensionReport: TButton
      Left = 16
      Top = 54
      Width = 180
      Height = 25
      Caption = #1055#1077#1085#1089#1080#1086#1085#1085#1099#1081' '#1074#1079#1085#1086#1089
      TabOrder = 8
      OnClick = btnPensionReportClick
    end
    object btnBankTransferReport: TButton
      Left = 204
      Top = 54
      Width = 260
      Height = 25
      Caption = #1057#1087#1080#1089#1086#1082' '#1085#1072' '#1087#1077#1088#1077#1095#1080#1089#1083#1077#1085#1080#1077' ('#1082#1072#1088#1090#1099')'
      TabOrder = 9
      OnClick = btnBankTransferReportClick
    end
  end
  object DBGrid1: TDBGrid
    Left = 0
    Top = 96
    Width = 1221
    Height = 404
    Align = alClient
    DataSource = dmMain.dsVacation
    PopupMenu = PopupMenu1
    TabOrder = 1
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -15
    TitleFont.Name = 'Segoe UI'
    TitleFont.Style = []
    OnDblClick = DBGrid1DblClick
    OnMouseDown = DBGrid1MouseDown
  end
  object PopupMenu1: TPopupMenu
    Left = 1080
    Top = 120
    object miEditEmployee: TMenuItem
      Caption = #1056#1077#1076#1072#1082#1090#1080#1088#1086#1074#1072#1090#1100' '#1089#1086#1090#1088#1091#1076#1085#1080#1082#1072
      OnClick = miEditEmployeeClick
    end
  end
end

object frameSickLeave: TframeSickLeave
  Left = 0
  Top = 0
  Width = 830
  Height = 465
  TabOrder = 0
  PixelsPerInch = 96
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 830
    Height = 41
    Align = alTop
    TabOrder = 0
    object Label1: TLabel
      Left = 16
      Top = 12
      Width = 121
      Height = 23
      Caption = #1060#1080#1083#1100#1090#1088' '#1087#1086' '#1084#1077#1089#1103#1094#1091':'
    end
    object btnNewCalc: TButton
      Left = 360
      Top = 8
      Width = 129
      Height = 25
      Caption = #1053#1086#1074#1099#1081' '#1088#1072#1089#1095#1077#1090
      TabOrder = 0
      OnClick = btnNewCalcClick
    end
    object btnDelete: TButton
      Left = 506
      Top = 8
      Width = 145
      Height = 25
      Caption = #1059#1076#1072#1083#1080#1090#1100
      TabOrder = 1
      OnClick = btnDeleteClick
    end
    object btnPrint: TButton
      Left = 665
      Top = 8
      Width = 138
      Height = 25
      Caption = #1055#1077#1095#1072#1090#1100' '#1087#1088#1080#1082#1072#1079#1072
      TabOrder = 2
      OnClick = btnPrintClick
    end
    object cmbMonthFilter: TComboBox
      Left = 183
      Top = 9
      Width = 154
      Height = 23
      TabOrder = 3
      Text = 'cmbMonthFilter'
      OnChange = cmbMonthFilterChange
    end
  end
  object DBGrid1: TDBGrid
    Left = 0
    Top = 41
    Width = 830
    Height = 424
    Align = alClient
    DataSource = dmMain.dsSickLeave
    TabOrder = 1
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -12
    TitleFont.Name = 'Segoe UI'
    TitleFont.Style = []
  end
end

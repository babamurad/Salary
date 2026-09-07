object frmPayrollDetail: TfrmPayrollDetail
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = #1044#1077#1090#1072#1083#1080#1079#1072#1094#1080#1103' '#1088#1072#1089#1095#1105#1090#1072' '#1079#1072#1088#1087#1083#1072#1090#1099
  ClientHeight = 720
  ClientWidth = 700
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poMainFormCenter
  PixelsPerInch = 96
  TextHeight = 17
  object PanelTop: TPanel
    Left = 0
    Top = 0
    Width = 700
    Height = 70
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 0
    object lblFio: TLabel
      Left = 16
      Top = 8
      Width = 60
      Height = 21
      Caption = 'lblFio'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -17
      Font.Name = 'Segoe UI Semibold'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object lblDeptPos: TLabel
      Left = 16
      Top = 34
      Width = 80
      Height = 17
      Caption = 'lblDeptPos'
    end
    object lblPeriod: TLabel
      Left = 16
      Top = 52
      Width = 60
      Height = 17
      Caption = 'lblPeriod'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clGrayText
      Font.Height = -13
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
    end
  end
  object GroupBox1: TGroupBox
    Left = 0
    Top = 70
    Width = 700
    Height = 340
    Align = alTop
    Caption = #1042#1093#1086#1076#1085#1099#1077' '#1076#1072#1085#1085#1099#1077' '#1088#1072#1089#1095#1105#1090#1072
    TabOrder = 1
    object lblWorkDays: TLabel
      Left = 16
      Top = 30
      Width = 130
      Height = 17
      Caption = #1054#1090#1088#1072#1073#1086#1090#1072#1085#1086' '#1076#1085#1077#1081':'
    end
    object lblWorkHours: TLabel
      Left = 280
      Top = 30
      Width = 130
      Height = 17
      Caption = #1054#1090#1088#1072#1073#1086#1090#1072#1085#1086' '#1095#1072#1089#1086#1074':'
    end
    object lblBaseSalary: TLabel
      Left = 16
      Top = 66
      Width = 130
      Height = 17
      Caption = #1054#1082#1083#1072#1076'/'#1090#1072#1088#1080#1092':'
    end
    object lblHourlyRateCaption: TLabel
      Left = 280
      Top = 66
      Width = 150
      Height = 17
      Caption = #1057#1090#1072#1074#1082#1072' '#1095#1072#1089#1072' ('#1088#1072#1089#1095'.):'
    end
    object lblHourlyRate: TLabel
      Left = 430
      Top = 66
      Width = 60
      Height = 17
      Caption = '0.00'
    end
    object lblRotationRate: TLabel
      Left = 280
      Top = 102
      Width = 140
      Height = 17
      Caption = #1057#1090#1072#1074#1082#1072' '#1085#1072#1076#1073#1072#1074#1082#1080', %:'
    end
    object lblClassRank: TLabel
      Left = 16
      Top = 138
      Width = 130
      Height = 17
      Caption = #1050#1083#1072#1089#1089#1085#1086#1089#1090#1100':'
    end
    object lblClassRate: TLabel
      Left = 280
      Top = 138
      Width = 140
      Height = 17
      Caption = #1057#1090#1072#1074#1082#1072' '#1085#1072#1076#1073#1072#1074#1082#1080', %:'
    end
    object lblPensionRate: TLabel
      Left = 16
      Top = 174
      Width = 150
      Height = 17
      Caption = #1055#1077#1085#1089#1080#1086#1085#1085#1099#1081' '#1074#1079#1085#1086#1089', %:'
    end
    object lblUnionRate: TLabel
      Left = 280
      Top = 210
      Width = 90
      Height = 17
      Caption = #1057#1090#1072#1074#1082#1072', %:'
    end
    object lblTaxRate: TLabel
      Left = 280
      Top = 246
      Width = 140
      Height = 17
      Caption = #1057#1090#1072#1074#1082#1072' '#1085#1072#1083#1086#1075#1072', %:'
    end
    object lblDepCount: TLabel
      Left = 16
      Top = 282
      Width = 130
      Height = 17
      Caption = #1048#1078#1076#1080#1074#1077#1085#1094#1077#1074':'
    end
    object lblDepDeduction: TLabel
      Left = 280
      Top = 282
      Width = 150
      Height = 17
      Caption = #1042#1099#1095#1077#1090' '#1085#1072' 1 '#1080#1078#1076#1080#1074#1077#1085#1094#1072':'
    end
    object lblAlimonyPct: TLabel
      Left = 16
      Top = 318
      Width = 100
      Height = 17
      Caption = #1040#1083#1080#1084#1077#1085#1090#1099', %:'
    end
    object edtWorkDays: TEdit
      Left = 170
      Top = 27
      Width = 80
      Height = 25
      TabOrder = 0
      OnChange = InputChange
    end
    object edtWorkHours: TEdit
      Left = 430
      Top = 27
      Width = 80
      Height = 25
      TabOrder = 1
      OnChange = InputChange
    end
    object edtBaseSalary: TEdit
      Left = 170
      Top = 63
      Width = 80
      Height = 25
      TabOrder = 2
      OnChange = InputChange
    end
    object chkIsRotation: TCheckBox
      Left = 16
      Top = 105
      Width = 200
      Height = 17
      Caption = #1042#1072#1093#1090#1086#1074#1099#1081' '#1084#1077#1090#1086#1076
      TabOrder = 3
      OnClick = InputChange
    end
    object edtRotationRate: TEdit
      Left = 430
      Top = 99
      Width = 80
      Height = 25
      TabOrder = 4
      OnChange = InputChange
    end
    object cbClassRank: TComboBox
      Left = 170
      Top = 135
      Width = 80
      Height = 25
      Style = csDropDownList
      TabOrder = 5
      OnChange = InputChange
      Items.Strings = (
        #1053#1077#1090
        '1'
        '2'
        '3')
    end
    object edtClassRate: TEdit
      Left = 430
      Top = 135
      Width = 80
      Height = 25
      TabOrder = 6
      OnChange = InputChange
    end
    object edtPensionRate: TEdit
      Left = 170
      Top = 171
      Width = 80
      Height = 25
      TabOrder = 7
      OnChange = InputChange
    end
    object chkIsTradeUnion: TCheckBox
      Left = 16
      Top = 213
      Width = 200
      Height = 17
      Caption = #1063#1083#1077#1085' '#1087#1088#1086#1092#1089#1086#1102#1079#1072
      TabOrder = 8
      OnClick = InputChange
    end
    object edtUnionRate: TEdit
      Left = 430
      Top = 207
      Width = 80
      Height = 25
      TabOrder = 9
      OnChange = InputChange
    end
    object chkIsTaxExempt: TCheckBox
      Left = 16
      Top = 249
      Width = 200
      Height = 17
      Caption = #1054#1089#1074#1086#1073#1086#1078#1076#1105#1085' '#1086#1090' '#1085#1072#1083#1086#1075#1072
      TabOrder = 10
      OnClick = InputChange
    end
    object edtTaxRate: TEdit
      Left = 430
      Top = 243
      Width = 80
      Height = 25
      TabOrder = 11
      OnChange = InputChange
    end
    object edtDepCount: TEdit
      Left = 170
      Top = 279
      Width = 80
      Height = 25
      TabOrder = 12
      OnChange = InputChange
    end
    object edtDepDeduction: TEdit
      Left = 440
      Top = 279
      Width = 80
      Height = 25
      TabOrder = 13
      OnChange = InputChange
    end
    object edtAlimonyPct: TEdit
      Left = 170
      Top = 315
      Width = 80
      Height = 25
      TabOrder = 14
      OnChange = InputChange
    end
  end
  object StringGrid1: TStringGrid
    Left = 0
    Top = 410
    Width = 700
    Height = 180
    Align = alClient
    ColCount = 2
    DefaultRowHeight = 22
    FixedCols = 0
    FixedRows = 0
    RowCount = 9
    Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine]
    TabOrder = 2
    ColWidths = (
      480
      190)
  end
  object PanelBottom: TPanel
    Left = 0
    Top = 590
    Width = 700
    Height = 130
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 3
    object lblTotalGross: TLabel
      Left = 16
      Top = 10
      Width = 100
      Height = 17
      Caption = #1048#1090#1086#1075#1086' '#1085#1072#1095#1080#1089#1083#1077#1085#1086':'
    end
    object lblTotalDeductions: TLabel
      Left = 16
      Top = 32
      Width = 100
      Height = 17
      Caption = #1048#1090#1086#1075#1086' '#1091#1076#1077#1088#1078#1072#1085#1086':'
    end
    object lblNet: TLabel
      Left = 16
      Top = 58
      Width = 90
      Height = 25
      Caption = #1050' '#1042#1067#1044#1040#1063#1045':'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -19
      Font.Name = 'Segoe UI Semibold'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object btnRecalc: TButton
      Left = 16
      Top = 92
      Width = 130
      Height = 30
      Caption = #1055#1077#1088#1077#1089#1095#1080#1090#1072#1090#1100
      TabOrder = 0
      OnClick = btnRecalcClick
    end
    object btnPrint: TButton
      Left = 300
      Top = 92
      Width = 100
      Height = 30
      Caption = #1055#1077#1095#1072#1090#1100
      TabOrder = 1
      OnClick = btnPrintClick
    end
    object btnSave: TButton
      Left = 410
      Top = 92
      Width = 130
      Height = 30
      Caption = #1057#1086#1093#1088#1072#1085#1080#1090#1100
      TabOrder = 2
      OnClick = btnSaveClick
    end
    object btnCancel: TButton
      Left = 550
      Top = 92
      Width = 130
      Height = 30
      Caption = #1054#1090#1084#1077#1085#1072
      TabOrder = 3
      OnClick = btnCancelClick
    end
  end
end

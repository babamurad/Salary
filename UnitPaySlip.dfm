object frmPaySlip: TfrmPaySlip
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = #1044#1077#1090#1072#1083#1080#1079#1072#1094#1080#1103' '#1088#1072#1089#1095#1077#1090#1072
  ClientHeight = 391
  ClientWidth = 685
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -16
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poMainFormCenter
  PixelsPerInch = 96
  TextHeight = 21
  object Bevel1: TBevel
    Left = 0
    Top = 64
    Width = 681
    Height = 321
  end
  object lblFIO: TLabel
    Left = 32
    Top = 72
    Width = 442
    Height = 21
    Caption = 'lblFIO'
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'Segoe UI Semibold'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object lblPeriod: TLabel
    Left = 32
    Top = 24
    Width = 61
    Height = 21
    Caption = 'lblPeriod'
  end
  object lblBaseSalary: TLabel
    Left = 432
    Top = 181
    Width = 140
    Height = 21
    Caption = 'lblBaseSalary'
  end
  object lblGross: TLabel
    Left = 432
    Top = 221
    Width = 113
    Height = 21
    Caption = 'lblGross'
  end
  object lblTax: TLabel
    Left = 432
    Top = 256
    Width = 38
    Height = 21
    Caption = 'lblTax'
  end
  object lblPension: TLabel
    Left = 432
    Top = 296
    Width = 71
    Height = 21
    Caption = 'lblPension'
  end
  object lblNet: TLabel
    Left = 432
    Top = 344
    Width = 45
    Height = 21
    Caption = 'lblNet'
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'Segoe UI Semibold'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Label1: TLabel
    Left = 32
    Top = 181
    Width = 238
    Height = 21
    Caption = #1054#1082#1083#1072#1076' '#1087#1086' '#1096#1090#1072#1090#1085#1086#1084#1091' '#1088#1072#1089#1087#1080#1089#1072#1085#1080#1102':'
  end
  object Label2: TLabel
    Left = 32
    Top = 221
    Width = 285
    Height = 21
    Caption = #1053#1072#1095#1080#1089#1083#1077#1085#1086' ('#1087#1088#1086#1087#1086#1088#1094#1080#1086#1085#1072#1083#1100#1085#1086' '#1090#1072#1073#1077#1083#1102'):'
  end
  object Label3: TLabel
    Left = 32
    Top = 256
    Width = 250
    Height = 21
    Caption = #1059#1076#1077#1088#1078#1072#1085' '#1087#1086#1076#1086#1093#1086#1076#1085#1099#1081' '#1085#1072#1083#1086#1075' (10%):'
  end
  object Label4: TLabel
    Left = 32
    Top = 296
    Width = 204
    Height = 21
    Caption = #1059#1076#1077#1088#1078#1072#1085' '#1087#1077#1085#1089#1080#1086#1085#1085#1099#1081' '#1074#1079#1085#1086#1089':'
  end
  object Label5: TLabel
    Left = 32
    Top = 344
    Width = 153
    Height = 21
    Caption = #1050' '#1042#1067#1044#1040#1063#1045' '#1053#1040' '#1056#1059#1050#1048':'
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'Segoe UI Semibold'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object lblDept: TLabel
    Left = 32
    Top = 107
    Width = 50
    Height = 21
    Caption = 'lblDept'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'Segoe UI'
    Font.Style = [fsItalic]
    ParentFont = False
  end
  object lblPosition: TLabel
    Left = 32
    Top = 146
    Width = 72
    Height = 21
    Caption = 'lblPosition'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'Segoe UI'
    Font.Style = [fsItalic]
    ParentFont = False
  end
  object btnPrint: TButton
    Left = 560
    Top = 23
    Width = 75
    Height = 25
    Caption = #1055#1077#1095#1072#1090#1100
    TabOrder = 0
    OnClick = btnPrintClick
  end
end

object frmBaseEdit: TfrmBaseEdit
  Left = 0
  Top = 0
  Caption = 'frmBaseEdit'
  ClientHeight = 507
  ClientWidth = 734
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -15
  Font.Name = 'Segoe UI'
  Font.Style = []
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 20
  object GroupBox1: TGroupBox
    Left = 8
    Top = 8
    Width = 713
    Height = 169
    Caption = #1054#1089#1085#1086#1074#1085#1099#1077' '#1076#1072#1085#1085#1099#1077
    TabOrder = 0
    object Label1: TLabel
      Left = 16
      Top = 24
      Width = 128
      Height = 20
      Caption = #1058#1072#1073#1077#1083#1100#1085#1099#1081' '#1085#1086#1084#1077#1088
    end
    object Label2: TLabel
      Left = 183
      Top = 19
      Width = 33
      Height = 20
      Caption = #1060#1048#1054
    end
    object Label3: TLabel
      Left = 16
      Top = 88
      Width = 90
      Height = 20
      Caption = #1044#1072#1090#1072' '#1087#1088#1080#1077#1084#1072
    end
    object Label4: TLabel
      Left = 183
      Top = 88
      Width = 41
      Height = 20
      Caption = #1054#1090#1076#1077#1083
    end
    object Label5: TLabel
      Left = 400
      Top = 88
      Width = 77
      Height = 20
      Caption = #1044#1086#1083#1078#1085#1086#1089#1090#1100
    end
    object Label6: TLabel
      Left = 520
      Top = 32
      Width = 43
      Height = 20
      Caption = #1057#1090#1072#1090#1091#1089
    end
    object dtpHireDate: TDateTimePicker
      Left = 16
      Top = 109
      Width = 113
      Height = 28
      Date = 46082.000000000000000000
      Time = 0.648358414349786500
      TabOrder = 0
    end
    object cmbDept: TComboBox
      Left = 183
      Top = 109
      Width = 195
      Height = 28
      TabOrder = 1
    end
    object cmbPos: TComboBox
      Left = 400
      Top = 109
      Width = 272
      Height = 28
      TabOrder = 2
    end
    object edtFIO: TEdit
      Left = 183
      Top = 45
      Width = 321
      Height = 28
      TabOrder = 3
      Text = 'edtFIO'
    end
    object edtTabNo: TEdit
      Left = 16
      Top = 45
      Width = 113
      Height = 28
      TabOrder = 4
      Text = 'edtTabNo'
    end
    object chkActive: TCheckBox
      Left = 520
      Top = 56
      Width = 177
      Height = 17
      Caption = #1057#1086#1090#1088#1091#1076#1085#1080#1082' '#1072#1082#1090#1080#1074#1077#1085
      TabOrder = 5
    end
  end
  object GroupBox2: TGroupBox
    Left = 8
    Top = 191
    Width = 713
    Height = 114
    Caption = #1058#1088#1091#1076#1086#1074#1086#1081' '#1089#1090#1072#1078' '#1080' '#1054#1082#1083#1072#1076
    TabOrder = 1
    object Label7: TLabel
      Left = 16
      Top = 32
      Width = 42
      Height = 20
      Caption = #1054#1082#1083#1072#1076
    end
    object Label8: TLabel
      Left = 168
      Top = 32
      Width = 141
      Height = 20
      Caption = #1055#1088#1086#1096#1083#1099#1081' '#1089#1090#1072#1078' ('#1083#1077#1090')'
    end
    object Label9: TLabel
      Left = 326
      Top = 32
      Width = 178
      Height = 20
      Caption = #1055#1088#1086#1096#1083#1099#1081' '#1089#1090#1072#1078' ('#1084#1077#1089#1103#1094#1077#1074')'
    end
    object edtSalary: TEdit
      Left = 16
      Top = 59
      Width = 121
      Height = 28
      TabOrder = 0
      Text = 'edtSalary'
    end
    object seExpMonths: TSpinEdit
      Left = 326
      Top = 58
      Width = 121
      Height = 30
      MaxValue = 11
      MinValue = 0
      TabOrder = 1
      Value = 0
    end
    object seExpYears: TSpinEdit
      Left = 168
      Top = 58
      Width = 121
      Height = 30
      MaxValue = 0
      MinValue = 0
      TabOrder = 2
      Value = 0
    end
  end
  object GroupBox3: TGroupBox
    Left = 5
    Top = 320
    Width = 716
    Height = 121
    Caption = #1053#1072#1083#1086#1075#1080' '#1080' '#1083#1100#1075#1086#1090#1099
    TabOrder = 2
    object Label10: TLabel
      Left = 16
      Top = 24
      Width = 129
      Height = 20
      Caption = #1048#1078#1076#1080#1074#1077#1085#1094#1099' ('#1076#1077#1090#1080')'
    end
    object seDependents: TSpinEdit
      Left = 16
      Top = 45
      Width = 121
      Height = 30
      MaxValue = 0
      MinValue = 0
      TabOrder = 0
      Value = 0
    end
  end
  object Panel1: TPanel
    Left = 0
    Top = 458
    Width = 734
    Height = 49
    Align = alBottom
    TabOrder = 3
    ExplicitTop = 447
    ExplicitWidth = 766
    object Button1: TButton
      Left = 120
      Top = 16
      Width = 99
      Height = 25
      Caption = #1057#1086#1093#1088#1072#1085#1080#1090#1100
      ModalResult = 1
      TabOrder = 0
    end
    object Button2: TButton
      Left = 376
      Top = 16
      Width = 75
      Height = 25
      Caption = #1054#1090#1084#1077#1085#1072
      ModalResult = 2
      TabOrder = 1
    end
  end
end

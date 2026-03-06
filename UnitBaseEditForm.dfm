object frmBaseEdit: TfrmBaseEdit
  Left = 0
  Top = 0
  Caption = #1050#1072#1088#1090#1086#1095#1082#1072' '#1089#1086#1090#1088#1091#1076#1085#1080#1082#1072
  ClientHeight = 576
  ClientWidth = 899
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
  object PageControl1: TPageControl
    Left = 0
    Top = 0
    Width = 899
    Height = 527
    ActivePage = tsMain
    Align = alClient
    TabOrder = 0
    OnChange = PageControl1Change
    ExplicitWidth = 1017
    ExplicitHeight = 726
    object tsMain: TTabSheet
      Caption = #1054#1089#1085#1086#1074#1085#1099#1077' '#1076#1072#1085#1085#1099#1077
      object GroupBox1: TGroupBox
        Left = 8
        Top = 8
        Width = 855
        Height = 172
        Caption = #1054#1089#1085#1086#1074#1085#1099#1077' '#1076#1072#1085#1085#1099#1077
        TabOrder = 0
        object Label1: TLabel
          Left = 16
          Top = 25
          Width = 128
          Height = 20
          Caption = #1058#1072#1073#1077#1083#1100#1085#1099#1081' '#1085#1086#1084#1077#1088
        end
        object Label2: TLabel
          Left = 183
          Top = 25
          Width = 33
          Height = 20
          Caption = #1060#1048#1054
        end
        object Label3: TLabel
          Left = 16
          Top = 97
          Width = 90
          Height = 20
          Caption = #1044#1072#1090#1072' '#1087#1088#1080#1077#1084#1072
        end
        object Label4: TLabel
          Left = 183
          Top = 97
          Width = 41
          Height = 20
          Caption = #1054#1090#1076#1077#1083
        end
        object Label5: TLabel
          Left = 400
          Top = 97
          Width = 77
          Height = 20
          Caption = #1044#1086#1083#1078#1085#1086#1089#1090#1100
        end
        object Label6: TLabel
          Left = 704
          Top = 97
          Width = 43
          Height = 20
          Caption = #1057#1090#1072#1090#1091#1089
        end
        object Label13: TLabel
          Left = 544
          Top = 25
          Width = 115
          Height = 20
          Caption = #1041#1072#1085#1082#1086#1074#1089#1082#1080#1081' '#1089#1095#1077#1090
        end
        object dtpHireDate: TDateTimePicker
          Left = 16
          Top = 118
          Width = 113
          Height = 28
          Date = 46082.000000000000000000
          Time = 0.648358414349786500
          TabOrder = 0
        end
        object cmbDept: TComboBox
          Left = 183
          Top = 118
          Width = 195
          Height = 28
          TabOrder = 1
        end
        object cmbPos: TComboBox
          Left = 400
          Top = 118
          Width = 272
          Height = 28
          TabOrder = 2
        end
        object edtFIO: TEdit
          Left = 183
          Top = 51
          Width = 321
          Height = 28
          TabOrder = 3
        end
        object edtTabNo: TEdit
          Left = 16
          Top = 51
          Width = 113
          Height = 28
          TabOrder = 4
        end
        object chkActive: TCheckBox
          Left = 688
          Top = 123
          Width = 160
          Height = 17
          Caption = #1057#1086#1090#1088#1091#1076#1085#1080#1082' '#1072#1082#1090#1080#1074#1077#1085
          TabOrder = 5
        end
        object edtBankAccount: TEdit
          Left = 542
          Top = 51
          Width = 293
          Height = 28
          MaxLength = 23
          TabOrder = 6
        end
      end
      object GroupBox2: TGroupBox
        Left = 8
        Top = 186
        Width = 855
        Height = 130
        Caption = #1054#1087#1083#1072#1090#1072' '#1080' '#1058#1088#1091#1076#1086#1074#1086#1081' '#1089#1090#1072#1078
        TabOrder = 1
        object Label7: TLabel
          Left = 223
          Top = 24
          Width = 42
          Height = 20
          Caption = #1054#1082#1083#1072#1076
        end
        object Label12: TLabel
          Left = 318
          Top = 26
          Width = 106
          Height = 20
          Caption = #1063#1072#1089#1086#1074#1072#1103' '#1089#1090#1072#1074#1082#1072
        end
        object Label8: TLabel
          Left = 440
          Top = 24
          Width = 91
          Height = 20
          Caption = #1057#1090#1072#1078' '#1076#1086' ('#1083#1077#1090')'
        end
        object Label9: TLabel
          Left = 568
          Top = 24
          Width = 95
          Height = 20
          Caption = #1057#1090#1072#1078' '#1076#1086' ('#1084#1077#1089')'
        end
        object Label14: TLabel
          Left = 704
          Top = 24
          Width = 84
          Height = 20
          Caption = #1044#1086#1083#1103' '#1089#1090#1072#1074#1082#1080
        end
        object Label15: TLabel
          Left = 603
          Top = 96
          Width = 78
          Height = 20
          Caption = #1050#1083#1072#1089#1089#1085#1086#1089#1090#1100
        end
        object rgWageType: TRadioGroup
          Left = 16
          Top = 26
          Width = 190
          Height = 87
          Caption = #1058#1080#1087' '#1086#1087#1083#1072#1090#1099
          ItemIndex = 0
          Items.Strings = (
            #1054#1082#1083#1072#1076
            #1058#1072#1088#1080#1092)
          TabOrder = 0
          OnClick = rgWageTypeClick
        end
        object edtSalary: TEdit
          Left = 223
          Top = 50
          Width = 80
          Height = 28
          TabOrder = 1
        end
        object edtHourlyRate: TEdit
          Left = 318
          Top = 50
          Width = 113
          Height = 28
          TabOrder = 2
        end
        object seExpYears: TSpinEdit
          Left = 440
          Top = 50
          Width = 113
          Height = 30
          MaxValue = 0
          MinValue = 0
          TabOrder = 3
          Value = 0
        end
        object seExpMonths: TSpinEdit
          Left = 568
          Top = 50
          Width = 113
          Height = 30
          MaxValue = 11
          MinValue = 0
          TabOrder = 4
          Value = 0
        end
        object cmbWorkFraction: TComboBox
          Left = 704
          Top = 48
          Width = 140
          Height = 28
          Style = csDropDownList
          TabOrder = 5
          Items.Strings = (
            '1.0 ('#1055#1086#1083#1085#1072#1103' '#1089#1090#1072#1074#1082#1072')'
            '0.75 ('#1058#1088#1080' '#1095#1077#1090#1074#1077#1088#1090#1080')'
            '0.5 ('#1055#1086#1083#1089#1090#1072#1074#1082#1080')'
            '0.25 ('#1063#1077#1090#1074#1077#1088#1090#1100' '#1089#1090#1072#1074#1082#1080')')
        end
        object cmbClassRank: TComboBox
          Left = 704
          Top = 90
          Width = 140
          Height = 28
          Style = csDropDownList
          TabOrder = 6
          Items.Strings = (
            #1041#1077#1079' '#1082#1083#1072#1089#1089#1072
            '1 '#1082#1083#1072#1089#1089
            '2 '#1082#1083#1072#1089#1089
            '3 '#1082#1083#1072#1089#1089)
        end
      end
      object GroupBox3: TGroupBox
        Left = 8
        Top = 322
        Width = 855
        Height = 145
        Caption = #1053#1072#1083#1086#1075#1080' '#1080' '#1083#1100#1075#1086#1090#1099
        TabOrder = 2
        object Label10: TLabel
          Left = 16
          Top = 27
          Width = 129
          Height = 20
          Caption = #1048#1078#1076#1080#1074#1077#1085#1094#1099' ('#1076#1077#1090#1080')'
        end
        object Label11: TLabel
          Left = 175
          Top = 27
          Width = 196
          Height = 20
          Caption = #1055#1077#1085#1089#1080#1086#1085#1085#1086#1077' '#1089#1090#1088#1072#1093#1086#1074#1072#1085#1080#1077' %'
        end
        object Label16: TLabel
          Left = 16
          Top = 104
          Width = 98
          Height = 20
          Caption = #1040#1083#1080#1084#1077#1085#1090#1099' (%)'
        end
        object seDependents: TSpinEdit
          Left = 16
          Top = 53
          Width = 121
          Height = 30
          MaxValue = 0
          MinValue = 0
          TabOrder = 0
          Value = 0
        end
        object sePension: TSpinEdit
          Left = 175
          Top = 53
          Width = 121
          Height = 30
          MaxValue = 0
          MinValue = 0
          TabOrder = 1
          Value = 0
        end
        object chkRotation: TCheckBox
          Left = 431
          Top = 36
          Width = 250
          Height = 20
          Caption = #1056#1072#1073#1086#1090#1072' '#1074#1072#1093#1090#1086#1074#1099#1084' '#1084#1077#1090#1086#1076#1086#1084
          TabOrder = 2
        end
        object chkTaxExempt: TCheckBox
          Left = 431
          Top = 62
          Width = 357
          Height = 17
          Caption = #1054#1089#1074#1086#1073#1086#1078#1076#1077#1085' '#1086#1090' '#1087#1086#1076#1086#1093#1086#1076#1085#1086#1075#1086' ('#1074#1077#1090#1077#1088#1072#1085'/'#1085#1072#1075#1088#1072#1076#1099')'
          TabOrder = 3
        end
        object chkTradeUnion: TCheckBox
          Left = 431
          Top = 85
          Width = 218
          Height = 17
          Caption = #1063#1083#1077#1085' '#1087#1088#1086#1092#1089#1086#1102#1079#1072' 1%'
          TabOrder = 4
        end
        object seAlimony: TSpinEdit
          Left = 175
          Top = 101
          Width = 121
          Height = 30
          MaxValue = 0
          MinValue = 100
          TabOrder = 5
          Value = 0
        end
      end
    end
    object tsHistory: TTabSheet
      Caption = #1048#1089#1090#1086#1088#1080#1103' '#1085#1072#1095#1080#1089#1083#1077#1085#1080#1081
      ImageIndex = 1
      object PanelHistory: TPanel
        Left = 0
        Top = 0
        Width = 891
        Height = 45
        Align = alTop
        TabOrder = 0
        ExplicitWidth = 1009
        object btnAutoGenerate: TButton
          Left = 8
          Top = 8
          Width = 230
          Height = 28
          Caption = #1047#1072#1087#1086#1083#1085#1080#1090#1100' '#1086#1082#1083#1072#1076#1086#1084' '#1079#1072' 12 '#1084#1077#1089'.'
          TabOrder = 0
          OnClick = btnAutoGenerateClick
        end
        object DBNavHistory: TDBNavigator
          Left = 244
          Top = 11
          Width = 230
          Height = 28
          DataSource = dmMain.dsEmpHistory
          TabOrder = 1
        end
      end
      object DBGridHistory: TDBGrid
        Left = 0
        Top = 45
        Width = 891
        Height = 447
        Align = alClient
        DataSource = dmMain.dsEmpHistory
        TabOrder = 1
        TitleFont.Charset = DEFAULT_CHARSET
        TitleFont.Color = clWindowText
        TitleFont.Height = -15
        TitleFont.Name = 'Segoe UI'
        TitleFont.Style = []
        Columns = <
          item
            Expanded = False
            FieldName = 'period_date'
            Title.Caption = #1055#1077#1088#1080#1086#1076' ('#1084#1077#1089#1103#1094')'
            Width = 150
            Visible = True
          end
          item
            Expanded = False
            FieldName = 'amount'
            Title.Caption = #1057#1091#1084#1084#1072' '#1076#1086#1093#1086#1076#1072
            Width = 180
            Visible = True
          end>
      end
    end
  end
  object Panel1: TPanel
    Left = 0
    Top = 527
    Width = 899
    Height = 49
    Align = alBottom
    TabOrder = 1
    ExplicitTop = 726
    ExplicitWidth = 1017
    object Button1: TButton
      Left = 120
      Top = 9
      Width = 188
      Height = 30
      Caption = #1057#1086#1093#1088#1072#1085#1080#1090#1100' '#1080' '#1079#1072#1082#1088#1099#1090#1100
      ModalResult = 1
      TabOrder = 0
    end
    object Button2: TButton
      Left = 556
      Top = 9
      Width = 99
      Height = 30
      Caption = #1054#1090#1084#1077#1085#1072
      ModalResult = 2
      TabOrder = 1
    end
    object btnSaveOnly: TButton
      Left = 330
      Top = 9
      Width = 175
      Height = 30
      Caption = #1057#1086#1093#1088#1072#1085#1080#1090#1100
      TabOrder = 2
      OnClick = btnSaveOnlyClick
    end
  end
end

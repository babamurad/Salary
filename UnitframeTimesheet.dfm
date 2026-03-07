object frameTimesheet: TframeTimesheet
  Left = 0
  Top = 0
  Width = 1040
  Height = 520
  TabOrder = 0
  PixelsPerInch = 96
  object Splitter1: TSplitter
    Left = 250
    Top = 81
    Height = 398
    ExplicitLeft = 520
    ExplicitTop = 208
    ExplicitHeight = 100
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 1040
    Height = 81
    Align = alTop
    TabOrder = 0
    object Label1: TLabel
      Left = 40
      Top = 19
      Width = 19
      Height = 15
      Caption = #1043#1086#1076
    end
    object Label2: TLabel
      Left = 208
      Top = 16
      Width = 36
      Height = 15
      Caption = #1052#1077#1089#1103#1094
    end
    object Label3: TLabel
      Left = 360
      Top = 19
      Width = 33
      Height = 15
      Caption = #1054#1090#1076#1077#1083
    end
    object cbYear: TComboBox
      Left = 40
      Top = 40
      Width = 145
      Height = 23
      TabOrder = 0
      Items.Strings = (
        '2025'
        '2026'
        '2027'
        '2028')
    end
    object cbMonth: TComboBox
      Left = 200
      Top = 40
      Width = 145
      Height = 23
      TabOrder = 1
      Items.Strings = (
        #1071#1085#1074#1072#1088#1100
        #1060#1077#1074#1088#1072#1083#1100
        #1052#1072#1088#1090
        #1040#1087#1088#1077#1083#1100
        #1052#1072#1081
        #1048#1102#1085#1100
        #1048#1102#1083#1100
        #1040#1074#1075#1091#1089#1090
        #1057#1077#1085#1090#1103#1073#1088#1100
        #1054#1082#1090#1103#1073#1088#1100
        #1053#1086#1103#1073#1088#1100
        #1044#1077#1082#1072#1073#1088#1100)
    end
    object cmbDept: TComboBox
      Left = 360
      Top = 40
      Width = 145
      Height = 23
      TabOrder = 2
    end
    object btnLoad: TButton
      Left = 520
      Top = 39
      Width = 209
      Height = 25
      Caption = #1057#1092#1086#1088#1084#1080#1088#1086#1074#1072#1090#1100' '#1090#1072#1073#1077#1083#1100
      TabOrder = 3
      OnClick = btnLoadClick
    end
    object btnAutoFill: TButton
      Left = 761
      Top = 39
      Width = 192
      Height = 25
      Caption = #1047#1072#1087#1086#1083#1085#1080#1090#1100' '#1087#1086' '#1085#1086#1088#1084#1077
      TabOrder = 4
      OnClick = btnAutoFillClick
    end
  end
  object DBGridTimesheet: TDBGrid
    Left = 253
    Top = 81
    Width = 787
    Height = 398
    Align = alClient
    DataSource = dmMain.dsTimesheet
    Options = [dgEditing, dgAlwaysShowEditor, dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgConfirmDelete, dgCancelOnExit, dgTitleClick, dgTitleHotTrack]
    TabOrder = 1
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -12
    TitleFont.Name = 'Segoe UI'
    TitleFont.Style = []
    OnDrawColumnCell = DBGridTimesheetDrawColumnCell
  end
  object Panel2: TPanel
    Left = 0
    Top = 479
    Width = 1040
    Height = 41
    Align = alBottom
    TabOrder = 2
    object Label4: TLabel
      Left = 288
      Top = 13
      Width = 145
      Height = 15
      Caption = #1058#1077#1082#1091#1097#1080#1081' '#1089#1086#1090#1088#1091#1076#1085#1080#1082
    end
    object lblCurrentEmp: TLabel
      Left = 496
      Top = 8
      Width = 105
      Height = 21
      Caption = 'lblCurrentEmp'
      Font.Charset = RUSSIAN_CHARSET
      Font.Color = clBlue
      Font.Height = -16
      Font.Name = 'Segoe UI Semibold'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object btnSave: TButton
      Left = 40
      Top = 6
      Width = 169
      Height = 25
      Caption = #1057#1086#1093#1088#1072#1085#1080#1090#1100' '#1090#1072#1073#1077#1083#1100
      TabOrder = 0
      OnClick = btnSaveClick
    end
  end
  object DBGridNames: TDBGrid
    Left = 0
    Top = 81
    Width = 250
    Height = 398
    Align = alLeft
    DataSource = dmMain.dsTimesheet
    Options = [dgEditing, dgTitles, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgConfirmDelete, dgCancelOnExit, dgTitleClick, dgTitleHotTrack]
    ReadOnly = True
    TabOrder = 3
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -12
    TitleFont.Name = 'Segoe UI'
    TitleFont.Style = []
    OnDrawColumnCell = DBGridTimesheetDrawColumnCell
  end
end

object frmLogin: TfrmLogin
  Left = 0
  Top = 0
  BorderStyle = bsNone
  Caption = #1054#1082#1085#1086' '#1074#1093#1086#1076#1072
  ClientHeight = 237
  ClientWidth = 354
  Color = clWindow
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -16
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poScreenCenter
  PixelsPerInch = 96
  TextHeight = 21
  object Label1: TLabel
    Left = 48
    Top = 81
    Width = 263
    Height = 25
    Caption = #55357#56420#1042#1074#1077#1076#1080#1090#1077' '#1087#1072#1088#1086#1083#1100' '#1076#1083#1103' '#1074#1093#1086#1076#1072':'
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clGray
    Font.Height = -19
    Font.Name = 'Segoe UI Semibold'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Label2: TLabel
    Left = 48
    Top = 118
    Width = 22
    Height = 21
    Caption = #55357#56594
  end
  object edtPassword: TEdit
    Left = 78
    Top = 112
    Width = 241
    Height = 33
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -19
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
    PasswordChar = '*'
    TabOrder = 0
    Text = 'admin'
  end
  object btnLogin: TButton
    Left = 56
    Top = 160
    Width = 105
    Height = 41
    Cursor = crHandPoint
    Caption = #1042#1086#1081#1090#1080
    Default = True
    TabOrder = 1
    OnClick = btnLoginClick
  end
  object btnCancel: TButton
    Left = 184
    Top = 160
    Width = 113
    Height = 41
    Cursor = crHandPoint
    Caption = #1054#1090#1084#1077#1085#1072
    TabOrder = 2
    OnClick = btnCancelClick
  end
  object Panel1: TPanel
    AlignWithMargins = True
    Left = 3
    Top = 3
    Width = 348
    Height = 50
    Align = alTop
    BevelOuter = bvNone
    Caption = #1040#1074#1090#1086#1088#1080#1079#1072#1094#1080#1103
    Color = 6538752
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWhite
    Font.Height = -19
    Font.Name = 'Times New Roman'
    Font.Style = [fsBold]
    ParentBackground = False
    ParentFont = False
    TabOrder = 3
  end
end

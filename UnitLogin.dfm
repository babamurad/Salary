object frmLogin: TfrmLogin
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'frmLogin'
  ClientHeight = 441
  ClientWidth = 624
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -16
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poScreenCenter
  PixelsPerInch = 96
  TextHeight = 21
  object Label1: TLabel
    Left = 184
    Top = 112
    Width = 190
    Height = 21
    Caption = #1042#1074#1077#1076#1080#1090#1077' '#1087#1072#1088#1086#1083#1100' '#1076#1083#1103' '#1074#1093#1086#1076#1072':'
  end
  object edtPassword: TEdit
    Left = 184
    Top = 152
    Width = 121
    Height = 29
    PasswordChar = '*'
    TabOrder = 0
    Text = 'edtPassword'
  end
  object btnLogin: TButton
    Left = 184
    Top = 200
    Width = 75
    Height = 25
    Caption = #1042#1086#1081#1090#1080
    Default = True
    TabOrder = 1
    OnClick = btnLoginClick
  end
  object btnCancel: TButton
    Left = 299
    Top = 200
    Width = 75
    Height = 25
    Caption = #1054#1090#1084#1077#1085#1072
    TabOrder = 2
    OnClick = btnCancelClick
  end
end

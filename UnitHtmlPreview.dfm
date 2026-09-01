object frmHtmlPreview: TfrmHtmlPreview
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = #1055#1088#1077#1076#1087#1088#1086#1089#1084#1086#1090#1088' '#1076#1086#1082#1091#1084#1077#1085#1090#1072
  ClientHeight = 750
  ClientWidth = 900
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -16
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poMainFormCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 21
  object PanelBottom: TPanel
    Left = 0
    Top = 690
    Width = 900
    Height = 60
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 0
    object btnPrint: TButton
      Left = 380
      Top = 12
      Width = 140
      Height = 35
      Caption = #1055#1077#1095#1072#1090#1100' '#1076#1086#1082#1091#1084#1077#1085#1090#1072
      TabOrder = 0
      OnClick = btnPrintClick
    end
  end
  object WebBrowser: TWebBrowser
    Left = 0
    Top = 0
    Width = 900
    Height = 690
    Align = alClient
    TabOrder = 1
    ExplicitLeft = 288
    ExplicitTop = 248
    ExplicitWidth = 300
    ExplicitHeight = 150
    ControlData = {
      4C000000055D0000504700000000000000000000000000000000000000000000
      000000004C000000000000000000000001000000E0D057007335CF11AE690800
      2B2E126208000000000000004C0000000114020000000000C000000000000046
      8000000000000000000000000000000000000000000000000000000000000000
      00000000000000000100000000000000000000000000000000000000}
  end
end

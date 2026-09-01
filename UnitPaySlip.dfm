object frmPaySlip: TfrmPaySlip
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = #1044#1077#1090#1072#1083#1080#1079#1072#1094#1080#1103' '#1088#1072#1089#1095#1077#1090#1072
  ClientHeight = 702
  ClientWidth = 832
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
    Top = 661
    Width = 832
    Height = 41
    Align = alBottom
    TabOrder = 0
    object btnPdf: TButton
      Left = 304
      Top = 8
      Width = 75
      Height = 25
      Caption = #1055#1077#1095#1072#1090#1100
      TabOrder = 0
      OnClick = btnPdfClick
    end
  end
  object WebBrowser: TWebBrowser
    Left = 0
    Top = 0
    Width = 832
    Height = 661
    Align = alClient
    TabOrder = 1
    ExplicitLeft = 232
    ExplicitTop = 208
    ExplicitWidth = 300
    ExplicitHeight = 150
    ControlData = {
      4C000000FD550000514400000000000000000000000000000000000000000000
      000000004C000000000000000000000001000000E0D057007335CF11AE690800
      2B2E126208000000000000004C0000000114020000000000C000000000000046
      8000000000000000000000000000000000000000000000000000000000000000
      00000000000000000100000000000000000000000000000000000000}
  end
end

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
  PixelsPerInch = 96
  TextHeight = 21
  object Edge: TEdgeBrowser
    Left = 0
    Top = 0
    Width = 832
    Height = 661
    Align = alClient
    TabOrder = 0
    OnCreateWebViewCompleted = EdgeCreateWebViewCompleted
    ExplicitLeft = 8
    ExplicitTop = 8
    ExplicitWidth = 669
    ExplicitHeight = 121
  end
  object PanelBottom: TPanel
    Left = 0
    Top = 661
    Width = 832
    Height = 41
    Align = alBottom
    TabOrder = 1
    ExplicitLeft = 256
    ExplicitTop = 192
    ExplicitWidth = 185
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
end

object frmReportPayroll: TfrmReportPayroll
  Left = 0
  Top = 0
  Caption = 'frmReportPayroll'
  ClientHeight = 441
  ClientWidth = 624
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  WindowState = wsMaximized
  PixelsPerInch = 96
  TextHeight = 15
  object PanelTop: TPanel
    Left = 0
    Top = 0
    Width = 624
    Height = 41
    Align = alTop
    TabOrder = 0
    ExplicitLeft = 232
    ExplicitTop = 224
    ExplicitWidth = 185
    object btnPrint: TButton
      Left = 16
      Top = 10
      Width = 75
      Height = 25
      Caption = #1055#1077#1095#1072#1090#1100
      TabOrder = 0
      OnClick = btnPrintClick
    end
  end
  object Edge: TEdgeBrowser
    Left = 0
    Top = 41
    Width = 624
    Height = 400
    Align = alClient
    TabOrder = 1
    OnCreateWebViewCompleted = EdgeCreateWebViewCompleted
    ExplicitLeft = 320
    ExplicitTop = 240
    ExplicitWidth = 100
    ExplicitHeight = 40
  end
end

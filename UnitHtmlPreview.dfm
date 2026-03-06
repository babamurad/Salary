object frmHtmlPreview: TfrmHtmlPreview
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Предпросмотр документа'
  ClientHeight = 750
  ClientWidth = 900
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
    Width = 900
    Height = 690
    Align = alClient
    TabOrder = 0
    OnCreateWebViewCompleted = EdgeCreateWebViewCompleted
  end
  object PanelBottom: TPanel
    Left = 0
    Top = 690
    Width = 900
    Height = 60
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 1
    object btnPrint: TButton
      Left = 380
      Top = 12
      Width = 140
      Height = 35
      Caption = 'Печать документа'
      TabOrder = 0
      OnClick = btnPrintClick
    end
  end
end
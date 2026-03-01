object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'Payroll System'
  ClientHeight = 545
  ClientWidth = 992
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -16
  Font.Name = 'Segoe UI'
  Font.Style = []
  WindowState = wsMaximized
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 21
  object Panel1: TPanel
    Left = 680
    Top = 400
    Width = 185
    Height = 41
    Caption = 'Panel1'
    TabOrder = 1
  end
  object PanelMain: TPanel
    Left = 0
    Top = 0
    Width = 992
    Height = 545
    Align = alClient
    TabOrder = 0
    object Splitter1: TSplitter
      Left = 257
      Top = 1
      Height = 543
      ExplicitLeft = 200
      ExplicitTop = 0
      ExplicitHeight = 100
    end
    object PanelLeft: TPanel
      Left = 1
      Top = 1
      Width = 256
      Height = 543
      Align = alLeft
      TabOrder = 0
      object TreeView1: TTreeView
        Left = 1
        Top = 1
        Width = 254
        Height = 541
        Align = alClient
        Indent = 19
        TabOrder = 0
        OnChange = TreeView1Change
      end
    end
    object PageControl1: TPageControl
      Left = 260
      Top = 1
      Width = 731
      Height = 543
      Align = alClient
      TabOrder = 1
      OnDrawTab = PageControl1DrawTab
      OnMouseDown = PageControl1MouseDown
      OnMouseMove = PageControl1MouseMove
    end
  end
  object ImageList1: TImageList
    Left = 272
    Top = 464
  end
end

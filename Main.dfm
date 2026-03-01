object MainForm: TMainForm
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
  Menu = MainMenu1
  WindowState = wsMaximized
  OnCreate = FormCreate
  OnShow = FormShow
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
      Left = 289
      Top = 1
      Height = 543
      ExplicitLeft = 200
      ExplicitTop = 0
      ExplicitHeight = 100
    end
    object PanelLeft: TPanel
      Left = 1
      Top = 1
      Width = 288
      Height = 543
      Align = alLeft
      TabOrder = 0
      object TreeView1: TTreeView
        Left = 1
        Top = 1
        Width = 286
        Height = 541
        Align = alClient
        Indent = 19
        TabOrder = 0
        OnChange = TreeView1Change
        ExplicitWidth = 254
      end
    end
    object PageControl1: TPageControl
      Left = 292
      Top = 1
      Width = 699
      Height = 543
      Align = alClient
      TabOrder = 1
      OnDrawTab = PageControl1DrawTab
      OnMouseDown = PageControl1MouseDown
      OnMouseMove = PageControl1MouseMove
      ExplicitLeft = 260
      ExplicitWidth = 731
    end
  end
  object ImageList1: TImageList
    Left = 272
    Top = 464
  end
  object MainMenu1: TMainMenu
    Left = 840
    Top = 152
    object N1: TMenuItem
      Caption = #1041#1072#1079#1072' '#1076#1072#1085#1085#1099#1093
      object N2: TMenuItem
        Caption = #1054#1090#1082#1088#1099#1090#1100' '#1073#1072#1079#1091' '#1076#1072#1085#1085#1099#1093
        OnClick = N2Click
      end
      object N3: TMenuItem
        Caption = #1057#1086#1079#1076#1072#1090#1100' '#1085#1086#1074#1091#1102' '#1073#1072#1079#1091
        OnClick = N3Click
      end
    end
    object N4: TMenuItem
      Caption = #1057#1087#1088#1072#1074#1082#1072
      object N5: TMenuItem
        Caption = #1056#1091#1082#1086#1074#1086#1076#1089#1090#1074#1086' '#1087#1086#1083#1100#1079#1086#1074#1072#1090#1077#1083#1103
        OnClick = N5Click
      end
    end
  end
  object dlgOpenDb: TOpenDialog
    Left = 840
    Top = 232
  end
  object dlgSaveDb: TSaveDialog
    Left = 840
    Top = 304
  end
end

object frameVacations: TframeVacations
  Left = 0
  Top = 0
  Width = 931
  Height = 552
  TabOrder = 0
  PixelsPerInch = 96
  object PanelTop: TPanel
    Left = 0
    Top = 0
    Width = 931
    Height = 41
    Align = alTop
    TabOrder = 0
    ExplicitLeft = 376
    ExplicitTop = 256
    ExplicitWidth = 185
    object btnAdd: TButton
      Left = 232
      Top = 8
      Width = 121
      Height = 25
      Caption = #1053#1086#1074#1099#1081' '#1088#1072#1089#1095#1077#1090
      TabOrder = 0
      OnClick = btnAddClick
    end
    object btnDelete: TButton
      Left = 376
      Top = 8
      Width = 115
      Height = 25
      Caption = #1059#1076#1072#1083#1080#1090#1100
      TabOrder = 1
      OnClick = btnDeleteClick
    end
    object btnRefresh: TButton
      Left = 521
      Top = 8
      Width = 112
      Height = 25
      Caption = #1054#1073#1085#1086#1074#1080#1090#1100
      TabOrder = 2
    end
    object btnPrint: TButton
      Left = 664
      Top = 8
      Width = 75
      Height = 25
      Caption = #1055#1077#1095#1072#1090#1100
      TabOrder = 3
      OnClick = btnPrintClick
    end
  end
  object DBGridVacations: TDBGrid
    Left = 0
    Top = 41
    Width = 931
    Height = 511
    Align = alClient
    DataSource = dmMain.dsVacation
    TabOrder = 1
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -12
    TitleFont.Name = 'Segoe UI'
    TitleFont.Style = []
  end
end

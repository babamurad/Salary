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
    Height = 80
    Align = alTop
    TabOrder = 0
    ExplicitLeft = 376
    ExplicitTop = 256
    ExplicitWidth = 185
    object Label1: TLabel
      Left = 8
      Top = 52
      Width = 82
      Height = 15
      Caption = #1055#1086#1080#1089#1082' '#1087#1086' '#1060#1048#1054':'
    end
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
    object edtSearch: TEdit
      Left = 100
      Top = 49
      Width = 300
      Height = 23
      TabOrder = 4
      OnChange = edtSearchChange
    end
  end
  object DBGridVacations: TDBGrid
    Left = 0
    Top = 80
    Width = 931
    Height = 472
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

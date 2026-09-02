object frameJournal: TframeJournal
  Left = 0
  Top = 0
  Width = 900
  Height = 600
  Align = alClient
  TabOrder = 0
  PixelsPerInch = 96
  object PanelEntries: TPanel
    Left = 0
    Top = 0
    Width = 900
    Height = 41
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 0
    object DBNavigator1: TDBNavigator
      Left = 0
      Top = 0
      Width = 265
      Height = 41
      Align = alLeft
      Flat = True
      TabOrder = 0
    end
    object LabelEntries: TLabel
      Left = 275
      Top = 13
      Width = 111
      Height = 13
      Caption = 'Документы (проводки)'
    end
    object ButtonToggleStatus: TButton
      Left = 780
      Top = 6
      Width = 110
      Height = 29
      Anchors = [akTop, akRight]
      Caption = 'Провести'
      TabOrder = 1
      OnClick = ButtonToggleStatusClick
    end
  end
  object DBGridEntries: TDBGrid
    Left = 0
    Top = 41
    Width = 900
    Height = 200
    Align = alTop
    TabOrder = 1
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -12
    TitleFont.Name = 'Segoe UI'
    TitleFont.Style = []
  end
  object Splitter1: TSplitter
    Left = 0
    Top = 241
    Width = 900
    Height = 5
    Cursor = crVSplit
    Align = alTop
  end
  object PanelLines: TPanel
    Left = 0
    Top = 246
    Width = 900
    Height = 41
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 2
    object DBNavigator2: TDBNavigator
      Left = 0
      Top = 0
      Width = 265
      Height = 41
      Align = alLeft
      Flat = True
      TabOrder = 0
    end
    object LabelLines: TLabel
      Left = 275
      Top = 13
      Width = 96
      Height = 13
      Caption = 'Строки проводки'
    end
    object LabelTotal: TLabel
      Left = 620
      Top = 13
      Width = 270
      Height = 13
      Anchors = [akTop, akRight]
      Alignment = taRightJustify
      Caption = 'Итого по документу: 0.00'
    end
  end
  object DBGridLines: TDBGrid
    Left = 0
    Top = 287
    Width = 900
    Height = 313
    Align = alClient
    TabOrder = 3
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -12
    TitleFont.Name = 'Segoe UI'
    TitleFont.Style = []
  end
end

object frameDepts: TframeDepts
  Left = 0
  Top = 0
  Width = 669
  Height = 434
  Align = alClient
  TabOrder = 0
  PixelsPerInch = 96
  object PanelTop: TPanel
    Left = 0
    Top = 0
    Width = 669
    Height = 41
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 0
    ExplicitWidth = 600
    object DBNavigator1: TDBNavigator
      Left = 0
      Top = 0
      Width = 265
      Height = 41
      Align = alLeft
      Flat = True
      TabOrder = 0
    end
  end
  object DBGrid1: TDBGrid
    Left = 0
    Top = 41
    Width = 669
    Height = 393
    Align = alClient
    DataSource = dmMain.dsDepts
    TabOrder = 1
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -12
    TitleFont.Name = 'Segoe UI'
    TitleFont.Style = []
  end
end

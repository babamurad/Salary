object frameSettings: TframeSettings
  Left = 0
  Top = 0
  Width = 979
  Height = 500
  Align = alClient
  TabOrder = 0
  PixelsPerInch = 96
  object PageControl1: TPageControl
    Left = 0
    Top = 0
    Width = 979
    Height = 500
    ActivePage = tsGeneral
    Align = alClient
    TabOrder = 0
    object tsGeneral: TTabSheet
      Caption = #1043#1083#1086#1073#1072#1083#1100#1085#1099#1077' '#1085#1072#1089#1090#1088#1086#1081#1082#1080
      object DBGrid1: TDBGrid
        Left = 0
        Top = 41
        Width = 971
        Height = 429
        Align = alClient
        DataSource = dmMain.dsSettings
        TabOrder = 0
        TitleFont.Charset = DEFAULT_CHARSET
        TitleFont.Color = clWindowText
        TitleFont.Height = -12
        TitleFont.Name = 'Segoe UI'
        TitleFont.Style = []
        OnDrawColumnCell = DBGrid1DrawColumnCell
      end
      object Panel2: TPanel
        Left = 0
        Top = 0
        Width = 971
        Height = 41
        Align = alTop
        TabOrder = 1
        object DBNavigator1: TDBNavigator
          Left = 8
          Top = 7
          Width = 240
          Height = 25
          DataSource = dmMain.dsSettings
          TabOrder = 0
        end
      end
    end
    object tsSickLeave: TTabSheet
      Caption = #1057#1090#1072#1074#1082#1080' '#1087#1086' '#1073#1086#1083#1100#1085#1080#1095#1085#1099#1084' '#1083#1080#1089#1090#1072#1084
      object DBGrid2: TDBGrid
        Left = 0
        Top = 0
        Width = 971
        Height = 470
        Align = alClient
        TabOrder = 0
        TitleFont.Charset = DEFAULT_CHARSET
        TitleFont.Color = clWindowText
        TitleFont.Height = -12
        TitleFont.Name = 'Segoe UI'
        TitleFont.Style = []
      end
    end
    object TabSheet1: TTabSheet
      Caption = #1056#1077#1082#1074#1080#1079#1080#1090#1099' '#1087#1088#1077#1076#1087#1088#1080#1103#1090#1080#1103
      ImageIndex = 2
      object DBGridCompany: TDBGrid
        Left = 0
        Top = 0
        Width = 971
        Height = 470
        Align = alClient
        DataSource = dmMain.dsCompanyInfo
        TabOrder = 0
        TitleFont.Charset = DEFAULT_CHARSET
        TitleFont.Color = clWindowText
        TitleFont.Height = -12
        TitleFont.Name = 'Segoe UI'
        TitleFont.Style = []
      end
    end
  end
end

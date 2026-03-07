object FrameReportSummary: TFrameReportSummary
  Left = 0
  Top = 0
  Width = 1061
  Height = 652
  TabOrder = 0
  PixelsPerInch = 96
  object PanelTop: TPanel
    Left = 0
    Top = 0
    Width = 1061
    Height = 49
    Align = alTop
    TabOrder = 0
    object cmbYear: TComboBox
      Left = 8
      Top = 12
      Width = 145
      Height = 23
      TabOrder = 0
      Text = 'cmbYear'
    end
    object cmbMonth: TComboBox
      Left = 159
      Top = 12
      Width = 170
      Height = 23
      TabOrder = 1
      Text = 'cmbMonth'
    end
    object cmbDept: TComboBox
      Left = 335
      Top = 12
      Width = 178
      Height = 23
      TabOrder = 2
      Text = 'cmbDept'
    end
    object btnGenerate: TButton
      Left = 519
      Top = 10
      Width = 162
      Height = 25
      Caption = #1057#1074#1086#1076#1085#1072#1103' '#1074#1077#1076#1086#1084#1086#1089#1090#1100
      TabOrder = 3
      OnClick = btnGenerateClick
    end
    object btnPrint: TButton
      Left = 687
      Top = 10
      Width = 75
      Height = 25
      Caption = #1055#1077#1095#1072#1090#1100
      TabOrder = 4
      OnClick = btnPrintClick
    end
    object btnExcel: TButton
      Left = 768
      Top = 10
      Width = 75
      Height = 25
      Caption = 'Excel'
      TabOrder = 5
      OnClick = btnExcelClick
    end
  end
  object Edge: TEdgeBrowser
    Left = 0
    Top = 49
    Width = 1061
    Height = 603
    Align = alClient
    TabOrder = 1
    OnCreateWebViewCompleted = EdgeCreateWebViewCompleted
  end
  object qryReport: TFDQuery
    Connection = dmMain.conn
    Left = 968
    Top = 304
  end
  object dsReport: TDataSource
    DataSet = qryReport
    Left = 960
    Top = 376
  end
end

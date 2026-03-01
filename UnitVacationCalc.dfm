object FormVacationCalc: TFormVacationCalc
  Left = 0
  Top = 0
  Caption = 'FormVacationCalc'
  ClientHeight = 530
  ClientWidth = 999
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  PixelsPerInch = 96
  TextHeight = 15
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 999
    Height = 185
    Align = alTop
    TabOrder = 0
    object DBLookupComboBox1: TDBLookupComboBox
      Left = 16
      Top = 16
      Width = 145
      Height = 23
      DataField = 'fio'
      DataSource = dmMain.dsVacation
      KeyField = 'id'
      ListField = 'fio'
      ListSource = dmMain.dsEmployees
      TabOrder = 0
    end
    object dtpEnd: TDateTimePicker
      Left = 296
      Top = 75
      Width = 186
      Height = 23
      Date = 46081.000000000000000000
      Time = 0.860848032411013300
      TabOrder = 1
    end
    object dtpStart: TDateTimePicker
      Left = 16
      Top = 75
      Width = 186
      Height = 23
      Date = 46081.000000000000000000
      Time = 0.860785960649082000
      TabOrder = 2
    end
    object Edit1: TEdit
      Left = 528
      Top = 75
      Width = 121
      Height = 23
      TabOrder = 3
      Text = 'Edit1'
    end
    object Button1: TButton
      Left = 32
      Top = 121
      Width = 75
      Height = 25
      Caption = #1056#1072#1089#1089#1095#1080#1090#1072#1090#1100
      TabOrder = 4
    end
    object Button2: TButton
      Left = 136
      Top = 121
      Width = 75
      Height = 25
      Caption = #1057#1086#1093#1088#1072#1085#1080#1090#1100
      TabOrder = 5
    end
  end
  object DBLookupComboBox2: TDBLookupComboBox
    Left = 72
    Top = 248
    Width = 145
    Height = 23
    DataField = 'emp_id'
    DataSource = dmMain.dsVacation
    KeyField = 'id'
    ListField = 'fio'
    ListSource = dmMain.dsEmployees
    TabOrder = 1
  end
end

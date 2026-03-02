object FormVacationCalc: TFormVacationCalc
  Left = 0
  Top = 0
  Caption = 'FormVacationCalc'
  ClientHeight = 227
  ClientWidth = 819
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -15
  Font.Name = 'Segoe UI'
  Font.Style = []
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 20
  object Button1: TButton
    Left = 32
    Top = 152
    Width = 98
    Height = 25
    Caption = #1056#1072#1089#1089#1095#1080#1090#1072#1090#1100
    TabOrder = 0
    OnClick = Button1Click
  end
  object ButtonSave: TButton
    Left = 216
    Top = 152
    Width = 105
    Height = 25
    Caption = #1057#1086#1093#1088#1072#1085#1080#1090#1100
    TabOrder = 1
    OnClick = ButtonSaveClick
  end
  object cmbEmployee: TComboBox
    Left = 32
    Top = 24
    Width = 426
    Height = 28
    Style = csDropDownList
    TabOrder = 2
  end
  object dtpEnd: TDateTimePicker
    Left = 272
    Top = 75
    Width = 186
    Height = 28
    Date = 46081.000000000000000000
    Time = 0.860848032411013300
    TabOrder = 3
  end
  object dtpStart: TDateTimePicker
    Left = 32
    Top = 75
    Width = 186
    Height = 28
    Date = 46081.000000000000000000
    Time = 0.860785960649082000
    TabOrder = 4
  end
  object GroupBox1: TGroupBox
    Left = 504
    Top = 8
    Width = 297
    Height = 169
    Caption = #1056#1077#1079#1091#1083#1100#1090#1072#1090#1099
    TabOrder = 5
    object lbResult: TLabel
      Left = 16
      Top = 19
      Width = 4
      Height = 20
    end
  end
end

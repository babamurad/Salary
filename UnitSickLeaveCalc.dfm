object FormSickLeaveCalc: TFormSickLeaveCalc
  Left = 0
  Top = 0
  Caption = 'FormSickLeaveCalc'
  ClientHeight = 385
  ClientWidth = 753
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -15
  Font.Name = 'Segoe UI'
  Font.Style = []
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 20
  object ComboBox1: TComboBox
    Left = 32
    Top = 56
    Width = 145
    Height = 28
    TabOrder = 0
    Text = 'ComboBox1'
  end
  object dtpStart: TDateTimePicker
    Left = 208
    Top = 56
    Width = 186
    Height = 28
    Date = 46082.000000000000000000
    Time = 0.439309039349609500
    TabOrder = 1
  end
  object dtpEnd: TDateTimePicker
    Left = 424
    Top = 56
    Width = 186
    Height = 28
    Date = 46082.000000000000000000
    Time = 0.439358958334196400
    TabOrder = 2
  end
  object edtTotalExp: TEdit
    Left = 360
    Top = 136
    Width = 121
    Height = 28
    TabOrder = 3
    Text = 'edtTotalExp'
  end
  object edtPercent: TEdit
    Left = 208
    Top = 136
    Width = 121
    Height = 28
    TabOrder = 4
    Text = 'edtPercent'
  end
  object Button1: TButton
    Left = 96
    Top = 224
    Width = 113
    Height = 25
    Caption = #1056#1072#1089#1089#1095#1080#1090#1072#1090#1100
    TabOrder = 5
    OnClick = Button1Click
  end
  object btnSave: TButton
    Left = 310
    Top = 224
    Width = 115
    Height = 25
    Caption = #1057#1086#1093#1088#1072#1085#1080#1090#1100
    TabOrder = 6
    OnClick = btnSaveClick
  end
end

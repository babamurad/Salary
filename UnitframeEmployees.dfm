object frameEmployees: TframeEmployees
  Left = 0
  Top = 0
  Width = 640
  Height = 480
  TabOrder = 0
  PixelsPerInch = 96
  object Label1: TLabel
    Left = 304
    Top = 232
    Width = 57
    Height = 15
    Caption = 'Employees'
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 640
    Height = 41
    Align = alTop
    TabOrder = 0
    ExplicitLeft = 176
    ExplicitTop = 56
    ExplicitWidth = 185
    object BtnAdd: TButton
      Left = 24
      Top = 9
      Width = 75
      Height = 25
      Caption = 'BtnAdd'
      TabOrder = 0
      OnClick = BtnAddClick
    end
  end
end

object Form2: TForm2
  Left = 0
  Top = 0
  Caption = 'Form2'
  ClientHeight = 511
  ClientWidth = 800
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 15
  object ListBoxNav: TListBox
    Left = 0
    Top = 0
    Width = 257
    Height = 511
    Style = lbOwnerDrawFixed
    Align = alLeft
    BorderStyle = bsNone
    ItemHeight = 20
    TabOrder = 0
    OnClick = ListBoxNavClick
    OnDrawItem = ListBoxNavDrawItem
    OnEnter = ListBoxNavEnter
    OnMouseLeave = ListBoxNavMouseLeave
    OnMouseMove = ListBoxNavMouseMove
  end
end

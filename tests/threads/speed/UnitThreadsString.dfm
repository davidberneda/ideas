object FormThreads2: TFormThreads2
  Left = 0
  Top = 0
  Caption = 'Threads Speed Test'
  ClientHeight = 420
  ClientWidth = 431
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  OnCreate = FormCreate
  TextHeight = 15
  object Memo1: TMemo
    Left = 8
    Top = 32
    Width = 393
    Height = 305
    TabOrder = 0
  end
  object Button1: TButton
    Left = 8
    Top = 360
    Width = 75
    Height = 25
    Caption = 'Run again'
    TabOrder = 1
    OnClick = Button1Click
  end
end

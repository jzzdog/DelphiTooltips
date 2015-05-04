object ServerForm: TServerForm
  Left = 537
  Top = 206
  Width = 706
  Height = 492
  Caption = 'Tcp socket server (port 10000)'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -14
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  DesignSize = (
    688
    445)
  PixelsPerInch = 120
  TextHeight = 16
  object Memo: TMemo
    Left = 10
    Top = 10
    Width = 664
    Height = 386
    Anchors = [akLeft, akTop, akRight, akBottom]
    ScrollBars = ssVertical
    TabOrder = 0
  end
  object btStartServer: TButton
    Left = 584
    Top = 405
    Width = 92
    Height = 31
    Anchors = [akRight, akBottom]
    Caption = 'Start server'
    TabOrder = 1
    OnClick = btStartServerClick
  end
  object btStopServer: TButton
    Left = 484
    Top = 405
    Width = 92
    Height = 31
    Anchors = [akRight, akBottom]
    Caption = 'Stop server'
    TabOrder = 2
    OnClick = btStopServerClick
  end
  object cbConvert: TCheckBox
    Left = 10
    Top = 405
    Width = 198
    Height = 21
    Anchors = [akLeft, akBottom]
    Caption = #1050#1086#1085#1074#1077#1088#1090#1080#1088#1086#1074#1072#1090#1100' '#1080#1079' utf-8'
    TabOrder = 3
  end
end

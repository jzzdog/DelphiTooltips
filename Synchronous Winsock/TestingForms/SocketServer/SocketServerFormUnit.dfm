object ServerForm: TServerForm
  Left = 537
  Top = 206
  Width = 505
  Height = 380
  Caption = 'Tcp socket server (port 10000)'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  DesignSize = (
    489
    342)
  PixelsPerInch = 96
  TextHeight = 13
  object Memo: TMemo
    Left = 8
    Top = 8
    Width = 478
    Height = 296
    Anchors = [akLeft, akTop, akRight, akBottom]
    ScrollBars = ssVertical
    TabOrder = 0
  end
  object btStartServer: TButton
    Left = 410
    Top = 313
    Width = 74
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'Start server'
    TabOrder = 1
    OnClick = btStartServerClick
  end
  object btStopServer: TButton
    Left = 328
    Top = 313
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'Stop server'
    TabOrder = 2
    OnClick = btStopServerClick
  end
  object cbConvert: TCheckBox
    Left = 9
    Top = 313
    Width = 161
    Height = 17
    Anchors = [akLeft, akBottom]
    Caption = #1050#1086#1085#1074#1077#1088#1090#1080#1088#1086#1074#1072#1090#1100' '#1080#1079' utf-8'
    TabOrder = 3
  end
end

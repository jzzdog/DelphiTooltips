object SocketClientForm: TSocketClientForm
  Left = 716
  Top = 193
  Width = 683
  Height = 415
  Caption = 'Tcp socket client (port 10000)'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  DesignSize = (
    667
    377)
  PixelsPerInch = 96
  TextHeight = 13
  object Memo: TMemo
    Left = 344
    Top = 0
    Width = 320
    Height = 338
    Anchors = [akLeft, akTop, akRight, akBottom]
    Lines.Strings = (
      '<s:Envelope '
      'xmlns:s="http://schemas.xmlsoap.org/soap/envelope/">'
      '  <s:Header>'
      '    <Action '
      'xmlns="http://schemas.microsoft.com/ws/2005/05/addressin'
      'g/none" '
      's:mustUnderstand="1">http://tempuri.org/IMeasurementServi'
      'ce/GetRoute</Action>'
      '  </s:Header>'
      '  <s:Body>'
      '    <GetRoute xmlns="http://tempuri.org/">'
      '      <barcode>77-1024-0043/1</barcode>'
      '    </GetRoute>'
      '  </s:Body>'
      '</s:Envelope>')
    ScrollBars = ssVertical
    TabOrder = 0
  end
  object btSend: TButton
    Left = 88
    Top = 349
    Width = 75
    Height = 24
    Anchors = [akLeft, akBottom]
    Caption = 'Send'
    TabOrder = 1
    OnClick = btSendClick
  end
  object btConnect: TButton
    Left = 8
    Top = 349
    Width = 75
    Height = 24
    Anchors = [akLeft, akBottom]
    Caption = 'Connect'
    TabOrder = 2
    OnClick = btConnectClick
  end
  object btDisconnect: TButton
    Left = 168
    Top = 349
    Width = 75
    Height = 24
    Anchors = [akLeft, akBottom]
    Caption = 'Disconnect'
    TabOrder = 3
    OnClick = btDisconnectClick
  end
  object btTestCase1: TButton
    Left = 342
    Top = 348
    Width = 75
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = 'Test case 1'
    TabOrder = 4
    OnClick = btTestCase1Click
  end
  object cbTesCase2: TButton
    Left = 432
    Top = 348
    Width = 75
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = 'Tes case 2'
    TabOrder = 5
    OnClick = cbTesCase2Click
  end
  object memoLog: TMemo
    Left = 0
    Top = 0
    Width = 329
    Height = 336
    Anchors = [akLeft, akTop, akBottom]
    ScrollBars = ssVertical
    TabOrder = 6
  end
end

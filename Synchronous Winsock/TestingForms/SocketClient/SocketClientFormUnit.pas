unit SocketClientFormUnit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, winsock, StdCtrls;

type
  TSocketClientForm = class(TForm)
    Memo: TMemo;
    btSend: TButton;
    btConnect: TButton;
    btDisconnect: TButton;
    btTestCase1: TButton;
    cbTesCase2: TButton;
    memoLog: TMemo;
    procedure btSendClick(Sender: TObject);
    procedure btConnectClick(Sender: TObject);
    procedure btDisconnectClick(Sender: TObject);
    procedure btTestCase1Click(Sender: TObject);
    procedure cbTesCase2Click(Sender: TObject);
  private
    FConnected: boolean;
    FSocket : TSocket;
    function Recv: string;
    procedure WriteLog(AMessage: string);
  public
    { Public declarations }
  end;

var
  SocketClientForm: TSocketClientForm;

implementation

{$R *.dfm}

procedure TSocketClientForm.btSendClick(Sender: TObject);
var
  buf : string;
begin
  //if not FConnected then
    //raise Exception.Create('Необходимо подключиться');

  buf := Memo.Text;
  if send(FSocket,buf[1],Length(buf),0) = SOCKET_ERROR then
    ShowMessage('Ошибка отправки сообщения');
  WriteLog(Recv);
end;

procedure TSocketClientForm.WriteLog(AMessage: string);
begin
  memoLog.Lines.Add(EmptyStr);
  memoLog.Lines.Add(AMessage);
  //memoLog.Text := memoLog.Text + AMessage;
end;

procedure TSocketClientForm.btConnectClick(Sender: TObject);
const
  cPort = 10000;
var
  vWSAData : TWSAData;
  vSockAddr : TSockAddr;
begin
  //if FConnected then
    //raise Exception.Create('Уже подключены');

  if WSAStartup($101, vWSAData)<>0 then
    raise Exception.Create('Ошибка инициализации WSAStartup');

  FSocket := socket(AF_INET,SOCK_STREAM,IPPROTO_IP);
  if FSocket = INVALID_SOCKET then
    raise Exception.Create('Ошибка создания сокета');

  FillChar(vSockAddr,SizeOf(TSockAddr),0);
  vSockAddr.sin_family := AF_INET;
  vSockAddr.sin_port := htons(cPort);
  vSockAddr.sin_addr.S_addr := inet_addr('127.0.0.1');
  if connect(FSocket,vSockAddr,SizeOf(TSockAddr)) <> SOCKET_ERROR then
  begin
    WriteLog('Connection - OK');
    FConnected := true;
  end
  else begin
    ShowMessage('Не удается подключиться к серверу!');
  end;

end;

procedure TSocketClientForm.btDisconnectClick(Sender: TObject);
begin
  //if not FConnected then
    //raise Exception.Create('Еще не подключены');

  closesocket(FSocket);
  WSACleanup;
end;

procedure TSocketClientForm.btTestCase1Click(Sender: TObject);
const
  BR = #13;
var
  s: string;
begin
  s :='<s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/">' + BR
  + '  <s:Header>' + BR
  + '    <Action xmlns="http://schemas.microsoft.com/ws/2005/05/addressing/none"' + BR
  + 's:mustUnderstand="1">http://tempuri.org/IMeasurementService/GetRoute</Action>' + BR
  + '  </s:Header>' + BR
  + '  <s:Body>' + BR
  + '    <GetRoute xmlns="http://tempuri.org/">' + BR
  + '      <barcode>77-1024-0043/1</barcode>' + BR
  + '    </GetRoute>' + BR
  + '  </s:Body>' + BR
  + '</s:Envelope>';

  Memo.Lines.Text := s;
end;

procedure TSocketClientForm.cbTesCase2Click(Sender: TObject);
const
  BR = #13;
var
  s: string;
begin
  s :='<s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/">' + BR
  + '  <s:Header>' + BR
  + '    <Action xmlns="http://schemas.microsoft.com/ws/2005/05/addressing/none" s:mustUnderstand="1">http://tempuri.org/IMeasurementService/SaveMeasure</Action>' + BR
  + '  </s:Header>' + BR
  + '  <s:Body>' + BR
  + '    <SaveMeasure xmlns="http://tempuri.org/">' + BR
  + '      <measure xmlns:d4p1="http://schemas.datacontract.org/2004/07/PE_UI_WcfService" xmlns:i="http://www.w3.org/2001/XMLSchema-instance">' + BR
  + '        <d4p1:Barcode>77-1024-0043</d4p1:Barcode>' + BR
  + '        <d4p1:Height>10</d4p1:Height>' + BR
  + '        <d4p1:Length>20</d4p1:Length>' + BR
  + '        <d4p1:Weight>1000</d4p1:Weight>' + BR
  + '        <d4p1:Width>25</d4p1:Width>' + BR
  + '      </measure>' + BR
  + '    </SaveMeasure>' + BR
  + '  </s:Body>' + BR
  + '</s:Envelope>';
  Memo.Lines.Text := s;
end;

function TSocketClientForm.Recv: string;
var
  BufArr: array of Char;
  BufStr, ReceivedStr: string;
  RecvSize: integer;
  vSize: integer;
  BufSize: integer;
begin
  // определяем размер буфера чтения для сокета
  vSize := sizeOf(BufSize);
  getsockopt(FSocket, SOL_SOCKET, SO_RCVBUF, PChar(@BufSize), vSize);
  WriteLog(format('Receive buffer size [%d]', [BufSize]));
  SetLength(BufArr, BufSize);

  repeat

    // сокет в блокирующем режиме, следующая строка кода не
    // получит управление, пока не поступят данные от клиента.
    RecvSize := winsock.recv(FSocket, BufArr[0], BufSize, 0);

    if RecvSize > 0 then //если получили 0, значит на клиенте закрыли соединение
    begin
      SetLength(BufStr, RecvSize);
      lstrcpyn(@BufStr[1], @BufArr[0], RecvSize + 1);
      ReceivedStr := ReceivedStr + BufStr;
    end;

  until RecvSize < BufSize;
  SetLength(BufArr, 0);
  Result := ReceivedStr;
end;

end.

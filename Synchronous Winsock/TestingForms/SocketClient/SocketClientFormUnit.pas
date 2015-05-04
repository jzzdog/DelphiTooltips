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
    procedure btSendClick(Sender: TObject);
    procedure btConnectClick(Sender: TObject);
    procedure btDisconnectClick(Sender: TObject);
  private
    FConnected: boolean;
    FSocket : TSocket;
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
    //raise Exception.Create('���������� ������������');

  buf := Memo.Text;
  if send(FSocket,buf[1],Length(buf),0) = SOCKET_ERROR then
    ShowMessage('������ �������� ���������');

end;

procedure TSocketClientForm.WriteLog(AMessage: string);
begin
//
end;

procedure TSocketClientForm.btConnectClick(Sender: TObject);
const
  cPort = 10000;
var
  vWSAData : TWSAData;
  vSockAddr : TSockAddr;
begin
  //if FConnected then
    //raise Exception.Create('��� ����������');

  if WSAStartup($101, vWSAData)<>0 then
    raise Exception.Create('������ ������������� WSAStartup');

  FSocket := socket(AF_INET,SOCK_STREAM,IPPROTO_IP);
  if FSocket = INVALID_SOCKET then
    raise Exception.Create('������ �������� ������');

  FillChar(vSockAddr,SizeOf(TSockAddr),0);
  vSockAddr.sin_family := AF_INET;
  vSockAddr.sin_port := htons(cPort);
  vSockAddr.sin_addr.S_addr := inet_addr('127.0.0.1');
  if connect(FSocket,vSockAddr,SizeOf(TSockAddr)) <> SOCKET_ERROR then
  begin
    ShowMessage('OK');
    FConnected := true;
  end
  else begin
    ShowMessage('�� ������� ������������ � �������!');
  end;

end;

procedure TSocketClientForm.btDisconnectClick(Sender: TObject);
begin
  //if not FConnected then
    //raise Exception.Create('��� �� ����������');

  closesocket(FSocket);
  WSACleanup;
end;

end.

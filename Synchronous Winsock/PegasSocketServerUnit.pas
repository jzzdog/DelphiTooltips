//Класс создает поток для прослушивания порта через сокеты в
//ассинхронном(блокирующем режиме). При акцепте соединения создается отедльный
//поток для обмена данными с клиентом.


unit PegasSocketServerUnit;

interface

uses Windows, SysUtils, Winsock, Syncobjs, Classes, Messages;

const
  WRITE_LOG_MESSAGE = WM_USER + 10001;
  RECIEVED_DATA_MESSAGE = WM_USER + 10002;

type

  TCallBackProcedure = procedure(AMessage: string) of object;
  TWriteLogProcedure = procedure(AMessage: string) of object;

  TPegasSocketServer = class(TObject)
  private
    FListeningPort: Word;
    FListeningSocket: TSocket;
    FServerThreadHandle: THandle;
    FServerThreadID: Cardinal;
    FCallBackProcedure: TCallBackProcedure;
    FWriteLogProcedure: TWriteLogProcedure;
    FMessageHandler: HWND;
    FTerminated: boolean;
    FClientsSocketList: TList;
    Procedure WriteLog(AMessage: string);
    Procedure CallBackProc(AMessage: string);
    function GetTerminated: boolean;
    procedure SetTerminated(const Value: boolean);
    function GetListeningSocket: TSocket;
    procedure Init(AListeningPort: Word);
  public
    property Terminated: boolean read GetTerminated write SetTerminated;
    property ListeningSocket: TSocket read GetListeningSocket;
    procedure StartServer;
    procedure StopServer;

    constructor Create(AListeningPort: Word; ACallBackProcedure: TCallBackProcedure;
      AWriteLogProcedure: TWriteLogProcedure); reintroduce; overload;

    constructor Create(AListeningPort: Word; AMessageHandler: HWND);
      reintroduce; overload;

    destructor Destroy; override;
  end;

  TClientSocketInfo = class(TObject)
  private
    FSocket: TSocket;
    FThreadHandle: THandle;
    FThreadID: Cardinal;
    FPegasSocketServer: TPegasSocketServer;
    FActive: boolean;
    function GetActive: boolean;
    procedure SetActive(const Value: boolean);
    function GetSocket: TSocket;
    function GetIsServerTerminated: Boolean;
  public
    property Active: boolean read GetActive write SetActive;
    property Socket: TSocket read GetSocket;
    property IsServerTerminated: Boolean read GetIsServerTerminated;
    constructor Create(ASocket: TSocket; APegasSocketServer: TPegasSocketServer); reintroduce;
    destructor Destroy; override;
  end;

implementation

var
  CriticalSection: TCriticalSection;

procedure SocketThread(AClientSocketInfo: TClientSocketInfo);

  procedure WriteLog(AMessage: string);
  begin
    AClientSocketInfo.FPegasSocketServer.WriteLog(AMessage);
  end;

var
  SockName: TSockAddr;
  Socket: TSocket;
  BufArr: array of Char;
  BufStr, RecievedStr: string;
  RecvSize: integer;
  vSize: integer;
  BufSize: integer;
begin
  try
    Socket := AClientSocketInfo.Socket;

    vSize := SizeOf(TSockAddr);
    getpeername(Socket, SockName, vSize);
    WriteLog(format('Client accepted, remote address [%s].',
      [inet_ntoa(SockName.sin_addr)]));

    // определяем размер буфера чтения для сокета
    vSize := sizeOf(BufSize);
    getsockopt(Socket, SOL_SOCKET, SO_RCVBUF, PChar(@BufSize), vSize);
    WriteLog(format('Receive buffer size [%d]', [BufSize]));
    SetLength(BufArr, BufSize);

    while not AClientSocketInfo.IsServerTerminated do
    begin

      // сокет в блокирующем режиме, следующая строка кода не
      // получит управление, пока не поступят данные от клиента.
      RecvSize := recv(Socket, BufArr[0], BufSize, 0);

      if RecvSize <= 0 then //если получили 0, значит на клиенте закрыли соединение
        Break;

      SetLength(BufStr, RecvSize);
      lstrcpyn(@BufStr[1], @BufArr[0], RecvSize + 1);
      RecievedStr := RecievedStr + BufStr;

      // последний пакет
      if RecvSize < BufSize then
      begin
        AClientSocketInfo.FPegasSocketServer.CallBackProc(BufStr);
        RecievedStr := EmptyStr;
      end;
    end;

    WriteLog(format('Client disconnected, remote address [%s].',
      [inet_ntoa(SockName.sin_addr)]));
    SetLength(BufArr, 0);
    closesocket(Socket);
  finally
    AClientSocketInfo.Active := False;
  end;
end;

procedure ServerThread(APegasSocketServer: TPegasSocketServer);
var
  ClientSocketInfo: TClientSocketInfo;
  ClientSocket: TSocket;
  ClientThreadID: Cardinal;
  ClientThreadHandle: THandle;
begin
  while not APegasSocketServer.Terminated do
  begin
    // ожидаем подключения.
    ClientSocket := accept(APegasSocketServer.FListeningSocket, nil, nil);

    // клиент подключился, запускаем новый процесс на соединение.
    if ClientSocket <> -1 then
    begin
      ClientSocketInfo := TClientSocketInfo.Create(ClientSocket, APegasSocketServer);
      ClientThreadHandle := BeginThread(nil, 0, @SocketThread, ClientSocketInfo, 0, ClientThreadID);
      ClientSocketInfo.FThreadHandle := ClientThreadHandle;
      ClientSocketInfo.FThreadID := ClientThreadID;
      APegasSocketServer.FClientsSocketList.Add(ClientSocketInfo);
    end;
  end;
end;

{ TPegasSocketServer }

constructor TPegasSocketServer.Create(AListeningPort: word;
  ACallBackProcedure: TCallBackProcedure; AWriteLogProcedure: TWriteLogProcedure);
begin
  inherited Create;
  FClientsSocketList := TList.Create;
  FCallBackProcedure := ACallBackProcedure;
  FWriteLogProcedure := AWriteLogProcedure;
  FMessageHandler := 0;
  Init(AListeningPort);
end;

constructor TPegasSocketServer.Create(AListeningPort: Word;
  AMessageHandler: HWND);
begin
  inherited Create;
  FClientsSocketList := TList.Create;
  FCallBackProcedure := nil;
  FWriteLogProcedure := nil;
  FMessageHandler := AMessageHandler;
  Init(AListeningPort)
end;


procedure TPegasSocketServer.StopServer;
var
  i: integer;
  SocketInfo: TClientSocketInfo;
begin
  Terminated := True;
  closesocket(ListeningSocket);
  WriteLog('Stoping server - OK');

  for i := 0 to FClientsSocketList.Count - 1 do
  begin
    SocketInfo := TClientSocketInfo(FClientsSocketList[i]);
    if SocketInfo.Active then
      closesocket(SocketInfo.Socket);
  end;

  (* if (FThreadHandle > 0) then
  begin
    tmpRes := WaitForSingleObject(FThreadHandle, AWaitThreadTimeout);
    if (tmpRes = WAIT_TIMEOUT) then begin
      ExitCode := 0;
      try GetExitCodeThread(FThreadHandle, ExitCode); except end;
      if (ExitCode = STILL_ACTIVE) then begin
        TerminateThread(FThreadHandle, 0);
      end;
    end;
    try
      CloseHandle(FThreadHandle);
    finally
      FThreadHandle := 0;
    end;
    FThreadID := 0;
  end; *)
  WSACleanup;
end;

procedure TPegasSocketServer.StartServer;
var
  SockAddr : TSockAddr;
begin
  //Создаем прослушивающий сокет.
  FListeningSocket := socket(AF_INET, SOCK_STREAM, IPPROTO_IP);
  WriteLog(format('Creating socket on port [%d].', [FListeningPort]));
  if FListeningSocket = INVALID_SOCKET then
    raise Exception.Create('Ошибка создания сокета');

  (*ierr = setsockopt( Socket->SocketHandle, SOL_SOCKET, SO_KEEPALIVE,
    (const char FAR * ) &optval, sizeof(bool));*)

  FillChar(SockAddr, SizeOf(TSockAddr), 0);
  SockAddr.sin_family := AF_INET;
  SockAddr.sin_port := htons(FListeningPort);
  SockAddr.sin_addr.S_addr := INADDR_ANY;

  //Привязываем адрес и порт к сокету.
  if bind(FListeningSocket, SockAddr, SizeOf(TSockAddr)) <> 0 then
    raise Exception.Create('Ошибка привязки адреса и порта к сокету');
  WriteLog('Socket binding - OK.');

  //Начинаем прослушивать.
  if listen(FListeningSocket, SOMAXCONN) <> 0 then
    raise Exception.Create('Ошибка перевода сокета в режим прослушивания');
  WriteLog('Socket status: listening.');

  Terminated := False;
  FServerThreadHandle := BeginThread(nil, 0, @ServerThread, Self, 0, FServerThreadID);
end;

procedure TPegasSocketServer.WriteLog(AMessage: string);
begin
  CriticalSection.Enter;
  try
    if FMessageHandler <> 0 then
    begin
      SendMessage(FMessageHandler, WRITE_LOG_MESSAGE, 0, DWORD(PChar(AMessage)));
    end;
    if Assigned(FWriteLogProcedure) then
      FWriteLogProcedure(AMessage);
  finally
    CriticalSection.Leave;
  end;
end;

destructor TPegasSocketServer.Destroy;
begin
  FClientsSocketList.Free;
  inherited;
end;

procedure TPegasSocketServer.CallBackProc(AMessage: string);
begin
  CriticalSection.Enter;
  try
    if FMessageHandler <> 0 then
    begin
      SendMessage(FMessageHandler, RECIEVED_DATA_MESSAGE, 0, DWORD(PChar(AMessage)));
    end;
    if Assigned(FCallBackProcedure) then
      FCallBackProcedure(AMessage);
  finally
    CriticalSection.Leave;
  end;
end;

function TPegasSocketServer.GetTerminated: boolean;
begin
  CriticalSection.Enter;
  try
    Result := FTerminated;
  finally
    CriticalSection.Leave;
  end;
end;

procedure TPegasSocketServer.SetTerminated(const Value: boolean);
begin
  CriticalSection.Enter;
  try
    FTerminated := Value;
  finally
    CriticalSection.Leave;
  end;
end;

function TPegasSocketServer.GetListeningSocket: TSocket;
begin
  CriticalSection.Enter;
  try
    Result := FListeningSocket;
  finally
    CriticalSection.Leave;
  end;
end;

procedure TPegasSocketServer.Init(AListeningPort: Word);
var
  WSAData: TWSAData;
begin
  FListeningPort := AListeningPort;
  WriteLog('Starting application...');
  if WSAStartup($101, WSAData) <> 0 then
    raise Exception.Create('Ошибка инициализации WSAStartup');
  WriteLog('WSAStartup - OK');
end;

{ TClientSocketInfo }

constructor TClientSocketInfo.Create(ASocket: TSocket; APegasSocketServer: TPegasSocketServer);
begin
  inherited create;
  FSocket := ASocket;
  FPegasSocketServer := APegasSocketServer;
  //CriticalSection := TCriticalSection.Create;
  FActive := true;
end;

destructor TClientSocketInfo.Destroy;
begin
  //FCriticalSection.Free;
  inherited;
end;

function TClientSocketInfo.GetActive: boolean;
begin
  CriticalSection.Enter;
  try
    Result := FActive;
  finally
    CriticalSection.Leave;
  end;
end;

function TClientSocketInfo.GetIsServerTerminated: Boolean;
begin
  CriticalSection.Enter;
  try
    Result := FPegasSocketServer.Terminated;
  finally
    CriticalSection.Leave;
  end;
end;

function TClientSocketInfo.GetSocket: TSocket;
begin
  CriticalSection.Enter;
  try
    Result := FSocket;
  finally
    CriticalSection.Leave;
  end;
end;

procedure TClientSocketInfo.SetActive(const Value: boolean);
begin
  CriticalSection.Enter;
  try
    FActive := Value;
  finally
    CriticalSection.Leave;
  end;
end;

initialization
  CriticalSection := TCriticalSection.Create;

finalization
  CriticalSection.Free;
  //WSACleanup;

end.


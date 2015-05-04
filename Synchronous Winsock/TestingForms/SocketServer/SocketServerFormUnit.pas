unit SocketServerFormUnit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, PegasSocketServerUnit, StdCtrls;

type
  TServerForm = class(TForm)
    Memo: TMemo;
    btStartServer: TButton;
    btStopServer: TButton;
    cbConvert: TCheckBox;
    procedure btStartServerClick(Sender: TObject);
    procedure btStopServerClick(Sender: TObject);
  private
    PegasSocketServer: TPegasSocketServer;
  public
    Procedure CallBackProc(AMessage: string);
    Procedure WriteLogProc(AMessage: string);
    procedure ProcWriteLogMessage(var msg: TMessage); message WRITE_LOG_MESSAGE;
    procedure ProcRecievedDataMessage(var msg: TMessage); message RECIEVED_DATA_MESSAGE;
  end;

var
  ServerForm: TServerForm;

implementation


{$R *.dfm}

procedure TServerForm.btStartServerClick(Sender: TObject);
const
  USE_MESSAGES = True;
  PORT_NUM = Word(10000);
begin
  Memo.Lines.Clear;
  if USE_MESSAGES then
    PegasSocketServer := TPegasSocketServer.Create(PORT_NUM, Self.Handle)
  else
    PegasSocketServer := TPegasSocketServer.Create(PORT_NUM, CallBackProc,
      WriteLogProc);
  PegasSocketServer.StartServer;
end;

procedure TServerForm.btStopServerClick(Sender: TObject);
begin
  PegasSocketServer.StopServer;
  PegasSocketServer.Free;
end;

procedure TServerForm.CallBackProc(AMessage: string);
begin
  if cbConvert.Checked then
    AMessage := Utf8ToAnsi(AMessage);
  Memo.Lines.Add(AMessage);
end;

procedure TServerForm.ProcRecievedDataMessage(var msg: TMessage);
begin
  Memo.Lines.Add(PChar(msg.lParam));
  msg.Result := 1;
end;

procedure TServerForm.ProcWriteLogMessage(var msg: TMessage);
begin
  Memo.Lines.Add(PChar(msg.lParam));
  msg.Result := 1;
end;

procedure TServerForm.WriteLogProc(AMessage: string);
begin
  Memo.Lines.Add(AMessage);
end;

end.

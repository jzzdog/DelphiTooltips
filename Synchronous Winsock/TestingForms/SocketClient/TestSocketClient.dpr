program TestSocketClient;

uses
  Forms,
  SocketClientFormUnit in 'SocketClientFormUnit.pas' {SocketClientForm};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TSocketClientForm, SocketClientForm);
  Application.Run;
end.

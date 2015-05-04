program TestPegasSocketServer;

uses
  Forms,
  SocketServerFormUnit in 'SocketServerFormUnit.pas' {ServerForm},
  PegasSocketServerUnit in '..\..\PegasSocketServerUnit.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TServerForm, ServerForm);
  Application.Run;
end.

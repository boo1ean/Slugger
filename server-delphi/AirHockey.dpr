program AirHockey;

uses
  Vcl.Forms,
  Main in 'Main.pas' {Form1},
  Players in 'Players.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.

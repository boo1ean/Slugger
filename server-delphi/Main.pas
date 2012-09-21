unit Main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, IdContext, IdBaseComponent, IdComponent, IdCustomTCPServer,
  IdTCPServer, Vcl.StdCtrls, IdIOHandler, Vcl.ExtCtrls, Math, Contnrs, Players;

type
  TForm1 = class(TForm)
    IdTCPServer1: TIdTCPServer;
    Label1: TLabel;
    Label2: TLabel;
    Timer1: TTimer;
    Shape1: TShape;
    lFps: TLabel;
    lFpsNet: TLabel;
    Label5: TLabel;
    lSensor: TLabel;
    Ball: TShape;
    lScore: TLabel;
    procedure IdTCPServer1Execute(AContext: TIdContext);
    procedure FormCreate(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormResize(Sender: TObject);
    procedure IdTCPServer1Connect(AContext: TIdContext);
    procedure FormDestroy(Sender: TObject);
    procedure IdTCPServer1Disconnect(AContext: TIdContext);
  private
    Sensor: array[0..2] of Single;
    NetFps: double;
    Players: TPlayers;
    procedure WMUser(var Msg: TMessage); message WM_USER;
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

const
  g: double = 9.8;

{$R *.dfm}

procedure TForm1.FormCreate(Sender: TObject);
var
  one: single;
  x: array[0..3] of byte absolute one;
begin
  one := 1;
  Players := TPlayers.Create;
  Players.Pattern := Shape1;
  Players.Ball := Ball;
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  FreeAndNil(Players);
end;

procedure TForm1.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  case Key of
  VK_ESCAPE:
    Close;
  VK_SPACE:
  end;
end;

procedure TForm1.FormResize(Sender: TObject);
begin
  Players.ClientWidth := ClientWidth;
  Players.ClientHeight := ClientHeight;
  Shape1.Width := ClientWidth div 50;
  Shape1.Height := ClientHeight div 7;
  Ball.Width := ClientWidth div 50;
  Ball.Height := Ball.Width;
  Players.ResetBall;
end;

procedure TForm1.IdTCPServer1Connect(AContext: TIdContext);
begin
  Players.CreateNew(AContext);
  if Players.Count > 1 then
  Players.RestartBall;
end;

procedure TForm1.IdTCPServer1Disconnect(AContext: TIdContext);
begin
  if Players = nil then
    Exit;
  Players.Remove(Players.FindByContext(AContext));
  Players.ResetBall;
end;

procedure TForm1.IdTCPServer1Execute(AContext: TIdContext);
var
  io: TIdIOHandler;
  bb:TBytes;
  Player: TPlayerInfo;
const
  cnt: Integer = 0;
  lastDT: TDateTime = 0;
begin
  if Application.Terminated then
    Exit;
  Player := Players.FindByContext(AContext);
  if Player = nil then
    Exit;
  io := AContext.Connection.IOHandler;
  io.CheckForDataOnSource(1);
  if io.InputBufferIsEmpty then
    exit;
  while io.InputBuffer.Size >= 12 do begin
    io.ReadBytes(bb, 12);
    Move(bb[0], Sensor[0], 12);
    Player.Angle := sensor[1];

    if lastDT = 0 then
      lastDT := now
    else
      inc(cnt);
    if (cnt>20) and (Now-lastDT>0) then begin
      NetFps := cnt/(Now-lastDT)/86400;
      lastDT := Now;
      cnt := 0;
    end;
  end;
end;

procedure TForm1.Timer1Timer(Sender: TObject);
const
  cnt: Integer = 0;
  lastDT: TDateTime = 0;
var
  delta: Single;
begin
  if lastDT = 0 then begin
    lastDT := Now;
    Exit;
  end;
  Inc(cnt);
  delta := (Now-lastDT)*86400;
  if delta = 0 then
    Exit;
  lastDT := Now;
  lFps.Caption := Format('%-2.0f', [cnt/(delta)]);
  lSensor.Caption := Format('%3.3f %3.3f %3.3f', [sensor[0], sensor[1], sensor[2]]);
  lFpsNet.Caption := Format('%-2.0f', [NetFps]);
  cnt := 0;

  Ball.Left := Round(Players.BallPos.x);
  Ball.Top := Round(Players.BallPos.y);
  Players.Move(delta);
end;

procedure TForm1.WMUser(var Msg: TMessage);
begin
end;

end.

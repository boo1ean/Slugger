unit Players;

interface uses
  Windows, Classes, IdContext, ExtCtrls, Contnrs;

type
  TPlayerInfo = class
    Shape: TShape;
    Location: TPointFloat;
    NetContext: TIdContext;
    Angle: Double;
    constructor Create(Pattern: TShape);
    destructor Destroy; override;
    procedure Move(delta: Single);
  end;

  TPlayers = class(TObjectList)
  private
    procedure Rearrange;
    function GetItem(Index: Integer): TPlayerInfo;
  protected
    procedure Notify(Ptr: Pointer; Action: TListNotification); override;
  public
    Pattern, Ball: TShape;
    ClientWidth, ClientHeight: Integer;
    BallSpeed, BallPos: TPointFloat;
    procedure CreateNew(NetContext: TIdContext);
    function FindByContext(NetContext: TIdContext): TPlayerInfo;
    procedure Move(delta: Single);
    procedure ResetBall;
    procedure RestartBall;
    property Items[Index: Integer]: TPlayerInfo read GetItem; default;
  end;

implementation uses
  Main;

{ TPlayerInfo }

constructor TPlayerInfo.Create(Pattern: TShape);
begin
  Shape := TShape.Create(nil);
  Shape.Parent := Pattern.Parent;
  Shape.Width := Pattern.Width;
  Shape.Height := Pattern.Height;
  Shape.Brush.Assign(Pattern.Brush);
  Shape.Shape := Pattern.Shape;
  Location.y := Pattern.Top;
end;

destructor TPlayerInfo.Destroy;
begin
  Shape.Free;
  inherited;
end;

procedure TPlayerInfo.Move(delta: Single);
begin
//      Speed := Speed + Angle*delta;
//      Location.y := Location.y + Speed*delta;
      Location.y := (Form1.ClientHeight * (1+Angle) - Shape.Height)/2;
      Shape.Left := Round(Location.x);
      Shape.Top := Round(Location.y);

end;

{ TPlayers }

procedure TPlayers.CreateNew(NetContext: TIdContext);
var
  pi: TPlayerInfo;
begin
  pi := TPlayerInfo.Create(Pattern);
  pi.NetContext := NetContext;
  Add(pi);
end;

function TPlayers.FindByContext(NetContext: TIdContext): TPlayerInfo;
var
  i: Integer;
begin
  Result := nil;
  for i := 0 to Count-1 do
    if Items[i].NetContext = NetContext then
      Result := Items[i];
end;

function TPlayers.GetItem(Index: Integer): TPlayerInfo;
begin
  Result := TPlayerInfo(inherited GetItem(index))  
end;

procedure TPlayers.Move(delta: Single);
var
  i: Integer;
begin
  for i := 0 to Count-1 do
    Items[i].Move(delta);
  BallPos.x := BallPos.x + BallSpeed.x * delta;
  BallPos.y := BallPos.y + BallSpeed.y * delta;
end;

procedure TPlayers.Notify(Ptr: Pointer; Action: TListNotification);
begin
  inherited;
  Rearrange;
end;

procedure TPlayers.Rearrange;
var
  i: Integer;
begin
  for i := 0 to Count-1 do
    if i mod 2 = 0 then
      Items[i].Location.x := Pattern.Width*(i+1)
    else
      Items[i].Location.x := Form1.ClientWidth - Pattern.Width*(i+1);
end;

procedure TPlayers.RestartBall;
begin
  BallSpeed.x := ClientWidth / 20;
  BallSpeed.y := 0;
end;

procedure TPlayers.ResetBall;
begin
  BallSpeed.x := 0;
  BallSpeed.y := 0;
  BallPos.x := (ClientWidth - Ball.Width) div 2;
  BallPos.y := (ClientHeight - Ball.Height) div 2;
end;

end.

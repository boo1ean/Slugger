object Form1: TForm1
  Left = 0
  Top = 0
  BorderStyle = bsNone
  Caption = 'Air Hockey'
  ClientHeight = 450
  ClientWidth = 800
  Color = clGreen
  DoubleBuffered = True
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  WindowState = wsMaximized
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnKeyDown = FormKeyDown
  OnResize = FormResize
  DesignSize = (
    800
    450)
  PixelsPerInch = 96
  TextHeight = 14
  object Label1: TLabel
    Left = 8
    Top = 8
    Width = 42
    Height = 14
    Caption = 'Gfx FPS'
    Color = clBlack
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clSilver
    Font.Height = -12
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentColor = False
    ParentFont = False
  end
  object Label2: TLabel
    Left = 97
    Top = 8
    Width = 44
    Height = 14
    Caption = 'Net FPS'
    Color = clBlack
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clSilver
    Font.Height = -12
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentColor = False
    ParentFont = False
  end
  object Shape1: TShape
    Left = 312
    Top = 72
    Width = 33
    Height = 166
    Brush.Color = clYellow
    Shape = stEllipse
    Visible = False
  end
  object lFps: TLabel
    Left = 56
    Top = 8
    Width = 35
    Height = 14
    Caption = 'Label1'
    Color = clBlack
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clSilver
    Font.Height = -12
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentColor = False
    ParentFont = False
  end
  object lFpsNet: TLabel
    Left = 145
    Top = 8
    Width = 35
    Height = 14
    Caption = 'Label1'
    Color = clBlack
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clSilver
    Font.Height = -12
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentColor = False
    ParentFont = False
  end
  object Label5: TLabel
    Left = 8
    Top = 428
    Width = 37
    Height = 14
    Anchors = [akLeft, akBottom]
    Caption = 'Sensor'
    Color = clBlack
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clSilver
    Font.Height = -12
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentColor = False
    ParentFont = False
  end
  object lSensor: TLabel
    Left = 56
    Top = 428
    Width = 35
    Height = 14
    Anchors = [akLeft, akBottom]
    Caption = 'Label1'
    Color = clBlack
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clSilver
    Font.Height = -12
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentColor = False
    ParentFont = False
  end
  object Ball: TShape
    Left = 368
    Top = 224
    Width = 33
    Height = 33
    Shape = stCircle
  end
  object lScore: TLabel
    Left = 368
    Top = 394
    Width = 65
    Height = 48
    Anchors = [akBottom]
    Caption = '0:0'
    Color = clBlack
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWhite
    Font.Height = -40
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentColor = False
    ParentFont = False
  end
  object IdTCPServer1: TIdTCPServer
    Active = True
    Bindings = <>
    DefaultPort = 9595
    OnConnect = IdTCPServer1Connect
    OnDisconnect = IdTCPServer1Disconnect
    OnExecute = IdTCPServer1Execute
    Left = 408
    Top = 176
  end
  object Timer1: TTimer
    Interval = 1
    OnTimer = Timer1Timer
    Left = 416
    Top = 256
  end
end

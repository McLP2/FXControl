unit player;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls,
  Buttons, Menus, FileUtil, MMSystem, LCLIntf, ExtCtrls, BearbKnopf,
  DOM, XMLWrite, XMLRead, Math, types;

type

  { TForm1 }
  TForm1 = class(TForm)
    BTstop: TBitBtn;
    BTblend: TBitBtn;
    BtnAddButton: TButton;
    LBvol: TLabel;
    BlendTimer: TTimer;
    MainMenu1: TMainMenu;
    MInone: TMenuItem;
    MIClose: TMenuItem;
    MIFile: TMenuItem;
    MIOpen: TMenuItem;
    MISave: TMenuItem;
    OpenDialog1: TOpenDialog;
    SaveDialog1: TSaveDialog;
    ScrollBar1: TScrollBar;
    VolBar: TScrollBar;
    procedure BTbellClick(Sender: TObject);
    procedure BTbellMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure BTblendClick(Sender: TObject);
    procedure BtnAddButtonClick(Sender: TObject);
    procedure BTstopClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormMouseWheelDown(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    procedure FormMouseWheelUp(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    procedure FormResize(Sender: TObject);
    procedure MICloseClick(Sender: TObject);
    procedure MIOpenClick(Sender: TObject);
    procedure MISaveClick(Sender: TObject);
    procedure PlayASound(FileName: String);
    procedure BlendTimerTimer(Sender: TObject);
    procedure ScrollBar1Change(Sender: TObject);
    procedure VolBarChange(Sender: TObject);
    procedure StopAllSounds;
  private

  public
    { public declarations }
  end;

const
  BtnDefaultWidth = 144;
  BtnDefaultMargin = 8;

var
  Form1: TForm1;
  PrevPos: Integer;
  blend: Boolean;
  sdbuttons: array[0..1000] of TButton;
  buttonscounter: Integer;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.BTbellMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if Button = mbRight then
    begin
      Form2.EdtButtonName.Text:=TButton(Sender).Caption;
      Form2.FNEsound.FileName:=filenames[TButton(Sender).Tag];
      ActiveButton:=TButton(Sender);
      Form2.show;
    end;
end;

procedure TForm1.BTblendClick(Sender: TObject);
begin
  blend := true;
end;

procedure TForm1.BtnAddButtonClick(Sender: TObject);
begin
  sdbuttons[buttonscounter]:=TButton.Create(NIL);
  with sdbuttons[buttonscounter] do
  begin
    Parent:=Form1;
    OnMouseWheelDown:=@FormMouseWheelDown;
    OnMouseWheelUp:=@FormMouseWheelUp;
    OnClick:=@BTbellClick;
    OnMouseUp:=@BTbellMouseUp;
    Left:=BtnAddButton.Left;
    Top:=BtnAddButton.Top;
    Width:=144;
    Height:=32;
    Visible:=true;
    Tag:=buttonscounter;
    Caption:=IntToStr(buttonscounter);
  end;
  filenames[buttonscounter]:='';
  buttonscounter:=buttonscounter+1;
  FormResize(nil);
  //BtnAddButton.Left:=BtnAddButton.Left+BtnDefaultWidth+BtnDefaultMargin;
end;

procedure TForm1.BTbellClick(Sender: TObject);
begin
  PlayASound(filenames[TButton(Sender).Tag]);
end;


procedure TForm1.BTstopClick(Sender: TObject);
begin
  blend:=false;
  StopAllSounds;
  VolBar.Position:=PrevPos;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin

end;

procedure TForm1.FormMouseWheelDown(Sender: TObject; Shift: TShiftState;
  MousePos: TPoint; var Handled: Boolean);
begin
  Scrollbar1.Position:=Scrollbar1.Position+9;
end;

procedure TForm1.FormMouseWheelUp(Sender: TObject; Shift: TShiftState;
  MousePos: TPoint; var Handled: Boolean);
begin
  Scrollbar1.Position:=Scrollbar1.Position-9;
end;

procedure TForm1.FormResize(Sender: TObject);
var
  BtnsPR, i, r, BtnsIR: Integer;
begin
  BtnsPR:=(ScrollBar1.Left-27) div (152);
  BtnsIR:=0;
  r:=0;
  for i:=0 to 1000 do
  begin
  if not(sdbuttons[i]=nil) then begin
    sdbuttons[i].Top:=(16+(r*40))-(ScrollBar1.Position);
    sdbuttons[i].Left:=24+(BtnsIR*152);
    BtnsIR:=BtnsIR+1;
    if BtnsIR >= BtnsPR then
      begin
        r:=r+1;
        BtnsIR:=0;
      end;
  end;
  end;
    BtnAddButton.Top:=(16+(r*40))-(ScrollBar1.Position);
    BtnAddButton.Left:=24+(BtnsIR*152);
    ScrollBar1.Max:=max(0, (((r+2)-((Form1.Height-16) div 40))*40));
end;

procedure TForm1.MICloseClick(Sender: TObject);
begin
  Form1.Close;
end;

procedure TForm1.MIOpenClick(Sender: TObject);
var
  Doc: TXMLDocument;
  Child: TDOMNode;
  i, j: Integer;
begin
  if OpenDialog1.Execute then
  begin
    try
    ReadXMLFile(Doc, OpenDialog1.FileName);
    for i:=0 to buttonscounter-1 do
    begin
      sdbuttons[i].Visible:=false;
      sdbuttons[i]:=nil;
      filenames[i]:='';
    end;
    buttonscounter:=0;
    FormResize(nil);
    // using FirstChild and NextSibling properties
    Child := Doc.DocumentElement.FirstChild;
    while Assigned(Child) do
    begin
      sdbuttons[buttonscounter]:=TButton.Create(nil);
      sdbuttons[buttonscounter].Tag:=StrToInt(Child.Attributes.Item[0].NodeValue);
      try
        sdbuttons[buttonscounter].Caption:=Child.FindNode('Caption').FirstChild.NodeValue;
      except
      end;
      try
        filenames[buttonscounter]:=Child.FindNode('AudioFile').FirstChild.NodeValue;
      except
      end;
      with sdbuttons[buttonscounter] do
      begin
        Parent:=Form1;
        OnClick:=@BTbellClick;
        OnMouseUp:=@BTbellMouseUp;
        OnMouseWheelDown:=@FormMouseWheelDown;
        OnMouseWheelUp:=@FormMouseWheelUp;
        Left:=BtnAddButton.Left;
        Top:=BtnAddButton.Top;
        Width:=144;
        Height:=32;
        Visible:=true;
        Tag:=buttonscounter;
      end;
      Child := Child.NextSibling;
      buttonscounter:=buttonscounter+1;
      FormResize(nil);
    end;
  finally
    Doc.Free;
  end;
  end;
end;

procedure TForm1.MISaveClick(Sender: TObject);
var
  i: Integer;
  Doc: TXMLDocument;                                         // Variable für das Dokument
  RootNode, parentNode, achildnode: TDOMNode;                   // Variable für die Elemente (Knoten)
begin
  if SaveDialog1.Execute then
  begin
    try
      // Erzeuge ein Dokument
      Doc := TXMLDocument.Create;

      // Erzeuge einen Wurzelknoten
      RootNode := Doc.CreateElement('Buttons');
      Doc.Appendchild(RootNode);                               // sichere den Wurzelelement
      for i:=0 to (buttonscounter-1) do
      begin
      //Create a parent node
      RootNode:= Doc.DocumentElement;
      parentNode := Doc.CreateElement('Button');
      TDOMElement(parentNode).SetAttribute('id', IntToStr(i));       // erzeuge die Attribute für das Elternelement
      RootNode.Appendchild(parentNode);                        // sichere das Elternelement

      // Create a child node
      parentNode := Doc.CreateElement('Caption');                 // erzeuge einen Kindelement
      achildnode := Doc.CreateTextNode(sdbuttons[i].Caption);               // füge einen Wert für den Knoten ein
      parentNode.Appendchild(achildnode);                         // sichere den Knoten
      RootNode.ChildNodes.Item[i].AppendChild(parentNode);     // füge das Kindelement in das Elternelement ein

      // Create a child node
      parentNode := Doc.CreateElement('AudioFile');                // erzeuge einen Kindelement
      achildnode := Doc.CreateTextNode(filenames[i]);                     // füge einen Wert für den Knoten ein
      parentNode.Appendchild(achildnode);                         // sichere den Knoten
      RootNode.ChildNodes.Item[i].AppendChild(parentNode);       // füge das Kindelement in das Elternelement ein
      end;

      writeXMLFile(Doc, SaveDialog1.FileName);
      // schreibe in die XML-Datei
    finally
      Doc.Free;                                                // gib den Speicher frei
    end;
  end;
end;

procedure TForm1.PlayASound(FileName: String);
begin
  sndPlaySound(pchar(UTF8ToSys(FileName)), snd_Async or snd_NoDefault);
end;

procedure TForm1.BlendTimerTimer(Sender: TObject);
begin
  if blend then
    begin
      if VolBar.Position = VolBar.Max then
        begin
          blend:=false;
          StopAllSounds;
          VolBar.Position:=PrevPos;
        end else
          VolBar.Position:=VolBar.Position+200;
    end
  else
    begin
      PrevPos:=VolBar.Position;
    end;
end;

procedure TForm1.ScrollBar1Change(Sender: TObject);
begin
  FormResize(nil);
end;

procedure TForm1.VolBarChange(Sender: TObject);
var
  MyWaveOutCaps: TWaveOutCaps;
  Volume: Integer;
begin
  LBvol.Caption:='Lautstärke '+ IntToStr(round(((VolBar.Max - VolBar.Position) / VolBar.Max)*100)) +'%';
    Volume:=VolBar.Max - VolBar.Position;
  if WaveOutGetDevCaps(
    WAVE_MAPPER,
    @MyWaveOutCaps,
    sizeof(MyWaveOutCaps))=MMSYSERR_NOERROR then
      WaveOutSetVolume(WAVE_MAPPER, Makelong(Volume, Volume));
end;

procedure TForm1.StopAllSounds;
begin
  sndPlaySound(nil, snd_Async or snd_NoDefault);
end;

end.


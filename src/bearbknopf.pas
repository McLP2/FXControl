unit BearbKnopf;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  EditBtn;

type

  { TForm2 }

  TForm2 = class(TForm)
    BtnOK: TButton;
    EdtButtonName: TEdit;
    FNEsound: TFileNameEdit;
    LblButtonName: TLabel;
    LblButtonSound: TLabel;
    procedure BtnOKClick(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: char);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  Form2: TForm2;
  ActiveButton: TButton;
  filenames: array[0..1000] of string;

implementation

{$R *.lfm}

{ TForm2 }

procedure TForm2.BtnOKClick(Sender: TObject);
begin
  ActiveButton.Caption:=EdtButtonName.Text;
  filenames[ActiveButton.Tag]:=FNEsound.FileName;
  Form2.Close;
end;

procedure TForm2.FormKeyPress(Sender: TObject; var Key: char);
begin
  if Key = #13 then
     BtnOKClick(Sender);
end;


end.


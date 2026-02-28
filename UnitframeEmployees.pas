unit UnitframeEmployees;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls;

type
  TframeEmployees = class(TFrame)
    Label1: TLabel;
    Panel1: TPanel;
    BtnAdd: TButton;
    procedure BtnAddClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

implementation

{$R *.dfm}

uses UnitEditEmployee;

procedure TframeEmployees.BtnAddClick(Sender: TObject);

begin
  frmEditEmployee.ShowModal;
end;

end.

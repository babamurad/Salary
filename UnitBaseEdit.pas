unit UnitBaseEdit;

interface

uses
  Winapi.Windows, System.SysUtils, System.Classes,
  Vcl.Forms, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.Controls;

type
  TEditMode = (emInsert, emEdit);

  TBaseEditForm = class(TForm)
    PanelBottom: TPanel;
    BtnSave: TButton;
    BtnCancel: TButton;
    procedure BtnCancelClick(Sender: TObject);
    procedure BtnSaveClick(Sender: TObject);
  private
    FMode: TEditMode;
    FRecordID: Integer;
  protected
    procedure LoadData; virtual;
    procedure SaveData; virtual;
    procedure ValidateData; virtual;
  public
    function Execute(AMode: TEditMode; AID: Integer = 0): Boolean;
    property Mode: TEditMode read FMode;
    property RecordID: Integer read FRecordID;
  end;

implementation

{$R *.dfm}

procedure TBaseEditForm.BtnCancelClick(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

procedure TBaseEditForm.BtnSaveClick(Sender: TObject);
begin
  ValidateData;
  SaveData;
  ModalResult := mrOk;
end;

function TBaseEditForm.Execute(AMode: TEditMode; AID: Integer): Boolean;
begin
  FMode := AMode;
  FRecordID := AID;

  if FMode = emEdit then
    LoadData;

  Result := ShowModal = mrOk;
end;

procedure TBaseEditForm.LoadData;
begin
  // Переопределяется в потомке
end;

procedure TBaseEditForm.SaveData;
begin
  // Переопределяется в потомке
end;

procedure TBaseEditForm.ValidateData;
begin
  // Переопределяется в потомке
end;

end.

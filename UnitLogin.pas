unit UnitLogin;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls;

type
  TfrmLogin = class(TForm)
    Label1: TLabel;
    edtPassword: TEdit;
    btnLogin: TButton;
    btnCancel: TButton;
    procedure btnLoginClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
  private
  public
  end;

var
  frmLogin: TfrmLogin;

implementation

{$R *.dfm}

uses UnitdmMain;

procedure TfrmLogin.btnLoginClick(Sender: TObject);
var
  CorrectPassword, InputPassword: string;
begin
  InputPassword := Trim(edtPassword.Text);

  // Пытаемся достать пароль из нашей удобной таблицы настроек
  CorrectPassword := 'admin'; // Пароль по умолчанию, если в базе еще ничего нет

  if Assigned(dmMain) then
  begin
    if not dmMain.qryCompanyInfo.Active then
      dmMain.qryCompanyInfo.Open;

    // Ищем ключ 'app_password'. Если его нет - будет 'admin'
    if dmMain.qryCompanyInfo.Locate('key_name', 'app_password', []) then
      CorrectPassword := dmMain.qryCompanyInfo.FieldByName('key_value').AsString;
  end;

  if InputPassword = CorrectPassword then
  begin
    ModalResult := mrOk; // Пароль верный, закрываем форму с успехом
  end
  else
  begin
    ShowMessage('Неверный пароль!');
    edtPassword.Clear;
    edtPassword.SetFocus;
  end;
end;

procedure TfrmLogin.btnCancelClick(Sender: TObject);
begin
  ModalResult := mrCancel; // Отмена
end;

end.

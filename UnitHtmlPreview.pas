unit UnitHtmlPreview;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls,
  Winapi.WebView2, Winapi.ActiveX, Vcl.Edge;

type
  TfrmHtmlPreview = class(TForm)
    Edge: TEdgeBrowser;
    PanelBottom: TPanel;
    btnPrint: TButton;
    procedure btnPrintClick(Sender: TObject);
    procedure EdgeCreateWebViewCompleted(Sender: TCustomEdgeBrowser; AResult: HRESULT);
  private
    FHtmlContent: string;
  public
    // Главный метод: передаем сюда заголовок окна и сам HTML-код
    procedure ShowDocument(const FormCaption, HtmlText: string);
  end;

var
  frmHtmlPreview: TfrmHtmlPreview;

implementation

{$R *.dfm}

{ TfrmHtmlPreview }

procedure TfrmHtmlPreview.ShowDocument(const FormCaption, HtmlText: string);
begin
  Self.Caption := FormCaption;
  FHtmlContent := HtmlText;

  // Указываем папку для кэша движка (как у вас в квитках)
  Edge.UserDataFolder := ExtractFilePath(ParamStr(0)) + 'EdgeCache';
  Edge.CreateWebView;

  Self.ShowModal; // Открываем форму как модальное окно
end;

procedure TfrmHtmlPreview.EdgeCreateWebViewCompleted(Sender: TCustomEdgeBrowser; AResult: HRESULT);
begin
  if Succeeded(AResult) then
    Edge.NavigateToString(FHtmlContent)
  else
    ShowMessage('Ошибка запуска WebView2.');
end;

procedure TfrmHtmlPreview.btnPrintClick(Sender: TObject);
begin
  Edge.SetFocus; // Важно для фокуса модального окна
  Edge.ExecuteScript('window.print();');
end;

end.

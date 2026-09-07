unit UnitHtmlPreview;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls,
  SHDocVw, UnitReportBrowserUtils, Vcl.OleCtrls;

type
  TfrmHtmlPreview = class(TForm)
    PanelBottom: TPanel;
    btnPreview: TButton;
    btnPrint: TButton;
    WebBrowser: TWebBrowser;
    procedure btnPrintClick(Sender: TObject);
    procedure btnPreviewClick(Sender: TObject);
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

  ShowHtmlInBrowser(WebBrowser, FHtmlContent, 'HtmlPreview');

  Self.ShowModal; // Открываем форму как модальное окно
end;

procedure TfrmHtmlPreview.btnPrintClick(Sender: TObject);
begin
  PrintBrowser(WebBrowser);
end;

procedure TfrmHtmlPreview.btnPreviewClick(Sender: TObject);
begin
  PrintPreviewBrowser(WebBrowser);
end;

end.

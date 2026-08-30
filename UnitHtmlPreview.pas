unit UnitHtmlPreview;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls,
  SHDocVw, UnitReportBrowserUtils;

type
  TfrmHtmlPreview = class(TForm)
    PanelBottom: TPanel;
    btnPrint: TButton;
    procedure btnPrintClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    FHtmlContent: string;
    FBrowser: TWebBrowser;
  public
    // √лавный метод: передаем сюда заголовок окна и сам HTML-код
    procedure ShowDocument(const FormCaption, HtmlText: string);
  end;

var
  frmHtmlPreview: TfrmHtmlPreview;

implementation

{$R *.dfm}

{ TfrmHtmlPreview }

procedure TfrmHtmlPreview.FormCreate(Sender: TObject);
begin
  // TWebBrowser создаЄтс€ кодом, а не кладЄтс€ на форму в дизайнере Ч
  // компонент, встроенный в Windows/Delphi (модуль SHDocVw), в этом
  // не нуждаетс€.
  FBrowser := TWebBrowser.Create(Self);
  FBrowser.Parent := Self;
  FBrowser.Align := alClient;
end;

procedure TfrmHtmlPreview.ShowDocument(const FormCaption, HtmlText: string);
begin
  Self.Caption := FormCaption;
  FHtmlContent := HtmlText;

  ShowHtmlInBrowser(FBrowser, FHtmlContent, 'HtmlPreview');

  Self.ShowModal; // ќткрываем форму как модальное окно
end;

procedure TfrmHtmlPreview.btnPrintClick(Sender: TObject);
begin
  PrintBrowser(FBrowser);
end;

end.

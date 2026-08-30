unit UnitPaySlip;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Data.DB, Vcl.StdCtrls,
  System.IOUtils,
  Vcl.ExtCtrls, SHDocVw, UnitReportBrowserUtils;

type
  TfrmPaySlip = class(TForm)
    PanelBottom: TPanel;
    btnPdf: TButton;
    procedure btnPdfClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    FHtmlContent: string; // --- ПЕРЕМЕННАЯ ДЛЯ ХРАНЕНИЯ HTML ---
    function GetHtmlTemplate: string;
    // Единая функция генерации, которая умеет делать и 1 квиток, и 100
    function GenerateSlips(Dataset: TDataSet; Period: string; IsSingle: Boolean): string;
  public
    function GenerateAllSlips(Dataset: TDataSet; Period: string): string;
  public
    procedure ShowPayroll(Dataset: TDataSet; Period: string);
    procedure ShowAllPayslips(Dataset: TDataSet; Period: string);
    procedure ShowSinglePayslip(Dataset: TDataSet; Period: string);
  private
    FBrowser: TWebBrowser;
  end;

  var
  frmPaySlip: TfrmPaySlip;

implementation

{$R *.dfm}

{ TfrmPaySlip }

procedure TfrmPaySlip.FormCreate(Sender: TObject);
begin
  // TWebBrowser создаётся кодом, а не кладётся на форму в дизайнере —
  // компонент, встроенный в Windows/Delphi (модуль SHDocVw), в этом
  // не нуждается.
  FBrowser := TWebBrowser.Create(Self);
  FBrowser.Parent := Self;
  FBrowser.Align := alClient;
end;

procedure TfrmPaySlip.ShowAllPayslips(Dataset: TDataSet; Period: string);
begin
  FHtmlContent := GenerateSlips(Dataset, Period, False); // False = цикл по всем
  ShowHtmlInBrowser(FBrowser, FHtmlContent, 'PaySlip');
end;

procedure TfrmPaySlip.ShowPayroll(Dataset: TDataSet; Period: string);
begin
  // 1. Генерируем HTML и прячем его в нашу переменную
  FHtmlContent := GenerateAllSlips(Dataset, Period);
  // 2. Показываем его в браузере
  ShowHtmlInBrowser(FBrowser, FHtmlContent, 'PaySlip');
end;

procedure TfrmPaySlip.ShowSinglePayslip(Dataset: TDataSet; Period: string);
begin
  FHtmlContent := GenerateSlips(Dataset, Period, True); // True = только текущий
  ShowHtmlInBrowser(FBrowser, FHtmlContent, 'PaySlip');
end;

function TfrmPaySlip.GetHtmlTemplate: string;
begin
  // Здесь ваша верстка в стиле Bootstrap
  // Плейсхолдеры: {{FIO}}, {{DEPT}}, {{GROSS}}, {{TAX}}, {{PENS}}, {{ALIM}}, {{UNION}}, {{NET}}

  Result :=
    '<div class="col-6 mb-4">' +
    '  <div class="card payslip-card">' +
    '    <div class="card-body">' +
    '      <h6 class="card-title text-primary border-bottom pb-2">Расчетный листок: {{PERIOD}}</h6>' +
    '      <div class="small mb-2"><strong>{{FIO}}</strong></div>' +
    '      <div class="text-muted" style="font-size: 0.8rem;">{{DEPT}} | {{POS}}</div>' +
    '      <table class="table table-sm table-borderless mt-2 mb-0" style="font-size: 0.85rem;">' +
    '        <tr><td>Начислено:</td><td class="text-end">{{GROSS}}</td></tr>' +
    '        <tr class="text-danger"><td>Подоходный:</td><td class="text-end">-{{TAX}}</td></tr>' +
    '        <tr class="text-danger"><td>Пенсионный:</td><td class="text-end">-{{PENS}}</td></tr>' +
    '        <tr class="text-danger"><td>Профсоюз:</td><td class="text-end">-{{UNION}}</td></tr>' +
    '        <tr class="text-danger"><td>Алименты:</td><td class="text-end">-{{ALIM}}</td></tr>' +
    '        <tr class="table-light border-top"><td><strong>К ВЫДАЧЕ:</strong></td>' +
    '            <td class="text-end"><strong>{{NET}}</strong></td></tr>' +
    '      </table>' +
    '    </div>' +
    '  </div>' +
    '</div>';
end;

function TfrmPaySlip.GenerateAllSlips(Dataset: TDataSet; Period: string): string;
var
  Body, Item: string;
  Bookmark: TBookmark;
  ReportCssPath, ReportCSS: string;
begin
  Body := '';

  // --- МАГИЯ 1: Замораживаем грид и ставим "закладку" ---
  Dataset.DisableControls;
  Bookmark := Dataset.GetBookmark;

  try
    Dataset.First;
    while not Dataset.Eof do
    begin
      Item := GetHtmlTemplate;
      Item := StringReplace(Item, '{{PERIOD}}', Period, [rfReplaceAll]);
      Item := StringReplace(Item, '{{FIO}}', Dataset.FieldByName('fio').AsString, [rfReplaceAll]);
      Item := StringReplace(Item, '{{DEPT}}', Dataset.FieldByName('dept_name').AsString, [rfReplaceAll]);
      Item := StringReplace(Item, '{{POS}}', Dataset.FieldByName('pos_name').AsString, [rfReplaceAll]);
      Item := StringReplace(Item, '{{GROSS}}', FormatFloat('#,##0.00', Dataset.FieldByName('gross_amount').AsFloat), [rfReplaceAll]);
      Item := StringReplace(Item, '{{TAX}}', FormatFloat('#,##0.00', Dataset.FieldByName('tax_amount').AsFloat), [rfReplaceAll]);
      Item := StringReplace(Item, '{{PENS}}', FormatFloat('#,##0.00', Dataset.FieldByName('pension_amount').AsFloat), [rfReplaceAll]);
      Item := StringReplace(Item, '{{UNION}}', FormatFloat('#,##0.00', Dataset.FieldByName('union_amount').AsFloat), [rfReplaceAll]);
      Item := StringReplace(Item, '{{ALIM}}', FormatFloat('#,##0.00', Dataset.FieldByName('alimony_amount').AsFloat), [rfReplaceAll]);
      Item := StringReplace(Item, '{{NET}}', FormatFloat('#,##0.00', Dataset.FieldByName('net_amount').AsFloat), [rfReplaceAll]);
      Body := Body + Item;
      Dataset.Next;
    end;
  finally
    // --- МАГИЯ 2: Возвращаемся на закладку и размораживаем грид ---
    if Dataset.BookmarkValid(Bookmark) then
    begin
      Dataset.GotoBookmark(Bookmark);
      Dataset.FreeBookmark(Bookmark);
    end;
    Dataset.EnableControls;
  end;

  // Оборачиваем всё в стандартный контейнер Bootstrap
  ReportCssPath := ExtractFilePath(ParamStr(0)) + 'assets\report.css';
  ReportCSS := '';
  if TFile.Exists(ReportCssPath) then
    ReportCSS := TFile.ReadAllText(ReportCssPath)
  else
    ShowMessage('Внимание: Файл ' + ReportCssPath + ' не найден! Вёрстка может поехать.');
  Result :=
    '<html><head>' +
    '<style>' + ReportCSS + '</style>' +
    '<style>' +
    '  @media print { .no-print { display: none; } }' +
    '  .payslip-card { page-break-inside: avoid; border: 1px solid #dee2e6; }' +
    '  body { background: #f8f9fa; padding: 20px; }' +
    '</style>' +
    '</head><body>' +
    '<div class="container-fluid"><div class="row">' + Body + '</div></div>' +
    '</body></html>';
end;

function TfrmPaySlip.GenerateSlips(Dataset: TDataSet; Period: string;
  IsSingle: Boolean): string;
var
  Body, Item: string;
  Bookmark: TBookmark;
  ReportCssPath, ReportCSS: string;
begin
  Body := '';
  if IsSingle then
  begin
    // ЕСЛИ ОДИН: Просто берем текущую запись (где стоит курсор в DBGrid)
    Item := GetHtmlTemplate;
    Item := StringReplace(Item, '{{PERIOD}}', Period, [rfReplaceAll]);
    Item := StringReplace(Item, '{{FIO}}', Dataset.FieldByName('fio').AsString, [rfReplaceAll]);
    Item := StringReplace(Item, '{{DEPT}}', Dataset.FieldByName('dept_name').AsString, [rfReplaceAll]);
    Item := StringReplace(Item, '{{POS}}', Dataset.FieldByName('pos_name').AsString, [rfReplaceAll]);
    Item := StringReplace(Item, '{{GROSS}}', FormatFloat('#,##0.00', Dataset.FieldByName('gross_amount').AsFloat), [rfReplaceAll]);
    Item := StringReplace(Item, '{{TAX}}', FormatFloat('#,##0.00', Dataset.FieldByName('tax_amount').AsFloat), [rfReplaceAll]);
    Item := StringReplace(Item, '{{PENS}}', FormatFloat('#,##0.00', Dataset.FieldByName('pension_amount').AsFloat), [rfReplaceAll]);
    Item := StringReplace(Item, '{{UNION}}', FormatFloat('#,##0.00', Dataset.FieldByName('union_amount').AsFloat), [rfReplaceAll]);
    Item := StringReplace(Item, '{{ALIM}}', FormatFloat('#,##0.00', Dataset.FieldByName('alimony_amount').AsFloat), [rfReplaceAll]);
    Item := StringReplace(Item, '{{NET}}', FormatFloat('#,##0.00', Dataset.FieldByName('net_amount').AsFloat), [rfReplaceAll]);
    Body := Item;
  end
  else
  begin
    // ЕСЛИ ВСЕ: Делаем наш старый добрый цикл с заморозкой
    Dataset.DisableControls;
    Bookmark := Dataset.GetBookmark;
    try
      Dataset.First;
      while not Dataset.Eof do
      begin
        Item := GetHtmlTemplate;
        Item := StringReplace(Item, '{{PERIOD}}', Period, [rfReplaceAll]);
        Item := StringReplace(Item, '{{FIO}}', Dataset.FieldByName('fio').AsString, [rfReplaceAll]);
        Item := StringReplace(Item, '{{DEPT}}', Dataset.FieldByName('dept_name').AsString, [rfReplaceAll]);
        Item := StringReplace(Item, '{{POS}}', Dataset.FieldByName('pos_name').AsString, [rfReplaceAll]);
        Item := StringReplace(Item, '{{GROSS}}', FormatFloat('#,##0.00', Dataset.FieldByName('gross_amount').AsFloat), [rfReplaceAll]);
        Item := StringReplace(Item, '{{TAX}}', FormatFloat('#,##0.00', Dataset.FieldByName('tax_amount').AsFloat), [rfReplaceAll]);
        Item := StringReplace(Item, '{{PENS}}', FormatFloat('#,##0.00', Dataset.FieldByName('pension_amount').AsFloat), [rfReplaceAll]);
        Item := StringReplace(Item, '{{UNION}}', FormatFloat('#,##0.00', Dataset.FieldByName('union_amount').AsFloat), [rfReplaceAll]);
        Item := StringReplace(Item, '{{ALIM}}', FormatFloat('#,##0.00', Dataset.FieldByName('alimony_amount').AsFloat), [rfReplaceAll]);
        Item := StringReplace(Item, '{{NET}}', FormatFloat('#,##0.00', Dataset.FieldByName('net_amount').AsFloat), [rfReplaceAll]);
        Body := Body + Item;
        Dataset.Next;
      end;
    finally
      if Dataset.BookmarkValid(Bookmark) then
      begin
        Dataset.GotoBookmark(Bookmark);
        Dataset.FreeBookmark(Bookmark);
      end;
      Dataset.EnableControls;
    end;
  end;
  ReportCssPath := ExtractFilePath(ParamStr(0)) + 'assets\report.css';
  ReportCSS := '';
  if TFile.Exists(ReportCssPath) then
    ReportCSS := TFile.ReadAllText(ReportCssPath) // Читаем весь файл в память
  else
    ShowMessage('Внимание: Файл ' + ReportCssPath + ' не найден! Верстка может поехать.');
  Result :=
    '<html><head>' +
    '<style>' + ReportCSS + '</style>' +
    '<style>' +
    '  @media print { .no-print { display: none; } }' +
    '  .payslip-card { page-break-inside: avoid; border: 1px solid #dee2e6; }' +
    '  body { background: #f8f9fa; padding: 20px; }' +
    '</style>' +
    '</head><body>' +
    '<div class="container-fluid"><div class="row">' + Body + '</div></div>' +
    '</body></html>';
end;

procedure TfrmPaySlip.btnPdfClick(Sender: TObject);
begin
  PrintBrowser(FBrowser);
end;

end.

unit UnitReportPayroll;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls,
  Winapi.WebView2, Winapi.ActiveX, Vcl.Edge, System.IOUtils, Data.DB;

type
  TfrmReportPayroll = class(TForm)
    PanelTop: TPanel;
    Edge: TEdgeBrowser;
    btnPrint: TButton;
    procedure btnPrintClick(Sender: TObject);
    procedure EdgeCreateWebViewCompleted(Sender: TCustomEdgeBrowser; AResult: HRESULT);
  private
    FHtmlContent: string;
    function GenerateReportHtml(Dataset: TDataSet; Period: string): string;
  public
    procedure ShowReport(Dataset: TDataSet; Period: string);
  end;

var
  frmReportPayroll: TfrmReportPayroll;

implementation

{$R *.dfm}

{ TfrmReportPayroll }

procedure TfrmReportPayroll.ShowReport(Dataset: TDataSet; Period: string);
begin
  // 1. Генерируем HTML-отчет
  FHtmlContent := GenerateReportHtml(Dataset, Period);

  // 2. Инициализируем браузер
  Edge.UserDataFolder := ExtractFilePath(ParamStr(0)) + 'EdgeCache';
  Edge.CreateWebView;
end;

procedure TfrmReportPayroll.EdgeCreateWebViewCompleted(Sender: TCustomEdgeBrowser; AResult: HRESULT);
begin
  if Succeeded(AResult) then
    Edge.NavigateToString(FHtmlContent)
  else
    ShowMessage('Ошибка запуска WebView2 для отчета.');
end;

function TfrmReportPayroll.GenerateReportHtml(Dataset: TDataSet; Period: string): string;
var
  BootstrapPath, BootstrapCSS: string;
  TBody: string;
  RowIndex: Integer;
  // Переменные для итогов
  TotGross, TotTax, TotPens, TotUnion, TotAlim, TotNet: Double;
begin
  // 1. Читаем локальный Bootstrap (без интернета!)
  BootstrapPath := ExtractFilePath(ParamStr(0)) + 'assets\bootstrap.min.css';
  BootstrapCSS := '';
  if TFile.Exists(BootstrapPath) then
    BootstrapCSS := TFile.ReadAllText(BootstrapPath);

  // 2. Обнуляем итоги
  TotGross := 0; TotTax := 0; TotPens := 0;
  TotUnion := 0; TotAlim := 0; TotNet := 0;
  RowIndex := 1;
  TBody := '';

  // 3. Собираем строки таблицы
  Dataset.DisableControls;
  try
    Dataset.First;
    while not Dataset.Eof do
    begin
      // Накапливаем суммы
      TotGross := TotGross + Dataset.FieldByName('gross_amount').AsFloat;
      TotTax := TotTax + Dataset.FieldByName('tax_amount').AsFloat;
      TotPens := TotPens + Dataset.FieldByName('pension_amount').AsFloat;
      TotUnion := TotUnion + Dataset.FieldByName('union_amount').AsFloat;
      TotAlim := TotAlim + Dataset.FieldByName('alimony_amount').AsFloat;
      TotNet := TotNet + Dataset.FieldByName('net_amount').AsFloat;

      // Генерируем <tr> для сотрудника
      TBody := TBody + '<tr>' +
        '<td class="text-center">' + IntToStr(RowIndex) + '</td>' +
        '<td><b>' + Dataset.FieldByName('fio').AsString + '</b><br>' +
        '<span class="text-muted" style="font-size: 0.75rem;">' + Dataset.FieldByName('pos_name').AsString + '</span></td>' +
        '<td class="text-end">' + FormatFloat('#,##0.00', Dataset.FieldByName('base_salary').AsFloat) + '</td>' +
        '<td class="text-end fw-bold">' + FormatFloat('#,##0.00', Dataset.FieldByName('gross_amount').AsFloat) + '</td>' +
        '<td class="text-end text-danger">-' + FormatFloat('#,##0.00', Dataset.FieldByName('tax_amount').AsFloat) + '</td>' +
        '<td class="text-end text-danger">-' + FormatFloat('#,##0.00', Dataset.FieldByName('pension_amount').AsFloat) + '</td>' +
        '<td class="text-end text-danger">-' + FormatFloat('#,##0.00', Dataset.FieldByName('union_amount').AsFloat) + '</td>' +
        '<td class="text-end text-danger">-' + FormatFloat('#,##0.00', Dataset.FieldByName('alimony_amount').AsFloat) + '</td>' +
        '<td class="text-end fw-bold" style="font-size: 1.1em;">' + FormatFloat('#,##0.00', Dataset.FieldByName('net_amount').AsFloat) + '</td>' +
        '</tr>';

      Inc(RowIndex);
      Dataset.Next;
    end;
  finally
    Dataset.EnableControls;
  end;

  // 4. Собираем весь документ
  Result :=
    '<html><head>' +
    '<style>' + BootstrapCSS + '</style>' +
    '<style>' +
    '  @media print { .no-print { display: none; } @page { size: landscape; margin: 10mm; } }' + // Печатаем альбомно!
    '  body { background: #f8f9fa; padding: 20px; font-family: "Segoe UI", Tahoma, Geneva, Verdana, sans-serif; }' +
    '  .report-container { background: white; padding: 25px; border-radius: 8px; box-shadow: 0 4px 6px rgba(0,0,0,0.1); }' +
    '  .table th { vertical-align: middle; text-align: center; background-color: #e9ecef !important; }' +
    '  .table td { vertical-align: middle; }' +
    '</style>' +
    '</head><body>' +

    '<div class="container-fluid report-container">' +
    '  <h3 class="text-center mb-4 border-bottom pb-3">Сводная ведомость по заработной плате<br>' +
    '  <small class="text-muted">Период: ' + Period + '</small></h3>' +

    '  <div class="table-responsive">' +
    '    <table class="table table-bordered table-sm table-hover" style="font-size: 0.85rem;">' +
    '      <thead>' +
    '        <tr>' +
    '          <th style="width: 3%;">№</th>' +
    '          <th style="width: 22%;">Сотрудник / Должность</th>' +
    '          <th style="width: 10%;">Оклад/Тариф</th>' +
    '          <th style="width: 10%;">Начислено</th>' +
    '          <th style="width: 9%;">Подоходный</th>' +
    '          <th style="width: 9%;">Пенсионный</th>' +
    '          <th style="width: 9%;">Профсоюз</th>' +
    '          <th style="width: 9%;">Алименты</th>' +
    '          <th style="width: 11%;">К выплате</th>' +
    '        </tr>' +
    '      </thead>' +
    '      <tbody>' +
             TBody +
    '      </tbody>' +
    '      <tfoot class="table-dark" style="font-size: 0.95rem;">' +
    '        <tr>' +
    '          <td colspan="3" class="text-end fw-bold">ИТОГО ПО ПРЕДПРИЯТИЮ:</td>' +
    '          <td class="text-end fw-bold">' + FormatFloat('#,##0.00', TotGross) + '</td>' +
    '          <td class="text-end text-warning">-' + FormatFloat('#,##0.00', TotTax) + '</td>' +
    '          <td class="text-end text-warning">-' + FormatFloat('#,##0.00', TotPens) + '</td>' +
    '          <td class="text-end text-warning">-' + FormatFloat('#,##0.00', TotUnion) + '</td>' +
    '          <td class="text-end text-warning">-' + FormatFloat('#,##0.00', TotAlim) + '</td>' +
    '          <td class="text-end fw-bold text-success" style="font-size: 1.1em;">' + FormatFloat('#,##0.00', TotNet) + '</td>' +
    '        </tr>' +
    '      </tfoot>' +
    '    </table>' +
    '  </div>' +

    '  <div class="row mt-5 pt-3 border-top no-print">' +
    '    <div class="col-6 text-center">Главный бухгалтер __________________</div>' +
    '    <div class="col-6 text-center">Директор __________________</div>' +
    '  </div>' +
    '</div>' +

    '</body></html>';
end;

procedure TfrmReportPayroll.btnPrintClick(Sender: TObject);
begin
  Edge.SetFocus;
  Edge.ExecuteScript('setTimeout(function() { window.print(); }, 100);');
end;

end.

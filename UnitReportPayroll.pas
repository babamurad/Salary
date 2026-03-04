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
  TBody, CurrentDept, DeptName: string;
  RowIndex: Integer;
  // Итоги по предприятию (Grand Totals)
  GrandGross, GrandTax, GrandPens, GrandUnion, GrandAlim, GrandNet: Double;
  // Промежуточные итоги по отделу (Department Totals)
  DeptGross, DeptTax, DeptPens, DeptUnion, DeptAlim, DeptNet: Double;
begin
  BootstrapPath := ExtractFilePath(ParamStr(0)) + 'assets\bootstrap.min.css';
  BootstrapCSS := '';
  if TFile.Exists(BootstrapPath) then BootstrapCSS := TFile.ReadAllText(BootstrapPath);

  GrandGross := 0; GrandTax := 0; GrandPens := 0; GrandUnion := 0; GrandAlim := 0; GrandNet := 0;
  DeptGross := 0; DeptTax := 0; DeptPens := 0; DeptUnion := 0; DeptAlim := 0; DeptNet := 0;

  RowIndex := 1;
  TBody := '';
  CurrentDept := '';

  Dataset.DisableControls;
  try
    Dataset.First;
    while not Dataset.Eof do
    begin
      DeptName := Dataset.FieldByName('dept_name').AsString;
      if DeptName = '' then DeptName := 'Без отдела';

      // Если отдел сменился — подбиваем итоги старого и рисуем заголовок нового
      if DeptName <> CurrentDept then
      begin
        // 1. Итоги предыдущего отдела (если он был)
        if CurrentDept <> '' then
        begin
          TBody := TBody + '<tr class="table-light fw-bold" style="font-size: 0.85rem;">' +
            '<td colspan="3" class="text-end">Итого по отделу:</td>' +
            '<td class="text-end">' + FormatFloat('#,##0.00', DeptGross) + '</td>' +
            '<td class="text-end text-danger">-' + FormatFloat('#,##0.00', DeptTax) + '</td>' +
            '<td class="text-end text-danger">-' + FormatFloat('#,##0.00', DeptPens) + '</td>' +
            '<td class="text-end text-danger">-' + FormatFloat('#,##0.00', DeptUnion) + '</td>' +
            '<td class="text-end text-danger">-' + FormatFloat('#,##0.00', DeptAlim) + '</td>' +
            '<td class="text-end text-success">' + FormatFloat('#,##0.00', DeptNet) + '</td>' +
            '</tr>';
        end;

        // Обнуляем счетчики отдела
        DeptGross := 0; DeptTax := 0; DeptPens := 0; DeptUnion := 0; DeptAlim := 0; DeptNet := 0;

        // 2. Заголовок нового отдела
        TBody := TBody + '<tr class="table-secondary"><td colspan="9" class="fw-bold text-uppercase">' + DeptName + '</td></tr>';
        CurrentDept := DeptName;
      end;

      // Накапливаем итоги Отдела
      DeptGross := DeptGross + Dataset.FieldByName('gross_amount').AsFloat;
      DeptTax := DeptTax + Dataset.FieldByName('tax_amount').AsFloat;
      DeptPens := DeptPens + Dataset.FieldByName('pension_amount').AsFloat;
      DeptUnion := DeptUnion + Dataset.FieldByName('union_amount').AsFloat;
      DeptAlim := DeptAlim + Dataset.FieldByName('alimony_amount').AsFloat;
      DeptNet := DeptNet + Dataset.FieldByName('net_amount').AsFloat;

      // Накапливаем итоги Предприятия
      GrandGross := GrandGross + Dataset.FieldByName('gross_amount').AsFloat;
      GrandTax := GrandTax + Dataset.FieldByName('tax_amount').AsFloat;
      GrandPens := GrandPens + Dataset.FieldByName('pension_amount').AsFloat;
      GrandUnion := GrandUnion + Dataset.FieldByName('union_amount').AsFloat;
      GrandAlim := GrandAlim + Dataset.FieldByName('alimony_amount').AsFloat;
      GrandNet := GrandNet + Dataset.FieldByName('net_amount').AsFloat;

      // Строка сотрудника
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
        '<td class="text-end fw-bold" style="font-size: 1.05em;">' + FormatFloat('#,##0.00', Dataset.FieldByName('net_amount').AsFloat) + '</td>' +
        '</tr>';

      Inc(RowIndex);
      Dataset.Next;
    end;

    // ВАЖНО: Выводим итоги для самого последнего отдела в списке!
    if CurrentDept <> '' then
    begin
      TBody := TBody + '<tr class="table-light fw-bold" style="font-size: 0.85rem;">' +
        '<td colspan="3" class="text-end">Итого по отделу:</td>' +
        '<td class="text-end">' + FormatFloat('#,##0.00', DeptGross) + '</td>' +
        '<td class="text-end text-danger">-' + FormatFloat('#,##0.00', DeptTax) + '</td>' +
        '<td class="text-end text-danger">-' + FormatFloat('#,##0.00', DeptPens) + '</td>' +
        '<td class="text-end text-danger">-' + FormatFloat('#,##0.00', DeptUnion) + '</td>' +
        '<td class="text-end text-danger">-' + FormatFloat('#,##0.00', DeptAlim) + '</td>' +
        '<td class="text-end text-success">' + FormatFloat('#,##0.00', DeptNet) + '</td>' +
        '</tr>';
    end;

  finally
    Dataset.EnableControls;
  end;

  // 4. Собираем весь документ (разбили длинные строки на части!)
  Result :=
    '<html><head><style>' + BootstrapCSS + '</style><style>' +
    '  @media print { .no-print { display: none; } @page { size: landscape; margin: 10mm; } }' +
    '  body { background: #f8f9fa; padding: 20px; font-family: "Segoe UI", sans-serif; }' +
    '  .report-container { background: white; padding: 25px; border-radius: 8px; box-shadow: 0 4px 6px rgba(0,0,0,0.1); }' +
    '  .table th { vertical-align: middle; text-align: center; background-color: #e9ecef !important; }' +
    '  .table td { vertical-align: middle; }' +
    '</style></head><body>' +
    '<div class="container-fluid report-container">' +
    '  <h3 class="text-center mb-4 border-bottom pb-3">Сводная ведомость по заработной плате<br>' +
    '  <small class="text-muted">Период: ' + Period + '</small></h3>' +
    '  <div class="table-responsive">' +
    '    <table class="table table-bordered table-sm table-hover" style="font-size: 0.85rem;">' +

    // --- ВОТ ЗДЕСЬ МЫ РАЗБИЛИ ДЛИННУЮ СТРОКУ НА КОРОТКИЕ КУСОЧКИ ---
    '      <thead><tr>' +
    '        <th style="width: 3%;">№</th>' +
    '        <th style="width: 22%;">Сотрудник / Должность</th>' +
    '        <th style="width: 10%;">Оклад/Тариф</th>' +
    '        <th style="width: 10%;">Начислено</th>' +
    '        <th style="width: 9%;">Подоходный</th>' +
    '        <th style="width: 9%;">Пенсионный</th>' +
    '        <th style="width: 9%;">Профсоюз</th>' +
    '        <th style="width: 9%;">Алименты</th>' +
    '        <th style="width: 11%;">К выплате</th>' +
    '      </tr></thead>' +
    // --------------------------------------------------------------

    '      <tbody>' + TBody + '</tbody>' +
    '      <tfoot class="table-dark" style="font-size: 0.95rem;">' +
    '        <tr><td colspan="3" class="text-end fw-bold">ИТОГО ПО ПРЕДПРИЯТИЮ:</td>' +
    '          <td class="text-end fw-bold">' + FormatFloat('#,##0.00', GrandGross) + '</td>' +
    '          <td class="text-end text-warning">-' + FormatFloat('#,##0.00', GrandTax) + '</td>' +
    '          <td class="text-end text-warning">-' + FormatFloat('#,##0.00', GrandPens) + '</td>' +
    '          <td class="text-end text-warning">-' + FormatFloat('#,##0.00', GrandUnion) + '</td>' +
    '          <td class="text-end text-warning">-' + FormatFloat('#,##0.00', GrandAlim) + '</td>' +
    '          <td class="text-end fw-bold text-success" style="font-size: 1.1em;">' + FormatFloat('#,##0.00', GrandNet) + '</td>' +
    '        </tr></tfoot></table></div>' +
    '  <div class="row mt-5 pt-3 border-top no-print">' +
    '    <div class="col-6 text-center">Главный бухгалтер __________________</div>' +
    '    <div class="col-6 text-center">Директор __________________</div>' +
    '  </div>' +
    '</div></body></html>';
end;

procedure TfrmReportPayroll.btnPrintClick(Sender: TObject);
begin
  Edge.SetFocus;
  Edge.ExecuteScript('setTimeout(function() { window.print(); }, 100);');
end;

end.

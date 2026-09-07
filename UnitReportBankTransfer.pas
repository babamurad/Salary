unit UnitReportBankTransfer;

// Отчёт для банка: список сумм к перечислению на карты сотрудников
// (зарплата на карту, не наличными) за выбранный период. Сумма к
// перечислению — это чистая сумма на руки (net_amount) из уже
// рассчитанной зарплаты; графа "командировочные" в реестре пока не
// заполняется (в системе такие суммы отдельно не учитываются) — она
// оставлена пустой/нулевой, бухгалтер может дописать её от руки при
// необходимости.
//
// Реквизиты организации и обслуживающего банка берутся из company_info
// (вкладка "Компания" в настройках) — реальные счета и коды конкретного
// заказчика в код не зашиваются.

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls,
  SHDocVw, System.IOUtils, Data.DB, UnitReportBrowserUtils, Vcl.OleCtrls,
  FireDAC.Comp.Client, FireDAC.Stan.Param, FireDAC.Comp.DataSet;

type
  TfrmReportBankTransfer = class(TForm)
    PanelTop: TPanel;
    btnPreview: TButton;
    btnPrint: TButton;
    WebBrowser: TWebBrowser;
    procedure btnPrintClick(Sender: TObject);
    procedure btnPreviewClick(Sender: TObject);
  private
    qryReport: TFDQuery;
    function GenerateReportHtml(Dataset: TDataSet; const Period: string): string;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure ShowReport(const APeriodSql, ADisplayPeriod: string; ADeptID: Integer);
  end;

var
  frmReportBankTransfer: TfrmReportBankTransfer;

implementation

{$R *.dfm}

uses
  UnitdmMain, UnitCompanyInfo;

{ TfrmReportBankTransfer }

constructor TfrmReportBankTransfer.Create(AOwner: TComponent);
begin
  inherited;
  qryReport := TFDQuery.Create(Self);
  if Assigned(dmMain) then
    qryReport.Connection := dmMain.conn;
end;

destructor TfrmReportBankTransfer.Destroy;
begin
  qryReport.Free;
  inherited;
end;

procedure TfrmReportBankTransfer.ShowReport(const APeriodSql, ADisplayPeriod: string; ADeptID: Integer);
var
  Html: string;
begin
  qryReport.Close;
  qryReport.SQL.Text :=
    'SELECT e.tabno, e.fio, e.bank_account, d.dept_name, ' +
    '       p.net_amount ' +
    'FROM payroll_journal p ' +
    'JOIN employees e ON p.emp_id = e.id ' +
    'LEFT JOIN departments d ON e.dept_id = d.id ' +
    'WHERE strftime(''%Y-%m'', p.period_date) = :period ';
  if ADeptID > 0 then
    qryReport.SQL.Text := qryReport.SQL.Text + ' AND e.dept_id = ' + IntToStr(ADeptID);
  qryReport.SQL.Text := qryReport.SQL.Text + ' ORDER BY d.dept_name, e.fio';
  qryReport.ParamByName('period').AsString := APeriodSql;
  qryReport.Open;

  if qryReport.IsEmpty then
    ShowMessage('За выбранный период нет рассчитанной зарплаты.');

  Html := GenerateReportHtml(qryReport, ADisplayPeriod);
  ShowHtmlInBrowser(WebBrowser, Html, 'ReportBankTransfer');
end;

function TfrmReportBankTransfer.GenerateReportHtml(Dataset: TDataSet; const Period: string): string;
var
  ReportCssPath, ReportCSS: string;
  TBody: string;
  RowIndex: Integer;
  NetAmount, BusinessTrip, RowTotal: Double;
  GrandNet, GrandTrip, GrandTotal: Double;
  BankAccount: string;
  CompanyName, PayingBankName, PayingBankAccount: string;
  DirectorTitle, DirectorFio, AccountantTitle, AccountantFio: string;
begin
  ReportCssPath := ExtractFilePath(ParamStr(0)) + 'assets\report.css';
  ReportCSS := '';
  if TFile.Exists(ReportCssPath) then ReportCSS := TFile.ReadAllText(ReportCssPath);

  CompanyName := GetCompanyInfoValue('company_name');
  PayingBankName := GetCompanyInfoValue('bank_name');
  PayingBankAccount := GetCompanyInfoValue('bank_account');
  DirectorTitle := GetCompanyInfoValue('director_title', 'Директор');
  DirectorFio := GetCompanyInfoValue('director_fio');
  AccountantTitle := GetCompanyInfoValue('accountant_title', 'Гл. бухгалтер');
  AccountantFio := GetCompanyInfoValue('accountant_fio');

  // Командировочные ("Iş sapary") в системе отдельно не учитываются —
  // графа всегда 0, до тех пор пока такой учёт не появится.
  BusinessTrip := 0;

  GrandNet := 0; GrandTrip := 0; GrandTotal := 0;
  RowIndex := 1;
  TBody := '';

  Dataset.DisableControls;
  try
    Dataset.First;
    while not Dataset.Eof do
    begin
      NetAmount := Dataset.FieldByName('net_amount').AsFloat;
      RowTotal := NetAmount + BusinessTrip;

      BankAccount := Dataset.FieldByName('bank_account').AsString;
      if BankAccount = '' then BankAccount := '&mdash;';

      TBody := TBody + '<tr>' +
        '<td class="text-center">' + IntToStr(RowIndex) + '</td>' +
        '<td class="text-center">' + BankAccount + '</td>' +
        '<td>' + Dataset.FieldByName('fio').AsString + '</td>' +
        '<td class="text-end">' + FormatFloat('#,##0.00', NetAmount) + '</td>' +
        '<td class="text-end">' + FormatFloat('#,##0.00', BusinessTrip) + '</td>' +
        '<td class="text-end fw-bold">' + FormatFloat('#,##0.00', RowTotal) + '</td>' +
        '</tr>';

      GrandNet := GrandNet + NetAmount;
      GrandTrip := GrandTrip + BusinessTrip;
      GrandTotal := GrandTotal + RowTotal;

      Inc(RowIndex);
      Dataset.Next;
    end;
  finally
    Dataset.EnableControls;
  end;

  Result :=
    '<html><head><style>' + ReportCSS + '</style><style>' +
    '  @media print { .no-print { display: none; } @page { size: landscape; margin: 10mm; } }' +
    '  body { background: #f8f9fa; padding: 20px; font-family: "Segoe UI", sans-serif; }' +
    '  .report-container { background: white; padding: 25px; border-radius: 8px; box-shadow: 0 4px 6px rgba(0,0,0,0.1); }' +
    '  .table th { vertical-align: middle; text-align: center; background-color: #e9ecef !important; }' +
    '  .table td { vertical-align: middle; }' +
    '  .req-line { font-size: 0.85rem; margin-bottom: 4px; }' +
    '</style></head><body>' +
    '<div class="container-fluid report-container">' +
    '  <h4 class="text-center mb-2">' + CompanyName + '</h4>' +
    '  <div class="req-line text-center">Банк: ' + PayingBankName +
    '&nbsp; &nbsp; Расчётный счёт: ' + PayingBankAccount + '</div>' +
    '  <h5 class="text-center mt-3 mb-4 border-bottom pb-3">Реестр на перечисление заработной платы на карты<br>' +
    '  <small class="text-muted">Период: ' + Period + '</small></h5>' +
    '  <div class="table-responsive">' +
    '    <table class="table table-bordered table-sm table-hover" style="font-size: 0.85rem;">' +
    '      <thead><tr>' +
    '        <th style="width: 4%;">№</th>' +
    '        <th style="width: 22%;">Номер счёта (карты)</th>' +
    '        <th style="width: 32%;">Ф.И.О.</th>' +
    '        <th style="width: 15%;">Заработная плата</th>' +
    '        <th style="width: 13%;">Командировочные</th>' +
    '        <th style="width: 14%;">Итого к перечислению</th>' +
    '      </tr></thead>' +
    '      <tbody>' + TBody + '</tbody>' +
    '      <tfoot class="table-dark">' +
    '        <tr><td colspan="3" class="text-end fw-bold">Итого по реестру:</td>' +
    '          <td class="text-end fw-bold">' + FormatFloat('#,##0.00', GrandNet) + '</td>' +
    '          <td class="text-end fw-bold">' + FormatFloat('#,##0.00', GrandTrip) + '</td>' +
    '          <td class="text-end fw-bold" style="font-size: 1.05em;">' + FormatFloat('#,##0.00', GrandTotal) + '</td>' +
    '        </tr></tfoot></table></div>' +
    '  <div class="row mt-5 pt-3 border-top no-print">' +
    '    <div class="col-6 text-center">' + DirectorTitle + ' __________________ ' + DirectorFio + '</div>' +
    '    <div class="col-6 text-center">' + AccountantTitle + ' __________________ ' + AccountantFio + '</div>' +
    '  </div>' +
    '</div></body></html>';
end;

procedure TfrmReportBankTransfer.btnPrintClick(Sender: TObject);
begin
  PrintBrowser(WebBrowser);
end;

procedure TfrmReportBankTransfer.btnPreviewClick(Sender: TObject);
begin
  PrintPreviewBrowser(WebBrowser);
end;

end.

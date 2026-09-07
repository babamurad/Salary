unit UnitReportPension;

// Отчёт для Пенсионного фонда: реестр обязательных и добровольных
// пенсионных взносов по сотрудникам за выбранный период. Обязательный
// взнос считается по единой ставке (company_info.mandatory_pension_rate,
// по умолчанию 20% — редактируется в настройках, это законодательная
// величина, а не персональные данные сотрудника). Добровольный взнос
// (meýletin) — это существующий индивидуальный pension_rate/pension_amount
// сотрудника, он не у всех больше нуля.
//
// Реквизиты организации и получателя платежа (коды, банк ПФ и т.д.)
// берутся из company_info (вкладка "Компания" в настройках) — реальные
// коды и счета конкретного заказчика в код не зашиваются.

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls,
  SHDocVw, System.IOUtils, Data.DB, UnitReportBrowserUtils, Vcl.OleCtrls,
  FireDAC.Comp.Client, FireDAC.Stan.Param, FireDAC.Comp.DataSet;

type
  TfrmReportPension = class(TForm)
    PanelTop: TPanel;
    btnPreview: TButton;
    btnPrint: TButton;
    WebBrowser: TWebBrowser;
    procedure btnPrintClick(Sender: TObject);
    procedure btnPreviewClick(Sender: TObject);
  private
    qryReport: TFDQuery;
    function GenerateReportHtml(Dataset: TDataSet; const Period: string;
      MandatoryRate: Double): string;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure ShowReport(const APeriodSql, ADisplayPeriod: string; ADeptID: Integer);
  end;

var
  frmReportPension: TfrmReportPension;

implementation

{$R *.dfm}

uses
  UnitdmMain, UnitCompanyInfo, System.Math, System.StrUtils;

{ TfrmReportPension }

constructor TfrmReportPension.Create(AOwner: TComponent);
begin
  inherited;
  qryReport := TFDQuery.Create(Self);
  if Assigned(dmMain) then
    qryReport.Connection := dmMain.conn;
end;

destructor TfrmReportPension.Destroy;
begin
  qryReport.Free;
  inherited;
end;

procedure TfrmReportPension.ShowReport(const APeriodSql, ADisplayPeriod: string; ADeptID: Integer);
var
  MandatoryRate: Double;
  Html: string;
begin
  MandatoryRate := StrToFloatDef(GetCompanyInfoValue('mandatory_pension_rate', '20'), 20);

  qryReport.Close;
  qryReport.SQL.Text :=
    'SELECT e.tabno, e.fio, e.pension_account, d.dept_name, ' +
    '       p.gross_amount, e.pension_rate as voluntary_rate, p.pension_amount as voluntary_amount ' +
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

  Html := GenerateReportHtml(qryReport, ADisplayPeriod, MandatoryRate);
  ShowHtmlInBrowser(WebBrowser, Html, 'ReportPension');
end;

function TfrmReportPension.GenerateReportHtml(Dataset: TDataSet; const Period: string;
  MandatoryRate: Double): string;
var
  ReportCssPath, ReportCSS: string;
  TBody, ReqLine1, ReqLine2: string;
  RowIndex: Integer;
  Gross, MandatoryAmt, VoluntaryRate, VoluntaryAmt, RowTotal: Double;
  GrandGross, GrandMandatory, GrandVoluntary, GrandTotal: Double;
  PensionAccount, VoluntaryCell: string;
  CompanyName, OrgCode, TaxCode, OwnershipCode, MinistryCode, RegionCode: string;
  PensionFundBank, PensionFundAccount: string;
  DirectorTitle, DirectorFio, AccountantTitle, AccountantFio: string;
begin
  ReportCssPath := ExtractFilePath(ParamStr(0)) + 'assets\report.css';
  ReportCSS := '';
  if TFile.Exists(ReportCssPath) then ReportCSS := TFile.ReadAllText(ReportCssPath);

  CompanyName := GetCompanyInfoValue('company_name');
  OrgCode := GetCompanyInfoValue('org_code');
  TaxCode := GetCompanyInfoValue('tax_code');
  OwnershipCode := GetCompanyInfoValue('ownership_type_code');
  MinistryCode := GetCompanyInfoValue('ministry_code');
  RegionCode := GetCompanyInfoValue('region_code');
  PensionFundBank := GetCompanyInfoValue('pension_fund_bank');
  PensionFundAccount := GetCompanyInfoValue('pension_fund_account');
  DirectorTitle := GetCompanyInfoValue('director_title', 'Директор');
  DirectorFio := GetCompanyInfoValue('director_fio');
  AccountantTitle := GetCompanyInfoValue('accountant_title', 'Гл. бухгалтер');
  AccountantFio := GetCompanyInfoValue('accountant_fio');

  ReqLine1 :=
    IfThen(OrgCode <> '', 'Код организации: ' + OrgCode + '&nbsp; &nbsp; ') +
    IfThen(TaxCode <> '', 'Налоговый код: ' + TaxCode + '&nbsp; &nbsp; ') +
    IfThen(OwnershipCode <> '', 'Форма собственности: ' + OwnershipCode + '&nbsp; &nbsp; ') +
    IfThen(MinistryCode <> '', 'Мин-во/ведомство: ' + MinistryCode + '&nbsp; &nbsp; ') +
    IfThen(RegionCode <> '', 'Регион: ' + RegionCode);

  ReqLine2 :=
    IfThen(PensionFundBank <> '', 'Получатель (банк): ' + PensionFundBank + '&nbsp; &nbsp; ') +
    IfThen(PensionFundAccount <> '', 'Счёт получателя: ' + PensionFundAccount);

  GrandGross := 0; GrandMandatory := 0; GrandVoluntary := 0; GrandTotal := 0;
  RowIndex := 1;
  TBody := '';

  Dataset.DisableControls;
  try
    Dataset.First;
    while not Dataset.Eof do
    begin
      Gross := Dataset.FieldByName('gross_amount').AsFloat;
      MandatoryAmt := SimpleRoundTo(Gross * MandatoryRate / 100, -2);
      VoluntaryRate := Dataset.FieldByName('voluntary_rate').AsFloat;
      VoluntaryAmt := Dataset.FieldByName('voluntary_amount').AsFloat;
      RowTotal := MandatoryAmt + VoluntaryAmt;

      PensionAccount := Dataset.FieldByName('pension_account').AsString;
      if PensionAccount = '' then PensionAccount := '&mdash;';

      if VoluntaryRate > 0 then
        VoluntaryCell := FormatFloat('0.##', VoluntaryRate) + '% / ' + FormatFloat('#,##0.00', VoluntaryAmt)
      else
        VoluntaryCell := '&mdash;';

      TBody := TBody + '<tr>' +
        '<td class="text-center">' + IntToStr(RowIndex) + '</td>' +
        '<td class="text-center">' + Dataset.FieldByName('tabno').AsString + '</td>' +
        '<td>' + Dataset.FieldByName('fio').AsString + '</td>' +
        '<td class="text-center">' + PensionAccount + '</td>' +
        '<td class="text-end">' + FormatFloat('#,##0.00', Gross) + '</td>' +
        '<td class="text-end">' + FormatFloat('#,##0.00', MandatoryAmt) + '</td>' +
        '<td class="text-center">' + VoluntaryCell + '</td>' +
        '<td class="text-end fw-bold">' + FormatFloat('#,##0.00', RowTotal) + '</td>' +
        '</tr>';

      GrandGross := GrandGross + Gross;
      GrandMandatory := GrandMandatory + MandatoryAmt;
      GrandVoluntary := GrandVoluntary + VoluntaryAmt;
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
    '  <div class="req-line text-center">' + ReqLine1 + '</div>' +
    '  <div class="req-line text-center">' + ReqLine2 + '</div>' +
    '  <h5 class="text-center mt-3 mb-4 border-bottom pb-3">Реестр пенсионных взносов<br>' +
    '  <small class="text-muted">Период: ' + Period + '</small></h5>' +
    '  <div class="table-responsive">' +
    '    <table class="table table-bordered table-sm table-hover" style="font-size: 0.85rem;">' +
    '      <thead><tr>' +
    '        <th style="width: 3%;">№</th>' +
    '        <th style="width: 6%;">Таб. №</th>' +
    '        <th style="width: 24%;">Ф.И.О.</th>' +
    '        <th style="width: 14%;">Пенс. счёт</th>' +
    '        <th style="width: 12%;">Начислено</th>' +
    '        <th style="width: 14%;">Обязательный (' + FormatFloat('0.##', MandatoryRate) + '%)</th>' +
    '        <th style="width: 14%;">Добровольный (me' + #253 + 'letin)</th>' +
    '        <th style="width: 13%;">Итого</th>' +
    '      </tr></thead>' +
    '      <tbody>' + TBody + '</tbody>' +
    '      <tfoot class="table-dark">' +
    '        <tr><td colspan="4" class="text-end fw-bold">Итого по реестру:</td>' +
    '          <td class="text-end fw-bold">' + FormatFloat('#,##0.00', GrandGross) + '</td>' +
    '          <td class="text-end fw-bold">' + FormatFloat('#,##0.00', GrandMandatory) + '</td>' +
    '          <td class="text-end fw-bold">' + FormatFloat('#,##0.00', GrandVoluntary) + '</td>' +
    '          <td class="text-end fw-bold" style="font-size: 1.05em;">' + FormatFloat('#,##0.00', GrandTotal) + '</td>' +
    '        </tr></tfoot></table></div>' +
    '  <div class="row mt-5 pt-3 border-top no-print">' +
    '    <div class="col-6 text-center">' + DirectorTitle + ' __________________ ' + DirectorFio + '</div>' +
    '    <div class="col-6 text-center">' + AccountantTitle + ' __________________ ' + AccountantFio + '</div>' +
    '  </div>' +
    '</div></body></html>';
end;

procedure TfrmReportPension.btnPrintClick(Sender: TObject);
begin
  PrintBrowser(WebBrowser);
end;

procedure TfrmReportPension.btnPreviewClick(Sender: TObject);
begin
  PrintPreviewBrowser(WebBrowser);
end;

end.

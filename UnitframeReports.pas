unit UnitframeReports;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Data.DB, Vcl.Grids,
  Vcl.DBGrids, Vcl.ExtCtrls, Vcl.StdCtrls, Vcl.ComCtrls,
  FireDAC.Comp.Client, FireDAC.Comp.DataSet, FireDAC.Stan.Param, ComObj;

type
  TframeReports = class(TFrame)
    PanelTop: TPanel;
    lblPeriod: TLabel;
    dtpPeriod: TDateTimePicker;
    btnGenerate: TButton;
    DBGrid1: TDBGrid;
    btnExport: TButton;
    SaveDialog1: TSaveDialog;
  private
    qryReport: TFDQuery;
    dsReport: TDataSource;
    procedure btnGenerateClick(Sender: TObject);
    procedure btnExportClick(Sender: TObject);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;

implementation

{$R *.dfm}

uses
  UnitdmMain;

constructor TframeReports.Create(AOwner: TComponent);
begin
  inherited;

  // --- НАСТРАИВАЕМ КАЛЕНДАРЬ ПРОГРАММНО ---
  dtpPeriod.Format := 'MM.yyyy'; // Формат только Месяц и Год
  dtpPeriod.Date := Date;        // Текущая дата
  // ----------------------------------------

  btnGenerate.OnClick := btnGenerateClick;
  btnExport.OnClick := btnExportClick;

  if Assigned(dmMain) then
  begin
    qryReport := TFDQuery.Create(Self);
    qryReport.Connection := dmMain.conn;

    dsReport := TDataSource.Create(Self);
    dsReport.DataSet := qryReport;

    DBGrid1.DataSource := dsReport;
  end;
end;

destructor TframeReports.Destroy;
begin
  if Assigned(qryReport) then qryReport.Free;
  if Assigned(dsReport) then dsReport.Free;
  inherited;
end;

procedure TframeReports.btnGenerateClick(Sender: TObject);
var
  PeriodStr: string;
begin
  if not Assigned(dmMain) then Exit;

  PeriodStr := FormatDateTime('yyyy-mm', dtpPeriod.Date);

  qryReport.Close;
  qryReport.SQL.Text :=
    'SELECT e.tabno, e.fio, d.dept_name, pos.name as pos_name, ' +
    'p.gross_amount, p.tax_amount, p.pension_amount, p.net_amount ' +
    'FROM payroll_journal p ' +
    'JOIN employees e ON p.emp_id = e.id ' +
    'LEFT JOIN departments d ON e.dept_id = d.id ' +
    'LEFT JOIN positions pos ON e.pos_id = pos.id ' +
    'WHERE strftime(''%Y-%m'', p.period_date) = :period ' +
    'ORDER BY d.dept_name, e.fio';

  qryReport.ParamByName('period').AsString := PeriodStr;
  qryReport.Open;

  if DBGrid1.Columns.Count > 0 then
  begin
    TIntegerField(qryReport.FieldByName('tabno')).DisplayFormat := '000';

    DBGrid1.Columns[0].Title.Caption := 'Таб. №';
    DBGrid1.Columns[0].Width := 60;
    DBGrid1.Columns[1].Title.Caption := 'Ф.И.О. сотрудника';
    DBGrid1.Columns[1].Width := 200;
    DBGrid1.Columns[2].Title.Caption := 'Отдел';
    DBGrid1.Columns[2].Width := 130;
    DBGrid1.Columns[3].Title.Caption := 'Должность';
    DBGrid1.Columns[3].Width := 130;
    DBGrid1.Columns[4].Title.Caption := 'Начислено';
    DBGrid1.Columns[4].Width := 100;
    DBGrid1.Columns[5].Title.Caption := 'Подоходный (10%)';
    DBGrid1.Columns[5].Width := 140;
    DBGrid1.Columns[6].Title.Caption := 'Пенсионный (2%)';
    DBGrid1.Columns[6].Width := 140;
    DBGrid1.Columns[7].Title.Caption := 'К выдаче';
    DBGrid1.Columns[7].Width := 100;
  end;

  if qryReport.IsEmpty then
    ShowMessage('За выбранный период начислений не найдено.');
end;

procedure TframeReports.btnExportClick(Sender: TObject);
var
  ExcelApp, Workbook, Sheet: OleVariant;
  Row: Integer;
  TemplatePath: string;
  BM: TBookmark;
begin
  if not qryReport.Active or qryReport.IsEmpty then
  begin
    ShowMessage('Сначала сформируйте ведомость для экспорта!');
    Exit;
  end;

  // Ищем шаблон
  TemplatePath := ExtractFilePath(ParamStr(0)) + 'Template.xlsx';
  if not FileExists(TemplatePath) then
  begin
    ShowMessage('Не найден файл шаблона!' + sLineBreak + TemplatePath);
    Exit;
  end;

  SaveDialog1.FileName := 'Ведомость_' + FormatDateTime('yyyy_mm', dtpPeriod.Date) + '.xlsx';

  if SaveDialog1.Execute then
  begin
    try
      ExcelApp := CreateOleObject('Excel.Application');
    except
      ShowMessage('Не удалось запустить MS Excel. Убедитесь, что он установлен на компьютере.');
      Exit;
    end;

    try
      ExcelApp.Visible := False;
      ExcelApp.DisplayAlerts := False;

      Workbook := ExcelApp.Workbooks.Open(TemplatePath);
      Sheet := Workbook.Worksheets[1];

      // Переводим выбранную дату в красивый текст для шапки документа
      Sheet.Cells[2, 1].Value := 'Ведомость начислений за ' + FormatDateTime('mm.yyyy', dtpPeriod.Date);

      Row := 4; // Строка, с которой начинаем вставлять данные

      dsReport.DataSet.DisableControls;
      BM := dsReport.DataSet.GetBookmark;
      try
        dsReport.DataSet.First;

        while not dsReport.DataSet.Eof do
        begin
          Sheet.Cells[Row, 1].Value := dsReport.DataSet.FieldByName('tabno').AsString;
          Sheet.Cells[Row, 2].Value := dsReport.DataSet.FieldByName('fio').AsString;
          Sheet.Cells[Row, 3].Value := dsReport.DataSet.FieldByName('dept_name').AsString;
          Sheet.Cells[Row, 4].Value := dsReport.DataSet.FieldByName('pos_name').AsString;
          Sheet.Cells[Row, 5].Value := dsReport.DataSet.FieldByName('gross_amount').AsFloat;
          Sheet.Cells[Row, 6].Value := dsReport.DataSet.FieldByName('tax_amount').AsFloat;
          Sheet.Cells[Row, 7].Value := dsReport.DataSet.FieldByName('pension_amount').AsFloat;
          Sheet.Cells[Row, 8].Value := dsReport.DataSet.FieldByName('net_amount').AsFloat;

          Inc(Row);
          dsReport.DataSet.Next;
        end;

        Sheet.Range[Sheet.Cells[4, 1], Sheet.Cells[Row - 1, 8]].Borders.LineStyle := 1;

      finally
        dsReport.DataSet.GotoBookmark(BM);
        dsReport.DataSet.FreeBookmark(BM);
        dsReport.DataSet.EnableControls;
      end;

      Workbook.SaveAs(SaveDialog1.FileName);
      ExcelApp.Visible := True;

    finally
      ExcelApp := Unassigned;
    end;
  end;
end;

end.

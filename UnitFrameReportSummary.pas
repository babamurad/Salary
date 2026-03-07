unit UnitFrameReportSummary;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  Winapi.WebView2, Winapi.ActiveX, Vcl.Edge, System.IOUtils, Data.DB, ComObj,
  FireDAC.Comp.Client, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf,
  System.DateUtils,
  FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt, FireDAC.Comp.DataSet; // Добавьте модули вашей БД, если нужно

type
  TframeReportSummary = class(TFrame)
    PanelTop: TPanel;
    cmbYear: TComboBox;
    cmbMonth: TComboBox;
    cmbDept: TComboBox;
    btnGenerate: TButton;
    btnPrint: TButton;
    btnExcel: TButton;
    Edge: TEdgeBrowser;
    qryReport: TFDQuery;
    dsReport: TDataSource; // Ваш запрос к БД
    procedure btnGenerateClick(Sender: TObject);
    procedure btnPrintClick(Sender: TObject);
    procedure btnExcelClick(Sender: TObject);
    procedure EdgeCreateWebViewCompleted(Sender: TCustomEdgeBrowser; AResult: HRESULT);
  private
    FHtmlContent: string;
    function GenerateReportHtml(Dataset: TDataSet; Period: string): string;
    procedure LoadData;
    procedure LoadDepartments;
  protected
    procedure SetParent(AParent: TWinControl); override;
  public
    constructor Create(AOwner: TComponent); override;
    // Процедура инициализации (можно вызывать при показе фрейма)

  end;

implementation

{$R *.dfm}

uses UnitdmMain;

{ TframeReportSummary }

procedure TframeReportSummary.LoadData;
var
  ReportDate: TDate;
begin
  // 1. Превращаем выбранный месяц и год в правильную ДАТУ (1-е число месяца)
  // cmbMonth.ItemIndex начинается с 0, поэтому прибавляем 1 для получения месяца
  ReportDate := EncodeDate(StrToInt(cmbYear.Text), cmbMonth.ItemIndex + 1, 1);

  qryReport.Close;
  qryReport.SQL.Clear;

  // 2. Делаем правильный SELECT:
  // - Вытаскиваем e.base_salary
  // - Переименовываем pos.name в pos_name, чтобы не сломать HTML-генератор
  qryReport.SQL.Add('SELECT p.*, e.fio, e.base_salary, d.dept_name, pos.name AS pos_name ');
  qryReport.SQL.Add('FROM payroll_journal p ');
  qryReport.SQL.Add('JOIN employees e ON p.emp_id = e.id ');
  qryReport.SQL.Add('LEFT JOIN departments d ON e.dept_id = d.id ');
  qryReport.SQL.Add('LEFT JOIN positions pos ON e.pos_id = pos.id ');

  // 3. Фильтруем по дате
  qryReport.SQL.Add('WHERE p.period_date = :p_date ');

  // 4. Безопасный фильтр по ID отдела (если выбран не "Все отделы")
  if cmbDept.ItemIndex > 0 then
    qryReport.SQL.Add('AND e.dept_id = :p_dept ');

  qryReport.SQL.Add('ORDER BY d.dept_name, e.fio');

  // 5. Передаем параметры
  // Передаем как правильную Дату
  qryReport.ParamByName('p_date').AsDate := ReportDate;

  // ВАЖНО: Если при начислении зарплаты вы сохраняли период текстом 'Март 2026'
  // несмотря на тип DATE (SQLite такое прощает), то закомментируйте строку выше
  // и раскомментируйте эту:
  // qryReport.ParamByName('p_date').AsString := cmbMonth.Text + ' ' + cmbYear.Text;

  // Передаем ID отдела из нашего AddObject
  if cmbDept.ItemIndex > 0 then
    qryReport.ParamByName('p_dept').AsInteger := Integer(cmbDept.Items.Objects[cmbDept.ItemIndex]);

  qryReport.Open;
end;

procedure TframeReportSummary.LoadDepartments;
begin
  if not Assigned(dmMain) then Exit;
    cmbDept.Items.Clear;
    cmbDept.Items.AddObject('--- Все отделы ---', TObject(0));
    if not dmMain.qryDepts.Active then dmMain.qryDepts.Open;
    dmMain.qryDepts.First;
    while not dmMain.qryDepts.Eof do
    begin
      cmbDept.Items.AddObject(dmMain.qryDepts.FieldByName('dept_name').AsString,
                              TObject(dmMain.qryDepts.FieldByName('id').AsInteger));
      dmMain.qryDepts.Next;
    end;
    cmbDept.ItemIndex := 0;
end;

procedure TframeReportSummary.SetParent(AParent: TWinControl);
begin
  inherited;
  // Как только у фрейма появился родитель (вкладка) — безопасно запускаем браузер!
  if (AParent <> nil) and not Assigned(Edge.DefaultInterface) then
  begin
    Edge.UserDataFolder := ExtractFilePath(ParamStr(0)) + 'EdgeCacheReports';
    Edge.CreateWebView;
  end;
end;

procedure TframeReportSummary.btnGenerateClick(Sender: TObject);
var
  PeriodStr: string;
begin

  if (cmbYear.Text = '') or (cmbMonth.Text = '') then
  begin
    ShowMessage('Выберите период!');
    Exit;
  end;

  // Загружаем данные из БД
  LoadData;

  if qryReport.IsEmpty then
  begin
    ShowMessage('Нет данных за выбранный период.');
    Exit;
  end;

  PeriodStr := cmbMonth.Text + ' ' + cmbYear.Text;

  // Генерируем HTML и отправляем в браузер
  FHtmlContent := GenerateReportHtml(qryReport, PeriodStr);
  Edge.NavigateToString(FHtmlContent);

  // Включаем кнопки экспорта
  btnPrint.Enabled := True;
  btnExcel.Enabled := True;
end;

procedure TframeReportSummary.EdgeCreateWebViewCompleted(Sender: TCustomEdgeBrowser; AResult: HRESULT);
begin
  if not Succeeded(AResult) then
    ShowMessage('Ошибка инициализации браузера для отчетов.');
end;

procedure TframeReportSummary.btnPrintClick(Sender: TObject);
begin
  // 1. Передаем фокус визуальному компоненту на форме
  if Edge.CanFocus then
    Edge.SetFocus;

  // 2. Двойной удар JS: сначала заставляем сам документ перехватить фокус,
  // а затем с чуть большей задержкой вызываем окно печати
  Edge.ExecuteScript('window.focus(); setTimeout(function() { window.print(); }, 250);');
end;

constructor TframeReportSummary.Create(AOwner: TComponent);
var
  i, vYear: Integer;
begin
  inherited;

  cmbMonth.Items.CommaText := 'Январь,Февраль,Март,Апрель,Май,Июнь,Июль,Август,Сентябрь,Октябрь,Ноябрь,Декабрь';
  vYear := YearOf(Date);

  for i := vYear - 2 to vYear + 2 do
    cmbYear.Items.Add(IntToStr(i));

  cmbMonth.ItemIndex := MonthOf(Date) - 1;
  cmbYear.Text := IntToStr(vYear);

  LoadDepartments;

  // ЭТИ ДВЕ СТРОЧКИ НУЖНО УДАЛИТЬ:
  // Edge.UserDataFolder := ExtractFilePath(ParamStr(0)) + 'EdgeCache';
  // Edge.CreateWebView;
end;

// --- ТУТ ВАШ КОД ИЗ ПРОШЛОГО ШАГА ---
// 1. Вставьте сюда полностью исправленную функцию GenerateReportHtml
// 2. Вставьте сюда полностью вашу функцию btnExcelClick (заменив qryPayroll на qryReport)

function TframeReportSummary.GenerateReportHtml(Dataset: TDataSet; Period: string): string;
var
  BootstrapPath, BootstrapCSS: string;
  TBody, CurrentDept, DeptName, TFoot: string;
  RowIndex: Integer;
  GrandGross, GrandTax, GrandPens, GrandUnion, GrandAlim, GrandNet: Double;
  DeptGross, DeptTax, DeptPens, DeptUnion, DeptAlim, DeptNet: Double;
begin
  // 1. Подгружаем локальный CSS Bootstrap
  BootstrapPath := ExtractFilePath(ParamStr(0)) + 'assets\bootstrap.min.css';
  BootstrapCSS := '';
  if TFile.Exists(BootstrapPath) then
    BootstrapCSS := TFile.ReadAllText(BootstrapPath);

  // 2. Инициализируем переменные для итогов
  GrandGross := 0; GrandTax := 0; GrandPens := 0; GrandUnion := 0; GrandAlim := 0; GrandNet := 0;
  DeptGross := 0; DeptTax := 0; DeptPens := 0; DeptUnion := 0; DeptAlim := 0; DeptNet := 0;

  RowIndex := 1;
  TBody := '';
  CurrentDept := '';
  TFoot := '';

  Dataset.DisableControls;
  try
    Dataset.First;
    while not Dataset.Eof do
    begin
      // Проверяем отдел
      DeptName := Dataset.FieldByName('dept_name').AsString;
      if DeptName = '' then DeptName := 'Без отдела';

      // Если отдел сменился — рисуем итоги старого и заголовок нового
      if DeptName <> CurrentDept then
      begin
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

        // Сбрасываем счетчики отдела и пишем серую полосу заголовка
        DeptGross := 0; DeptTax := 0; DeptPens := 0; DeptUnion := 0; DeptAlim := 0; DeptNet := 0;
        TBody := TBody + '<tr class="table-secondary"><td colspan="9" class="fw-bold text-uppercase">' +
                 DeptName + '</td></tr>';
        CurrentDept := DeptName;
      end;

      // Суммируем для Отдела
      DeptGross := DeptGross + Dataset.FieldByName('gross_amount').AsFloat;
      DeptTax := DeptTax + Dataset.FieldByName('tax_amount').AsFloat;
      DeptPens := DeptPens + Dataset.FieldByName('pension_amount').AsFloat;
      DeptUnion := DeptUnion + Dataset.FieldByName('union_amount').AsFloat;
      DeptAlim := DeptAlim + Dataset.FieldByName('alimony_amount').AsFloat;
      DeptNet := DeptNet + Dataset.FieldByName('net_amount').AsFloat;

      // Суммируем для Предприятия (Гранд Итог)
      GrandGross := GrandGross + Dataset.FieldByName('gross_amount').AsFloat;
      GrandTax := GrandTax + Dataset.FieldByName('tax_amount').AsFloat;
      GrandPens := GrandPens + Dataset.FieldByName('pension_amount').AsFloat;
      GrandUnion := GrandUnion + Dataset.FieldByName('union_amount').AsFloat;
      GrandAlim := GrandAlim + Dataset.FieldByName('alimony_amount').AsFloat;
      GrandNet := GrandNet + Dataset.FieldByName('net_amount').AsFloat;

      // Формируем строчку сотрудника
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

    // Итоги для самого последнего отдела в цикле
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

  // Если выбраны "Все отделы" (ItemIndex = 0), формируем "ИТОГО ПО ПРЕДПРИЯТИЮ"
  if cmbDept.ItemIndex = 0 then
  begin
    TFoot :=
      '<tfoot class="table-dark" style="font-size: 0.95rem;">' +
      '  <tr><td colspan="3" class="text-end fw-bold">ИТОГО ПО ПРЕДПРИЯТИЮ:</td>' +
      '    <td class="text-end fw-bold">' + FormatFloat('#,##0.00', GrandGross) + '</td>' +
      '    <td class="text-end text-warning">-' + FormatFloat('#,##0.00', GrandTax) + '</td>' +
      '    <td class="text-end text-warning">-' + FormatFloat('#,##0.00', GrandPens) + '</td>' +
      '    <td class="text-end text-warning">-' + FormatFloat('#,##0.00', GrandUnion) + '</td>' +
      '    <td class="text-end text-warning">-' + FormatFloat('#,##0.00', GrandAlim) + '</td>' +
      '    <td class="text-end fw-bold text-success" style="font-size: 1.1em;">' + FormatFloat('#,##0.00', GrandNet) + '</td>' +
      '  </tr></tfoot>';
  end;

  // 3. Собираем финальный HTML документ (разбито на короткие строки)
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

    // Шапка таблицы
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

    '      <tbody>' + TBody + '</tbody>' +
           TFoot +
    '    </table></div>' +

    // Подвал документа с подписями
    '  <div class="row mt-5 pt-3 border-top no-print">' +
    '    <div class="col-6 text-center">Главный бухгалтер __________________</div>' +
    '    <div class="col-6 text-center">Директор __________________</div>' +
    '  </div>' +
    '</div></body></html>';
end;

procedure TframeReportSummary.btnExcelClick(Sender: TObject);
var
  ExcelApp, Sheet: Variant;
  Row: Integer;
  GrandGross, GrandTax, GrandPens, GrandUnion, GrandAlim, GrandNet: Double;
  DeptGross, DeptTax, DeptPens, DeptUnion, DeptAlim, DeptNet: Double;
  Bookmark: TBookmark;
  CurrentDept, DeptName: string;
begin
  // 1. Защита от дурака: проверяем, есть ли данные
  if not Assigned(qryReport) or not qryReport.Active or qryReport.IsEmpty then
  begin
    ShowMessage('Сначала сформируйте отчет!');
    Exit;
  end;

  try
    ExcelApp := CreateOleObject('Excel.Application');
  except
    ShowMessage('Не удалось запустить Excel.');
    Exit;
  end;

  qryReport.DisableControls;
  Bookmark := qryReport.GetBookmark; // Запоминаем текущую позицию
  try
    ExcelApp.Workbooks.Add;
    Sheet := ExcelApp.ActiveSheet;
    Sheet.Name := 'Зарплата ' + cmbMonth.Text;

    // 2. Рисуем шапку
    Sheet.Cells[1, 1].Value := 'Сотрудник / Должность';
    Sheet.Cells[1, 2].Value := 'Оклад/Тариф';
    Sheet.Cells[1, 3].Value := 'Начислено';
    Sheet.Cells[1, 4].Value := 'Подоходный';
    Sheet.Cells[1, 5].Value := 'Пенсионный';
    Sheet.Cells[1, 6].Value := 'Профсоюз';
    Sheet.Cells[1, 7].Value := 'Алименты';
    Sheet.Cells[1, 8].Value := 'К выплате';

    Sheet.Range['A1:H1'].Font.Bold := True;
    Sheet.Range['A1:H1'].Interior.Color := $D3D3D3; // Серый фон шапки

    Row := 2;
    GrandGross := 0; GrandTax := 0; GrandPens := 0; GrandUnion := 0; GrandAlim := 0; GrandNet := 0;
    DeptGross := 0; DeptTax := 0; DeptPens := 0; DeptUnion := 0; DeptAlim := 0; DeptNet := 0;
    CurrentDept := '';

    // ВАЖНО: Возвращаем курсор в начало перед выгрузкой!
    qryReport.First;

    // 3. Выгружаем данные
    while not qryReport.Eof do
    begin
      DeptName := qryReport.FieldByName('dept_name').AsString;
      if DeptName = '' then DeptName := 'Без отдела';

      // Группировка
      if DeptName <> CurrentDept then
      begin
        // Итоги прошлого отдела
        if CurrentDept <> '' then
        begin
          Sheet.Cells[Row, 1].Value := 'ИТОГО ПО ОТДЕЛУ:';
          Sheet.Cells[Row, 3].Value := DeptGross;
          Sheet.Cells[Row, 4].Value := DeptTax;
          Sheet.Cells[Row, 5].Value := DeptPens;
          Sheet.Cells[Row, 6].Value := DeptUnion;
          Sheet.Cells[Row, 7].Value := DeptAlim;
          Sheet.Cells[Row, 8].Value := DeptNet;
          Sheet.Range['A' + IntToStr(Row) + ':H' + IntToStr(Row)].Font.Bold := True;
          Sheet.Range['A' + IntToStr(Row) + ':H' + IntToStr(Row)].Interior.Color := $F0F8FF;
          Inc(Row);
        end;

        DeptGross := 0; DeptTax := 0; DeptPens := 0; DeptUnion := 0; DeptAlim := 0; DeptNet := 0;

        // Заголовок нового отдела
        Sheet.Cells[Row, 1].Value := 'ОТДЕЛ: ' + DeptName;
        Sheet.Range['A' + IntToStr(Row) + ':H' + IntToStr(Row)].Merge;
        Sheet.Range['A' + IntToStr(Row) + ':H' + IntToStr(Row)].Font.Bold := True;
        Sheet.Range['A' + IntToStr(Row) + ':H' + IntToStr(Row)].Interior.Color := $E0FFFF;
        Inc(Row);
        CurrentDept := DeptName;
      end;

      // Данные сотрудника
      Sheet.Cells[Row, 1].Value := qryReport.FieldByName('fio').AsString + ' (' + qryReport.FieldByName('pos_name').AsString + ')';
      Sheet.Cells[Row, 2].Value := qryReport.FieldByName('base_salary').AsFloat;
      Sheet.Cells[Row, 3].Value := qryReport.FieldByName('gross_amount').AsFloat;
      Sheet.Cells[Row, 4].Value := qryReport.FieldByName('tax_amount').AsFloat;
      Sheet.Cells[Row, 5].Value := qryReport.FieldByName('pension_amount').AsFloat;
      Sheet.Cells[Row, 6].Value := qryReport.FieldByName('union_amount').AsFloat;
      Sheet.Cells[Row, 7].Value := qryReport.FieldByName('alimony_amount').AsFloat;
      Sheet.Cells[Row, 8].Value := qryReport.FieldByName('net_amount').AsFloat;

      // Накапливаем итоги
      DeptGross := DeptGross + qryReport.FieldByName('gross_amount').AsFloat;
      DeptTax := DeptTax + qryReport.FieldByName('tax_amount').AsFloat;
      DeptPens := DeptPens + qryReport.FieldByName('pension_amount').AsFloat;
      DeptUnion := DeptUnion + qryReport.FieldByName('union_amount').AsFloat;
      DeptAlim := DeptAlim + qryReport.FieldByName('alimony_amount').AsFloat;
      DeptNet := DeptNet + qryReport.FieldByName('net_amount').AsFloat;

      GrandGross := GrandGross + qryReport.FieldByName('gross_amount').AsFloat;
      GrandTax := GrandTax + qryReport.FieldByName('tax_amount').AsFloat;
      GrandPens := GrandPens + qryReport.FieldByName('pension_amount').AsFloat;
      GrandUnion := GrandUnion + qryReport.FieldByName('union_amount').AsFloat;
      GrandAlim := GrandAlim + qryReport.FieldByName('alimony_amount').AsFloat;
      GrandNet := GrandNet + qryReport.FieldByName('net_amount').AsFloat;

      Inc(Row);
      qryReport.Next;
    end;

    // 4. Итоги самого последнего отдела
    if CurrentDept <> '' then
    begin
      Sheet.Cells[Row, 1].Value := 'ИТОГО ПО ОТДЕЛУ:';
      Sheet.Cells[Row, 3].Value := DeptGross;
      Sheet.Cells[Row, 4].Value := DeptTax;
      Sheet.Cells[Row, 5].Value := DeptPens;
      Sheet.Cells[Row, 6].Value := DeptUnion;
      Sheet.Cells[Row, 7].Value := DeptAlim;
      Sheet.Cells[Row, 8].Value := DeptNet;
      Sheet.Range['A' + IntToStr(Row) + ':H' + IntToStr(Row)].Font.Bold := True;
      Sheet.Range['A' + IntToStr(Row) + ':H' + IntToStr(Row)].Interior.Color := $F0F8FF;
      Inc(Row);
    end;

    // 5. Итоги по предприятию (ТОЛЬКО ЕСЛИ ВЫБРАНЫ ВСЕ ОТДЕЛЫ)
    if cmbDept.ItemIndex = 0 then
    begin
      Sheet.Cells[Row, 1].Value := 'ИТОГО ПО ПРЕДПРИЯТИЮ:';
      Sheet.Cells[Row, 3].Value := GrandGross;
      Sheet.Cells[Row, 4].Value := GrandTax;
      Sheet.Cells[Row, 5].Value := GrandPens;
      Sheet.Cells[Row, 6].Value := GrandUnion;
      Sheet.Cells[Row, 7].Value := GrandAlim;
      Sheet.Cells[Row, 8].Value := GrandNet;

      Sheet.Range['A' + IntToStr(Row) + ':H' + IntToStr(Row)].Font.Bold := True;
      Sheet.Range['D' + IntToStr(Row) + ':G' + IntToStr(Row)].Font.Color := $0000FF; // Красный текст для налогов
      Sheet.Range['A' + IntToStr(Row) + ':H' + IntToStr(Row)].Interior.Color := $C0C0C0; // Серый фон
    end;

    Sheet.Columns.AutoFit;

  finally
    // Возвращаем курсор на место, где он был
    if qryReport.BookmarkValid(Bookmark) then
    begin
      qryReport.GotoBookmark(Bookmark);
      qryReport.FreeBookmark(Bookmark);
    end;
    qryReport.EnableControls;
  end;

  ExcelApp.Visible := True;
end;

end.

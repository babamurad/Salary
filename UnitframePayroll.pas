unit UnitframePayroll;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Data.DB, Vcl.Grids,
  Vcl.DBGrids, Vcl.ExtCtrls, Vcl.DBCtrls, Vcl.StdCtrls, System.Math, System.DateUtils,
  ComObj,
  FireDAC.Comp.Client, FireDAC.Comp.DataSet, FireDAC.Stan.Param;

type
  TframePayroll = class(TFrame)
    PanelTop: TPanel;
    DBNavigator1: TDBNavigator;
    DBGrid1: TDBGrid;
    btnCalc: TButton;
    cmbMonth: TComboBox;
    cmbYear: TComboBox;
    btnCloseMonth: TButton;
    btnExport: TButton;
    procedure btnCalcClick(Sender: TObject);
    procedure btnCloseMonthClick(Sender: TObject);
    procedure FilterChange(Sender: TObject);
    procedure DBGrid1DblClick(Sender: TObject);
    procedure btnExportClick(Sender: TObject); // Общий обработчик для смены фильтра
  private
    qryPayroll: TFDQuery;
    dsPayroll: TDataSource;
    procedure qryPayrollAfterOpen(DataSet: TDataSet);
    procedure RefreshData; // Метод для пересборки SQL с учетом фильтра
    function IsPeriodClosed(APeriod: string): Boolean; // Проверка замка
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function GetWorkingDaysNorm(AYear, AMonth: Integer): Integer;
  end;

implementation

{$R *.dfm}

uses UnitdmMain, UnitPaySlip;

{ TframePayroll }

constructor TframePayroll.Create(AOwner: TComponent);
var
  i, CurrentYear: Integer;
begin
  inherited;

  // 1. Заполняем месяцы
  cmbMonth.Items.CommaText := 'Январь,Февраль,Март,Апрель,Май,Июнь,Июль,Август,Сентябрь,Октябрь,Ноябрь,Декабрь';

  // 2. Заполняем годы (текущий +/- 2 года)
  CurrentYear := YearOf(Date);
  for i := CurrentYear - 2 to CurrentYear + 2 do
    cmbYear.Items.Add(IntToStr(i));

  // 3. Ставим текущие значения
  cmbMonth.ItemIndex := MonthOf(Date) - 1;
  cmbYear.Text := IntToStr(CurrentYear);

  if Assigned(dmMain) then
  begin
    qryPayroll := TFDQuery.Create(Self);
    qryPayroll.Connection := dmMain.conn;
    qryPayroll.AfterOpen := qryPayrollAfterOpen;
    qryPayroll.UpdateOptions.UpdateTableName := 'payroll_journal';
    qryPayroll.UpdateOptions.KeyFields := 'id';

    dsPayroll := TDataSource.Create(Self);
    dsPayroll.DataSet := qryPayroll;

    DBGrid1.DataSource := dsPayroll;
    DBNavigator1.DataSource := dsPayroll;

    RefreshData; // Загружаем данные с учетом фильтра
  end;

  // Привязываем события
  cmbMonth.OnChange := FilterChange;
  cmbYear.OnChange := FilterChange;
end;

procedure TframePayroll.RefreshData;
var
  SelectedPeriod: string;
begin
  SelectedPeriod := cmbYear.Text + '-' + Format('%.2d', [cmbMonth.ItemIndex + 1]);

  qryPayroll.Close;
  // Добавляем JOIN к таблицам departments и positions, чтобы вытащить их названия
  qryPayroll.SQL.Text :=
    'SELECT p.*, e.fio, e.base_salary, ' +
    '       d.dept_name, pos.name as pos_name ' + // <-- Забираем названия!
    'FROM payroll_journal p ' +
    'JOIN employees e ON p.emp_id = e.id ' +
    'LEFT JOIN departments d ON e.dept_id = d.id ' + // LEFT JOIN на случай, если отдел не указан
    'LEFT JOIN positions pos ON e.pos_id = pos.id ' +
    'WHERE strftime(''%Y-%m'', p.period_date) = :period ' +
    'ORDER BY e.fio';
  qryPayroll.ParamByName('period').AsString := SelectedPeriod;
  qryPayroll.Open;
end;

procedure TframePayroll.FilterChange(Sender: TObject);
begin
  RefreshData;
end;

function TframePayroll.GetWorkingDaysNorm(AYear, AMonth: Integer): Integer;
var
  i, DaysCount: Integer;
  D: TDateTime;
begin
  Result := 0;
  DaysCount := DaysInAMonth(AYear, AMonth);
  for i := 1 to DaysCount do
  begin
    D := EncodeDate(AYear, AMonth, i);
    // Считаем все дни, кроме 6 (Суббота) и 7 (Воскресенье)
    if not (DayOfTheWeek(D) in [6, 7]) then
      Inc(Result);
  end;
end;

function TframePayroll.IsPeriodClosed(APeriod: string): Boolean;
var
  Q: TFDQuery;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := dmMain.conn;
    Q.SQL.Text := 'SELECT 1 FROM closed_periods WHERE period_str = :p';
    Q.ParamByName('p').AsString := APeriod;
    Q.Open;
    Result := not Q.IsEmpty;
  finally
    Q.Free;
  end;
end;

procedure TframePayroll.btnCalcClick(Sender: TObject);
var
  QryEmp, QrySet, QryExec: TFDQuery;
  TaxRate, PensionRate, DepDeduction: Double;
  EmpId, DepCount, NormDays: Integer;
  NormHours, FactHours, HourlyRate, RegularHours, OvertimeHours: Double;
  BaseSal, Tax, Pension, Net, TaxBase: Double;
  SelectedPeriod, CalcDateStr: string;
  // --- НОВЫЕ ПЕРЕМЕННЫЕ ---
  HourlyRateDB: Double;
  WageType, IsRotation: Integer;
  BaseGross, RotationBonus, TotalGross: Double;
begin
  SelectedPeriod := cmbYear.Text + '-' + Format('%.2d', [cmbMonth.ItemIndex + 1]);

  // ПРОВЕРКА ЗАМКА (закрыт ли месяц)
  if IsPeriodClosed(SelectedPeriod) then
  begin
    ShowMessage('Этот месяц уже закрыт для редактирования!');
    Exit;
  end;

  if MessageDlg('Рассчитать зарплату за ' + cmbMonth.Text + ' ' + cmbYear.Text + '?',
     mtConfirmation, [mbYes, mbNo], 0) <> mrYes then Exit;

  // Узнаем НОРМУ рабочих дней и переводим в НОРМУ ЧАСОВ (при 8-часовом графике)
  NormDays := GetWorkingDaysNorm(StrToIntDef(cmbYear.Text, YearOf(Now)), cmbMonth.ItemIndex + 1);
  if NormDays = 0 then NormDays := 1; // Защита от деления на ноль
  NormHours := NormDays * 8.0;

  CalcDateStr := SelectedPeriod + '-01';

  QryEmp := TFDQuery.Create(nil);
  QrySet := TFDQuery.Create(nil);
  QryExec := TFDQuery.Create(nil);
  try
    QryEmp.Connection := dmMain.conn;
    QrySet.Connection := dmMain.conn;
    QryExec.Connection := dmMain.conn;

    // Читаем налоги из таблицы настроек
    QrySet.SQL.Text := 'SELECT key_name, key_value FROM settings';
    QrySet.Open;
    TaxRate := 10.0; PensionRate := 2.0; DepDeduction := 50.0; // Значения по умолчанию
    while not QrySet.Eof do
    begin
      if QrySet.FieldByName('key_name').AsString = 'income_tax' then TaxRate := QrySet.FieldByName('key_value').AsFloat
      else if QrySet.FieldByName('key_name').AsString = 'pension_fund' then PensionRate := QrySet.FieldByName('key_value').AsFloat
      else if QrySet.FieldByName('key_name').AsString = 'dependent_deduction' then DepDeduction := QrySet.FieldByName('key_value').AsFloat;
      QrySet.Next;
    end;

    // Достаем сотрудников и их часы из табеля
    QryEmp.SQL.Text :=
      'SELECT e.id, e.base_salary, e.hourly_rate, IFNULL(e.dependents_count, 0) as dep_count, ' +
      ' e.wage_type, e.is_rotation, ' +
      ' (SELECT IFNULL(SUM(t.hours_worked), 0) FROM timesheet t WHERE t.emp_id = e.id AND strftime(''%Y-%m'', t.work_date) = :p) as fact_hours ' +
      'FROM employees e WHERE e.status = 1';
    QryEmp.ParamByName('p').AsString := SelectedPeriod;
    QryEmp.Open;

    dmMain.conn.StartTransaction;
    try
      // Очищаем старые начисления
      QryExec.SQL.Text := 'DELETE FROM payroll_journal WHERE strftime(''%Y-%m'', period_date) = :P';
      QryExec.ParamByName('P').AsString := SelectedPeriod;
      QryExec.ExecSQL;

      QryExec.SQL.Text := 'INSERT INTO payroll_journal (emp_id, period_date, gross_amount, tax_amount, pension_amount, net_amount) ' +
                          'VALUES (:emp, :dt, :gross, :tax, :pens, :net)';

      while not QryEmp.Eof do
      begin
        // Читаем данные из запроса
        BaseSal := QryEmp.FieldByName('base_salary').AsFloat;
        HourlyRateDB := QryEmp.FieldByName('hourly_rate').AsFloat;
        DepCount := QryEmp.FieldByName('dep_count').AsInteger;
        FactHours := QryEmp.FieldByName('fact_hours').AsFloat;
        WageType := QryEmp.FieldByName('wage_type').AsInteger;
        IsRotation := QryEmp.FieldByName('is_rotation').AsInteger;

        // --- 1. ОПРЕДЕЛЯЕМ СТОИМОСТЬ ЧАСА (Оклад или Тариф) ---
        if WageType = 1 then
          HourlyRate := HourlyRateDB            // Если Тариф, берем ставку из hourly_rate
        else
          HourlyRate := BaseSal / NormHours;    // Если Оклад, считаем стоимость часа

        // --- 2. РАСЧЕТ ЧАСОВ (Обычные и Сверхурочные) ---
        if FactHours > NormHours then
        begin
          RegularHours := NormHours;
          OvertimeHours := FactHours - NormHours;
        end
        else
        begin
          RegularHours := FactHours;
          OvertimeHours := 0;
        end;

        // --- 3. БАЗОВОЕ НАЧИСЛЕНИЕ (Обычные часы + Сверхурочные х2) ---
        BaseGross := SimpleRoundTo((RegularHours * HourlyRate) + (OvertimeHours * HourlyRate * 2.0), -2);

        // --- 4. ВАХТОВАЯ НАДБАВКА (75%) ---
        if IsRotation = 1 then
          RotationBonus := SimpleRoundTo(BaseGross * 0.75, -2)
        else
          RotationBonus := 0;

        TotalGross := BaseGross + RotationBonus; // Итого начислено (грязными)

        // --- 5. РАСЧЕТ НАЛОГОВ ---
        // Пенсионный берется со ВСЕЙ суммы
        Pension := SimpleRoundTo((TotalGross * PensionRate) / 100.0, -2);

        // Подоходный налог берется ТОЛЬКО с базы (без учета вахтовых 75%)
        TaxBase := BaseGross - (DepCount * DepDeduction);
        Tax := SimpleRoundTo(Max(0, TaxBase * TaxRate / 100.0), -2);

        // --- 6. НА РУКИ ---
        Net := SimpleRoundTo(TotalGross - Tax - Pension, -2);

        // --- СОХРАНЕНИЕ В БАЗУ ---
        QryExec.ParamByName('emp').AsInteger := QryEmp.FieldByName('id').AsInteger;
        QryExec.ParamByName('dt').AsString := CalcDateStr;
        QryExec.ParamByName('gross').AsFloat := TotalGross; // Сохраняем итоговую сумму с надбавками
        QryExec.ParamByName('tax').AsFloat := Tax;
        QryExec.ParamByName('pens').AsFloat := Pension;
        QryExec.ParamByName('net').AsFloat := Net;
        QryExec.ExecSQL;

        QryEmp.Next;
      end;

      // Фиксируем транзакцию
      dmMain.conn.Commit;
      RefreshData;
      ShowMessage('Расчет успешно завершен! Зарплата, тарифы, сверхурочные и вахтовые начислены.');

    except
      on E: Exception do
      begin
        dmMain.conn.Rollback;
        ShowMessage('Ошибка при расчете: ' + E.Message);
      end;
    end;
  finally
    QryEmp.Free; QrySet.Free; QryExec.Free;
  end;
end;

procedure TframePayroll.btnCloseMonthClick(Sender: TObject);
var
  Period: string;
begin
  Period := cmbYear.Text + '-' + Format('%.2d', [cmbMonth.ItemIndex + 1]);
  if MessageDlg('Вы уверены, что хотите ЗАКРЫТЬ ' + cmbMonth.Text + ' для редактирования? Это действие нельзя отменить.',
     mtWarning, [mbYes, mbNo], 0) = mrYes then
  begin
    try
      dmMain.conn.ExecSQL('INSERT INTO closed_periods (period_str) VALUES (:p)', [Period]);
      ShowMessage('Период заблокирован!');
    except
      ShowMessage('Этот период уже был закрыт ранее.');
    end;
  end;
end;

procedure TframePayroll.btnExportClick(Sender: TObject);
var
  ExcelApp, Sheet: Variant;
  Row: Integer;
  TotalGross, TotalTax, TotalPension, TotalNet: Double;
  Bookmark: TBookmark;
begin
  if not Assigned(qryPayroll) or not qryPayroll.Active or qryPayroll.IsEmpty then
  begin
    ShowMessage('Нет данных для выгрузки!');
    Exit;
  end;

  // Пытаемся запустить Excel
  try
    ExcelApp := CreateOleObject('Excel.Application');
  except
    ShowMessage('Не удалось запустить Excel. Убедитесь, что он установлен на компьютере.');
    Exit;
  end;

  // Замораживаем интерфейс, чтобы таблица не прыгала во время экспорта
  qryPayroll.DisableControls;
  // Запоминаем текущую строчку, где стоял курсор
  Bookmark := qryPayroll.GetBookmark;
  try
    // Создаем новую книгу и лист
    ExcelApp.Workbooks.Add;
    Sheet := ExcelApp.ActiveSheet;
    Sheet.Name := 'Зарплата за ' + cmbMonth.Text;

    // --- ПЕЧАТАЕМ ЗАГОЛОВКИ ---
    Sheet.Cells[1, 1].Value := 'Сотрудник';
    Sheet.Cells[1, 2].Value := 'Отдел';
    Sheet.Cells[1, 3].Value := 'Должность';
    Sheet.Cells[1, 4].Value := 'Оклад';
    Sheet.Cells[1, 5].Value := 'Начислено';
    Sheet.Cells[1, 6].Value := 'Подоходный';
    Sheet.Cells[1, 7].Value := 'Пенсионный';
    Sheet.Cells[1, 8].Value := 'На руки';

    // Делаем заголовки жирными
    Sheet.Range['A1:H1'].Font.Bold := True;

    Row := 2; // Данные начинаются со 2-й строки
    TotalGross := 0; TotalTax := 0; TotalPension := 0; TotalNet := 0;

    // --- ПЕРЕБИРАЕМ ДАННЫЕ ИЗ БАЗЫ ---
    qryPayroll.First;
    while not qryPayroll.Eof do
    begin
      Sheet.Cells[Row, 1].Value := qryPayroll.FieldByName('fio').AsString;
      Sheet.Cells[Row, 2].Value := qryPayroll.FieldByName('dept_name').AsString;
      Sheet.Cells[Row, 3].Value := qryPayroll.FieldByName('pos_name').AsString;

      Sheet.Cells[Row, 4].Value := qryPayroll.FieldByName('base_salary').AsFloat;
      Sheet.Cells[Row, 5].Value := qryPayroll.FieldByName('gross_amount').AsFloat;
      Sheet.Cells[Row, 6].Value := qryPayroll.FieldByName('tax_amount').AsFloat;
      Sheet.Cells[Row, 7].Value := qryPayroll.FieldByName('pension_amount').AsFloat;
      Sheet.Cells[Row, 8].Value := qryPayroll.FieldByName('net_amount').AsFloat;

      // Накапливаем итоги
      TotalGross := TotalGross + qryPayroll.FieldByName('gross_amount').AsFloat;
      TotalTax := TotalTax + qryPayroll.FieldByName('tax_amount').AsFloat;
      TotalPension := TotalPension + qryPayroll.FieldByName('pension_amount').AsFloat;
      TotalNet := TotalNet + qryPayroll.FieldByName('net_amount').AsFloat;

      Inc(Row);
      qryPayroll.Next;
    end;

    // --- ПОДБИВАЕМ ИТОГИ В КОНЦЕ ---
    Sheet.Cells[Row, 1].Value := 'ИТОГО ПО ВЕДОМОСТИ:';
    Sheet.Cells[Row, 5].Value := TotalGross;
    Sheet.Cells[Row, 6].Value := TotalTax;
    Sheet.Cells[Row, 7].Value := TotalPension;
    Sheet.Cells[Row, 8].Value := TotalNet;

    // Красиво форматируем строку итогов (Жирный шрифт, красный цвет для налогов)
    Sheet.Range['A' + IntToStr(Row) + ':H' + IntToStr(Row)].Font.Bold := True;
    Sheet.Cells[Row, 6].Font.Color := $0000FF; // Красный в Excel (BGR формат)
    Sheet.Cells[Row, 7].Font.Color := $0000FF;

    // Делаем автоширину всех колонок, чтобы текст не обрезался
    Sheet.Columns.AutoFit;

  finally
    // Возвращаем курсор на место и включаем интерфейс
    if qryPayroll.BookmarkValid(Bookmark) then
    begin
      qryPayroll.GotoBookmark(Bookmark);
      qryPayroll.FreeBookmark(Bookmark);
    end;
    qryPayroll.EnableControls;
  end;

  // --- ЭФФЕКТНО ПОКАЗЫВАЕМ EXCEL ПОЛЬЗОВАТЕЛЮ ---
  ExcelApp.Visible := True;
end;

procedure TframePayroll.qryPayrollAfterOpen(DataSet: TDataSet);
begin
  if DBGrid1.Columns.Count > 0 then
  begin
    DBGrid1.Columns[0].Visible := False; // id
    DBGrid1.Columns[1].Visible := False; // emp_id
    DBGrid1.Columns[2].Title.Caption := 'Дата';
    DBGrid1.Columns[3].Title.Caption := 'Начислено';
    DBGrid1.Columns[3].Width := 150;
    DBGrid1.Columns[4].Title.Caption := 'Налог';
    DBGrid1.Columns[4].Width := 150;
    DBGrid1.Columns[5].Title.Caption := 'Пенс. фонд';
    DBGrid1.Columns[6].Title.Caption := 'На руки';
    DBGrid1.Columns[7].Title.Caption := 'Сотрудник';
    DBGrid1.Columns[7].Width := 220;
    DBGrid1.Columns[7].Index := 0;
    DBGrid1.Columns[8].Title.Caption := 'Оклад';
    DBGrid1.Columns[8].Width := 180;
    DBGrid1.Columns[8].Index := 1;
  end;
  // Красивое форматирование денег (с пробелами тысячных и TMT)
  if DataSet.FindField('gross_amount') <> nil then
    TFloatField(DataSet.FieldByName('gross_amount')).DisplayFormat := '#,##0.00 TMT';

  if DataSet.FindField('tax_amount') <> nil then
    TFloatField(DataSet.FieldByName('tax_amount')).DisplayFormat := '#,##0.00 TMT';

  if DataSet.FindField('pension_amount') <> nil then
    TFloatField(DataSet.FieldByName('pension_amount')).DisplayFormat := '#,##0.00 TMT';

  if DataSet.FindField('net_amount') <> nil then
    TFloatField(DataSet.FieldByName('net_amount')).DisplayFormat := '#,##0.00 TMT';

  if DataSet.FindField('base_salary') <> nil then
    TFloatField(DataSet.FieldByName('base_salary')).DisplayFormat := '#,##0.00 TMT';
end;

procedure TframePayroll.DBGrid1DblClick(Sender: TObject);
var
  SlipForm: TfrmPaySlip;
  Period: string;
begin
  if qryPayroll.IsEmpty then Exit;

  // Формируем красивую строку периода (например "Март 2026")
  Period := cmbMonth.Text + ' ' + cmbYear.Text;

  SlipForm := TfrmPaySlip.Create(Self);
  try
    // Передаем текущую строку запроса и период в форму листка
    SlipForm.LoadFromDataset(qryPayroll, Period);

    // Показываем окно
    SlipForm.ShowModal;
  finally
    SlipForm.Free;
  end;
end;

destructor TframePayroll.Destroy;
begin
  if Assigned(qryPayroll) then qryPayroll.Free;
  if Assigned(dsPayroll) then dsPayroll.Free;
  inherited;
end;

end.

unit UnitSickLeaveCalc;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls,
  System.DateUtils,
  Vcl.StdCtrls;

type
  TFormSickLeaveCalc = class(TForm)
    ComboBox1: TComboBox;
    dtpStart: TDateTimePicker;
    dtpEnd: TDateTimePicker;
    Button1: TButton;
    btnSave: TButton;
    edtPercent: TEdit;
    lbResult: TLabel;
    procedure Button1Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btnSaveClick(Sender: TObject);
  private
    { Private declarations }
    // --- НАШИ ПЕРЕМЕННЫЕ ДЛЯ РАСЧЕТА ---
    FSelectedEmpID: Integer;
    FDaysCount: Integer;
    FTotalYears: Integer;
    FPercent: Double;
    FAvgMonthly: Double;
    FAvgDaily: Double;
    FTotalAmount: Double;
    FIsCalculated: Boolean; // Тот самый флаг!
  public
    { Public declarations }
    FEditMode: Boolean; // Флаг режима редактирования
    FDocID: Integer;    // ID документа, который редактируем
    procedure DoCalculate;
  end;

var
  FormSickLeaveCalc: TFormSickLeaveCalc;

implementation

{$R *.dfm}

uses UnitdmMain, FireDAC.Comp.Client, Data.DB, System.Math;

procedure TFormSickLeaveCalc.btnSaveClick(Sender: TObject);
begin
  // Если кадровик нажал сразу "Сохранить", не нажав "Рассчитать" - считаем за него
  if not FIsCalculated then
    DoCalculate;

  // Если после расчета всё равно ошибка (например, отказался считать из оклада)
  if not FIsCalculated then Exit;

try
    if FEditMode then
    begin
      // РЕЖИМ ОБНОВЛЕНИЯ
      dmMain.conn.ExecSQL(
        'UPDATE sick_leave_journal SET calc_date = :calc, start_date = :st, end_date = :en, ' +
        'days_count = :d, avg_daily_salary = :avg_d, payment_percent = :perc, total_amount = :tot ' +
        'WHERE id = :id',
        [
          FormatDateTime('yyyy-mm-dd', Date),
          FormatDateTime('yyyy-mm-dd', dtpStart.Date),
          FormatDateTime('yyyy-mm-dd', dtpEnd.Date),
          FDaysCount, FAvgDaily, FPercent, FTotalAmount,
          FDocID // Передаем ID редактируемого документа
        ]
      );
    end
    else
    begin
      // РЕЖИМ СОЗДАНИЯ (Ваш старый код INSERT INTO...)
      dmMain.conn.ExecSQL(
        'INSERT INTO sick_leave_journal (emp_id, calc_date, start_date, end_date, ' +
        'days_count, avg_daily_salary, experience_years, payment_percent, total_amount) ' +
        'VALUES (:emp_id, :calc_date, :start_date, :end_date, :days, :avg_d, :exp_y, :percent, :total)',
        [ FSelectedEmpID, FormatDateTime('yyyy-mm-dd', Date), FormatDateTime('yyyy-mm-dd', dtpStart.Date), FormatDateTime('yyyy-mm-dd', dtpEnd.Date), FDaysCount, FAvgDaily, 0, FPercent, FTotalAmount ]
      );
    end;

    ModalResult := mrOk;
  except
    on E: Exception do
      ShowMessage('Ошибка при сохранении: ' + E.Message);
  end;
end;

procedure TFormSickLeaveCalc.Button1Click(Sender: TObject);
begin
  DoCalculate;
end;



procedure TFormSickLeaveCalc.DoCalculate;
begin
  if ComboBox1.ItemIndex = -1 then
  begin
    ShowMessage('Выберите сотрудника!');
    Exit;
  end;

  FSelectedEmpID := Integer(ComboBox1.Items.Objects[ComboBox1.ItemIndex]);

  if dtpEnd.Date < dtpStart.Date then
  begin
    ShowMessage('Ошибка: Дата окончания не может быть раньше!');
    Exit;
  end;

  // 1. Берем готовый процент прямо из справочника сотрудников
  if dmMain.qryEmployees.Locate('id', FSelectedEmpID, []) then
    FPercent := dmMain.qryEmployees.FieldByName('sick_leave_percent').AsFloat
  else
    FPercent := 60; // На всякий случай

  edtPercent.Text := FloatToStr(FPercent); // Показываем на экране

  // 2. Считаем дни
  FDaysCount := DaysBetween(dtpEnd.Date, dtpStart.Date) + 1;

  // 3. Берем средний заработок за 12 месяцев
  FAvgMonthly := dmMain.GetAverageYearlySalary(FSelectedEmpID, dtpStart.Date);

  // --- ЗАЩИТА ОТ ПУСТОЙ ИСТОРИИ ---
  if FAvgMonthly <= 0 then
  begin
    if MessageDlg('У сотрудника пустая история начислений!' + sLineBreak +
                  'Рассчитать больничный исходя из текущего оклада?',
                  mtWarning, [mbYes, mbNo], 0) = mrYes then
    begin
      FAvgMonthly := dmMain.qryEmployees.FieldByName('base_salary').AsFloat;
    end
    else
    begin
      FIsCalculated := False;
      Exit;
    end;
  end;

  // 4. Финансовая математика
  FAvgMonthly := SimpleRoundTo(FAvgMonthly, -2);
  if FAvgMonthly > 0 then
    FAvgDaily := SimpleRoundTo(FAvgMonthly / 29.7, -2)
  else
    FAvgDaily := 0;

  // Главная формула: Дни * Среднедневной * (Процент / 100)
  FTotalAmount := SimpleRoundTo(FAvgDaily * FDaysCount * (FPercent / 100.0), -2);

  FTotalYears := 0; // Обнуляем стаж, так как мы его больше не считаем
  FIsCalculated := True;

  // 5. Выводим результат
  if Assigned(lbResult) then
  begin
    lbResult.Caption :=
      'Дней болезни: ' + IntToStr(FDaysCount) + sLineBreak +
      'Процент оплаты: ' + FloatToStr(FPercent) + '%' + sLineBreak +
      'Среднедневной: ' + FormatFloat('#,##0.00', FAvgDaily) + ' TMT' + sLineBreak +
      sLineBreak +
      'ИТОГО К ВЫПЛАТЕ: ' + FormatFloat('#,##0.00', FTotalAmount) + ' TMT';
  end;
end;

procedure TFormSickLeaveCalc.FormShow(Sender: TObject);
begin
  ComboBox1.Items.Clear;

  // Защита от ошибок, если модуль данных еще не создан
  if not Assigned(dmMain) then Exit;
  // Открываем таблицу сотрудников, если она вдруг закрыта
  if not dmMain.qryEmployees.Active then
    dmMain.qryEmployees.Open;
  // Пробегаемся по всем сотрудникам и добавляем в список
  dmMain.qryEmployees.First;
  while not dmMain.qryEmployees.Eof do
  begin
    // Добавляем ФИО и скрыто привязываем к нему ID
    ComboBox1.Items.AddObject(
      dmMain.qryEmployees.FieldByName('fio').AsString,
      TObject(dmMain.qryEmployees.FieldByName('id').AsInteger)
    );
    dmMain.qryEmployees.Next;
  end;
  // Автоматически выбираем первого человека в списке, чтобы поле не было пустым
  if ComboBox1.Items.Count > 0 then
    ComboBox1.ItemIndex := 0;

  // --- МАГИЯ РЕДАКТИРОВАНИЯ ---
  if FEditMode then
  begin
    Self.Caption := 'Редактирование больничного';
    btnSave.Caption := 'Обновить';

    // Загружаем даты из базы
    dtpStart.Date := dmMain.qrySickLeave.FieldByName('start_date').AsDateTime;
    dtpEnd.Date := dmMain.qrySickLeave.FieldByName('end_date').AsDateTime;

    // Выбираем нужного сотрудника в комбобоксе
    for var i := 0 to ComboBox1.Items.Count - 1 do
      if Integer(ComboBox1.Items.Objects[i]) = dmMain.qrySickLeave.FieldByName('emp_id').AsInteger then
      begin
        ComboBox1.ItemIndex := i;
        Break;
      end;

    // Блокируем смену сотрудника (обычно при ошибке меняют только даты)
    ComboBox1.Enabled := False;

    // Автоматически нажимаем кнопку "Рассчитать", чтобы подтянуть суммы
    DoCalculate;
  end
  else
  begin
    Self.Caption := 'Новый расчет больничного';
    btnSave.Caption := 'Сохранить';
    ComboBox1.Enabled := True;
  end;
end;

end.

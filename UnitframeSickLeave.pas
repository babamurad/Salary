unit UnitframeSickLeave;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Data.DB,
  Vcl.Grids, Vcl.DBGrids, Vcl.StdCtrls, FireDAC.Comp.Client;

type
  TframeSickLeave = class(TFrame)
    Panel1: TPanel;
    btnNewCalc: TButton;
    DBGrid1: TDBGrid;
    btnDelete: TButton;
    btnPrint: TButton;
    cmbMonthFilter: TComboBox;
    Label1: TLabel;
    btnEdit: TButton;
    procedure btnNewCalcClick(Sender: TObject);
    procedure btnDeleteClick(Sender: TObject);
    procedure btnPrintClick(Sender: TObject);
    procedure cmbMonthFilterChange(Sender: TObject);
    procedure btnEditClick(Sender: TObject);
  private
    procedure SetupGrid;
    procedure LoadMonths; // Загрузка месяцев для фильтра
    procedure RefreshData; // Умное обновление данных с учетом фильтра
  public
    constructor Create(AOwner: TComponent); override;
  end;

implementation

{$R *.dfm}

uses UnitdmMain, UnitSickLeaveCalc, UnitHtmlPreview;

constructor TframeSickLeave.Create(AOwner: TComponent);
begin
  inherited;
  if Assigned(dmMain) then
  begin
    LoadMonths; // Сначала загружаем список месяцев
    RefreshData; // Затем открываем данные

    DBGrid1.DataSource := dmMain.dsSickLeave;
    SetupGrid;
  end;
end;

// --- 1. УМНАЯ ЗАГРУЗКА МЕСЯЦЕВ ДЛЯ ФИЛЬТРА ---
procedure TframeSickLeave.LoadMonths;
var
  Qry: TFDQuery;
begin
  cmbMonthFilter.Items.Clear;
  cmbMonthFilter.Items.AddObject('Все месяцы', nil);

  Qry := TFDQuery.Create(nil);
  try
    Qry.Connection := dmMain.conn;
    // Вытягиваем уникальные месяцы в формате "YYYY-MM" и для отображения "MM.YYYY"
    Qry.SQL.Text := 'SELECT DISTINCT strftime(''%Y-%m'', calc_date) AS ym, ' +
                    'strftime(''%m.%Y'', calc_date) AS m_disp ' +
                    'FROM sick_leave_journal ORDER BY ym DESC';
    Qry.Open;

    while not Qry.Eof do
    begin
      cmbMonthFilter.Items.AddObject(
        Qry.FieldByName('m_disp').AsString,
        TStringList.Create // Используем TStringList как контейнер для скрытого хранения YYYY-MM
      );
      TStringList(cmbMonthFilter.Items.Objects[cmbMonthFilter.Items.Count - 1]).Text := Qry.FieldByName('ym').AsString;
      Qry.Next;
    end;
  finally
    Qry.Free;
  end;

  if cmbMonthFilter.Items.Count > 0 then
    cmbMonthFilter.ItemIndex := 0; // По умолчанию выбираем "Все месяцы"
end;

// --- 2. ПРИМЕНЕНИЕ ФИЛЬТРА И ОБНОВЛЕНИЕ ДАННЫХ ---
procedure TframeSickLeave.RefreshData;
var
  BaseSQL, FilterYM: string;
begin
  // Базовый SQL запрос (тот же, что вы делали в qrySickLeave)
  BaseSQL := 'SELECT s.*, CAST(e.fio AS VARCHAR(150)) AS fio ' +
             'FROM sick_leave_journal s JOIN employees e ON s.emp_id = e.id ';

  dmMain.qrySickLeave.Close;
  dmMain.qrySickLeave.SQL.Clear;

  if cmbMonthFilter.ItemIndex <= 0 then
  begin
    // Если "Все месяцы"
    dmMain.qrySickLeave.SQL.Text := BaseSQL + ' ORDER BY s.calc_date DESC';
  end
  else
  begin
    // Если выбран конкретный месяц, достаем его YYYY-MM из скрытого объекта
    FilterYM := Trim(TStringList(cmbMonthFilter.Items.Objects[cmbMonthFilter.ItemIndex]).Text);

    dmMain.qrySickLeave.SQL.Text := BaseSQL + ' WHERE strftime(''%Y-%m'', s.calc_date) = :ym ORDER BY s.calc_date DESC';
    dmMain.qrySickLeave.ParamByName('ym').AsString := FilterYM;
  end;

  dmMain.qrySickLeave.Open;
end;

procedure TframeSickLeave.cmbMonthFilterChange(Sender: TObject);
begin
  RefreshData;
end;

// --- 3. НАСТРОЙКА ГРИДА ---
procedure TframeSickLeave.SetupGrid;
begin
  if dmMain.qrySickLeave.FieldCount > 0 then
  begin
    DBGrid1.Columns.Clear;
    with DBGrid1.Columns.Add do begin FieldName := 'calc_date'; Title.Caption := 'Дата расчета'; Width := 100; end;
    with DBGrid1.Columns.Add do begin FieldName := 'fio'; Title.Caption := 'Сотрудник'; Width := 230; end;
    with DBGrid1.Columns.Add do begin FieldName := 'start_date'; Title.Caption := 'С'; Width := 100; end;
    with DBGrid1.Columns.Add do begin FieldName := 'end_date'; Title.Caption := 'По'; Width := 100; end;
    with DBGrid1.Columns.Add do begin FieldName := 'days_count'; Title.Caption := 'Дни'; Width := 40; end;
    with DBGrid1.Columns.Add do begin FieldName := 'payment_percent'; Title.Caption := '% оплаты'; Width := 65; end;
    with DBGrid1.Columns.Add do begin FieldName := 'total_amount'; Title.Caption := 'Начислено (TMT)'; Width := 120; end;

    if dmMain.qrySickLeave.FindField('calc_date') <> nil then
      (dmMain.qrySickLeave.FieldByName('calc_date') as TDateTimeField).DisplayFormat := 'dd.mm.yyyy';
    if dmMain.qrySickLeave.FindField('start_date') <> nil then
      (dmMain.qrySickLeave.FieldByName('start_date') as TDateTimeField).DisplayFormat := 'dd.mm.yyyy';
    if dmMain.qrySickLeave.FindField('end_date') <> nil then
      (dmMain.qrySickLeave.FieldByName('end_date') as TDateTimeField).DisplayFormat := 'dd.mm.yyyy';

    if dmMain.qrySickLeave.FindField('payment_percent') <> nil then
      (dmMain.qrySickLeave.FieldByName('payment_percent') as TNumericField).DisplayFormat := '0"%";-0"%"';
    if dmMain.qrySickLeave.FindField('total_amount') <> nil then
      (dmMain.qrySickLeave.FieldByName('total_amount') as TNumericField).DisplayFormat := '#,##0.00';
  end;
end;

// --- 4. ДОБАВЛЕНИЕ НОВОГО РАСЧЕТА ---
procedure TframeSickLeave.btnEditClick(Sender: TObject);
var
  Frm: TFormSickLeaveCalc;
begin
  if dmMain.qrySickLeave.IsEmpty then Exit;

  Frm := TFormSickLeaveCalc.Create(Self);
  try
    // Говорим форме, что мы хотим редактировать!
    Frm.FEditMode := True;
    Frm.FDocID := dmMain.qrySickLeave.FieldByName('id').AsInteger;

    if Frm.ShowModal = mrOk then
      RefreshData; // Обновляем таблицу
  finally
    Frm.Free;
  end;
end;

procedure TframeSickLeave.btnNewCalcClick(Sender: TObject);
var
  Frm: TFormSickLeaveCalc;
begin
  Frm := TFormSickLeaveCalc.Create(Self);
  try
    if Frm.ShowModal = mrOk then
    begin
      LoadMonths; // На случай, если появился новый месяц
      RefreshData;
    end;
  finally
    Frm.Free;
  end;
end;

// --- 5. БЕЗОПАСНОЕ УДАЛЕНИЕ ---
procedure TframeSickLeave.btnDeleteClick(Sender: TObject);
var
  DocID: Integer;
  EmpName: string;
begin
  if dmMain.qrySickLeave.IsEmpty then Exit;

  DocID := dmMain.qrySickLeave.FieldByName('id').AsInteger;
  EmpName := dmMain.qrySickLeave.FieldByName('fio').AsString;

  if MessageDlg('Удалить больничный лист сотрудника: ' + EmpName + '?',
                mtConfirmation, [mbYes, mbNo], 0) = mrYes then
  begin
    dmMain.conn.ExecSQL('DELETE FROM sick_leave_journal WHERE id = :id', [DocID]);
    RefreshData; // Обновляем грид после удаления
  end;
end;

// --- 6. ПЕЧАТЬ ПРИКАЗА (Используем ваш модуль предпросмотра) ---
procedure TframeSickLeave.btnPrintClick(Sender: TObject);
var
  HTML: TStringList;
  CompanyName, DirectorName: string;
  PreviewForm: TfrmHtmlPreview;
begin
  if dmMain.qrySickLeave.IsEmpty then
  begin
    ShowMessage('Выберите документ для печати!');
    Exit;
  end;

  // Тянем настройки из базы
  CompanyName := 'Название не указано';
  DirectorName := 'Директор не указан';

  if Assigned(dmMain.qryCompanyInfo) then
  begin
    if not dmMain.qryCompanyInfo.Active then dmMain.qryCompanyInfo.Open;

    if dmMain.qryCompanyInfo.Locate('key_name', 'company_name', []) then
      CompanyName := dmMain.qryCompanyInfo.FieldByName('key_value').AsString;

    if dmMain.qryCompanyInfo.Locate('key_name', 'director_fio', []) then
      DirectorName := dmMain.qryCompanyInfo.FieldByName('key_value').AsString;
  end;

  // Формируем HTML
  HTML := TStringList.Create;
  try
    HTML.Add('<!DOCTYPE html>');
    HTML.Add('<html><head><meta charset="utf-8"><title>Приказ на больничный</title>');
    HTML.Add('<style>');
    // Белый фон для защиты от темной темы!
    HTML.Add('body { background-color: white; color: black; font-family: "Times New Roman", Times, serif; font-size: 14pt; padding: 40px; line-height: 1.5; max-width: 800px; margin: 0 auto; }');
    HTML.Add('.header { text-align: center; font-weight: bold; border-bottom: 2px solid black; padding-bottom: 10px; margin-bottom: 20px; }');
    HTML.Add('.title { text-align: center; font-weight: bold; font-size: 16pt; margin: 30px 0; }');
    HTML.Add('.content { text-align: justify; }');
    HTML.Add('.emp-name { font-size: 16pt; font-weight: bold; text-align: center; margin: 20px 0; }');
    HTML.Add('.sign-block { margin-top: 50px; display: table; width: 100%; }');
    HTML.Add('.sign-row { display: table-row; }');
    HTML.Add('.sign-cell { display: table-cell; padding-top: 20px; }');
    HTML.Add('.line { border-bottom: 1px solid black; display: inline-block; width: 250px; margin: 0 10px; }');
    HTML.Add('@media print { body { padding: 0; } }');
    HTML.Add('</style></head><body>');

    HTML.Add('<div class="header">' + CompanyName + '</div>');

    HTML.Add('<div class="title">ПРИКАЗ № ' + dmMain.qrySickLeave.FieldByName('id').AsString + '<br>');
    HTML.Add('от &laquo;' + FormatDateTime('dd', dmMain.qrySickLeave.FieldByName('calc_date').AsDateTime) + '&raquo; ' +
             FormatDateTime('mm.yyyy', dmMain.qrySickLeave.FieldByName('calc_date').AsDateTime) + ' г.<br>');
    HTML.Add('<span style="font-weight: normal; font-size: 14pt;">о назначении пособия по временной нетрудоспособности</span></div>');

    HTML.Add('<div class="content">');
    HTML.Add('Назначить выплату пособия по временной нетрудоспособности сотруднику:');
    HTML.Add('<div class="emp-name">' + dmMain.qrySickLeave.FieldByName('fio').AsString + '</div>');

    HTML.Add('<p>Период нетрудоспособности: с <b>' + FormatDateTime('dd.mm.yyyy', dmMain.qrySickLeave.FieldByName('start_date').AsDateTime) + '</b> ' +
             'по <b>' + FormatDateTime('dd.mm.yyyy', dmMain.qrySickLeave.FieldByName('end_date').AsDateTime) + '</b> ' +
             '(Всего: <b>' + dmMain.qrySickLeave.FieldByName('days_count').AsString + '</b> календарных дней).</p>');

    HTML.Add('<p>Размер оплаты: <b>' + dmMain.qrySickLeave.FieldByName('payment_percent').AsString + '%</b> от среднего заработка.</p>');

    HTML.Add('<p>Сумма пособия (до удержания налогов): <b>' +
             FormatFloat('#,##0.00', dmMain.qrySickLeave.FieldByName('total_amount').AsFloat) + ' TMT</b>.</p>');
    HTML.Add('</div>');

    // Подписи
    HTML.Add('<div class="sign-block">');
    HTML.Add('<div class="sign-row">');
    HTML.Add('<div class="sign-cell">Руководитель организации</div>');
    HTML.Add('<div class="sign-cell"><span class="line"></span> / ' + DirectorName + ' /</div>');
    HTML.Add('</div>');

    HTML.Add('<div class="sign-row">');
    HTML.Add('<div class="sign-cell">С приказом ознакомлен</div>');
    HTML.Add('<div class="sign-cell"><span class="line"></span> / ' + dmMain.qrySickLeave.FieldByName('fio').AsString + ' /</div>');
    HTML.Add('</div>');
    HTML.Add('</div>');

    HTML.Add('</body></html>');

    // Открываем во встроенном окне предпросмотра!
    PreviewForm := TfrmHtmlPreview.Create(Self);
    try
      PreviewForm.ShowDocument('Приказ по больничному №' + dmMain.qrySickLeave.FieldByName('id').AsString, HTML.Text);
    finally
      PreviewForm.Free;
    end;

  finally
    HTML.Free;
  end;
end;

end.


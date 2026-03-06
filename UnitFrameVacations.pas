unit UnitFrameVacations;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  System.DateUtils,System.IOUtils, Winapi.ShellAPI,
  Vcl.Grids, Vcl.DBGrids, Data.DB, System.UITypes;

type
  TframeVacations = class(TFrame)
    PanelTop: TPanel;
    btnAdd: TButton;
    btnDelete: TButton;
    btnRefresh: TButton;
    DBGridVacations: TDBGrid;
    btnPrint: TButton;
    procedure btnAddClick(Sender: TObject);
    procedure btnDeleteClick(Sender: TObject);
    procedure btnRefreshClick(Sender: TObject);
    procedure btnPrintClick(Sender: TObject);
  private
    procedure SetupGrid;
  public
    constructor Create(AOwner: TComponent); override;
  end;

implementation

{$R *.dfm}

uses UnitdmMain, UnitVacationCalc, UnitHtmlPreview; // Подключаем базу и форму расчета отпускных

constructor TframeVacations.Create(AOwner: TComponent);
begin
  inherited;
  if Assigned(dmMain) then
  begin
    // Открываем запрос, если он закрыт
    if not dmMain.qryVacation.Active then
      dmMain.qryVacation.Open;

    DBGridVacations.DataSource := dmMain.dsVacation;
    SetupGrid;
  end;
end;

procedure TframeVacations.SetupGrid;
begin
  if dmMain.qryVacation.FieldCount > 0 then
  begin
    DBGridVacations.Columns.Clear;

    // Настраиваем колонки
    with DBGridVacations.Columns.Add do begin FieldName := 'calc_date'; Title.Caption := 'Дата расчета'; Width := 100; end;
    with DBGridVacations.Columns.Add do begin FieldName := 'fio'; Title.Caption := 'Сотрудник'; Width := 250; end;
    with DBGridVacations.Columns.Add do begin FieldName := 'start_date'; Title.Caption := 'С'; Width := 90; end;
    with DBGridVacations.Columns.Add do begin FieldName := 'end_date'; Title.Caption := 'По'; Width := 90; end;
    with DBGridVacations.Columns.Add do begin FieldName := 'days_count'; Title.Caption := 'Дни'; Width := 50; end;
    with DBGridVacations.Columns.Add do begin FieldName := 'total_amount'; Title.Caption := 'Начислено (TMT)'; Width := 120; end;

    // Красивые форматы для дат
    if dmMain.qryVacation.FindField('calc_date') <> nil then
      (dmMain.qryVacation.FieldByName('calc_date') as TDateTimeField).DisplayFormat := 'dd.mm.yyyy';
    if dmMain.qryVacation.FindField('start_date') <> nil then
      (dmMain.qryVacation.FieldByName('start_date') as TDateTimeField).DisplayFormat := 'dd.mm.yyyy';
    if dmMain.qryVacation.FindField('end_date') <> nil then
      (dmMain.qryVacation.FieldByName('end_date') as TDateTimeField).DisplayFormat := 'dd.mm.yyyy';

    // Формат денег
    if dmMain.qryVacation.FindField('total_amount') <> nil then
      (dmMain.qryVacation.FieldByName('total_amount') as TNumericField).DisplayFormat := '#,##0.00';
  end;
end;

// --- ВЫЗОВ ФОРМЫ РАСЧЕТА ---
procedure TframeVacations.btnAddClick(Sender: TObject);
var
  Frm: TFormVacationCalc;
begin
  Frm := TFormVacationCalc.Create(Self);
  try
    // Открываем наше красивое окно как модальное (поверх остальных)
    Frm.ShowModal;

    // Перезагружать qryVacation здесь не обязательно,
    // так как мы добавили Refresh прямо в кнопку "Сохранить" внутри FormVacationCalc!
  finally
    Frm.Free;
  end;
end;

// --- БЕЗОПАСНОЕ УДАЛЕНИЕ ---
procedure TframeVacations.btnDeleteClick(Sender: TObject);
var
  DocID: Integer;
  EmpName: string;
begin
  if dmMain.qryVacation.IsEmpty then Exit;

  DocID := dmMain.qryVacation.FieldByName('id').AsInteger;
  EmpName := dmMain.qryVacation.FieldByName('fio').AsString;

  if MessageDlg('Удалить расчет отпускных для сотрудника: ' + EmpName + '?',
                mtConfirmation, [mbYes, mbNo], 0) = mrYes then
  begin
    // Безопасное удаление через SQL (т.к. запрос с JOIN часто не дает делать .Delete)
    dmMain.conn.ExecSQL('DELETE FROM vacation_journal WHERE id = :id', [DocID]);
    dmMain.qryVacation.Refresh;
  end;
end;

procedure TframeVacations.btnPrintClick(Sender: TObject);
var
  HTML: TStringList;
  CompanyName, DirectorName: string;
  PreviewForm: TfrmHtmlPreview;
begin
  if dmMain.qryVacation.IsEmpty then
  begin
    ShowMessage('Выберите документ для печати!');
    Exit;
  end;

  // 1. БЕРЕМ РЕКВИЗИТЫ ИЗ ТАБЛИЦЫ COMPANY_INFO (Ключ-Значение)
  CompanyName := 'Название не указано'; // Заглушки на случай, если таблица пустая
  DirectorName := 'Директор не указан';

  if Assigned(dmMain.qryCompanyInfo) then
  begin
    if not dmMain.qryCompanyInfo.Active then
      dmMain.qryCompanyInfo.Open;

    // Ищем строку, где key_name = 'company_name', и берем её key_value
    // ВНИМАНИЕ: Если ваши ключи называются иначе (например, 'org_name'), поменяйте текст ниже!
    if dmMain.qryCompanyInfo.Locate('key_name', 'company_name', []) then
      CompanyName := dmMain.qryCompanyInfo.FieldByName('key_value').AsString;

    // Ищем строку директора
    if dmMain.qryCompanyInfo.Locate('key_name', 'director_fio', []) then
      DirectorName := dmMain.qryCompanyInfo.FieldByName('key_value').AsString;
  end;

  // 2. ФОРМИРУЕМ HTML ДОКУМЕНТ
  HTML := TStringList.Create;
  try
    HTML.Add('<!DOCTYPE html>');
    HTML.Add('<html><head><meta charset="utf-8"><title>Приказ на отпуск</title>');
    HTML.Add('<style>');
    HTML.Add('body { font-family: "Times New Roman", Times, serif; font-size: 14pt; padding: 40px; line-height: 1.5; max-width: 800px; margin: 0 auto; }');HTML.Add('body { background-color: white; color: black; font-family: "Times New Roman", Times, serif; font-size: 14pt; padding: 40px; line-height: 1.5; max-width: 800px; margin: 0 auto; }');
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

    HTML.Add('<div class="title">ПРИКАЗ № ' + dmMain.qryVacation.FieldByName('id').AsString + '<br>');
    HTML.Add('от &laquo;' + FormatDateTime('dd', dmMain.qryVacation.FieldByName('calc_date').AsDateTime) + '&raquo; ' +
             FormatDateTime('mm.yyyy', dmMain.qryVacation.FieldByName('calc_date').AsDateTime) + ' г.<br>');
    HTML.Add('<span style="font-weight: normal; font-size: 14pt;">о предоставлении отпуска работнику</span></div>');

    HTML.Add('<div class="content">');
    HTML.Add('Предоставить ежегодный основной оплачиваемый отпуск сотруднику:');
    HTML.Add('<div class="emp-name">' + dmMain.qryVacation.FieldByName('fio').AsString + '</div>');

    HTML.Add('<p>Продолжительность отпуска: <b>' + dmMain.qryVacation.FieldByName('days_count').AsString + '</b> календарных дней.</p>');
    HTML.Add('<p>Период отпуска: с <b>' + FormatDateTime('dd.mm.yyyy', dmMain.qryVacation.FieldByName('start_date').AsDateTime) + '</b> ' +
             'по <b>' + FormatDateTime('dd.mm.yyyy', dmMain.qryVacation.FieldByName('end_date').AsDateTime) + '</b>.</p>');

    HTML.Add('<p>Сумма начисленных отпускных (до удержания налогов): <b>' +
             FormatFloat('#,##0.00', dmMain.qryVacation.FieldByName('total_amount').AsFloat) + ' TMT</b>.</p>');
    HTML.Add('</div>');

    HTML.Add('<div class="sign-block">');
    HTML.Add('<div class="sign-row">');
    HTML.Add('<div class="sign-cell">Руководитель организации</div>');
    HTML.Add('<div class="sign-cell"><span class="line"></span> / ' + DirectorName + ' /</div>');
    HTML.Add('</div>');

    HTML.Add('<div class="sign-row">');
    HTML.Add('<div class="sign-cell">С приказом ознакомлен</div>');
    HTML.Add('<div class="sign-cell"><span class="line"></span> / ' + dmMain.qryVacation.FieldByName('fio').AsString + ' /</div>');
    HTML.Add('</div>');
    HTML.Add('</div>');

    HTML.Add('</body></html>');

    // --- МАГИЯ ВНУТРЕННЕГО ПРЕДПРОСМОТРА ---
    PreviewForm := TfrmHtmlPreview.Create(Self);
    try
      // Отправляем сгенерированный текст в нашу новую форму
      PreviewForm.ShowDocument('Приказ на отпуск №' + dmMain.qryVacation.FieldByName('id').AsString, HTML.Text);
    finally
      PreviewForm.Free;
    end;

  finally
    HTML.Free;
  end;
end;

procedure TframeVacations.btnRefreshClick(Sender: TObject);
begin
  if dmMain.qryVacation.Active then
    dmMain.qryVacation.Refresh
  else
    dmMain.qryVacation.Open;
end;

end.

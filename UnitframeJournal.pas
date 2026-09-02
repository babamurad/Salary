unit UnitframeJournal;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Data.DB, Vcl.Grids,
  Vcl.DBGrids, Vcl.ExtCtrls, Vcl.DBCtrls, Vcl.StdCtrls,
  FireDAC.Comp.DataSet, FireDAC.Comp.Client;

type
  TframeJournal = class(TFrame)
    PanelEntries: TPanel;
    DBNavigator1: TDBNavigator;
    LabelEntries: TLabel;
    ButtonToggleStatus: TButton;
    DBGridEntries: TDBGrid;
    Splitter1: TSplitter;
    PanelLines: TPanel;
    LabelLines: TLabel;
    LabelTotal: TLabel;
    DBNavigator2: TDBNavigator;
    DBGridLines: TDBGrid;
    procedure ButtonToggleStatusClick(Sender: TObject);
  private
    { Private declarations }
    FAllowStatusEdit: Boolean;
    procedure SetupEntriesColumns;
    procedure SetupLinesColumns;
    procedure EntriesAfterScroll(DataSet: TDataSet);
    procedure EntriesAfterInsert(DataSet: TDataSet);
    procedure EntriesAfterPost(DataSet: TDataSet);
    procedure EntriesBeforeEdit(DataSet: TDataSet);
    procedure EntriesBeforeDelete(DataSet: TDataSet);
    procedure LinesAfterInsert(DataSet: TDataSet);
    procedure LinesAfterPost(DataSet: TDataSet);
    procedure LinesAfterDelete(DataSet: TDataSet);
    procedure StatusGetText(Sender: TField; var Text: string; DisplayText: Boolean);
    procedure RefreshLines;
    procedure UpdateTotalLabel;
    procedure UpdateLinesEnabled;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;

implementation

{$R *.dfm}

uses
  UnitdmMain;

{ ================= CREATE / DESTROY ================= }

constructor TframeJournal.Create(AOwner: TComponent);
begin
  inherited;

  if not Assigned(dmMain) then Exit;

  DBGridEntries.DataSource := dmMain.dsJournalEntries;
  DBNavigator1.DataSource := dmMain.dsJournalEntries;
  DBGridLines.DataSource := dmMain.dsJournalLines;
  DBNavigator2.DataSource := dmMain.dsJournalLines;

  if not dmMain.qryJournalEntries.Active then
    dmMain.qryJournalEntries.Open;

  SetupEntriesColumns;
  SetupLinesColumns;

  if Assigned(dmMain.qryJournalEntries.FindField('status')) then
    dmMain.qryJournalEntries.FieldByName('status').OnGetText := StatusGetText;

  dmMain.qryJournalEntries.AfterScroll := EntriesAfterScroll;
  dmMain.qryJournalEntries.AfterInsert := EntriesAfterInsert;
  dmMain.qryJournalEntries.AfterPost := EntriesAfterPost;
  dmMain.qryJournalEntries.BeforeEdit := EntriesBeforeEdit;
  dmMain.qryJournalEntries.BeforeDelete := EntriesBeforeDelete;

  dmMain.qryJournalLines.AfterInsert := LinesAfterInsert;
  dmMain.qryJournalLines.AfterPost := LinesAfterPost;
  dmMain.qryJournalLines.AfterDelete := LinesAfterDelete;

  RefreshLines;
end;

destructor TframeJournal.Destroy;
begin
  // Отвязываем обработчики от общего (на весь datamodule) датасета —
  // иначе после закрытия вкладки эти события продолжат ссылаться на
  // уже уничтоженный фрейм.
  if Assigned(dmMain) then
  begin
    if TMethod(dmMain.qryJournalEntries.AfterScroll).Code = TMethod(EntriesAfterScroll).Code then
      dmMain.qryJournalEntries.AfterScroll := nil;
    if TMethod(dmMain.qryJournalEntries.AfterInsert).Code = TMethod(EntriesAfterInsert).Code then
      dmMain.qryJournalEntries.AfterInsert := nil;
    if TMethod(dmMain.qryJournalEntries.AfterPost).Code = TMethod(EntriesAfterPost).Code then
      dmMain.qryJournalEntries.AfterPost := nil;
    if TMethod(dmMain.qryJournalEntries.BeforeEdit).Code = TMethod(EntriesBeforeEdit).Code then
      dmMain.qryJournalEntries.BeforeEdit := nil;
    if TMethod(dmMain.qryJournalEntries.BeforeDelete).Code = TMethod(EntriesBeforeDelete).Code then
      dmMain.qryJournalEntries.BeforeDelete := nil;

    if TMethod(dmMain.qryJournalLines.AfterInsert).Code = TMethod(LinesAfterInsert).Code then
      dmMain.qryJournalLines.AfterInsert := nil;
    if TMethod(dmMain.qryJournalLines.AfterPost).Code = TMethod(LinesAfterPost).Code then
      dmMain.qryJournalLines.AfterPost := nil;
    if TMethod(dmMain.qryJournalLines.AfterDelete).Code = TMethod(LinesAfterDelete).Code then
      dmMain.qryJournalLines.AfterDelete := nil;
  end;
  inherited;
end;

{ ================= COLUMNS ================= }

procedure TframeJournal.SetupEntriesColumns;

  function AddCol(const AFieldName, ACaption: string; AWidth: Integer): TColumn;
  begin
    Result := DBGridEntries.Columns.Add;
    Result.FieldName := AFieldName;
    Result.Title.Caption := ACaption;
    Result.Width := AWidth;
  end;

begin
  DBGridEntries.Columns.Clear;
  AddCol('entry_number', '№', 70);
  AddCol('entry_date', 'Дата', 90);
  AddCol('description', 'Описание документа', 350);
  AddCol('status', 'Статус', 100);
  AddCol('created_by', 'Автор', 120);
end;

procedure TframeJournal.SetupLinesColumns;

  function AddCol(const AFieldName, ACaption: string; AWidth: Integer): TColumn;
  begin
    Result := DBGridLines.Columns.Add;
    Result.FieldName := AFieldName;
    Result.Title.Caption := ACaption;
    Result.Width := AWidth;
  end;

begin
  DBGridLines.Columns.Clear;
  AddCol('line_no', '№', 40);
  AddCol('account_debit_code', 'Дт счёт', 80);
  AddCol('debit_name', 'Наименование (Дт)', 230);
  AddCol('account_credit_code', 'Кт счёт', 80);
  AddCol('credit_name', 'Наименование (Кт)', 230);
  AddCol('amount', 'Сумма', 110);
  AddCol('description', 'Описание строки', 220);
end;

{ ================= СТАТУС: подпись вместо draft/posted ================= }

procedure TframeJournal.StatusGetText(Sender: TField; var Text: string; DisplayText: Boolean);
begin
  if Sender.AsString = 'posted' then
    Text := 'Проведён'
  else
    Text := 'Черновик';
end;

{ ================= MASTER (JOURNAL ENTRIES) ================= }

procedure TframeJournal.EntriesAfterScroll(DataSet: TDataSet);
begin
  RefreshLines;
end;

procedure TframeJournal.EntriesAfterInsert(DataSet: TDataSet);
begin
  DataSet.FieldByName('entry_date').AsDateTime := Date;
  DataSet.FieldByName('status').AsString := 'draft';
  DataSet.FieldByName('is_manual').AsInteger := 1;
  if DataSet.FieldByName('created_by').IsNull then
    DataSet.FieldByName('created_by').AsString := GetEnvironmentVariable('USERNAME');
  RefreshLines;
end;

procedure TframeJournal.EntriesAfterPost(DataSet: TDataSet);
begin
  RefreshLines;
end;

procedure TframeJournal.EntriesBeforeEdit(DataSet: TDataSet);
begin
  if (DataSet.FieldByName('status').AsString = 'posted') and not FAllowStatusEdit then
    raise Exception.Create('Проведённый документ нельзя редактировать напрямую.' + sLineBreak +
      'Сначала нажмите «Вернуть в черновик», либо исправляйте встречной проводкой (сторно).');
end;

procedure TframeJournal.EntriesBeforeDelete(DataSet: TDataSet);
begin
  if DataSet.FieldByName('status').AsString = 'posted' then
    raise Exception.Create('Проведённый документ нельзя удалить.' + sLineBreak +
      'Сначала нажмите «Вернуть в черновик».');
end;

procedure TframeJournal.ButtonToggleStatusClick(Sender: TObject);
var
  NewStatus: string;
begin
  if not dmMain.qryJournalEntries.Active or dmMain.qryJournalEntries.IsEmpty then Exit;

  if dmMain.qryJournalEntries.FieldByName('status').AsString = 'posted' then
  begin
    if MessageDlg('Снять проведение и вернуть документ в черновик?',
       mtConfirmation, [mbYes, mbNo], 0) <> mrYes then Exit;
    NewStatus := 'draft';
  end
  else
  begin
    if dmMain.qryJournalLines.RecordCount = 0 then
    begin
      ShowMessage('В документе нет ни одной строки проводки — нечего проводить.');
      Exit;
    end;
    if MessageDlg('Провести документ?' + sLineBreak +
       'После проведения проводки нельзя редактировать напрямую — только сторно (встречной проводкой).',
       mtConfirmation, [mbYes, mbNo], 0) <> mrYes then Exit;
    NewStatus := 'posted';
  end;

  FAllowStatusEdit := True;
  try
    dmMain.qryJournalEntries.Edit;
    dmMain.qryJournalEntries.FieldByName('status').AsString := NewStatus;
    dmMain.qryJournalEntries.Post;
  finally
    FAllowStatusEdit := False;
  end;

  UpdateLinesEnabled;
end;

{ ================= DETAIL (JOURNAL LINES) ================= }

procedure TframeJournal.RefreshLines;
begin
  dmMain.qryJournalLines.Close;
  if dmMain.qryJournalEntries.Active and not dmMain.qryJournalEntries.IsEmpty
     and not (dmMain.qryJournalEntries.State = dsInsert) then
  begin
    dmMain.qryJournalLines.ParamByName('entry_id').AsInteger :=
      dmMain.qryJournalEntries.FieldByName('id').AsInteger;
    dmMain.qryJournalLines.Open;
  end;
  UpdateTotalLabel;
  UpdateLinesEnabled;
end;

procedure TframeJournal.LinesAfterInsert(DataSet: TDataSet);
begin
  DataSet.FieldByName('entry_id').AsInteger := dmMain.qryJournalEntries.FieldByName('id').AsInteger;
  DataSet.FieldByName('line_no').AsInteger := DataSet.RecordCount;
  DataSet.FieldByName('amount').AsCurrency := 0;
end;

procedure TframeJournal.LinesAfterPost(DataSet: TDataSet);
begin
  // Перезапрашиваем: имена счетов (debit_name/credit_name) — это JOIN,
  // они не обновятся в сетке сами по себе, пока не перечитаем данные.
  RefreshLines;
end;

procedure TframeJournal.LinesAfterDelete(DataSet: TDataSet);
begin
  UpdateTotalLabel;
end;

{ ================= ИТОГО / БЛОКИРОВКА ПРИ "ПРОВЕДЁН" ================= }

procedure TframeJournal.UpdateTotalLabel;
var
  Total: Currency;
  Bookmark: TBookmark;
begin
  Total := 0;
  if dmMain.qryJournalLines.Active and (dmMain.qryJournalLines.RecordCount > 0) then
  begin
    dmMain.qryJournalLines.DisableControls;
    Bookmark := dmMain.qryJournalLines.GetBookmark;
    try
      dmMain.qryJournalLines.First;
      while not dmMain.qryJournalLines.Eof do
      begin
        Total := Total + dmMain.qryJournalLines.FieldByName('amount').AsCurrency;
        dmMain.qryJournalLines.Next;
      end;
    finally
      if dmMain.qryJournalLines.BookmarkValid(Bookmark) then
        dmMain.qryJournalLines.GotoBookmark(Bookmark);
      dmMain.qryJournalLines.FreeBookmark(Bookmark);
      dmMain.qryJournalLines.EnableControls;
    end;
  end;
  LabelTotal.Caption := Format('Итого по документу: %.2f', [Total]);
end;

procedure TframeJournal.UpdateLinesEnabled;
var
  IsPosted: Boolean;
begin
  IsPosted := dmMain.qryJournalEntries.Active and not dmMain.qryJournalEntries.IsEmpty
              and (dmMain.qryJournalEntries.FieldByName('status').AsString = 'posted');

  if IsPosted then
  begin
    DBGridLines.Options := DBGridLines.Options - [dgEditing];
    DBNavigator2.VisibleButtons := [nbFirst, nbPrior, nbNext, nbLast];
    ButtonToggleStatus.Caption := 'Вернуть в черновик';
  end
  else
  begin
    DBGridLines.Options := DBGridLines.Options + [dgEditing];
    DBNavigator2.VisibleButtons := [nbFirst, nbPrior, nbNext, nbLast, nbInsert, nbDelete, nbEdit, nbPost, nbCancel];
    ButtonToggleStatus.Caption := 'Провести';
  end;
end;

end.

unit UnitframeTimesheet;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Data.DB, Vcl.Grids,
  System.DateUtils,
  Vcl.DBGrids, Vcl.StdCtrls, Vcl.ExtCtrls, FireDAC.Stan.Intf,
  FireDAC.Stan.Option, FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS,
  FireDAC.Phys.Intf, FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt,
  FireDAC.Comp.DataSet, FireDAC.Comp.Client;

type
  TframeTimesheet = class(TFrame)
    Panel1: TPanel;
    cbYear: TComboBox;
    cbMonth: TComboBox;
    cmbDept: TComboBox;
    btnLoad: TButton;
    btnAutoFill: TButton;
    DBGridTimesheet: TDBGrid;
    Panel2: TPanel;
    btnSave: TButton;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    procedure DBGridTimesheetDrawColumnCell(Sender: TObject; const Rect: TRect;
      DataCol: Integer; Column: TColumn; State: TGridDrawState);
    procedure btnLoadClick(Sender: TObject);
    procedure btnAutoFillClick(Sender: TObject);
    procedure btnSaveClick(Sender: TObject);
  private
    FCurYear: Integer;   // Текущий год табеля на экране
    FCurMonth: Integer;  // Текущий месяц табеля на экране
    procedure ReadPeriodFromUI;
    procedure LoadDepartments;
  public
    procedure PrepareMemTable(AYear, AMonth: Integer);
    procedure FillEmployeesList;
    constructor Create(AOwner: TComponent); override;
  end;

implementation

{$R *.dfm}

uses UnitdmMain;

{ TframeTimesheet }

constructor TframeTimesheet.Create(AOwner: TComponent);
begin
  inherited;
  // Инициализируем стартовые значения, чтобы отрисовка сетки не ругалась на нули
  FCurYear := YearOf(Now);
  FCurMonth := MonthOfTheYear(Now);
  LoadDepartments;
end;

procedure TframeTimesheet.LoadDepartments;
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

procedure TframeTimesheet.ReadPeriodFromUI;
begin
  FCurYear := StrToIntDef(cbYear.Text, YearOf(Now));
  FCurMonth := cbMonth.ItemIndex + 1;
  if FCurMonth = 0 then FCurMonth := MonthOfTheYear(Now);
end;

procedure TframeTimesheet.btnLoadClick(Sender: TObject);
begin
  ReadPeriodFromUI; // 1. Читаем и ЗАПОМИНАЕМ выбор пользователя в FCurYear/FCurMonth

  // 2. Создаем сетку, передавая наши глобальные переменные
  PrepareMemTable(FCurYear, FCurMonth);

  // 3. Заполняем её сотрудниками
  FillEmployeesList;
end;

procedure TframeTimesheet.PrepareMemTable(AYear, AMonth: Integer);
var
  i, DaysCount: Integer;
begin
  if not Assigned(dmMain) then Exit;

  DBGridTimesheet.DataSource := nil;

  with dmMain.memTimesheet do
  begin
    Active := False;
    Fields.Clear;
    FieldDefs.Clear;

    FieldDefs.Add('emp_id', ftInteger);
    FieldDefs.Add('fio', ftString, 100);

    DaysCount := DaysInAMonth(AYear, AMonth);
    for i := 1 to DaysCount do
      FieldDefs.Add('day_' + IntToStr(i), ftString, 5);

    CreateDataSet;

    DBGridTimesheet.DataSource := dmMain.dsTimesheet;

    FieldByName('emp_id').Visible := False;

    FieldByName('fio').DisplayLabel := 'Сотрудник';
    FieldByName('fio').DisplayWidth := 25;

    for i := 1 to DaysCount do
    begin
      with FieldByName('day_' + IntToStr(i)) do
      begin
        DisplayLabel := IntToStr(i);
        DisplayWidth := 4;
        Alignment := taCenter;
      end;
    end;
  end;
end;

procedure TframeTimesheet.FillEmployeesList;
var
  DeptID, DayNum, EmpID: Integer;
  LoadQuery: TFDQuery;
  CellValue: string;
begin
  if not Assigned(dmMain) then Exit;

  DeptID := 0;
  if cmbDept.ItemIndex <> -1 then
    DeptID := Integer(cmbDept.Items.Objects[cmbDept.ItemIndex]);

  if not dmMain.qryEmployees.Active then dmMain.qryEmployees.Open;

  dmMain.qryEmployees.Filtered := False;
  if DeptID > 0 then
  begin
    dmMain.qryEmployees.Filter := 'dept_id = ' + IntToStr(DeptID);
    dmMain.qryEmployees.Filtered := True;
  end;

  LoadQuery := TFDQuery.Create(nil);
  dmMain.memTimesheet.DisableControls;
  try
    LoadQuery.Connection := dmMain.conn;
    LoadQuery.SQL.Text := 'SELECT strftime(''%d'', work_date) as dday, hours_worked, status_code ' +
                          'FROM timesheet WHERE emp_id = :emp_id AND strftime(''%Y-%m'', work_date) = :ym';

    dmMain.memTimesheet.FieldByName('fio').ReadOnly := False;
    dmMain.qryEmployees.First;

    if dmMain.qryEmployees.IsEmpty then
    begin
      ShowMessage('Для выбранного отдела нет сотрудников!');
      Exit;
    end;

    while not dmMain.qryEmployees.Eof do
    begin
      if (dmMain.qryEmployees.FieldByName('status').AsInteger = 1) or
         (dmMain.qryEmployees.FieldByName('status').IsNull) then
      begin
        EmpID := dmMain.qryEmployees.FieldByName('id').AsInteger;

        dmMain.memTimesheet.Append;
        dmMain.memTimesheet.FieldByName('emp_id').AsInteger := EmpID;
        dmMain.memTimesheet.FieldByName('fio').AsString := dmMain.qryEmployees.FieldByName('fio').AsString;

        LoadQuery.Close;
        LoadQuery.ParamByName('emp_id').AsInteger := EmpID;
        // Используем наши глобальные FCurYear и FCurMonth!
        LoadQuery.ParamByName('ym').AsString := Format('%.4d-%.2d', [FCurYear, FCurMonth]);
        LoadQuery.Open;

        while not LoadQuery.Eof do
        begin
          DayNum := StrToIntDef(LoadQuery.FieldByName('dday').AsString, 0);

          if DayNum > 0 then
          begin
            if LoadQuery.FieldByName('hours_worked').AsFloat > 0 then
              CellValue := FloatToStr(LoadQuery.FieldByName('hours_worked').AsFloat)
            else
              CellValue := LoadQuery.FieldByName('status_code').AsString;

            dmMain.memTimesheet.FieldByName('day_' + IntToStr(DayNum)).AsString := CellValue;
          end;
          LoadQuery.Next;
        end;

        dmMain.memTimesheet.Post;
      end;
      dmMain.qryEmployees.Next;
    end;

    dmMain.memTimesheet.First;

  finally
    LoadQuery.Free;
    dmMain.memTimesheet.FieldByName('fio').ReadOnly := True;
    dmMain.memTimesheet.EnableControls;
    dmMain.qryEmployees.Filtered := False;
  end;
end;

procedure TframeTimesheet.btnAutoFillClick(Sender: TObject);
var
  i, DaysCount: Integer;
  CurrentDate: TDateTime;
begin
  if not Assigned(dmMain) or not dmMain.memTimesheet.Active then Exit;
  if dmMain.memTimesheet.IsEmpty then Exit;

  // Просто берем сохраненные значения
  DaysCount := DaysInAMonth(FCurYear, FCurMonth);

  dmMain.memTimesheet.DisableControls;
  try
    dmMain.memTimesheet.First;

    while not dmMain.memTimesheet.Eof do
    begin
      dmMain.memTimesheet.Edit;

      for i := 1 to DaysCount do
      begin
        if TryEncodeDate(Word(FCurYear), Word(FCurMonth), Word(i), CurrentDate) then
        begin
          if DayOfTheWeek(CurrentDate) in [6, 7] then
            dmMain.memTimesheet.FieldByName('day_' + IntToStr(i)).AsString := 'В'
          else
            dmMain.memTimesheet.FieldByName('day_' + IntToStr(i)).AsString := '8';
        end;
      end;

      dmMain.memTimesheet.Post;
      dmMain.memTimesheet.Next;
    end;

    dmMain.memTimesheet.First;
  finally
    dmMain.memTimesheet.EnableControls;
  end;
end;

procedure TframeTimesheet.btnSaveClick(Sender: TObject);
var
  DaysCount, i, EmpID: Integer;
  CurrentDate: TDateTime;
  CellText: string;
  Hours: Double;
  SaveQuery: TFDQuery;
begin
  if not Assigned(dmMain) or not dmMain.memTimesheet.Active then Exit;
  if dmMain.memTimesheet.IsEmpty then Exit;

  DaysCount := DaysInAMonth(FCurYear, FCurMonth);

  SaveQuery := TFDQuery.Create(nil);
  try
    SaveQuery.Connection := dmMain.conn;
    dmMain.conn.StartTransaction;
    try
      dmMain.memTimesheet.First;

      while not dmMain.memTimesheet.Eof do
      begin
        EmpID := dmMain.memTimesheet.FieldByName('emp_id').AsInteger;

        SaveQuery.SQL.Text := 'DELETE FROM timesheet WHERE emp_id = :emp_id AND strftime(''%Y-%m'', work_date) = :ym';
        SaveQuery.ParamByName('emp_id').AsInteger := EmpID;
        SaveQuery.ParamByName('ym').AsString := Format('%.4d-%.2d', [FCurYear, FCurMonth]);
        SaveQuery.ExecSQL;

        SaveQuery.SQL.Text := 'INSERT INTO timesheet (emp_id, work_date, hours_worked, status_code) ' +
                              'VALUES (:emp_id, :wdate, :hrs, :code)';

        for i := 1 to DaysCount do
        begin
          CellText := Trim(dmMain.memTimesheet.FieldByName('day_' + IntToStr(i)).AsString);

          if CellText = '' then Continue;

          CurrentDate := EncodeDate(FCurYear, FCurMonth, i);

          SaveQuery.ParamByName('emp_id').AsInteger := EmpID;
          SaveQuery.ParamByName('wdate').AsDate := CurrentDate;

          Hours := StrToFloatDef(CellText, 0);

          if Hours > 0 then
          begin
            SaveQuery.ParamByName('hrs').AsFloat := Hours;
            SaveQuery.ParamByName('code').AsString := 'Я';
          end
          else
          begin
            SaveQuery.ParamByName('hrs').AsFloat := 0;
            SaveQuery.ParamByName('code').AsString := UpperCase(Copy(CellText, 1, 5));
          end;

          SaveQuery.ExecSQL;
        end;

        dmMain.memTimesheet.Next;
      end;

      dmMain.conn.Commit;
      ShowMessage('Табель успешно сохранен в базу данных!');

    except
      on E: Exception do
      begin
        dmMain.conn.Rollback;
        ShowMessage('Ошибка при сохранении табеля: ' + E.Message);
      end;
    end;
  finally
    SaveQuery.Free;
  end;
end;

procedure TframeTimesheet.DBGridTimesheetDrawColumnCell(Sender: TObject;
  const Rect: TRect; DataCol: Integer; Column: TColumn; State: TGridDrawState);
var
  DayNum: Integer;
  CurrentDate: TDateTime;
begin
  if Pos('day_', Column.FieldName) = 1 then
  begin
    DayNum := StrToIntDef(Copy(Column.FieldName, 5, Length(Column.FieldName)), 1);

    // Используем готовые глобальные переменные без лишнего чтения из UI!
    if (FCurYear > 0) and (FCurMonth > 0) then
    begin
      if TryEncodeDate(Word(FCurYear), Word(FCurMonth), Word(DayNum), CurrentDate) then
      begin
        if DayOfTheWeek(CurrentDate) in [6, 7] then
        begin
          DBGridTimesheet.Canvas.Brush.Color := $00E1E1FF;

          if gdSelected in State then
            DBGridTimesheet.Canvas.Brush.Color := clHighlight;
        end;
      end;
    end;
  end;

  DBGridTimesheet.DefaultDrawColumnCell(Rect, DataCol, Column, State);
end;

end.

unit UnitframeDashboard;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  FireDAC.Comp.Client, FireDAC.Comp.DataSet, Vcl.Imaging.pngimage,
  Vcl.WinXCalendars, Vcl.WinXCtrls, Vcl.WinXPanels;

type
  TframeDashboard = class(TFrame)
    Panel1: TPanel;
    lblWelcome: TLabel;
    Image1: TImage;
    lblEmpCount: TLabel;
    lblFund: TLabel;
    Label1: TLabel;
    Label2: TLabel;
    Panel2: TPanel;
    Panel3: TPanel;
    Label3: TLabel;
    Label4: TLabel;
    Panel4: TPanel;
    Panel5: TPanel;
    lblBirthdaysList: TLabel;
    lblAbsentList: TLabel;
    Panel6: TPanel;
    Panel7: TPanel;
    Shape2: TShape;
    Shape1: TShape;
  private
    { Private declarations }
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    procedure UpdateStats;
    procedure RefreshDashboard;
  end;

implementation

{$R *.dfm}

uses UnitdmMain;

{ TframeDashboard }

constructor TframeDashboard.Create(AOwner: TComponent);
var
  Q: TFDQuery;
begin
  inherited;

  lblWelcome.Color := clNavy;
  // Защита от ошибок в режиме дизайна
  if not Assigned(dmMain) then Exit;

  Q := TFDQuery.Create(nil);
  try
    Q.Connection := dmMain.conn;
    // 1. Считаем активных сотрудников
    Q.SQL.Text := 'SELECT COUNT(id) FROM employees WHERE status = 1';
    Q.Open;
    Label1.Caption :=  'Сотрудников в штате: ';
    Label1.Color := clHotLight;
    lblEmpCount.Caption := Q.Fields[0].AsString;
    Q.Close;

    // 2. Считаем фонд окладов
    Q.SQL.Text := 'SELECT SUM(base_salary) FROM employees WHERE status = 1';
    Q.Open;
    // Проверка на NULL (если база вдруг пустая)
    if Q.Fields[0].IsNull then
    begin
      Label2.Caption := 'Месячный фонд окладов: ';
      lblFund.Caption := ' 0.00 TMT'
    end
    else
    begin
      Label2.Caption := 'Месячный фонд окладов: ';
      lblFund.Caption := FormatFloat('#,##0.00 TMT', Q.Fields[0].AsFloat);
    end;
    Label2.Color := clHotLight;
  finally
    Q.Free;
  end;

  // --- ДОБАВЛЯЕМ ВЫЗОВ НАШЕЙ НОВОЙ ПРОЦЕДУРЫ ЗДЕСЬ! ---
  RefreshDashboard;
  // ----------------------------------------------------
//  Label1.Transparent := False;
//  Label1.Color := $0063C600;
end;

procedure TframeDashboard.RefreshDashboard;
var
  Qry: TFDQuery;
begin
  if not Assigned(dmMain) then Exit;

  Qry := TFDQuery.Create(nil);
  try
    Qry.Connection := dmMain.conn;

    // --- 1. ДНИ РОЖДЕНИЯ В ЭТОМ МЕСЯЦЕ ---
    lblBirthdaysList.Caption := ''; // Очищаем текст
    Qry.Close;
    Qry.SQL.Text := 'SELECT fio, strftime(''%d.%m'', birth_date) as bdate ' +
                    'FROM employees ' +
                    'WHERE strftime(''%m'', birth_date) = strftime(''%m'', ''now'') AND status = 1 ' +
                    'ORDER BY strftime(''%d'', birth_date)';
    Qry.Open;

    while not Qry.Eof do
    begin
      // Если текст уже есть, добавляем перенос строки перед новым
      if lblBirthdaysList.Caption <> '' then
        lblBirthdaysList.Caption := lblBirthdaysList.Caption + sLineBreak;

      // Добавляем красивый маркер-точку перед именем для вида списка
      lblBirthdaysList.Caption := lblBirthdaysList.Caption +
        '• ' + Qry.FieldByName('fio').AsString + ' (' + Qry.FieldByName('bdate').AsString + ')';

      Qry.Next;
    end;

    if lblBirthdaysList.Caption = '' then
      lblBirthdaysList.Caption := 'В этом месяце именинников нет.';


    // --- 2. КТО ОТСУТСТВУЕТ ПРЯМО СЕГОДНЯ ---
    lblAbsentList.Caption := ''; // Очищаем текст
    Qry.Close;
    Qry.SQL.Text :=
      'SELECT e.fio, ''Отпуск'' as reason, strftime(''%d.%m.%Y'', v.end_date) as end_dt ' +
      'FROM vacation_journal v JOIN employees e ON v.emp_id = e.id ' +
      'WHERE date(''now'') BETWEEN v.start_date AND v.end_date ' +
      'UNION ALL ' +
      'SELECT e.fio, ''Больничный'' as reason, strftime(''%d.%m.%Y'', s.end_date) as end_dt ' +
      'FROM sick_leave_journal s JOIN employees e ON s.emp_id = e.id ' +
      'WHERE date(''now'') BETWEEN s.start_date AND s.end_date';
    Qry.Open;

    while not Qry.Eof do
    begin
      if lblAbsentList.Caption <> '' then
        lblAbsentList.Caption := lblAbsentList.Caption + sLineBreak;

      lblAbsentList.Caption := lblAbsentList.Caption + '• ' + Qry.FieldByName('fio').AsString +
                               ' - ' + Qry.FieldByName('reason').AsString +
                               ' (по ' + Qry.FieldByName('end_dt').AsString + ')';
      Qry.Next;
    end;

    if lblAbsentList.Caption = '' then
      lblAbsentList.Caption := 'Все сотрудники на рабочих местах.';

  finally
    Qry.Free;
  end;
end;

procedure TframeDashboard.UpdateStats;
var
  Q: TFDQuery;
begin
  // Защита от ошибок в режиме дизайна
  if not Assigned(dmMain) or not dmMain.conn.Connected then Exit;
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := dmMain.conn;
    // 1. Считаем активных сотрудников
    Q.SQL.Text := 'SELECT COUNT(id) FROM employees WHERE status = 1';
    Q.Open;
    lblEmpCount.Caption := Q.Fields[0].AsString;
    Q.Close;
    // 2. Считаем фонд окладов
    Q.SQL.Text := 'SELECT SUM(base_salary) FROM employees WHERE status = 1';
    Q.Open;
    if Q.Fields[0].IsNull then
      lblFund.Caption := ' 0.00 TMT'
    else
      lblFund.Caption := FormatFloat('#,##0.00 TMT', Q.Fields[0].AsFloat);
    // Наводим красоту
    lblWelcome.Font.Color := clNavy;
    Label1.Font.Color := clHotLight;
    Label2.Font.Color := clHotLight;
  finally
    Q.Free;
  end;
end;

end.

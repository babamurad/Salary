unit Main;

interface

uses
  Winapi.Windows, Winapi.Messages,
  System.SysUtils, System.Classes,
  Vcl.Controls, Vcl.Forms, Vcl.ComCtrls,
  Vcl.ExtCtrls, Vcl.ImgList, Vcl.Dialogs,
  System.Types, FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  FireDAC.Stan.Async, FireDAC.DApt, Data.DB, FireDAC.Comp.DataSet,
  Vcl.Graphics,
  FireDAC.Comp.Client, System.ImageList;

type
  TFrameClass = class of TFrame;

  TForm1 = class(TForm)
    Splitter1: TSplitter;
    TreeView1: TTreeView;
    PageControl1: TPageControl;
    ImageList1: TImageList;
    Panel1: TPanel;
    procedure FormCreate(Sender: TObject);
    procedure TreeView1Change(Sender: TObject; Node: TTreeNode);
    procedure PageControl1DrawTab(Control: TCustomTabControl;
      TabIndex: Integer; const Rect: TRect; Active: Boolean);
    procedure PageControl1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure PageControl1MouseMove(Sender: TObject; Shift: TShiftState;
      X, Y: Integer);
  private
     FHoverCloseTab: Integer;  // можно раскомментировать, если нужен hover-эффект
    procedure BuildTree;
    procedure OpenTab(AFrameClass: TFrameClass; const ACaption: string);
    procedure CloseTab(Index: Integer);
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

uses
  UnitframeEmployees,
  UnitframePayroll,
  UnitframeReports, UnitBaseEditForm, UnitdmMain, UnitEditEmployee,
  UnitframeDepts, UnitframePositions, UnitframeSettings;

{ ================= TREE ================= }

procedure TForm1.BuildTree;
var
  Root, Child: TTreeNode;
begin
  TreeView1.Items.Clear;

  // --- БЛОК 1: Справочники ---
  Root := TreeView1.Items.Add(nil, 'Справочники');

  Child := TreeView1.Items.AddChild(Root, 'Отделы');
  Child.Data := TframeDepts; // Твой будущий фрейм

  Child := TreeView1.Items.AddChild(Root, 'Должности');
  Child.Data := TframePositions; // Твой будущий фрейм

  Child := TreeView1.Items.AddChild(Root, 'Сотрудники');
  Child.Data := TframeEmployees;

  Child := TreeView1.Items.AddChild(Root, 'Настройки');
  Child.Data := TframeSettings; // Сюда можно вывести settings, const_settings и ставки

  Root.Expand(True);

  // --- БЛОК 2: Документы ---
  Root := TreeView1.Items.Add(nil, 'Документы');

  Child := TreeView1.Items.AddChild(Root, 'Начисление зарплаты');
  Child.Data := TframePayroll;

  Root.Expand(True);

  // --- БЛОК 3: Отчеты ---
  Root := TreeView1.Items.Add(nil, 'Отчеты');

  Child := TreeView1.Items.AddChild(Root, 'Ведомость');
  Child.Data := TframeReports;

  Root.Expand(True);
end;

{ ================= FORM CREATE ================= }

procedure TForm1.FormCreate(Sender: TObject);
begin
  BuildTree;

  PageControl1.OwnerDraw := True;
  PageControl1.DoubleBuffered := True;
  PageControl1.HotTrack := True;
  PageControl1.TabWidth := 200;

  FHoverCloseTab := -1;
end;

{ ================= OPEN TAB ================= }

procedure TForm1.OpenTab(AFrameClass: TFrameClass; const ACaption: string);
var
  i: Integer;
  Tab: TTabSheet;
  Frame: TFrame;
begin
  for i := 0 to PageControl1.PageCount - 1 do
    if PageControl1.Pages[i].Caption = ACaption then
    begin
      PageControl1.ActivePage := PageControl1.Pages[i];
      Exit;
    end;

  Tab := TTabSheet.Create(PageControl1);
  Tab.PageControl := PageControl1;
  Tab.Caption := ACaption;

  Frame := AFrameClass.Create(Tab);
  Frame.Parent := Tab;
  Frame.Align := alClient;

  PageControl1.ActivePage := Tab;
end;

{ ================= CLOSE TAB ================= }

procedure TForm1.CloseTab(Index: Integer);
begin
  if (Index >= 0) and (Index < PageControl1.PageCount) then
    PageControl1.Pages[Index].Free;
end;

{ ================= TREE CLICK ================= }

procedure TForm1.TreeView1Change(Sender: TObject; Node: TTreeNode);
begin
  if Assigned(Node.Data) then
    OpenTab(TFrameClass(Node.Data), Node.Text);
end;

{ ================= DRAW TAB ================= }

procedure TForm1.PageControl1DrawTab(Control: TCustomTabControl;
  TabIndex: Integer; const Rect: TRect; Active: Boolean);
var
  C: TCanvas;
  CloseRect: TRect;
  Hovered: Boolean;
begin
  C := PageControl1.Canvas;
  // Единые координаты крестика для всех 3-х методов!
  CloseRect := System.Types.Rect(Rect.Right - 22, Rect.Top + 6, Rect.Right - 6, Rect.Bottom - 6);

  // Отрисовка фона вкладки
  if Active then
    C.Brush.Color := clWhite
  else
    C.Brush.Color := $00F0F0F0;
  C.FillRect(Rect);

  // Делаем фон текста прозрачным, чтобы не было "грязных" квадратов вокруг букв
  SetBkMode(C.Handle, TRANSPARENT);

  // Цвет текста вкладки
  if Active then
    C.Font.Color := clBlack
  else
    C.Font.Color := clDkGray;

  // Текст заголовка
  C.TextOut(Rect.Left + 10, Rect.Top + 6, PageControl1.Pages[TabIndex].Caption);

  // Определяем, наведена ли мышь на крестик
  Hovered := (FHoverCloseTab = TabIndex);

  // Выбор цвета крестика
  if Hovered then
    C.Font.Color := clRed
  else
    C.Font.Color := clGray;

  // Рисуем крестик
  C.Font.Name := 'Arial'; // Arial гарантированно есть на всех ПК Windows и содержит базовые символы
  C.Font.Size := 10;
  C.Font.Style := [fsBold];

  // Рисуем обычную "X" или спецсимвол
  C.TextOut(CloseRect.Left + 2, CloseRect.Top + 1, 'x');
end;

{ ================= MOUSE DOWN ================= }

procedure TForm1.PageControl1MouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  i: Integer;
  TabR: TRect;
  CloseRect: TRect;
begin
  if Button = mbLeft then
    for i := 0 to PageControl1.PageCount - 1 do
    begin
      TabR := PageControl1.TabRect(i);
      // Используем строго те же координаты (22 и 6), что и при отрисовке!
      CloseRect := System.Types.Rect(TabR.Right - 22, TabR.Top + 6, TabR.Right - 6, TabR.Bottom - 6);

      if PtInRect(CloseRect, Point(X, Y)) then
      begin
        CloseTab(i);
        // Сбрасываем Hover, иначе при удалении вкладки крестик может "зависнуть"
        FHoverCloseTab := -1;
        Break;
      end;
    end;
end;

{ ================= MOUSE MOVE ================= }

procedure TForm1.PageControl1MouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
var
  i: Integer;
  TabR: TRect;
  CloseRect: TRect;
  NewHover: Integer;
begin
  NewHover := -1;
  for i := 0 to PageControl1.PageCount - 1 do
  begin
    TabR := PageControl1.TabRect(i);
    // И тут те же самые координаты
    CloseRect := System.Types.Rect(TabR.Right - 22, TabR.Top + 6, TabR.Right - 6, TabR.Bottom - 6);

    if PtInRect(CloseRect, Point(X, Y)) then
    begin
      NewHover := i;
      Break;
    end;
  end;

  if NewHover <> FHoverCloseTab then
  begin
    FHoverCloseTab := NewHover;
    PageControl1.Invalidate; // Перерисовываем только если поменялся ховер
  end;
end;

end.

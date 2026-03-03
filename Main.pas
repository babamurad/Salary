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
  FireDAC.Comp.Client, System.ImageList, Vcl.Menus;

type
  TFrameClass = class of TFrame;

  TMainForm = class(TForm)
    Splitter1: TSplitter;
    TreeView1: TTreeView;
    PageControl1: TPageControl;
    ImageList1: TImageList;
    Panel1: TPanel;
    MainMenu1: TMainMenu;
    dlgOpenDb: TOpenDialog;
    dlgSaveDb: TSaveDialog;
    N1: TMenuItem;
    N2: TMenuItem;
    N3: TMenuItem;
    N4: TMenuItem;
    N5: TMenuItem;
    ImageList2: TImageList;
    procedure FormCreate(Sender: TObject);
    procedure TreeView1Change(Sender: TObject; Node: TTreeNode);
    procedure PageControl1DrawTab(Control: TCustomTabControl;
      TabIndex: Integer; const Rect: TRect; Active: Boolean);
    procedure PageControl1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure PageControl1MouseMove(Sender: TObject; Shift: TShiftState;
      X, Y: Integer);
    procedure FormShow(Sender: TObject);
    procedure N2Click(Sender: TObject);
    procedure N3Click(Sender: TObject);
    procedure N5Click(Sender: TObject);
  private
     FHoverCloseTab: Integer;  // можно раскомментировать, если нужен hover-эффект
    procedure BuildTree;
    procedure OpenTab(AFrameClass: TFrameClass; const ACaption: string);
    procedure CloseTab(Index: Integer);
    procedure CloseAllTabsExceptFirst;
    // Функция, которая делает всю грязную работу за нас
    function AddMenuNode(ParentNode: TTreeNode; const NodeText: string;
                       FrameClass: Pointer; IconIndex: Integer): TTreeNode;
    // Изменили заголовок: добавили AImageIndex
    procedure OpenTab(AFrameClass: TFrameClass; const ACaption: string; AImageIndex: Integer);

  public
    procedure RefreshDashboard;
  end;

var
  MainForm: TMainForm;

implementation

{$R *.dfm}

uses
  UnitframeEmployees,
  UnitframePayroll,
  UnitframeReports, UnitBaseEditForm, UnitdmMain, UnitEditEmployee,
  UnitframeDepts, UnitframePositions, UnitframeSettings, UnitframeVacation,
  UnitframeSickLeave, UnitframeDashboard, UnitframeCalendar, UnitFormHelp,
  UnitframeTimesheet;

{ ================= TREE ================= }

function TMainForm.AddMenuNode(ParentNode: TTreeNode; const NodeText: string;
  FrameClass: Pointer; IconIndex: Integer): TTreeNode;
begin
  // 1. Создаем узел (если ParentNode пустой - значит это корень, иначе - дочерняя ветка)
  if ParentNode = nil then
    Result := TreeView1.Items.Add(nil, NodeText)
  else
    Result := TreeView1.Items.AddChild(ParentNode, NodeText);

  // 2. Привязываем класс фрейма
  Result.Data := FrameClass;

  // 3. Магия картинок: применяем один индекс ко всем состояниям разом!
  Result.ImageIndex := IconIndex;
  Result.SelectedIndex := IconIndex; // Картинка не будет меняться при клике
  //Result.ExpandedIndex := IconIndex; // Картинка не будет меняться при разворачивании
end;

procedure TMainForm.BuildTree;
var
  Root: TTreeNode;
begin
  TreeView1.Items.Clear;
  TreeView1.Images := ImageList2;

  // --- БЛОК : Главная ---
  // (nil = корень, 0 = иконка календарика)
  AddMenuNode(nil, 'Главная', TframeDashboard, 0);

  // --- БЛОК 1: Справочники ---
  Root := AddMenuNode(nil, 'Справочники', nil, 5); // 5 = Желтая папка
  AddMenuNode(Root, 'Отделы', TframeDepts, 1);     // 1 = Структура
  AddMenuNode(Root, 'Должности', TframePositions, 13);
  AddMenuNode(Root, 'Сотрудники', TframeEmployees, 9); // 2 = Люди
  AddMenuNode(Root, 'Настройки', TframeSettings, 14);  // 14 = Шестеренка
  AddMenuNode(Root, 'Пр. календарь', TframeCalendar, 7);
  Root.Expand(True);

  // --- БЛОК 2: Документы ---
  Root := AddMenuNode(nil, 'Документы', nil, 5);
  AddMenuNode(Root, 'Табель', TframeTimesheet, 17);
  AddMenuNode(Root, 'Начисление зарплаты', TframePayroll, 6); // 6 = Деньги в руке
  AddMenuNode(Root, 'Расчет отпускных', TframeVacation, 18);   // 7 = Домик
  AddMenuNode(Root, 'Расчет больничных', TframeSickLeave, 3); // 3 = Чемоданчик с крестом
  Root.Expand(True);

  // --- БЛОК 3: Отчеты ---
  Root := AddMenuNode(nil, 'Отчеты', nil, 5);
  AddMenuNode(Root, 'Ведомость', TframeReports, 12);
  Root.Expand(True);
end;

{ ================= FORM CREATE ================= }

procedure TMainForm.FormCreate(Sender: TObject);
begin
  BuildTree;

  dmMain.LoadConfig;

  TreeView1.FullExpand;

  PageControl1.OwnerDraw := True;
  PageControl1.DoubleBuffered := True;
  PageControl1.HotTrack := True;
  PageControl1.TabWidth := 200;
  PageControl1.Images := ImageList2;

  FHoverCloseTab := -1;
end;

procedure TMainForm.FormShow(Sender: TObject);
var
  TabSheet: TTabSheet;
  DashFrame: TframeDashboard;
begin
  // 1. Создаем новую вкладку
  TabSheet := TTabSheet.Create(PageControl1);
  TabSheet.PageControl := PageControl1;
  TabSheet.Caption := 'Главная';
  // 2. Создаем наш фрейм Дашборда и кладем его на вкладку
  DashFrame := TframeDashboard.Create(TabSheet);
  DashFrame.Parent := TabSheet;
  DashFrame.Align := alClient; // Чтобы растянулся на всё окно
  // 3. Делаем эту вкладку активной
  PageControl1.ActivePage := TabSheet;
  // (Опционально) Раскрываем ветки дерева, чтобы было видно меню
  TreeView1.FullExpand;
end;

procedure TMainForm.N2Click(Sender: TObject);
begin
if dlgOpenDb.Execute then
  begin
    // Закрываем все вкладки, кроме первой (Дашборда)
    CloseAllTabsExceptFirst;

    // Подключаем новую базу
    dmMain.ApplyDatabase(dlgOpenDb.FileName);

    // Обновляем цифры на Дашборде (если он открыт)
    RefreshDashboard;

    ShowMessage('База данных успешно загружена!');
  end;
end;

procedure TMainForm.N3Click(Sender: TObject);
begin
if dlgSaveDb.Execute then
  begin

    // Вызываем метод создания из ДатаМодуля
    if ExtractFileExt(dlgSaveDb.FileName) = '' then
      dlgSaveDb.FileName := dlgSaveDb.FileName + '.db';

    // Закрываем лишние вкладки
    CloseAllTabsExceptFirst;

    // Создаем базу
    dmMain.CreateNewDb(dlgSaveDb.FileName);

    RefreshDashboard;
  end;
end;

procedure TMainForm.N5Click(Sender: TObject);
begin
  // Открываем окно справки поверх всех остальных окон
  // 1. Создаем форму в памяти
  FormHelp := TFormHelp.Create(Self);
  try
    // 2. Показываем её пользователю
    FormHelp.ShowModal;
  finally
    // 3. Удаляем из памяти после закрытия крестиком
    FormHelp.Free;
  end;
end;

procedure TMainForm.OpenTab(AFrameClass: TFrameClass; const ACaption: string; AImageIndex: Integer);
var
  i: Integer;
  Tab: TTabSheet;
  Frame: TFrame;
begin
  // 1. Проверяем, не открыта ли уже такая вкладка
  for i := 0 to PageControl1.PageCount - 1 do
    if PageControl1.Pages[i].Caption := ACaption then
    begin
      // Если открыта - просто активируем её
      PageControl1.ActivePage := PageControl1.Pages[i];
      // (Опционально) Обновляем иконку, если вдруг она поменялась в дереве
      PageControl1.Pages[i].ImageIndex := AImageIndex;
      Exit;
    end;

  // 2. Создаем новую вкладку
  Tab := TTabSheet.Create(PageControl1);
  Tab.PageControl := PageControl1;
  Tab.Caption := ACaption;

  // --- МАГИЯ ЗДЕСЬ: Назначаем иконку вкладке ---
  Tab.ImageIndex := AImageIndex;

  // 3. Создаем фрейм
  Frame := AFrameClass.Create(Tab);
  Frame.Parent := Tab;
  Frame.Align := alClient;

  PageControl1.ActivePage := Tab;
end;

{ ================= OPEN TAB ================= }

procedure TMainForm.OpenTab(AFrameClass: TFrameClass; const ACaption: string);
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

procedure TMainForm.CloseAllTabsExceptFirst;
begin
  // Удаляем все вкладки в PageControl, начиная со второй (индекс 1)
  while PageControl1.PageCount > 1 do
    PageControl1.Pages[1].Free;
end;

procedure TMainForm.CloseTab(Index: Integer);
begin
  if (Index >= 0) and (Index < PageControl1.PageCount) then
    PageControl1.Pages[Index].Free;
end;


{ ================= TREE CLICK ================= }

procedure TMainForm.TreeView1Change(Sender: TObject; Node: TTreeNode);
begin
  if Assigned(Node.Data) then
    OpenTab(TFrameClass(Node.Data), Node.Text);
end;

{ ================= DRAW TAB ================= }

procedure TMainForm.PageControl1DrawTab(Control: TCustomTabControl;
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

procedure TMainForm.PageControl1MouseDown(Sender: TObject;
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

procedure TMainForm.PageControl1MouseMove(Sender: TObject;
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

procedure TMainForm.RefreshDashboard;
var
  i, j: Integer;
begin
  // Проверка, что PageControl готов
  if (PageControl1 = nil) or (PageControl1.PageCount = 0) then Exit;

  for i := 0 to PageControl1.PageCount - 1 do
  begin
    if PageControl1.Pages[i].Caption = 'Главная' then
    begin
      for j := 0 to PageControl1.Pages[i].ControlCount - 1 do
      begin
        if PageControl1.Pages[i].Controls[j] is TframeDashboard then
        begin
          // Обновляем статистику (она будет по нулям в новой базе)
          TframeDashboard(PageControl1.Pages[i].Controls[j]).UpdateStats;
          Exit;
        end;
      end;
    end;
  end;
end;

end.

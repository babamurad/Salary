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
    FHoverCloseTab: Integer;  // для hover-эффекта крестика
    procedure BuildTree;
    // ВНИМАНИЕ: Изменили заголовок OpenTab, добавив AImageIndex
    procedure OpenTab(AFrameClass: TFrameClass; const ACaption: string; AImageIndex: Integer);
    procedure CloseTab(Index: Integer);
    procedure CloseAllTabsExceptFirst;
    // Функция, которая делает всю грязную работу за нас
    function AddMenuNode(ParentNode: TTreeNode; const NodeText: string;
                       FrameClass: Pointer; IconIndex: Integer): TTreeNode;

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
  if ParentNode = nil then
    Result := TreeView1.Items.Add(nil, NodeText)
  else
    Result := TreeView1.Items.AddChild(ParentNode, NodeText);

  Result.Data := FrameClass;

  Result.ImageIndex := IconIndex;
  Result.SelectedIndex := IconIndex;
  // Result.ExpandedIndex := IconIndex;
end;

procedure TMainForm.BuildTree;
var
  Root: TTreeNode;
begin
  TreeView1.Items.Clear;
  TreeView1.Images := ImageList2;

  AddMenuNode(nil, 'Главная', TframeDashboard, 0);

  Root := AddMenuNode(nil, 'Справочники', nil, 5);
  AddMenuNode(Root, 'Отделы', TframeDepts, 1);
  AddMenuNode(Root, 'Должности', TframePositions, 13);
  AddMenuNode(Root, 'Сотрудники', TframeEmployees, 9);
  AddMenuNode(Root, 'Настройки', TframeSettings, 14);
  AddMenuNode(Root, 'Пр. календарь', TframeCalendar, 7);
  Root.Expand(True);

  Root := AddMenuNode(nil, 'Документы', nil, 5);
  AddMenuNode(Root, 'Табель', TframeTimesheet, 17);
  AddMenuNode(Root, 'Начисление зарплаты', TframePayroll, 6);
  AddMenuNode(Root, 'Расчет отпускных', TframeVacation, 18);
  AddMenuNode(Root, 'Расчет больничных', TframeSickLeave, 3);
  Root.Expand(True);

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

  // ОБЯЗАТЕЛЬНО: Привязываем картинки к вкладкам
  PageControl1.Images := ImageList2;

  PageControl1.OwnerDraw := True;
  PageControl1.DoubleBuffered := True;
  PageControl1.HotTrack := True;
  PageControl1.TabWidth := 270;

  FHoverCloseTab := -1;
end;

procedure TMainForm.FormShow(Sender: TObject);
var
  TabSheet: TTabSheet;
  DashFrame: TframeDashboard;
begin
  TabSheet := TTabSheet.Create(PageControl1);
  TabSheet.PageControl := PageControl1;
  TabSheet.Caption := 'Главная';
  // Назначаем иконку для стартовой вкладки (0 - календарик)
  TabSheet.ImageIndex := 0;

  DashFrame := TframeDashboard.Create(TabSheet);
  DashFrame.Parent := TabSheet;
  DashFrame.Align := alClient;

  PageControl1.ActivePage := TabSheet;
  TreeView1.FullExpand;
end;

{ ================= MENU ACTIONS ================= }

procedure TMainForm.N2Click(Sender: TObject);
begin
  if dlgOpenDb.Execute then
  begin
    CloseAllTabsExceptFirst;
    dmMain.ApplyDatabase(dlgOpenDb.FileName);
    RefreshDashboard;
    ShowMessage('База данных успешно загружена!');
  end;
end;

procedure TMainForm.N3Click(Sender: TObject);
begin
  if dlgSaveDb.Execute then
  begin
    if ExtractFileExt(dlgSaveDb.FileName) = '' then
      dlgSaveDb.FileName := dlgSaveDb.FileName + '.db';

    CloseAllTabsExceptFirst;
    dmMain.CreateNewDb(dlgSaveDb.FileName);
    RefreshDashboard;
  end;
end;

procedure TMainForm.N5Click(Sender: TObject);
begin
  FormHelp := TFormHelp.Create(Self);
  try
    FormHelp.ShowModal;
  finally
    FormHelp.Free;
  end;
end;

{ ================= OPEN TAB ================= }

// Передаем AImageIndex, чтобы вкладка знала свою картинку
procedure TMainForm.OpenTab(AFrameClass: TFrameClass; const ACaption: string; AImageIndex: Integer);
var
  i: Integer;
  Tab: TTabSheet;
  Frame: TFrame;
begin
  for i := 0 to PageControl1.PageCount - 1 do
    if PageControl1.Pages[i].Caption = ACaption then
    begin
      PageControl1.ActivePage := PageControl1.Pages[i];
      PageControl1.Pages[i].ImageIndex := AImageIndex; // Обновляем картинку на всякий случай
      Exit;
    end;

  Tab := TTabSheet.Create(PageControl1);
  Tab.PageControl := PageControl1;
  Tab.Caption := ACaption;
  Tab.ImageIndex := AImageIndex; // Записываем индекс иконки!
//  Tab.Width :=250;

  Frame := AFrameClass.Create(Tab);
  Frame.Parent := Tab;
  Frame.Align := alClient;

  PageControl1.ActivePage := Tab;
end;

{ ================= CLOSE TAB ================= }

procedure TMainForm.CloseAllTabsExceptFirst;
begin
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
    // Передаем в OpenTab не только класс и имя, но и картинку узла!
    OpenTab(TFrameClass(Node.Data), Node.Text, Node.ImageIndex);
end;

{ ================= DRAW TAB (МАГИЯ ОТРИСОВКИ ИКОНОК И КРЕСТИКОВ) ================= }

procedure TMainForm.PageControl1DrawTab(Control: TCustomTabControl;
  TabIndex: Integer; const Rect: TRect; Active: Boolean);
var
  C: TCanvas;
  CloseRect: TRect;
  Hovered: Boolean;
  ImgIdx, IconY, TextLeft: Integer;
begin
  C := PageControl1.Canvas;
  CloseRect := System.Types.Rect(Rect.Right - 22, Rect.Top + 6, Rect.Right - 6, Rect.Bottom - 6);

  // 1. Рисуем фон
  if Active then
    C.Brush.Color := clWhite
  else
    C.Brush.Color := $00F0F0F0;
  C.FillRect(Rect);

  SetBkMode(C.Handle, TRANSPARENT);

  if Active then
  begin
    C.Font.Color := clBlack;
    C.Font.Style := [fsBold];
  end
  else
  begin
    C.Font.Color := clDkGray;
    C.Font.Style := [];
  end;

  TextLeft := Rect.Left + 8; // Начальный отступ слева

  // 2. Рисуем иконку (если она есть)
  if Assigned(PageControl1.Images) then
  begin
    ImgIdx := PageControl1.Pages[TabIndex].ImageIndex;
    if (ImgIdx >= 0) and (ImgIdx < PageControl1.Images.Count) then
    begin
      // Вычисляем вертикальный центр для иконки
      IconY := Rect.Top + ((Rect.Bottom - Rect.Top) - PageControl1.Images.Height) div 2;
      PageControl1.Images.Draw(C, TextLeft, IconY, ImgIdx);
      // Сдвигаем текст правее, чтобы он не налез на иконку
      TextLeft := TextLeft + PageControl1.Images.Width + 6;
    end;
  end;

  // 3. Рисуем текст заголовка
  C.TextOut(TextLeft, Rect.Top + 6, PageControl1.Pages[TabIndex].Caption);

  // 4. Рисуем крестик закрытия
  Hovered := (FHoverCloseTab = TabIndex);
  if Hovered then
    C.Font.Color := clRed
  else
    C.Font.Color := clGray;

  C.Font.Name := 'Arial';
  C.Font.Size := 10;
  C.Font.Style := [fsBold];
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
      CloseRect := System.Types.Rect(TabR.Right - 22, TabR.Top + 6, TabR.Right - 6, TabR.Bottom - 6);
      if PtInRect(CloseRect, Point(X, Y)) then
      begin
        CloseTab(i);
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
    PageControl1.Invalidate;
  end;
end;

{ ================= REFRESH DASHBOARD ================= }

procedure TMainForm.RefreshDashboard;
var
  i, j: Integer;
begin
  if (PageControl1 = nil) or (PageControl1.PageCount = 0) then Exit;

  for i := 0 to PageControl1.PageCount - 1 do
  begin
    if PageControl1.Pages[i].Caption = 'Главная' then
    begin
      for j := 0 to PageControl1.Pages[i].ControlCount - 1 do
      begin
        if PageControl1.Pages[i].Controls[j] is TframeDashboard then
        begin
          TframeDashboard(PageControl1.Pages[i].Controls[j]).UpdateStats;
          Exit;
        end;
      end;
    end;
  end;
end;

end.

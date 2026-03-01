unit UnitMusor;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls;

type
  TForm2 = class(TForm)
    ListBoxNav: TListBox;
    procedure FormCreate(Sender: TObject);
    procedure ListBoxNavDrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure ListBoxNavClick(Sender: TObject);
    procedure ListBoxNavMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure ListBoxNavEnter(Sender: TObject);
    procedure ListBoxNavMouseLeave(Sender: TObject);
  private
    { Private declarations }
    FHoverIndex: Integer;

  public
    { Public declarations }
  end;

var
  Form2: TForm2;

implementation

{$R *.dfm}

procedure TForm2.FormCreate(Sender: TObject);
begin
  FHoverIndex := -1;
  ListBoxNav.OnMouseMove := ListBoxNavMouseMove;
  ListBoxNav.OnMouseLeave := ListBoxNavMouseLeave;

  // === НАСТРОЙКА ВНЕШНЕГО ВИДА ===
  ListBoxNav.Align := alLeft;
  ListBoxNav.Width := 220;
  ListBoxNav.Style := lbOwnerDrawFixed;  // Обязательно!
  ListBoxNav.ItemHeight := 36;           // Высота пункта
  ListBoxNav.BorderStyle := bsNone;      // Без рамки
  ListBoxNav.Color := RGB(250, 250, 250);
  ListBoxNav.TabStop := False;           // Убрать синюю рамку фокуса

  // Пункты меню
  ListBoxNav.Items.Clear;
  ListBoxNav.Items.Add('🏠 Главная');
  ListBoxNav.Items.Add('👤 Сотрудники');
  ListBoxNav.Items.Add('💰 Зарплата');
  ListBoxNav.Items.Add('📊 Отчёты');
  ListBoxNav.Items.Add('⚙️ Настройки');

  ListBoxNav.ItemIndex := 0;
end;

procedure TForm2.ListBoxNavClick(Sender: TObject);
begin
//  case ListBoxNav.ItemIndex of
//    0: ShowMainPage;
//    1: ShowEmployeesPage;
//    2: ShowSalaryPage;
//    3: ShowReportsPage;
//    4: ShowSettingsPage;
//  end;
end;

procedure TForm2.ListBoxNavDrawItem(Control: TWinControl; Index: Integer;
  Rect: TRect; State: TOwnerDrawState);
var
  ListBox: TListBox;
  Text: string;
  TextRect: TRect;
  StripRect: TRect; // для полоски
begin
  ListBox := TListBox(Control);
  Text := ListBox.Items[Index];
  // Цвета
  if odSelected in State then
  begin
    ListBox.Canvas.Brush.Color := RGB(0, 120, 215);
    ListBox.Canvas.Font.Color := clWhite;
    ListBox.Canvas.Font.Style := [fsBold];
  end
  else
  begin
    ListBox.Canvas.Brush.Color := ListBox.Color;
    ListBox.Canvas.Font.Color := RGB(60, 60, 60);
    ListBox.Canvas.Font.Style := [];
  end;
  // Заливаем фон
  ListBox.Canvas.FillRect(Rect);
  // Левая полоска для выделенного пункта
  if odSelected in State then
  begin
    StripRect := Rect;
    StripRect.Right := Rect.Left + 4; // ширина полоски 4 пикселя
    ListBox.Canvas.Brush.Color := RGB(0, 90, 160);
    ListBox.Canvas.FillRect(StripRect);
  end;
  // Текст
  TextRect := Rect;
  TextRect.Left := Rect.Left + 20;
  TextRect.Right := Rect.Right - 10;
  ListBox.Canvas.Font.Name := 'Segoe UI';
  ListBox.Canvas.Font.Size := 10;
  DrawText(ListBox.Canvas.Handle, PChar(Text), -1, TextRect,
    DT_LEFT or DT_VCENTER or DT_END_ELLIPSIS);
end;

procedure TForm2.ListBoxNavEnter(Sender: TObject);
begin
  // Убираем фокусную рамку
  ListBoxNav.Invalidate;
end;

procedure TForm2.ListBoxNavMouseLeave(Sender: TObject);
begin
  FHoverIndex := -1;
  ListBoxNav.Invalidate;
end;

procedure TForm2.ListBoxNavMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
var
  Index: Integer;
begin
  Index := ListBoxNav.ItemAtPos(Point(X, Y), True);
  if Index <> FHoverIndex then
  begin
    FHoverIndex := Index;
    ListBoxNav.Invalidate;
  end;

end;

{
Логика расчета отпускных:
Средний заработок = Сумма начислений за 12 мес./12

Расчет больничных
Например: до 5 лет — 60%, 5-8 лет — 80%, свыше 8 лет — 100%.


Давайте реализуем ту самую вкладку «Исторические данные» (Входящие сальдо).

Как это будет работать:

Мы создадим таблицу, где будет: Сотрудник | Месяц | Год | Сумма.

Бухгалтер один раз впишет туда данные за прошлый год (до того, как начали пользоваться программой).

Наш будущий скрипт расчета отпускных будет суммировать: (Данные из программы) + (Данные из этой таблицы).


Про расчет отпускных (Средний заработок)
Раз мы наладили ввод истории, теперь мы можем написать тот самый «умный» SQL-запрос.
Он будет складывать данные из двух разных корзин за последние 12 месяцев.

Логика запроса:

Что это дает бухгалтеру:
Даже если вы пользуетесь программой всего 2 месяца, она увидит эти 2 месяца в журнале,
а остальные 10 месяцев подтянет из вкладки «История», которую вы сейчас заполнили.
Итог — честный средний заработок!

Обычно в Туркменистане для отпускных используется коэффициент рабочих дней
(например, среднее количество дней в месяце — 29.7 или 26, уточните в вашей бухгалтерии).

Логика кнопки «Рассчитать»
В обработчике кнопки напишите код, который:

Вычисляет количество дней: Days := DaysBetween(dtpEnd.Date, dtpStart.Date) + 1;

Вызывает функцию GetAverageYearlySalary из вашего DataModule.

Делит полученную сумму на коэффициент (например, 29.7 — среднее количество дней в месяце).

Умножает результат на количество дней отпуска.

Шаг В: Сохранение данных
Кнопка «Сохранить» должна выполнить INSERT запрос в таблицу vacation_journal, используя значения из компонентов формы и результаты расчетов.

Нужно ли мне подготовить для вас готовый код функции расчета, которая объединяет текущую зарплату
и "историю" из старых записей?

}

end.

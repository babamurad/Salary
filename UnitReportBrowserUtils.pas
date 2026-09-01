unit UnitReportBrowserUtils;

// Общие функции для показа HTML-отчётов через TWebBrowser (SHDocVw) —
// компонент, который поставляется вместе с самой Delphi (пакет vclie),
// без сторонних DLL и рантаймов. Он основан на движке Internet Explorer,
// встроенном в Windows, и работает одинаково на Windows 7, 8, 10 и 11.

interface

uses
  Winapi.Windows, System.SysUtils, System.IOUtils, System.Win.Registry,
  System.Variants, Vcl.Dialogs, Vcl.Forms, SHDocVw;

// Разово (при старте программы) включает для текущего exe режим рендеринга
// "как в IE11" вместо режима совместимости с IE7, который Internet Explorer
// использует по умолчанию для встроенных (не запущенных отдельным окном)
// браузеров. Без этой настройки современный HTML/CSS в отчётах
// отображается некорректно. Это обычная запись в реестре текущего
// пользователя (HKCU) — административные права не нужны.
procedure EnsureIE11BrowserEmulation;

// Показывает готовый HTML-документ во встроенном браузере отчёта.
// HTML сохраняется во временный файл во временной папке пользователя
// (а не рядом с exe) — так печать отчётов работает, даже если программа
// установлена в папку без прав на запись (например, "Program Files").
procedure ShowHtmlInBrowser(WB: TWebBrowser; const Html: string; const CacheName: string);

// Печать документа, уже загруженного в TWebBrowser — стандартный диалог
// печати Windows/Internet Explorer.
procedure PrintBrowser(WB: TWebBrowser);

implementation

const
  // 11001 = "IE11 Edge mode" — самый современный режим рендеринга,
  // который умеет движок MSHTML, встроенный в Windows 7/8/10/11.
  IE11_EDGE_MODE = 11001;

procedure EnsureIE11BrowserEmulation;
var
  Reg: TRegistry;
  ExeName: string;
begin
  ExeName := ExtractFileName(ParamStr(0));
  Reg := TRegistry.Create(KEY_READ or KEY_WRITE);
  try
    Reg.RootKey := HKEY_CURRENT_USER;
    try
      if Reg.OpenKey('Software\Microsoft\Internet Explorer\Main\FeatureControl\FEATURE_BROWSER_EMULATION', True) then
      begin
        if (not Reg.ValueExists(ExeName)) or (Reg.ReadInteger(ExeName) <> IE11_EDGE_MODE) then
          Reg.WriteInteger(ExeName, IE11_EDGE_MODE);
        Reg.CloseKey;
      end;
    except
      // Нет доступа к реестру — не критично: отчёт всё равно откроется,
      // просто в устаревшем режиме совместимости IE7 (выглядит хуже).
    end;
  finally
    Reg.Free;
  end;
end;

procedure ShowHtmlInBrowser(WB: TWebBrowser; const Html: string; const CacheName: string);
var
  Folder, FileName, Url: string;
  ForceHandle: HWND;
begin
  // Отчёты открываются из форм, которые в момент вызова ещё скрыты
  // (создаются один раз при старте программы через Application.CreateForm
  // и показываются позже через ShowModal). У скрытого окна ActiveX-контрол
  // TWebBrowser ещё не имеет реального оконного handle — Navigate,
  // вызванный до его появления, молча "теряется", и когда форма потом
  // показывается, контрол остаётся пустым белым полем. Чтение свойства
  // Handle форсирует создание окна (и инициализацию ActiveX-объекта)
  // прямо сейчас, ещё до показа формы.
  ForceHandle := WB.Handle;
  Application.ProcessMessages;

  Folder := IncludeTrailingPathDelimiter(TPath.GetTempPath) + 'SalaryReports';
  ForceDirectories(Folder);
  FileName := IncludeTrailingPathDelimiter(Folder) + CacheName + '.html';

  // UTF-8 с BOM — Internet Explorer определяет кодировку по BOM и корректно
  // показывает кириллицу без явного <meta charset> в самом HTML-тексте.
  TFile.WriteAllText(FileName, Html, TEncoding.UTF8);

  Url := 'file:///' + StringReplace(FileName, '\', '/', [rfReplaceAll]);
  WB.Navigate(Url);
end;

procedure PrintBrowser(WB: TWebBrowser);
begin
  try
    // OLECMDID_PRINT / OLECMDEXECOPT_PROMPTUSER — стандартный вызов диалога
    // печати Internet Explorer для загруженной в браузер страницы.
    WB.ExecWB(OLECMDID_PRINT, OLECMDEXECOPT_PROMPTUSER, EmptyParam, EmptyParam);
  except
    on E: Exception do
      ShowMessage('Не удалось открыть диалог печати: ' + E.Message);
  end;
end;

end.

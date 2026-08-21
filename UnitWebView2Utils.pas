unit UnitWebView2Utils;

interface

uses
  Winapi.Windows, System.SysUtils, Vcl.Dialogs, Vcl.Edge;

const
  // Имя папки рядом с exe, куда при желании кладётся портативный
  // (Fixed Version) рантайм WebView2 — тогда программа не зависит от того,
  // установлен ли Microsoft Edge WebView2 Runtime на компьютере пользователя.
  // Скачивается на https://developer.microsoft.com/microsoft-edge/webview2/
  // (раздел "Download the WebView2 Runtime" -> "Fixed Version", архитектура x86).
  WEBVIEW2_RUNTIME_FOLDER = 'WebView2Runtime';

// Показывает понятное пользователю сообщение об ошибке инициализации WebView2
// с расшифровкой наиболее частых причин (нет рантайма / нет прав на запись).
procedure ShowWebView2Error(AResult: HRESULT);

// Если рядом с программой лежит папка WebView2Runtime с портативным
// (Fixed Version) рантаймом WebView2 — возвращает путь к ней, иначе ''.
function GetBundledWebView2RuntimeFolder: string;

// Единая точка запуска WebView2 для всех отчётных форм: задаёт папку кэша,
// при наличии портативного рантайма (см. WEBVIEW2_RUNTIME_FOLDER) указывает
// его WebView2 вместо системного, и перехватывает исключения, которые
// Vcl.Edge выбрасывает синхронно — ещё до вызова OnCreateWebViewCompleted —
// если WebView2Loader.dll не найден рядом с exe или не смог загрузиться.
// Без этой обёртки на компьютере без DLL программа либо падает
// с необработанным исключением, либо ошибка происходит "тихо".
procedure SafeCreateWebView(Edge: TEdgeBrowser; const CacheFolderName: string);

implementation

const
  // HRESULT-обёртки над стандартными кодами ошибок Win32
  E_FILE_NOT_FOUND = HRESULT($80070002);
  E_PATH_NOT_FOUND  = HRESULT($80070003);
  E_ACCESS_DENIED   = HRESULT($80070005);

procedure ShowWebView2Error(AResult: HRESULT);
var
  Msg: string;
begin
  Msg := 'Ошибка запуска WebView2 (код 0x' + IntToHex(Cardinal(AResult), 8) + ').' + sLineBreak + sLineBreak;

  if (AResult = E_FILE_NOT_FOUND) or (AResult = E_PATH_NOT_FOUND) then
    Msg := Msg +
      'Похоже, на этом компьютере не установлен Microsoft Edge WebView2 Runtime — ' +
      'компонент, необходимый для отображения отчётов, и рядом с программой ' +
      'нет портативной копии рантайма (папка ' + WEBVIEW2_RUNTIME_FOLDER + ').' + sLineBreak + sLineBreak +
      'Скачайте и установите "Evergreen Bootstrapper" с официальной страницы Microsoft:' + sLineBreak +
      'https://developer.microsoft.com/microsoft-edge/webview2/' + sLineBreak + sLineBreak +
      'После установки перезапустите программу.'
  else if AResult = E_ACCESS_DENIED then
    Msg := Msg +
      'У программы нет прав на запись в свою папку (например, она установлена в "Program Files").' + sLineBreak +
      'Переместите папку программы в место, где у пользователя есть полный доступ ' +
      '(например, C:\Salary), либо запустите программу от имени администратора.'
  else
    Msg := Msg +
      'Возможные причины:' + sLineBreak +
      '- На компьютере не установлен Microsoft Edge WebView2 Runtime ' +
      '(скачать: https://developer.microsoft.com/microsoft-edge/webview2/);' + sLineBreak +
      '- Программа установлена в папку без прав на запись (например, "Program Files") — ' +
      'переместите её в папку с полным доступом (например, C:\Salary);' + sLineBreak +
      '- Путь к программе содержит кириллицу или пробелы.';

  ShowMessage(Msg);
end;

function GetBundledWebView2RuntimeFolder: string;
var
  Candidate: string;
begin
  Candidate := IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0)) + WEBVIEW2_RUNTIME_FOLDER);
  if FileExists(Candidate + 'msedgewebview2.exe') then
    Result := Candidate
  else
    Result := '';
end;

procedure SafeCreateWebView(Edge: TEdgeBrowser; const CacheFolderName: string);
var
  RuntimeFolder: string;
begin
  Edge.UserDataFolder := ExtractFilePath(ParamStr(0)) + CacheFolderName;

  // Если рядом с программой есть портативный рантайм — используем его вместо
  // системного WebView2 Runtime. Так отчёты работают на любом компьютере,
  // даже если Evergreen-рантайм не установлен и никогда не был установлен.
  RuntimeFolder := GetBundledWebView2RuntimeFolder;
  if RuntimeFolder <> '' then
    Edge.BrowserExecutableFolder := RuntimeFolder;

  if not FileExists(ExtractFilePath(ParamStr(0)) + 'WebView2Loader.dll') then
  begin
    ShowMessage(
      'Не найден файл WebView2Loader.dll рядом с программой' + sLineBreak +
      '(' + ExtractFilePath(ParamStr(0)) + ').' + sLineBreak + sLineBreak +
      'Скопируйте WebView2Loader.dll из папки сборки (Win32\Debug или Win32\Release) ' +
      'в папку, куда установлена программа на этом компьютере, и перезапустите её.');
    Exit;
  end;

  try
    Edge.CreateWebView;
  except
    on E: Exception do
      if RuntimeFolder <> '' then
        ShowMessage(
          'Не удалось запустить компонент отображения отчётов (WebView2) ' +
          'из портативного рантайма в папке' + sLineBreak + RuntimeFolder + '.' + sLineBreak +
          E.ClassName + ': ' + E.Message + sLineBreak + sLineBreak +
          'Возможные причины:' + sLineBreak +
          '- папка ' + WEBVIEW2_RUNTIME_FOLDER + ' скопирована не полностью или повреждена ' +
          '(в ней должен быть файл msedgewebview2.exe и всё, что рядом с ним);' + sLineBreak +
          '- папка программы недоступна для записи (например, "Program Files");' + sLineBreak +
          '- файл WebView2Loader.dll повреждён или заблокирован антивирусом.')
      else
        ShowMessage(
          'Не удалось запустить компонент отображения отчётов (WebView2).' + sLineBreak +
          E.ClassName + ': ' + E.Message + sLineBreak + sLineBreak +
          'Возможные причины:' + sLineBreak +
          '- на компьютере не установлен Microsoft Edge WebView2 Runtime ' +
          '(скачать: https://developer.microsoft.com/microsoft-edge/webview2/) ' +
          'и рядом с программой нет портативного рантайма (папка ' + WEBVIEW2_RUNTIME_FOLDER + ');' + sLineBreak +
          '- папка программы недоступна для записи (например, "Program Files");' + sLineBreak +
          '- файл WebView2Loader.dll повреждён или заблокирован антивирусом.');
  end;
end;

end.

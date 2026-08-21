unit UnitWebView2Utils;

interface

uses
  Winapi.Windows, System.SysUtils, Vcl.Dialogs, Vcl.Edge;

// Показывает понятное пользователю сообщение об ошибке инициализации WebView2
// с расшифровкой наиболее частых причин (нет рантайма / нет прав на запись).
procedure ShowWebView2Error(AResult: HRESULT);

// Единая точка запуска WebView2 для всех отчётных форм: задаёт папку кэша
// и перехватывает исключения, которые Vcl.Edge выбрасывает синхронно —
// ещё до вызова OnCreateWebViewCompleted — если WebView2Loader.dll не найден
// рядом с exe или не смог загрузиться. Без этой обёртки на компьютере без DLL
// программа либо падает с необработанным исключением, либо ошибка происходит "тихо".
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
      'компонент, необходимый для отображения отчётов.' + sLineBreak + sLineBreak +
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

procedure SafeCreateWebView(Edge: TEdgeBrowser; const CacheFolderName: string);
begin
  Edge.UserDataFolder := ExtractFilePath(ParamStr(0)) + CacheFolderName;

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
      ShowMessage(
        'Не удалось запустить компонент отображения отчётов (WebView2).' + sLineBreak +
        E.ClassName + ': ' + E.Message + sLineBreak + sLineBreak +
        'Возможные причины:' + sLineBreak +
        '- на компьютере не установлен Microsoft Edge WebView2 Runtime ' +
        '(скачать: https://developer.microsoft.com/microsoft-edge/webview2/);' + sLineBreak +
        '- папка программы недоступна для записи (например, "Program Files");' + sLineBreak +
        '- файл WebView2Loader.dll повреждён или заблокирован антивирусом.');
  end;
end;

end.

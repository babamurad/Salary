unit UnitWebView2Utils;

interface

uses
  Winapi.Windows, System.SysUtils, Vcl.Dialogs;

// Показывает понятное пользователю сообщение об ошибке инициализации WebView2
// с расшифровкой наиболее частых причин (нет рантайма / нет прав на запись).
procedure ShowWebView2Error(AResult: HRESULT);

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

end.

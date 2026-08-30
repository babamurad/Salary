# Как устроены HTML-отчёты (TWebBrowser вместо Edge/WebView2)

Раньше отчёты (расчётные листки, ведомости) показывались через `TEdgeBrowser`
(Microsoft Edge WebView2). Это давало красивую вёрстку на Bootstrap, но требовало
отдельно установленный **Microsoft Edge WebView2 Runtime** — компонент, который
есть не на каждом компьютере (особенно на урезанных/старых сборках Windows),
и который в принципе [не работает на Windows 7/8/8.1](https://blogs.windows.com/msedgedev/2022/12/09/microsoft-edge-and-webview2-ending-support-for-windows-7-and-windows-8-8-1/).
Из-за этого отчёты открывались не на всех машинах.

## Новое решение: TWebBrowser (SHDocVw)

Теперь отчёты показываются через **`TWebBrowser`** — стандартный компонент,
который поставляется вместе с самой Delphi (пакет `vclie`, модуль `SHDocVw`),
без сторонних DLL, рантаймов и загрузок из интернета. Он основан на движке
Internet Explorer (MSHTML), который встроен в Windows начиная с XP, то есть
**есть абсолютно на любом компьютере с Windows 7, 8, 10 или 11** — устанавливать
ничего не нужно.

Компонент `TWebBrowser` создаётся кодом (а не кладётся на форму в дизайнере),
чтобы не тащить в .dfm бинарные данные ActiveX-контрола — см.
`FormCreate`/конструктор в каждой из форм отчётов.

### Режим рендеринга (IE11 Edge mode)

По умолчанию встроенный в Windows Internet Explorer показывает вставленные
в приложения страницы в устаревшем режиме совместимости с IE7 — современный
CSS в этом режиме выглядит сломанным. Чтобы этого избежать, программа при
старте один раз выставляет для своего exe в реестре текущего пользователя
(`HKCU\...\FeatureControl\FEATURE_BROWSER_EMULATION`) режим "IE11 Edge mode"
(значение `11001`) — см. `UnitReportBrowserUtils.EnsureIE11BrowserEmulation`,
вызывается из `Salary.dpr` перед созданием форм. Права администратора для
этого не нужны, это обычная запись в реестре текущего пользователя.

### Как показывается HTML

`UnitReportBrowserUtils.ShowHtmlInBrowser` сохраняет готовый HTML во временный
файл в папке `%TEMP%\SalaryReports\` (а не рядом с exe — так печать работает,
даже если программа установлена в папку без прав на запись, например
"Program Files") и открывает его через `WebBrowser.Navigate('file:///...')`.

### Печать

`UnitReportBrowserUtils.PrintBrowser` вызывает стандартный диалог печати
Internet Explorer/Windows через `WebBrowser.ExecWB(OLECMDID_PRINT, ...)` —
это встроенный, документированный способ печати документа, загруженного
в `TWebBrowser`.

## CSS отчётов: `assets\report.css` вместо Bootstrap

Bootstrap 5 активно использует CSS-переменные и flexbox-сетку, которые движок
Internet Explorer (в отличие от WebView2/Chromium) не поддерживает — с ним
вёрстка "поехала" бы. Поэтому вместо Bootstrap теперь используется свой,
простой CSS-файл `Win32\Debug\assets\report.css` (копируется рядом с exe
при развёртывании, как раньше `bootstrap.min.css`).

Он специально использует **те же имена классов**, что и раньше (`table`,
`text-danger`, `card`, `col-6` и т.д.) — HTML-код отчётов в
`UnitReportPayroll.pas`, `UnitFrameReportSummary.pas`, `UnitPaySlip.pas`
трогать не пришлось, поменялся только путь к CSS-файлу и сам файл.
Внутри — только старый добрый CSS (float-сетка, обычные свойства), который
одинаково понятен и IE11, и любому современному браузеру.

## Что было удалено

- `UnitWebView2Utils.pas` → заменён на `UnitReportBrowserUtils.pas`.
- Пакет `vcledge` убран из зависимостей проекта (`Salary.dproj`).
- `Win32\Debug\WebView2Loader.dll` и весь `Win32\Debug\assets\css` /
  `Win32\Debug\assets\js` (файлы Bootstrap) — больше не нужны и удалены
  из репозитория.
- Git LFS для `WebView2Runtime/**` (см. старый `DEPLOY_WEBVIEW2.md`,
  который этот файл заменяет) — рантайм WebView2 в проекте больше не
  используется, LFS-настройка в `.gitattributes` убрана.

## Проверка

1. Собрать проект в Delphi (пакет `vclie`, дающий `SHDocVw`/`TWebBrowser`,
   уже входит в стандартную поставку RAD Studio).
2. Скопировать `Salary.exe` и папку `assets` (с `report.css`) на любой
   компьютер с Windows 7/8/10/11 — без установки WebView2 Runtime,
   Edge или чего-либо ещё.
3. Открыть любой отчёт — он должен открыться и печататься как обычно.

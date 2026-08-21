# Как сделать так, чтобы отчёты (WebView2) работали на любом компьютере

По умолчанию `TEdgeBrowser` использует **Evergreen** WebView2 Runtime — компонент,
который должен быть установлен отдельно на каждом компьютере (обычно он уже
стоит вместе с Windows 11 и свежими сборками Windows 10, но на части машин
его нет, и это ломает все отчётные формы).

Начиная с этого коммита программа умеет работать и без установленного
рантайма — если положить рядом с `Salary.exe` папку `WebView2Runtime`
с портативной сборкой WebView2 (**Fixed Version**). Если эта папка есть —
используется она, и наличие/версия рантайма на компьютере пользователя
уже не важны. Если папки нет — программа, как и раньше, использует системный
Evergreen-рантайм.

## 1. Скачать Fixed Version рантайм

1. Открыть https://developer.microsoft.com/microsoft-edge/webview2/
2. В разделе «Download the WebView2 Runtime» выбрать **Fixed Version**,
   архитектуру **x86** (проект собирается только под Win32).
3. Скачается архив `.cab` вида
   `Microsoft.WebView2.FixedVersionRuntime.<версия>.x86.cab`.
4. Распаковать его (Windows `.cab` не открывается двойным щелчком как zip):
   - через 7-Zip: правая кнопка → «Извлечь файлы…»;
   - либо командой `expand -F:* Microsoft.WebView2.FixedVersionRuntime.<версия>.x86.cab .\WebView2Runtime`.
5. Внутри должна получиться папка, где прямо на верхнем уровне лежит
   `msedgewebview2.exe` (и рядом с ним — `icudtl.dat`, `*.pak`, `EBWebView`
   и т.д.). Именно эту папку и нужно переименовать/положить как `WebView2Runtime`.

## 2. Разложить файлы рядом с программой

Итоговая структура папки с установленной программой должна выглядеть так:

```
Salary.exe
WebView2Loader.dll          <- уже есть в репозитории (Win32\Debug)
WebView2Runtime\
    msedgewebview2.exe
    icudtl.dat
    ...остальные файлы из Fixed Version архива...
```

`WebView2Runtime` в git не хранится (см. `.gitignore`) — это тяжёлый
(150–200 МБ) бинарный редистрибутив Microsoft, его нужно докладывать
на этапе сборки инсталлятора/архива для раздачи пользователям, а не коммитить.

## 3. Как это работает в коде

`UnitWebView2Utils.SafeCreateWebView` (используется всеми формами с отчётами)
перед запуском WebView2 проверяет, есть ли рядом с exe папка `WebView2Runtime`
с `msedgewebview2.exe`, и если да — выставляет
`Edge.BrowserExecutableFolder` на неё перед `Edge.CreateWebView`. Это
официальный механизм WebView2 SDK для «портативного» режима без установки
рантайма в систему (см. документацию Microsoft: "Fixed Version" distribution
mode, параметр `browserExecutableFolder` /
`Vcl.Edge.TCustomEdgeBrowser.BrowserExecutableFolder`).

Если папки `WebView2Runtime` нет — поведение не меняется: используется
системный Evergreen-рантайм, как и раньше.

## 4. Проверка

1. Собрать проект.
2. Скачать и разложить `WebView2Runtime`, как описано выше.
3. Скопировать `Salary.exe`, `WebView2Loader.dll` и `WebView2Runtime`
   на "чистый" компьютер без установленного Microsoft Edge WebView2 Runtime
   (в новых Windows его можно временно удалить через
   «Установка и удаление программ» → Microsoft Edge WebView2 Runtime,
   чтобы проверить сценарий).
4. Открыть любой отчёт — он должен открыться без установки чего-либо
   дополнительно.

## 5. Дальнейшие обновления версии

Fixed Version рантайм не обновляется автоматически (в отличие от Evergreen).
При обновлении версии WebView2 SDK/рантайма достаточно скачать новый архив
и заменить содержимое папки `WebView2Runtime` в дистрибутиве — код менять
не нужно.

unit UnitCompanyInfo;

// Небольшой хелпер для чтения значений из справочника company_info
// (реквизиты организации: банк, счета, коды и т.д. — редактируются в
// настройках, на вкладке "Компания"). Общий для всех печатных форм и
// отчётов, которым нужны эти данные в шапке, чтобы не дублировать один и
// тот же SELECT в каждом отчёте.

interface

function GetCompanyInfoValue(const AKey: string; const ADefault: string = ''): string;

implementation

uses
  System.SysUtils, FireDAC.Comp.Client, UnitdmMain;

function GetCompanyInfoValue(const AKey: string; const ADefault: string): string;
var
  Q: TFDQuery;
begin
  Result := ADefault;
  if not Assigned(dmMain) or not dmMain.conn.Connected then
    Exit;

  Q := TFDQuery.Create(nil);
  try
    Q.Connection := dmMain.conn;
    Q.SQL.Text := 'SELECT key_value FROM company_info WHERE key_name = :k';
    Q.ParamByName('k').AsString := AKey;
    Q.Open;
    if not Q.IsEmpty and not Q.FieldByName('key_value').IsNull then
    begin
      Result := Q.FieldByName('key_value').AsString;
      if Result = '' then
        Result := ADefault;
    end;
  finally
    Q.Free;
  end;
end;

end.

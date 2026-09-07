unit UnitPayrollCalc;

interface

uses
  System.Math;

type
  // Входные данные для расчёта одного сотрудника за период — либо взятые
  // "по умолчанию" (из employees/settings, как раньше), либо поправленные
  // бухгалтером вручную на форме детализации. Формула одна и та же в обоих
  // случаях — это единственное место, где она реализована, чтобы массовый
  // расчёт (UnitframePayroll.btnCalcClick) и точечное редактирование
  // (UnitPayrollDetail) не могли разъехаться.
  TPayrollCalcInputs = record
    WorkDays: Double;      // отработано дней (справочно, в саму формулу не входит)
    WorkHours: Double;     // отработано часов — фактические часы для расчёта
    NormHours: Double;     // норма часов за месяц
    WageType: Integer;     // 0 = оклад, 1 = часовая ставка
    WorkFraction: Double;  // ставка (доля от полной, напр. 0.5)
    HourlyRateDB: Double;  // часовая ставка из карточки сотрудника (если WageType=1)
    BaseSalary: Double;    // оклад (если WageType=0)
    IsRotation: Integer;
    RotationRate: Double;  // % надбавки за вахтовый метод
    ClassRank: Integer;    // 0/1/2/3
    ClassRate: Double;     // % надбавки за классность (для указанного ClassRank)
    PensionRate: Double;   // % пенсионного взноса
    IsTradeUnion: Integer;
    UnionRate: Double;     // % профсоюзного взноса
    IsTaxExempt: Integer;
    TaxRate: Double;       // % подоходного налога
    DepCount: Integer;     // кол-во иждивенцев
    DepDeduction: Double;  // вычет на 1 иждивенца из базы налога
    AlimonyPct: Double;    // % алиментов
  end;

  TPayrollCalcResult = record
    HourlyRate: Double;
    RegularHours, OvertimeHours: Double;
    BaseGross: Double;        // оплата за отработанное время (с учётом сверхурочных x2)
    RotationBonus: Double;
    ClassBonus: Double;
    TotalGross: Double;       // = BaseGross + RotationBonus + ClassBonus
    TaxBase: Double;
    Tax: Double;
    Pension: Double;
    UnionAmount: Double;
    NetBeforeAlimony: Double;
    AlimonyAmount: Double;
    Net: Double;
  end;

function CalcPayroll(const Inp: TPayrollCalcInputs): TPayrollCalcResult;

implementation

function CalcPayroll(const Inp: TPayrollCalcInputs): TPayrollCalcResult;
var
  WorkFrac: Double;
begin
  WorkFrac := Inp.WorkFraction;
  if WorkFrac <= 0 then WorkFrac := 1.0; // Защита

  // --- 1. СТОИМОСТЬ ЧАСА ---
  if Inp.WageType = 1 then
    Result.HourlyRate := Inp.HourlyRateDB
  else if Inp.NormHours > 0 then
    Result.HourlyRate := (Inp.BaseSalary * WorkFrac) / Inp.NormHours
  else
    Result.HourlyRate := 0;

  // --- 2. ЧАСЫ ---
  if Inp.WorkHours > Inp.NormHours then
  begin
    Result.RegularHours := Inp.NormHours;
    Result.OvertimeHours := Inp.WorkHours - Inp.NormHours;
  end
  else
  begin
    Result.RegularHours := Inp.WorkHours;
    Result.OvertimeHours := 0;
  end;

  // --- 3. БАЗА ---
  Result.BaseGross := SimpleRoundTo(
    (Result.RegularHours * Result.HourlyRate) + (Result.OvertimeHours * Result.HourlyRate * 2.0), -2);

  // --- 4. НАДБАВКИ ---
  Result.RotationBonus := 0;
  if Inp.IsRotation = 1 then
    Result.RotationBonus := SimpleRoundTo(Result.BaseGross * (Inp.RotationRate / 100.0), -2);

  Result.ClassBonus := 0;
  if Inp.ClassRank in [1, 2, 3] then
    Result.ClassBonus := SimpleRoundTo(Result.BaseGross * (Inp.ClassRate / 100.0), -2);

  Result.TotalGross := Result.BaseGross + Result.RotationBonus + Result.ClassBonus;

  // --- 5. УДЕРЖАНИЯ (до вычета алиментов) ---
  Result.Pension := SimpleRoundTo((Result.TotalGross * Inp.PensionRate) / 100.0, -2);

  Result.UnionAmount := 0;
  if Inp.IsTradeUnion = 1 then
    Result.UnionAmount := SimpleRoundTo(Result.TotalGross * (Inp.UnionRate / 100.0), -2);

  if Inp.IsTaxExempt = 1 then
  begin
    Result.Tax := 0;
    Result.TaxBase := 0;
  end
  else
  begin
    Result.TaxBase := Result.BaseGross - (Inp.DepCount * Inp.DepDeduction);
    Result.Tax := SimpleRoundTo(Max(0, Result.TaxBase * Inp.TaxRate / 100.0), -2);
  end;

  // --- 6. АЛИМЕНТЫ (строго после налогов) ---
  Result.NetBeforeAlimony := Result.TotalGross - Result.Tax - Result.Pension - Result.UnionAmount;
  Result.AlimonyAmount := 0;
  if Inp.AlimonyPct > 0 then
    Result.AlimonyAmount := SimpleRoundTo(Result.NetBeforeAlimony * (Inp.AlimonyPct / 100.0), -2);

  // --- 7. К ВЫПЛАТЕ ---
  Result.Net := SimpleRoundTo(Result.NetBeforeAlimony - Result.AlimonyAmount, -2);
end;

end.

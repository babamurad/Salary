program Salary;

uses
  Vcl.Forms,
  Vcl.Controls,
  Main in 'Main.pas' {MainForm},
  UnitdmMain in 'UnitdmMain.pas' {dmMain: TDataModule},
  UnitframeEmployees in 'UnitframeEmployees.pas' {frameEmployees: TFrame},
  UnitMusor in 'UnitMusor.pas' {Form2},
  UnitframeReports in 'UnitframeReports.pas' {frameReports: TFrame},
  UnitframePayroll in 'UnitframePayroll.pas' {framePayroll: TFrame},
  UnitBaseEditForm in 'UnitBaseEditForm.pas' {frmBaseEdit},
  UnitframeDepts in 'UnitframeDepts.pas' {frameDepts: TFrame},
  UnitframePositions in 'UnitframePositions.pas' {framePositions: TFrame},
  UnitframeSettings in 'UnitframeSettings.pas' {frameSettings: TFrame},
  UnitframeVacation in 'UnitframeVacation.pas' {frameVacation: TFrame},
  UnitVacationCalc in 'UnitVacationCalc.pas' {FormVacationCalc},
  UnitSickLeaveCalc in 'UnitSickLeaveCalc.pas' {FormSickLeaveCalc},
  UnitframeSickLeave in 'UnitframeSickLeave.pas' {frameSickLeave: TFrame},
  UnitframeDashboard in 'UnitframeDashboard.pas' {frameDashboard: TFrame},
  UnitframeCalendar in 'UnitframeCalendar.pas' {frameCalendar: TFrame},
  UnitFormHelp in 'UnitFormHelp.pas' {FormHelp},
  UnitframeTimesheet in 'UnitframeTimesheet.pas' {frameTimesheet: TFrame},
  UnitPaySlip in 'UnitPaySlip.pas' {frmPaySlip},
  UnitReportPayroll in 'UnitReportPayroll.pas' {frmReportPayroll},
  UnitFrameReportSummary in 'UnitFrameReportSummary.pas' {FrameReportSummary: TFrame},
  UnitFrameVacations in 'UnitFrameVacations.pas' {frameVacations: TFrame},
  UnitHtmlPreview in 'UnitHtmlPreview.pas' {frmHtmlPreview},
  UnitLogin in 'UnitLogin.pas' {frmLogin};

{$R *.res}

var
  LoginForm: TfrmLogin; // Создаем переменную для окна логина

begin
  Application.Initialize;
  // 1. Первым делом поднимаем базу данных (чтобы логин мог проверить пароль)
  Application.CreateForm(TdmMain, dmMain);

  // --- 2. ЖЕЛЕЗОБЕТОННЫЙ ВЫЗОВ ЛОГИНА ---
  LoginForm := TfrmLogin.Create(nil);
  try
    if LoginForm.ShowModal <> mrOk then
    begin
      Application.Terminate;
      Exit; // Пароль неверный - жестко прерываем запуск программы!
    end;
  finally
    LoginForm.Free;
  end;
  // --------------------------------------

  // 3. Если код дошел сюда (пароль верный) - строим интерфейс!
  Application.CreateForm(TMainForm, MainForm);

  Application.CreateForm(TMainForm, MainForm);
  Application.CreateForm(TfrmPaySlip, frmPaySlip);
  Application.CreateForm(TfrmReportPayroll, frmReportPayroll);
  Application.CreateForm(TfrmHtmlPreview, frmHtmlPreview);
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainForm, MainForm);
  Application.CreateForm(TdmMain, dmMain);
  Application.CreateForm(TForm2, Form2);
  Application.CreateForm(TfrmBaseEdit, frmBaseEdit);
  Application.CreateForm(TFormVacationCalc, FormVacationCalc);
  Application.CreateForm(TFormSickLeaveCalc, FormSickLeaveCalc);
  Application.Run;
end.

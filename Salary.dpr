program Salary;

uses
  Vcl.Forms,
  Main in 'Main.pas' {MainForm},
  UnitdmMain in 'UnitdmMain.pas' {dmMain: TDataModule},
  UnitframeEmployees in 'UnitframeEmployees.pas' {frameEmployees: TFrame},
  UnitMusor in 'UnitMusor.pas' {Form2},
  UnitframeReports in 'UnitframeReports.pas' {frameReports: TFrame},
  UnitframePayroll in 'UnitframePayroll.pas' {framePayroll: TFrame},
  UnitBaseEditForm in 'UnitBaseEditForm.pas' {frmBaseEdit},
  UnitEditEmployee in 'UnitEditEmployee.pas' {frmEditEmployee},
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
  UnitPaySlip in 'UnitPaySlip.pas' {frmPaySlip};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TdmMain, dmMain);
  Application.CreateForm(TMainForm, MainForm);
  Application.CreateForm(TfrmPaySlip, frmPaySlip);
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainForm, MainForm);
  Application.CreateForm(TdmMain, dmMain);
  Application.CreateForm(TForm2, Form2);
  Application.CreateForm(TfrmBaseEdit, frmBaseEdit);
  Application.CreateForm(TfrmEditEmployee, frmEditEmployee);
  Application.CreateForm(TFormVacationCalc, FormVacationCalc);
  Application.CreateForm(TFormSickLeaveCalc, FormSickLeaveCalc);
  Application.Run;
end.

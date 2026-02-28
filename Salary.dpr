program Salary;

uses
  Vcl.Forms,
  Main in 'Main.pas' {Form1},
  UnitdmMain in 'UnitdmMain.pas' {dmMain: TDataModule},
  UnitframeEmployees in 'UnitframeEmployees.pas' {frameEmployees: TFrame},
  UnitMusor in 'UnitMusor.pas' {Form2},
  UnitframeReports in 'UnitframeReports.pas' {frameReports: TFrame},
  UnitframePayroll in 'UnitframePayroll.pas' {framePayroll: TFrame},
  UnitBaseEditForm in 'UnitBaseEditForm.pas' {frmBaseEdit},
  UnitEditEmployee in 'UnitEditEmployee.pas' {frmEditEmployee},
  UnitframeDepts in 'UnitframeDepts.pas' {frameDepts: TFrame},
  UnitframePositions in 'UnitframePositions.pas' {framePositions: TFrame},
  UnitframeSettings in 'UnitframeSettings.pas' {frameSettings: TFrame};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm1, Form1);
  Application.CreateForm(TdmMain, dmMain);
  Application.CreateForm(TForm2, Form2);
  Application.CreateForm(TfrmBaseEdit, frmBaseEdit);
  Application.CreateForm(TfrmEditEmployee, frmEditEmployee);
  Application.Run;
end.

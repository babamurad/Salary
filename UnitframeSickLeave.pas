unit UnitframeSickLeave;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Data.DB,
  Vcl.Grids, Vcl.DBGrids, Vcl.StdCtrls;

type
  TframeSickLeave = class(TFrame)
    Panel1: TPanel;
    btnNewCalc: TButton;
    DBGrid1: TDBGrid;
    procedure btnNewCalcClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

implementation

{$R *.dfm}

uses UnitdmMain, UnitSickLeaveCalc;

procedure TframeSickLeave.btnNewCalcClick(Sender: TObject);
var
  Frm: TFormSickLeaveCalc;
begin
  Frm := TFormSickLeaveCalc.Create(Self);
  try
    // Открываем окно. Если расчет сохранен успешно (mrOk), обновляем таблицу
    if Frm.ShowModal = mrOk then
    begin
      if dmMain.qrySickLeave.Active then
        dmMain.qrySickLeave.Refresh
      else
        dmMain.qrySickLeave.Open;
    end;
  finally
    Frm.Free;
  end;
end;

end.

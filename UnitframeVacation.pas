unit UnitframeVacation;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  Data.DB, Vcl.Grids, Vcl.DBGrids;

type
  TframeVacation = class(TFrame)
    Panel1: TPanel;
    btnNewCalc: TButton;
    DBGrid1: TDBGrid;
    procedure btnNewCalcClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;

implementation

{$R *.dfm}

uses UnitVacationCalc, UnitdmMain, UnitGridPersist;

procedure TframeVacation.btnNewCalcClick(Sender: TObject);
var
  Frm: TFormVacationCalc;
begin
  Frm := TFormVacationCalc.Create(Self);
  try
    // Если окно закрылось с ModalResult := mrOk (то есть сохранение прошло успешно)
    if Frm.ShowModal = mrOk then
    begin
      // Обновляем таблицу, чтобы бухгалтер сразу увидел новый отпуск
      dmMain.qryVacation.Refresh;
    end;
  finally
    Frm.Free;
  end;

end;

constructor TframeVacation.Create(AOwner: TComponent);
begin
  inherited;
  // Столбцы этого грида заданы на этапе разработки (персистентные Columns
  // в .dfm), поэтому они уже существуют к этому моменту.
  LoadGridColumnWidths(DBGrid1, 'Vacation');
end;

destructor TframeVacation.Destroy;
begin
  SaveGridColumnWidths(DBGrid1, 'Vacation');
  inherited;
end;

end.

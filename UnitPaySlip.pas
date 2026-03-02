unit UnitPaySlip;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Data.DB,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls;

type
  TfrmPaySlip = class(TForm)
    lblFIO: TLabel;
    lblPeriod: TLabel;
    lblBaseSalary: TLabel;
    lblGross: TLabel;
    lblTax: TLabel;
    lblPension: TLabel;
    lblNet: TLabel;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Bevel1: TBevel;
    lblDept: TLabel;
    lblPosition: TLabel;
    btnPrint: TButton;
    procedure btnPrintClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure LoadFromDataset(Dataset: TDataSet; PeriodStr: string);
  end;

var
  frmPaySlip: TfrmPaySlip;

implementation

{$R *.dfm}

{ TfrmPaySlip }

procedure TfrmPaySlip.btnPrintClick(Sender: TObject);
begin
  // 1. Прячем саму кнопку, чтобы она не распечаталась на бумаге
  btnPrint.Visible := False;
  try
    // 2. Отправляем внешний вид окна прямо на принтер по умолчанию!
    Self.Print;
  finally
    // 3. Возвращаем кнопку на место
    btnPrint.Visible := True;
  end;
end;

procedure TfrmPaySlip.LoadFromDataset(Dataset: TDataSet; PeriodStr: string);
begin
  lblPeriod.Caption := 'Расчетный листок за: ' + PeriodStr;
  lblPeriod.Font.Style := [fsBold];

  lblFIO.Caption := 'Сотрудник: ' + Dataset.FieldByName('fio').AsString;
  lblFIO.Font.Style := [fsBold];

  // --- НОВЫЕ СТРОЧКИ ДЛЯ ОТДЕЛА И ДОЛЖНОСТИ ---
  lblDept.Caption := 'Отдел: ' + Dataset.FieldByName('dept_name').AsString;
  lblPosition.Caption := 'Должность: ' + Dataset.FieldByName('pos_name').AsString;

  // ... дальше ваш код с суммами и налогами остается без изменений ...
  lblBaseSalary.Caption := FormatFloat('#,##0.00 TMT', Dataset.FieldByName('base_salary').AsFloat);
  lblGross.Caption := FormatFloat('#,##0.00 TMT', Dataset.FieldByName('gross_amount').AsFloat);

  lblTax.Caption := FormatFloat('- #,##0.00 TMT', Dataset.FieldByName('tax_amount').AsFloat);
  lblTax.Font.Color := clMaroon;

  lblPension.Caption := FormatFloat('- #,##0.00 TMT', Dataset.FieldByName('pension_amount').AsFloat);
  lblPension.Font.Color := clMaroon;

  lblNet.Caption := FormatFloat('#,##0.00 TMT', Dataset.FieldByName('net_amount').AsFloat);
end;

end.

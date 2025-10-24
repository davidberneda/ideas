unit UnitThreads;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls;

type
  TTest<T>=record
  private
    const
      QUANTITY = {$IFDEF CPUX64}50_000_000{$ELSE}10_000_000{$ENDIF}; // 3GB max in 32bit

    var
      Items : Array of T;
  public
    procedure Init;
    procedure Multi(const Value:T);
    procedure Simple(const Value:T);
  end;

  TFormThreads = class(TForm)
    Memo1: TMemo;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }

    procedure RunTest<T>(const Test:TTest<T>; const Value:T);
  end;

var
  FormThreads: TFormThreads;

implementation

{$R *.dfm}

uses
  System.Diagnostics, System.Threading;

procedure TTest<T>.Init;
begin
  SetLength(Items,QUANTITY);
end;

procedure TTest<T>.Multi(const Value:T);
var
  workerCount: Integer;
  workers: TArray<ITask>;
  i, min, max: Integer;
  _Items : Array of T;
begin
  workerCount := TThread.ProcessorCount;
  SetLength(workers, workerCount);

  _Items:=Items;

  for i := 0 to workerCount - 1 do
  begin
    min := (QUANTITY div workerCount) * i;

    if i + 1 < workerCount then
       max := QUANTITY div workerCount * (i + 1) - 1
    else
       max := QUANTITY - 1;

    workers[i] := TTask.Run(
      procedure
      var Index : Integer;
      begin
        for Index:=Min to Max do
            _Items[Index]:=Value;
      end)
  end;

  TTask.WaitForAll(workers);
end;

procedure TTest<T>.Simple(const Value:T);
var Index : Integer;
begin
  for Index:=0 to QUANTITY-1 do
      Items[Index]:=Value;
end;

procedure TFormThreads.RunTest<T>(const Test:TTest<T>; const Value:T);
var t1 : TStopwatch;
begin
  Test.Init;

  t1:=TStopwatch.StartNew;

  Test.Simple(Value);
  Memo1.Lines.Add('Simple: '+t1.ElapsedMilliseconds.ToString);

  t1:=TStopwatch.StartNew;

  Test.Multi(Value);
  Memo1.Lines.Add('Multi: '+t1.ElapsedMilliseconds.ToString);
end;

type
  TFoo=record
    A,B,C: Integer;
    D : Double;
    E : Extended;
    S : Single;
  end;

const
  Foo : TFoo=(A:1; B:2; C:3; D:3.14; E:4.15; S:6.7);

procedure TFormThreads.FormCreate(Sender: TObject);
var D : TTest<TFoo>;
    S : TTest<String>;
begin
  Memo1.Clear;

  RunTest<TFoo>(D,Foo);  // Multi-cpu is 500% FASTER than single cpu
  RunTest<String>(S,'Hello');   // Multi-cpu is 300% SLOWER than single cpu
end;

end.

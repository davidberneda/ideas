unit UnitThreads;

interface

{
  See this thread, with hints and fixes by Mr. Stefan Glienke

  https://en.delphipraxis.net/topic/14612-string-type-breaks-threading-speed-how-to-solve
}

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

    procedure Check(const Value:T);
    class function GetWorker(min, max: Integer; const items: TArray<T>; const value: T): TProc; static;
  public
    procedure Init;
    procedure Multi(const Value:T);
    procedure Simple(const Min,Max:Integer; const Value:T);
  end;

  TFormThreads = class(TForm)
    Memo1: TMemo;
    Button1: TButton;
    procedure FormCreate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }

    procedure RunTest<T>(const Test:TTest<T>; const Value:T);
    procedure RunTests;
  public
    { Public declarations }

  end;

var
  FormThreads: TFormThreads;

implementation

{$R *.dfm}

uses
  System.Diagnostics, System.Threading, System.TypInfo;

procedure TTest<T>.Check;
var Index : Integer;
begin
  if GetTypeKind(T) = tkRecord then
  begin
    for Index:=0 to QUANTITY-1 do
        if not CompareMem(@Items[Index],@Value,SizeOf(Value)) then
           raise Exception.Create('FAIL');
  end
  else
  for Index:=0 to QUANTITY-1 do
      if Items[Index]<>Value then
         raise Exception.Create('FAIL');
end;

class function TTest<T>.GetWorker(min, max: Integer; const items: TArray<T>; const value: T): TProc;
var _items: TArray<T>;
begin
  _items := items;

  if GetTypeKind(T) = tkUString then
     UniqueString(PString(@value)^);

//  {$R-,Q-}

  Result := procedure
    var Index : Integer;
    begin
      for Index:=Min to Max do
          _items[Index]:=Value;
    end;
end;

procedure TTest<T>.Init;
begin
  SetLength(Items,QUANTITY);
end;

procedure TTest<T>.Multi(const Value:T);
var
  workerCount: Integer;
  workers: TArray<ITask>;
  i, min, max: Integer;
begin
  workerCount := TThread.ProcessorCount;
  SetLength(workers, workerCount);

  for i := 0 to workerCount - 1 do
  begin
    min := (QUANTITY div workerCount) * i;

    if i + 1 < workerCount then
       max := QUANTITY div workerCount * (i + 1) - 1
    else
       max := QUANTITY - 1;

    workers[i] := TTask.Run(GetWorker(min, max, items, value));
  end;

  TTask.WaitForAll(workers);
end;

procedure TTest<T>.Simple(const Min,Max:Integer; const Value:T);
var P : TProc;
begin
  P:=GetWorker(min, max, items, value);
  P();
end;

procedure TFormThreads.RunTest<T>(const Test:TTest<T>; const Value:T);
var t1 : TStopwatch;
begin
  Memo1.Lines.Add(GetTypeName(TypeInfo(T)));

  Test.Init;

  t1:=TStopwatch.StartNew;

  Test.Simple(0,Test.QUANTITY-1,Value);
  Memo1.Lines.Add('Simple: '+t1.ElapsedMilliseconds.ToString);

  Test.Check(Value);

  Test.Simple(0,Test.QUANTITY-1,Default(T)); // Reset

  t1:=TStopwatch.StartNew;

  Test.Multi(Value);
  Memo1.Lines.Add('Multi: '+t1.ElapsedMilliseconds.ToString);

  Test.Check(Value);

  Memo1.Lines.Add('');
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

procedure TFormThreads.RunTests;
var F : TTest<TFoo>;
    S : TTest<String>;
    D : TTest<Double>;
begin
  Memo1.Clear;

  RunTest<TFoo>(F,Foo);
  RunTest<Double>(D,3.1415);
  RunTest<String>(S,'Hello');
end;

procedure TFormThreads.Button1Click(Sender: TObject);
begin
  RunTests;
end;

procedure TFormThreads.FormCreate(Sender: TObject);
begin
  RunTests;
end;

end.

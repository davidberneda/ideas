unit UnitThreadsString;

interface

{
  See this thread, with hints and fixes by Mr. Stefan Glienke

  https://en.delphipraxis.net/topic/14612-string-type-breaks-threading-speed-how-to-solve
}

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls;

type
  TTest=record
  private
    const
      QUANTITY = {$IFDEF CPUX64}50_000_000{$ELSE}10_000_000{$ENDIF}; // 3GB max in 32bit

    var
      Items : TArray<String>;

    procedure Check(const Value:String);
    class function GetWorker(min, max: Integer; const items: TArray<String>; const value: String): TProc; static;
  public
    procedure Init;
    procedure Multi(const Value:String);
    procedure Simple(const Min,Max:Integer; const Value:String);
  end;

  TFormThreads2 = class(TForm)
    Memo1: TMemo;
    Button1: TButton;
    procedure FormCreate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }

    procedure RunTestString(const Test:TTest; const Value:String);
    procedure RunTests;
  public
    { Public declarations }

  end;

var
  FormThreads2: TFormThreads2;

implementation

{$R *.dfm}

uses
  System.Diagnostics, System.Threading, System.TypInfo;

procedure TTest.Check;
var Index : Integer;
begin
  for Index:=0 to QUANTITY-1 do
      if Items[Index]<>Value+'a' then
         raise Exception.Create('FAIL');
end;

class function TTest.GetWorker(min, max: Integer; const items: TArray<String>; const value: String): TProc;
var _items: TArray<String>;
begin
  _items := items;

  UniqueString(PString(@value)^);

//  {$R-,Q-}

  Result := procedure
    var Index : Integer;
    begin
      for Index:=Min to Max do
          _items[Index]:=Value+'a';  // <-----
    end;
end;

procedure TTest.Init;
begin
  SetLength(Items,QUANTITY);
end;

procedure TTest.Multi(const Value:String);
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

procedure TTest.Simple(const Min,Max:Integer; const Value:String);
var P : TProc;
begin
  P:=GetWorker(min, max, items, value);
  P();
end;

procedure TFormThreads2.RunTestString(const Test:TTest; const Value:String);
var t1 : TStopwatch;
begin
  Memo1.Lines.Add('String');

  Test.Init;

  t1:=TStopwatch.StartNew;

  Test.Simple(0,Test.QUANTITY-1,Value);
  Memo1.Lines.Add('Simple: '+t1.ElapsedMilliseconds.ToString);

  Test.Check(Value);

  Test.Simple(0,Test.QUANTITY-1,''); // Reset

  t1:=TStopwatch.StartNew;

  Test.Multi(Value);
  Memo1.Lines.Add('Multi: '+t1.ElapsedMilliseconds.ToString);

  Test.Check(Value);

  Memo1.Lines.Add('');
end;

procedure TFormThreads2.RunTests;
var T : TTest;
begin
  Memo1.Clear;

  RunTestString(T,'Hello');
end;

procedure TFormThreads2.Button1Click(Sender: TObject);
begin
  RunTests;
end;

procedure TFormThreads2.FormCreate(Sender: TObject);
begin
  RunTests;
end;

end.

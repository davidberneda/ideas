program ThreadSpeed;

uses
  Vcl.Forms,
  UnitThreads in 'UnitThreads.pas' {FormThreads},
  UnitThreadsString in 'UnitThreadsString.pas' {FormThreads2};

{$R *.res}

begin
  {$IFOPT D+}
  ReportMemoryLeaksOnShutdown:=True;
  {$ENDIF}
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFormThreads2, FormThreads2);
  Application.Run;
end.

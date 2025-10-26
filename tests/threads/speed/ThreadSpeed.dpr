program ThreadSpeed;

uses
//  FastMM5,
  Vcl.Forms,
  UnitThreads in 'UnitThreads.pas' {FormThreads};

{$R *.res}

begin
  {$IFOPT D+}
  ReportMemoryLeaksOnShutdown:=True;
  {$ENDIF}
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFormThreads, FormThreads);
  Application.Run;
end.

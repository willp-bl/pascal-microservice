unit Main;

{$mode objfpc}{$H+}

interface

uses
  BrookAction,
  BrookHttpDefs,
  BrookUtils,
  Dos,
  FPJSON,
  StrUtils,
  SysUtils;

type
  TWPAction = class(TBrookAction)
  public
    procedure Request(Request: TBrookRequest; Response: TBrookResponse); override;
  end;
  TRootAction = class(TWPAction)
  public
    procedure Get; override;
  end;
  THelloWorldAction = class(TWPAction)
  public
    procedure Get; override;
  end;
  TFactoralAction = class(TWPAction)
  public
    procedure Get; override;
  end;
  TPathAction = class(TWPAction)
  public
    procedure Get; override;
  end;
  TJSONAction = class(TWPAction)
  public
    procedure Get; override;
  end;

implementation

// Logging procedures

// add an error handler? unrecognised urls don't get logged right now
// overload TBrookRouter.Request to log all requests??
procedure LogRequest(Method: string; Request: TBrookRequest; Response: TBrookResponse);
begin
  Write(Request.RemoteAddress+' - - '+FormatDateTime('[DD"/"mmm"/"YYYY:HH:MM:SS]', Now)+' "'+Method+Request.HeaderLine+'" ');
  Write(IntToStr(Response.Code)+' '+IntToStr(Response.Content.Length)+' ');
  if Request.Referer <> '' then
    Write('"'+Request.Referer+'" ')
  else
    Write('- ');
  if Request.UserAgent <> '' then
    Write('"'+Request.UserAgent+'"')
  else
    Write('-');
  WriteLn;
end;

procedure TWPAction.Request(Request: TBrookRequest; Response: TBrookResponse);
begin
  Inherited;
  LogRequest(Method, Request, Response);
end;

// Root procedures
procedure TRootAction.Get;
begin
  Write('<a href="/hello">see a hello</a><br>');
  Write('<a href="/factoral?fac=1">see a factoral</a><br>');
  Write('<a href="/path/10">see a path in action</a><br>');
  Write('<a href="/json">see some json</a><br>');
end;

// Hello World procedures
procedure THelloWorldAction.Get;
begin
  Write('Hello world!<br>');
end;

// Factoral procedures (currently just prints all query params to the page)
procedure TFactoralAction.Get;
var
  Index: Integer;
  Name, Value: string;
begin
  Write('Hello factoral!<br>');
  for Index := 0 to Pred(Params.Count) do
  begin
    Params.GetNameValue(Index, Name, Value);
    Write(Name+': '+Value+'<br>');
  end
end;

// Path param procedures
procedure TPathAction.Get;
var
  Index: Integer;
  Name, Value: string;
begin
  Write('Hello paths!<br>');
  for Index := 0 to Pred(Variables.Count) do
  begin
    Variables.GetNameValue(Index, Name, Value);
    Write(Name+': '+Value+'<br>');
  end
end;

// JSON
procedure TJSONAction.Get;
var
  json: TJSONObject;
begin
  HttpResponse.ContentType := 'application/json';
  json := TJSONObject.Create(['message', 'hello world']);
  Write(json.AsJSON);
  json.Free;
end;

// End of actions

function GetPortNumber(): Integer;
var
    Port: String;
begin
    Port := GetEnv('PORT');
    if Port = '' then
        Port := '4321';
    GetPortNumber := StrToInt(Port);
end;

initialization
  TRootAction.Register(''); // no / for root
  THelloWorldAction.Register('/hello');
  TFactoralAction.Register('/factoral');
  TPathAction.Register('/path/:variable1');
  TJSONAction.Register('/json');
  BrookSettings.Port := GetPortNumber;

end.

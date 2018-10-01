unit Main;

{$mode objfpc}{$H+}

interface

uses
  BrookAction,
  BrookHttpDefs,
  BrookUtils,
  Dos,
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

implementation

// Logging procedures

// add an error handler? unrecognised urls don't get logged right now

// see https://github.com/graemeg/freepascal/blob/master/packages/fcl-web/src/base/httpdefs.pp THTTPHeader & TRequest
// Add Request.HTTPUserAgent?

// overload TBrookRouter.Request to log all requests??

procedure LogRequest(Method: string; Request: TBrookRequest; Response: TBrookResponse);
begin
  Write(Request.RemoteAddress+' - - '+FormatDateTime('[DD"/"mmm"/"YYYY:HH:MM:SS]', Now)+' "'+Method+' '+Request.URI+' HTTP/1.0" ');
  WriteLn(IntToStr(Response.Code)+' '+IntToStr(Response.Content.Length));
  // add referer, user agent & size of request??
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
  Write('<a href="/path/is/real">see a path in action</a>');
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
//  for Index := 0 to Pred(Values.Count) do
//  begin
//    Values.GetNameValue(Index, Name, Value);
//    Write(Name+': '+Value+'<br>');
//  end
end;

// End of actions

function GetPortNumber(): String;
var
    Port: String;
begin
    Port := GetEnv('PORT');
    if Port = '' then
        Port := '4321';
    GetPortNumber := Port;
end;

initialization
  TRootAction.Register(''); // no / for root
  THelloWorldAction.Register('/hello');
  TFactoralAction.Register('/factoral');
  TPathAction.Register('/path');
  BrookSettings.Port := StrToInt(GetPortNumber);

end.

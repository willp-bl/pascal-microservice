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
  TRootAction = class(TBrookAction)
  public
    procedure Get; override;
    procedure Request(Request: TBrookRequest; Response: TBrookResponse); override;
  end;
  THelloWorldAction = class(TBrookAction)
  public
    procedure Get; override;
    procedure Request(Request: TBrookRequest; Response: TBrookResponse); override;
  end;
  TFactoralAction = class(TBrookAction)
  public
    procedure Get; override;
    procedure Request(Request: TBrookRequest; Response: TBrookResponse); override;
  end;
  TPathAction = class(TBrookAction)
  public
    procedure Get; override;
    procedure Request(Request: TBrookRequest; Response: TBrookResponse); override;
  end;

implementation

// Logging procedures

// add an error handler? unrecognised urls don't get logged right now

// see https://github.com/graemeg/freepascal/blob/master/packages/fcl-web/src/base/httpdefs.pp THTTPHeader & TRequest
// Add Request.HTTPUserAgent?

// overload TBrookRouter.Request to log all requests??

// should probably just log this when the response is served...
procedure LogRequest(Method: string; Request: TBrookRequest);
begin
  Write(Request.RemoteAddress+' - - '+FormatDateTime('[DD"/"mmm"/"YYYY:HH:MM:SS]', Now)+' "'+Method+' '+Request.URI+' HTTP/1.0" ');
end;

procedure LogResponse(Response: TBrookResponse);
begin
  WriteLn(IntToStr(Response.Code)+' '+IntToStr(Response.Content.Length));
  // add referer, user agent & size of request??
end;

// Actions

// Root procedures

procedure TRootAction.Request(Request: TBrookRequest; Response: TBrookResponse);
begin
  LogRequest(Method, Request);
  Get;
  LogResponse(Response);
end;

procedure TRootAction.Get;
begin
  Write('<a href="/hello">see a hello</a><br>');
  Write('<a href="/factoral?fac=1">see a factoral</a><br>');
  Write('<a href="/path/is/real">see a path in action</a>');
end;

// Hello World procedures

procedure THelloWorldAction.Request(Request: TBrookRequest; Response: TBrookResponse);
begin
  LogRequest(Method, Request);
  Get;
  LogResponse(Response);
end;

procedure THelloWorldAction.Get;
begin
  Write('Hello world!<br>');
end;

// Factoral procedures (currently just prints all query params to the page)

procedure TFactoralAction.Request(Request: TBrookRequest; Response: TBrookResponse);
begin
  LogRequest(Method, Request);
  Get;
  LogResponse(Response);
end;

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

procedure TPathAction.Request(Request: TBrookRequest; Response: TBrookResponse);
begin
  LogRequest(Method, Request);
  Get;
  LogResponse(Response);
end;

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

initialization
  TRootAction.Register(''); // no / for root
  THelloWorldAction.Register('/hello');
  TFactoralAction.Register('/factoral');
  TPathAction.Register('/path');
  // TODO: get this from an env var
  BrookSettings.Port := 4321;

end.

unit Redis.NetLib.Factory;

interface

uses Redis.Client, System.Generics.Collections;

type
  // this class introduce the virtual constructor
  TRedisNetLibAdapter = class abstract(TInterfacedObject, IRedisNetLibAdapter)
    constructor Create; virtual;
  protected
    procedure Connect(const HostName: string; const Port: Word); virtual; abstract;
    procedure Send(const Value: string); virtual; abstract;
    procedure SendCmd(const Values: TRedisCmdParts); virtual; abstract;
    function Receive(const Timeout): string; virtual; abstract;
    procedure Disconnect; virtual; abstract;
  end;

  TRedisTCPLibClass = class of TRedisNetLibAdapter;

  TLibFactory = class sealed
    class function Get(const LibName: string): IRedisNetLibAdapter;
    class procedure RegisterRedisTCPLib(const LibName: string; Clazz: TRedisTCPLibClass);
  end;

implementation

uses
  System.SysUtils;

var
  RedisTCPLibraryRegistry: TDictionary<string, TRedisTCPLibClass>;

  { TLibFactory }

class function TLibFactory.Get(const LibName: string): IRedisNetLibAdapter;
var
  Clazz: TRedisTCPLibClass;
begin
  if not RedisTCPLibraryRegistry.TryGetValue(LibName, Clazz) then
    raise Exception.Createfmt('Cannot instantiate %s TCP lib', [LibName]);
  Result := Clazz.Create;
end;

class procedure TLibFactory.RegisterRedisTCPLib(const LibName: string;
  Clazz: TRedisTCPLibClass);
begin
  RedisTCPLibraryRegistry.Add(LibName, Clazz);
end;

{ TRedisTCPLib }

constructor TRedisNetLibAdapter.Create;
begin
  inherited Create;
end;

initialization

RedisTCPLibraryRegistry := TDictionary<string, TRedisTCPLibClass>.Create;

finalization

RedisTCPLibraryRegistry.Free;

end.
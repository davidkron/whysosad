%%%-------------------------------------------------------------------
%%% @author Simeon Ivanov
%%% @copyright (C) 2014, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 06. Nov 2014 12:53 PM
%%%-------------------------------------------------------------------
-module(database_riak).
-author("Simeon").

%% API
-export([start/0, stop/0, getMap/1, clearMap/1, getData/2, setData/3, printMap/1, printMap/2]).

start() ->
  ServerPid = whereis(sts),
  if is_pid(ServerPid) == true -> {ok, ServerPid};
    true -> {ok, Pid} = riakc_pb_socket:start_link("127.0.0.1", 8087),
    register(sts, Pid), {ok, Pid, riakc_pb_socket:ping(Pid)}
  end.

stop()-> ServerPid = whereis(sts),
  process_flag(trap_exit, true),
  if is_pid(ServerPid) == true -> exit(ServerPid, kill),
      receive
        _-> stopped
      end;
    true -> already_stopped
  end.

clearMap(Key) ->
  riakc_pb_socket:put(sts,
    riakc_obj:new(
      <<"whysosad">>,
      list_to_binary(Key),
      #{}
    )
  ),
  #{}.

getMap(Key) ->
  try
    {_,{_,_,_,_,[{_,Map}],_,_}} = riakc_pb_socket:get(sts,
      <<"whysosad">>,
      list_to_binary(Key)
    ),
    binary_to_term(Map)
  catch
   % If map doesn't exist, create an empty one
    _:_ -> clearMap(Key)
  end.

getData(Key, MapKey) -> Map = getMap(MapKey), maps:get(Key, Map, "0").

setData(Key, Value, MapKey) -> Map = getMap(MapKey),
  MapNew = maps:put(Key, Value, Map),
  RiakObject = riakc_obj:new(<<"whysosad">>, list_to_binary(MapKey), MapNew),
  riakc_pb_socket:put(sts, RiakObject).

printMap(stop) -> PrintPid = whereis(print),
  if PrintPid == undefined -> already_stopped;
    true -> exit(whereis(print), kill), stopped
  end;
printMap(Key) ->
  io:format("\e[H\e[J"),
  Map = lists:concat([ "{" ++ K ++ ","++ V ++ "} " || {K, V} <-maps:to_list(getMap(Key))]),
  io:format("~p~n", [Map]).

printMap(Key, Freq) -> PrintPid = whereis(print),
  if is_pid(PrintPid) == true -> exit(PrintPid, kill); true -> ok end,
  register(print, spawn(fun() -> printLoop(Key, Freq) end)).

printLoop(Key, Freq) ->
  receive
    after Freq ->
      printMap(Key), printLoop(Key, Freq)
  end.
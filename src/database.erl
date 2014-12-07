%%%-------------------------------------------------------------------
%%% @author Simeon Ivanov
%%% @copyright (C) 2014, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 06. Nov 2014 12:53 PM
%%%-------------------------------------------------------------------
-module(database).
-author("Simeon").

%% API
-export([start/0, stop/0, store/2, fetch/1, fetchMap/1, remove/1, store_in_store/3]).

start() ->
  ServerPid = whereis(sts),
  if is_pid(ServerPid) == true ->
    already_started;
  true ->
    spawn(fun() -> init() end),
    started
  end.

init() ->
  process_flag(trap_exit, true),
  {ok, Pid} = riakc_pb_socket:start_link("127.0.0.1", 8087),
  register(sts, Pid),
  receive _ ->
    init()
  end.

stop()-> ServerPid = whereis(sts),
  process_flag(trap_exit, true),
  if is_pid(ServerPid) == true -> exit(ServerPid, kill),
      receive
        _-> stopped
      end;
    true -> already_stopped
  end.

store_in_store(Key1, Key2, Value) ->
  store(Key1, maps:put(Key2, Value, fetch(Key1))).

store(Key, Value) ->
  if is_map(Value) == true ->
    ProcessedValue = Value;
  true ->
    ProcessedValue = term_to_binary(Value)
  end,
  RiakObject = riakc_obj:new(<<"whysosad">>, list_to_binary(Key), ProcessedValue),
  riakc_pb_socket:put(sts, RiakObject).

fetch(Key) ->
  Response = riakc_pb_socket:get(sts, <<"whysosad">>, list_to_binary(Key)),
  fetch(handle_response, Response).

fetch(handle_response, {error,_}) -> notfound;
fetch(handle_response, Response) ->
  {_,{_,_,_,_,[{_,Value}],_,_}} = Response,
  binary_to_term(Value).

fetchMap(Key) ->
  Map = fetch(Key),
  if Map == notfound ->
    #{};
  true ->
    Map
  end.

remove(Key) -> riakc_pb_socket:delete(sts, <<"whysosad">>, list_to_binary(Key)).
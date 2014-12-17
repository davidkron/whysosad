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
-behaviour(gen_server).

%% API
-export([start/0, init/1, store/2, fetch/1, fetchMap/1, fetch_recursive/2,
  remove/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2,
  code_change/3, connect/0, store_in_store/3]).

connect() -> database_sup:start_link().

start() ->
  gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).

init([]) ->
  {ok, Pid} = riakc_pb_socket:start_link("127.0.0.1", 8087),
  {ok, Pid}.

store(Key, Value) ->
  gen_server:call(?MODULE, {store, Key, Value}).

store_in_store(Key1, Key2, Value) ->
  store(Key1, maps:put(Key2, Value, fetch(Key1))).

fetch(Key) ->
  gen_server:call(?MODULE, {fetch, Key}).

fetch_recursive(Bucket, [Keys]) ->
  fetch_recursive(Keys, fetchMap(Bucket));
fetch_recursive([Key | Keys], Map) ->
  fetch_recursive(Keys, maps:get(Key, Map));
fetch_recursive(Key, Map) ->
  maps:get(Key, Map).

fetchMap(Key) ->
  Map = fetch(Key),
  if Map == notfound ->
    store(Key, #{}), #{};
    true ->
      Map
  end.

remove(Key) ->
  gen_server:call(?MODULE, {remove, Key}).

handle_call({store, Key, Value}, _From, RiakPid) ->
  if is_map(Value) == true ->
    ProcessedValue = Value;
  true ->
    ProcessedValue = term_to_binary(Value)
  end,
  RiakObject = riakc_obj:new(<<"whysosad">>, list_to_binary(Key), ProcessedValue),
  Reply = riakc_pb_socket:put(RiakPid, RiakObject),
  {reply, Reply, RiakPid};
handle_call({fetch, Key}, _From, RiakPid) ->
  Response = riakc_pb_socket:get(RiakPid, <<"whysosad">>, list_to_binary(Key)),
  Reply = case Response of
    {error,_} -> notfound;
    {_,{_,_,_,_,[{_,Value}],_,_}} -> binary_to_term(Value)
  end,
  {reply, Reply, RiakPid};
handle_call({remove, Key}, _From, RiakPid) ->
  Reply = riakc_pb_socket:delete(RiakPid, <<"whysosad">>, list_to_binary(Key)),
  {reply, Reply, RiakPid}.

handle_cast(stop, RiakPid) -> {stop, normal, RiakPid}.

handle_info(_Info, _State) ->
  erlang:error(not_implemented).

terminate(_Reason, _State) -> ok.

code_change(_OldVsn, _State, _Extra) ->
  erlang:error(not_implemented).

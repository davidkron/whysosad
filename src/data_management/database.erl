%%%-------------------------------------------------------------------
%%% @author Simeon Ivanov, David Jensen
%%% @copyright (C) 2014, Team Pegasus
%%% @doc
%%%
%%% @end
%%% Created : 06. Nov 2014 12:53 PM
%%%-------------------------------------------------------------------
-module(database).
-author("Simeon").
-behaviour(gen_server).

%% API
-export([start/0, init/1, store/3, fetch/2, remove/2, handle_call/3,
  handle_cast/2, handle_info/2, terminate/2, code_change/3, connect/0,
  stop/0, fetch_map/2, map_reduce/2, to_binary/1, store_set/2, fetch_set/1]).

connect() -> database_sup:start_link().

start() ->
  gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).

init([]) ->
  {ok, Pid} = riakc_pb_socket:start_link("127.0.0.1", 8087),
  {ok, Pid}.

stop() ->
  gen_server:cast(?MODULE, stop).

store(Bucket, Key, Value) ->
  gen_server:call(?MODULE, {store, Bucket, Key, Value}).

store_set(Key, Value) ->
  gen_server:call(?MODULE, {store_set, Key, Value}).

fetch(Bucket, Key) ->
  gen_server:call(?MODULE, {fetch, Bucket, Key}).

fetch_set(Key) ->
  gen_server:call(?MODULE, {fetch_set, Key}).

fetch_map(Bucket, Key) ->
  case fetch(Bucket, Key) of
    notfound -> #{};
    Map -> Map
  end.

remove(Bucket, Key) ->
  gen_server:call(?MODULE, {remove, Bucket, Key}).

map_reduce(Inputs, QueryTerms) ->
  gen_server:call(?MODULE, {map_reduce, Inputs, QueryTerms}).

handle_call({store, Bucket, Key, Value}, _From, RiakPid) ->
  RiakObject = riakc_obj:new(
    to_binary(Bucket),
    to_binary(Key),
    to_binary(Value)
  ),
  Reply = riakc_pb_socket:put(RiakPid, RiakObject),
  {reply, Reply, RiakPid};
handle_call({store_set, Key, Value}, _From, RiakPid) ->
  Set = riakc_set:new(),
  NewSet = riakc_set:add_element(list_to_binary(Value), Set),
  Reply = riakc_pb_socket:update_type(RiakPid,
    {<<"sets">>, <<"sets">>},
    list_to_binary(Key),
    riakc_set:to_op(NewSet)
  ),
  {reply, Reply, RiakPid};
handle_call({fetch, Bucket, Key}, _From, RiakPid) ->
  Response = riakc_pb_socket:get(
    RiakPid, to_binary(Bucket),
    to_binary(Key)
  ),
  Reply = case Response of
    {error,_} -> notfound;
    {ok, Obj} -> binary_to_term(riakc_obj:get_value(Obj))
  end,
  {reply, Reply, RiakPid};
handle_call({fetch_set, Key}, _From, RiakPid) ->
  Response = riakc_pb_socket:fetch_type(
    RiakPid,
    {<<"sets">>,<<"sets">>},
    list_to_binary(Key)
  ),
  Reply = case Response of
            {error,_} -> notfound;
            {ok, Set} -> riakc_set:value(Set)
          end,
  {reply, Reply, RiakPid};
handle_call({remove, Bucket, Key}, _From, RiakPid) ->
  Reply = riakc_pb_socket:delete(
    RiakPid,
    to_binary(Bucket),
    to_binary(Key)
  ),
  {reply, Reply, RiakPid};
handle_call({map_reduce, Input, QueryTerms}, _From, RiakPid) ->
  Reply = riakc_pb_socket:mapred(RiakPid, Input, QueryTerms),
  {reply, Reply, RiakPid}.

handle_cast(stop, RiakPid) ->
  {stop, normal, RiakPid}.

handle_info(_Info, _State) ->
  erlang:error(not_implemented).

terminate(_Reason, _State) ->
  ok.

code_change(_OldVsn, _State, _Extra) ->
  erlang:error(not_implemented).

to_binary(Value) ->
  IsList = is_list(Value),
  IsInteger = is_integer(Value),
  IsBinary = is_binary(Value),
  if IsList ->
      list_to_binary(Value);
    IsInteger ->
      integer_to_binary(Value);
    IsBinary ->
      Value;
    true ->
      term_to_binary(Value)
  end.
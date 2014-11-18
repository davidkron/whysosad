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
-export([start/0, stop/0, getMap/1, clearMap/1, getTimestamp/1, setTimestamp/2, getHappiness/2, setHappiness/3, getTotal/2, setTotal/3]).

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

setData(Country, TimeFrame, Key, Value) ->
  CountriesMap = getMap("countries"),
  CountryMap = maps:get(Country, CountriesMap, #{}),
  TimeFrameMap = maps:get(TimeFrame, CountryMap, #{}),
  NewTimeFrameMap = maps:put(Key, Value, TimeFrameMap),
  NewCountryMap = maps:put(TimeFrame, NewTimeFrameMap, CountryMap),
  NewCountriesMap = maps:put(Country, NewCountryMap, CountriesMap),
  RiakObject = riakc_obj:new(<<"whysosad">>, list_to_binary("countries"), NewCountriesMap),
  riakc_pb_socket:put(sts, RiakObject).

getData(Country, TimeFrame, Key) ->
  CountriesMap = getMap("countries"),
  CountryMap = maps:get(Country, CountriesMap, #{}),
  TimeFrameMap = maps:get(TimeFrame, CountryMap, #{}),
  maps:get(Key, TimeFrameMap, 0).

getTimestamp(Country) -> getData(Country, "previous", "timestamp").

setTimestamp(Country, Value) -> setData(Country, "previous", "timestamp", Value).

getHappiness(Country, TimeFrame) -> getData(Country, TimeFrame, "value").

setHappiness(Country, TimeFrame, Value) -> setData(Country, TimeFrame, "value", Value).

setTotal(Country, TimeFrame, Value) -> setData(Country, TimeFrame, "total", Value).

getTotal(Country, TimeFrame) -> getData(Country, TimeFrame, "total").
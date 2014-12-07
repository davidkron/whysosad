-module(esi_facade).
-export([current_happiness/3, place_bet/3]).

current_time() -> {_, Time, _} = now(), Time div const:interval_ms().

safe_deliver(Sid, Fun) ->
  try Fun() of
    {false, Error} -> erlang:display(Error), mod_esi:deliver(Sid, "Error: " ++ atom_to_list(Error));
    Result -> mod_esi:deliver(Sid, Result)
  catch
    Error -> erlang:display(Error), mod_esi:deliver(Sid, Error)
  end.

current_happiness(Sid, _Env, _In) -> safe_deliver(Sid, fun() ->
  getPropertyValue(current_time(), "value")
end).

place_bet(Sid, _Env, Input) -> safe_deliver(Sid, fun() ->
  place_bet(httpd:parse_query(Input))
end).

getPropertyValue(TimeFrame, Value) ->
  Map = database:fetchMap("countries"),
  Countries = maps:keys(Map),
  KeyValues  = ["\"" ++ Country ++ "\"" ++ "\: " ++ integer_to_list(maps:get(Value, maps:get(TimeFrame, maps:get(Country,Map),maps:new()),0)) || Country<-Countries],
  "{" ++ string:join(KeyValues,",") ++ "}".

place_bet(Args) ->
  User = proplists:get_value("user", Args),
  Password = proplists:get_value("password", Args),
  Country = proplists:get_value("country", Args),
  TargetTime = proplists:get_value("targettime", Args),
  TargetStatus = proplists:get_value("targetstatus", Args),
  betting:place_bet(User, Password, Country, TargetTime, TargetStatus).

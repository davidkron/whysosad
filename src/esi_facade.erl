-module(esi_facade).
-import(proplists, [get_value/2]).
-export([current_happiness/3, place_bet/3, register_user/3, get_all_bets/3]).

current_time() -> {_, Time, _} = now(), Time div const:interval_ms().

safe_deliver(Sid, Fun) ->
  try Fun() of
    {false, Error} -> mod_esi:deliver(Sid, "{Error:" ++ atom_to_list(Error) ++ "}");
    ok -> mod_esi:deliver(Sid, "Sucess");
    Result -> mod_esi:deliver(Sid, Result)
  catch
    error:Error -> mod_esi:deliver(Sid, "{Error:" ++ atom_to_list(Error) ++ "}");
    Error -> mod_esi:deliver(Sid, "{Error:" ++ Error ++ "}")
  end.

current_happiness(Sid, _Env, Input) -> safe_deliver(Sid, fun() ->
  Args = httpd:parse_query(Input),
  ApiKey = required_param("apikey", Args),
  validate_apikey(ApiKey),
  getPropertyValue(current_time(), "value")
end).

validate_apikey(Key) ->
  case Key of
    "23jk4n823nasdf23rgdf" -> ok;
    _ -> throw("Unknown api key")
  end.

required_param_int(Param, Args) -> list_to_integer(required_param(Param, Args)).

required_param(Param, Args) ->
  case get_value(Param, Args) of
    undefined -> throw("Missing parameter '" ++ Param ++ "'");
    X -> X
  end.

place_bet(Sid, _Env, Input) -> safe_deliver(Sid, fun() ->
  Args = httpd:parse_query(Input),
  User = required_param("user", Args),
  Password = required_param("password", Args),
  Country = required_param("country", Args),
  TargetTime = required_param_int("targettime", Args),
  TargetStatus = required_param("targetstatus", Args),
  Credits = required_param_int("credits", Args),
  betting:place_bet(User, Password, Country, TargetTime, TargetStatus, Credits)
end).

register_user(Sid, _Env, Input) -> safe_deliver(Sid, fun() ->
  Args = httpd:parse_query(Input),
  User = required_param("user", Args),
  Password = required_param("password", Args),
  users:add(User, Password)
end).

get_all_bets(Sid, _Env, Input) -> safe_deliver(Sid, fun() ->
  Args = httpd:parse_query(Input),
  User = required_param("user", Args),
  Password = required_param("password", Args),
  erlang:display(betting:get_users_bets(User, Password))
end).

getPropertyValue(TimeFrame, Value) ->
  Map = database:fetchMap("countries"),
  Countries = maps:keys(Map),
  KeyValues  = ["\"" ++ Country ++ "\"" ++ "\: " ++ integer_to_list(maps:get(Value, maps:get(TimeFrame, maps:get(Country,Map),maps:new()),0)) || Country<-Countries],
  "{" ++ string:join(KeyValues,",") ++ "}".

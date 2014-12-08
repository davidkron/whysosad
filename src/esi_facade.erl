-module(esi_facade).
-import(proplists, [get_value/2]).
-export([current_happiness/3, place_bet/3, register_user/3, get_all_bets/3, get_user_credits/3]).

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


to_list(X) when is_list(X) -> X;
to_list(X) when is_atom(X) -> atom_to_list(X);
to_list(X) when is_integer(X) -> integer_to_list(X);
to_list(X) when is_float(X) -> float_to_list(X);
to_list(X) -> erlang:display(X).

map_to_json(Map) ->
  KeyValues = ["\"" ++ to_list(Key) ++ "\"" ++ "\: " ++ to_list(maps:get(Key, Map)) || Key <- maps:keys(Map)],
  "{" ++ string:join(KeyValues, ",") ++ "}".

get_all_bets(Sid, _Env, Input) -> safe_deliver(Sid, fun() ->
  Args = httpd:parse_query(Input),
  User = required_param("user", Args),
  Password = required_param("password", Args),
  Bets = betting:get_users_bets(User, Password),
  JsonBets = [map_to_json(Bet) || Bet <- Bets, is_map(Bet)],
  "[" ++ string:join(JsonBets, ",") ++ "]"
end).

get_user_credits(Sid, _Env, Input) -> safe_deliver(Sid, fun() ->
  Args = httpd:parse_query(Input),
  integer_to_list(users:get_credits(required_param("user", Args), required_param("password", Args)))
end).

getPropertyValue(TimeFrame, Value) ->
  Map = database:fetchMap("countries"),
  Countries = maps:keys(Map),
  KeyValues = ["\"" ++ Country ++ "\"" ++ "\: " ++ integer_to_list(country:getCountryData(Country, TimeFrame, Value)) || Country <- Countries],
  "{" ++ string:join(KeyValues,",") ++ "}".

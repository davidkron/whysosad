-module(esi_facade).
-import(esi_util, [required_param/2,required_param_int/2]).
-export([login/3,current_happiness/3, place_bet/3, register_user/3, get_all_bets/3,current_score/3, get_user_credits/3, total_users/3]).

current_happiness(Sid, _Env, Input) -> esi_util:safe_deliver(Sid, fun() ->
  Args = httpd:parse_query(Input),
  ApiKey = required_param("apikey", Args),
  validate_apikey(ApiKey),
  country:happiness_json(util:current_time())
end).

current_score(Sid, _Env, Input) -> esi_util:safe_deliver(Sid, fun() ->
  Args = httpd:parse_query(Input),
  ApiKey = required_param("apikey", Args),
  validate_apikey(ApiKey),
  country:happiness_score_json(util:current_time())
end).

validate_apikey(Key) ->
  case Key of
    "23jk4n823nasdf23rgdf" -> ok;
    _ -> throw("Unknown api key")
  end.

place_bet(Sid, _Env, Input) -> esi_util:safe_deliver(Sid, fun() ->
  Args = httpd:parse_query(Input),
  User = required_param("user", Args),
  Password = required_param("password", Args),
  Country = required_param("country", Args),
  SentHour = required_param_int("hour", Args),
  SentMin = required_param_int("minute", Args),
  TargetStatus = required_param("targetstatus", Args),
  Credits = required_param_int("credits", Args),
  {_, {Hour, Min, _}} = calendar:local_time(),
  Timediff = (SentHour * 60 + SentMin) - (Hour * 60 + Min),
  case (Timediff < 0) of
    true ->
      betting:place_bet(User, Password, Country, util:current_time() + ((Timediff + (24 * 60 * 60)) div const:interval_s()), TargetStatus, Credits);
    false ->
      betting:place_bet(User, Password, Country, util:current_time() + (Timediff div const:interval_s()), TargetStatus, Credits)
  end
end).

login(Sid, _Env, Input) -> esi_util:safe_deliver(Sid, fun() ->
  Args = httpd:parse_query(Input),
  User = required_param("user", Args),
  Password = required_param("password", Args),
  users:authenticate(User,Password)
end).

register_user(Sid, _Env, Input) -> esi_util:safe_deliver(Sid, fun() ->
  Args = httpd:parse_query(Input),
  User = required_param("user", Args),
  Password = required_param("password", Args),
  users:add(User, Password)
end).

total_users(Sid, _Env, _Input) -> esi_util:safe_deliver(Sid, fun() ->
  Users = database:fetchMap("users"),
  Usernames = maps:keys(Users),
  integer_to_list(length(Usernames))
end).


get_all_bets(Sid, _Env, Input) -> esi_util:safe_deliver(Sid, fun() ->
  Args = httpd:parse_query(Input),
  User = required_param("user", Args),
  Password = required_param("password", Args),
  Bets = betting:get_users_bets(User, Password),
  JsonBets = [esi_util:map_to_json(Bet) || Bet <- Bets, is_map(Bet)],
  "[" ++ string:join(JsonBets, ",") ++ "]"
end).

get_user_credits(Sid, _Env, Input) -> esi_util:safe_deliver(Sid, fun() ->
  Args = httpd:parse_query(Input),
  integer_to_list(users:get_credits(required_param("user", Args), required_param("password", Args)))
end).

-module(esi_facade).
-export([current_happiness/3, previous_happiness/3, happiness_change/3, current_total/3, previous_total/3]).

getPropertyValue(TimeFrame, Value) ->
  Map = database:fetchMap("countries"),
  Countries = maps:keys(Map),
  KeyValues  = ["\"" ++ Country ++ "\"" ++ "\: " ++ integer_to_list(maps:get(Value, maps:get(TimeFrame, maps:get(Country,Map)))) || Country<-Countries],
  "{" ++ string:join(KeyValues,",") ++ "}".

current_happiness(Sid, _Env, _In) -> mod_esi:deliver(Sid, getPropertyValue("current", "value")).

previous_happiness(Sid, _Env, _In) -> mod_esi:deliver(Sid, getPropertyValue("previous", "value")).

current_total(Sid, _Env, _In) -> mod_esi:deliver(Sid, getPropertyValue("current", "total")).

previous_total(Sid, _Env, _In) -> mod_esi:deliver(Sid, getPropertyValue("previous", "total")).

happiness_change(Sid, _Env, _In) -> mod_esi:deliver(Sid, ["{\"Sweden\":-5,\"Denmark\":200,}"]).

-module(esi_facade).
-export([current_happiness/3, happiness_change/3, current_total/3]).

current_time() -> {_, Time, _} = now(), Time div 60.

getPropertyValue(TimeFrame, Value) ->
  Map = database:fetchMap("countries"),
  Countries = maps:keys(Map),
  KeyValues  = ["\"" ++ Country ++ "\"" ++ "\: " ++ integer_to_list(maps:get(Value, maps:get(TimeFrame, maps:get(Country,Map)))) || Country<-Countries],
  "{" ++ string:join(KeyValues,",") ++ "}".


current_happiness(Sid, _Env, _In) -> mod_esi:deliver(Sid, getPropertyValue(current_time(), "value")).

current_total(Sid, _Env, _In) -> mod_esi:deliver(Sid, getPropertyValue(current_time(), "total")).

happiness_change(Sid, _Env, _In) -> mod_esi:deliver(Sid, ["{\"Sweden\":-5,\"Denmark\":200,}"]).

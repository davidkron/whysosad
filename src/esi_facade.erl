-module(esi_facade).
-export([current_happiness/3, previous_happiness/3, happiness_change/3]).

getHappiness(TimeFrame) ->
  Map = database_riak:getMap("countries"),
  Countries = maps:keys(Map),
  KeyValues  = ["\"" ++ Country ++ "\"" ++ "\: " ++ integer_to_list(maps:get("value", maps:get(TimeFrame, maps:get(Country,Map)))) || Country<-Countries],
  "{" ++ string:join(KeyValues,",") ++ "}".

current_happiness(Sid, _Env, _In) -> mod_esi:deliver(Sid, getHappiness("current")).

previous_happiness(Sid, _Env, _In) -> mod_esi:deliver(Sid, getHappiness("previous")).

happiness_change(Sid, _Env, _In) -> mod_esi:deliver(Sid, ["{\"Sweden\":-5,\"Denmark\":200,}"]).

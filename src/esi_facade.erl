-module(esi_facade).
-export([current_happiness/3,happiness_change/3]).

current_happiness(Sid, _Env, _In) ->
Map = database_riak:getMap("countries"),
Countries = maps:keys(Map),
KeyValues  = ["\"" ++ Country ++ "\"" ++ "\: " ++ maps:get(Country,Map) || Country<-Countries],
Json = "{" ++ string:join(KeyValues,",") ++ "}",
mod_esi:deliver(Sid, Json).

happiness_change(Sid, _Env, _In) -> mod_esi:deliver(Sid, ["{\"Sweden\":-5,\"Denmark\":200,}"]).

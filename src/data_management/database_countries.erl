%%%-------------------------------------------------------------------
%%% @author David Jensen, Simeon Ivanov
%%% @copyright (C) 2014, Team Pegasus
%%% @doc
%%%
%%% @end
%%% Created : 08. Dec 2014 9:20 PM
%%%-------------------------------------------------------------------
-module(database_countries).
-author("david").

%% API
-export([get_happiness/2, get_total/2, clear_all_data/0,
  decrement_happiness/2, increment_happiness/2, increment_total/2]).

clear_all_data() ->
  %% batch it
  ok.

get_happiness(Country, TimeFrame) ->
  Map = database:fetch_map("country_" ++ Country, TimeFrame),
  maps:get("happiness", Map, 0).

get_total(Country, TimeFrame) ->
  Map = database:fetch_map("country_" ++ Country, TimeFrame),
  maps:get("total", Map, 0).

increment_happiness(Country, TimeFrame) ->
  Map = database:fetch_map("country_" ++ Country, TimeFrame),
  Happiness =  maps:get("happiness", Map, 0),
  database:store(
    "country_" ++ Country, TimeFrame,
    maps:put("happiness", Happiness + 1, Map)
  ).

decrement_happiness(Country, TimeFrame) ->
  Map = database:fetch_map("country_" ++ Country, TimeFrame),
  Happiness =  maps:get("happiness", Map, 0),
  database:store(
    "country_" ++ Country, TimeFrame,
    maps:put("happiness", Happiness - 1, Map)
  ).

increment_total(Country, TimeFrame) ->
  Map = database:fetch_map("country_" ++ Country, TimeFrame),
  Happiness =  maps:get("total", Map, 0),
  database:store(
    "country_" ++ Country, TimeFrame,
    maps:put("total", Happiness + 1, Map)
  ).
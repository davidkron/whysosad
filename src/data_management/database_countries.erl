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
  decrement_happiness/2, increment_happiness/2, increment_total/2, get_countries/0, add_country/1, get_all_happiness/0, set_all_happiness/0]).

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

add_country(Country) ->
  database:store_set("countries", Country).

get_countries() ->
  Response = database:fetch_set("countries"),
  Countries = case Response of
              notfound -> [];
              _ -> Response
            end,
  [binary_to_list(Country) || Country <- Countries].

set_all_happiness() ->
  Key = util:current_time(),
  CountriesList = database_countries:get_countries(),
  Input = [
    {list_to_binary("country_" ++ Country), integer_to_binary(Key)}
    || Country <- CountriesList
  ],
  QueryTerms = [
    {map, {modfun, mapreduce, countries_happiness_reduce}, none, false},
    {reduce, {modfun, mapreduce, countries_happiness_reduce}, none, true}
  ],
  {ok, [{_, Data}]} = database:map_reduce(Input, QueryTerms),
  database:store("stats", "all_current_happiness", jiffy:encode(Data)).

get_all_happiness() -> database:fetch("stats", "all_current_happiness").
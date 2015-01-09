%%%-------------------------------------------------------------------
%%% @author Simeon Ivanov
%%% @copyright (C) 2014, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 20. Nov 2014 12:40 PM
%%%-------------------------------------------------------------------
-module(country).
-author("Simeon").

%% API
-export([happiness_score_json/1, happiness_json/1, get_happiness/2,
 get_total/2, get_score/2, decrease_happiness/2, increase_happiness/2,
 increase_total/2, get_all_happiness/0, add_country/1, set_all_happiness/0]).

get_score(Country, TimeFrame) ->
 Total = database_countries:get_total(Country, TimeFrame),
 case Total of
  0 -> 0.0;
  _ -> database_countries:get_happiness(Country, TimeFrame) / Total
 end.

get_happiness(Country, TimeFrame) -> database_countries:get_happiness(Country, TimeFrame).
get_total(Country, TimeFrame) -> database_countries:get_total(Country, TimeFrame).

increase_total(Country, TimeFrame) ->
 database_countries:increment_total(Country, TimeFrame).
increase_happiness(Country, TimeFrame) ->
 database_countries:increment_happiness(Country, TimeFrame).
decrease_happiness(Country, TimeFrame) ->
 database_countries:decrement_happiness(Country, TimeFrame).

add_country(Country) -> database_countries:add_country(Country).

set_all_happiness() -> database_countries:get_all_happiness().

get_all_happiness() -> database_countries:get_all_happiness().

happiness_json(TimeFrame) ->
 Map = database:fetchMap("countries"),
 Countries = maps:keys(Map),
 KeyValues = ["\"" ++ Country ++ "\"" ++ "\: " ++ integer_to_list(country:get_happiness(Country, TimeFrame)) || Country <- Countries],
 "{" ++ string:join(KeyValues,",") ++ "}".

happiness_score_json(TimeFrame) ->
 Map = database:fetchMap("countries"),
 Countries = maps:keys(Map),
 KeyValues = ["\"" ++ Country ++ "\"" ++ "\: " ++ float_to_list(country:get_score(Country, TimeFrame)) || Country <- Countries],
 "{" ++ string:join(KeyValues,",") ++ "}".
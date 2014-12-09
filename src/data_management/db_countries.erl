%%%-------------------------------------------------------------------
%%% @author david
%%% @copyright (C) 2014, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 08. Dec 2014 9:20 PM
%%%-------------------------------------------------------------------
-module(db_countries).
-author("david").

%% API
-export([get_happiness/2, get_total/2, set_happiness/3, set_total/3, clear_all_data/0]).

clear_all_data() ->
  database:start(),
  database:remove("countries").

get_country(Country) ->
  CountriesMap = database:fetchMap("countries"),
  maps:get(Country, CountriesMap, #{}).

get_values(Country, Timeframe) ->
  CountryMap = get_country(Country),
  maps:get(Timeframe, CountryMap, #{}).

set_values(Country, Timeframe, Values) ->
  PreviousCountry = get_country(Country),
  NewCountry = maps:put(Timeframe, Values, PreviousCountry),
  database:store_in_store("countries", Country, NewCountry).

get_happiness(Country, TimeFrame) ->
  maps:get("value", get_values(Country, TimeFrame), 0).
get_total(Country, TimeFrame) -> maps:get("total", get_values(Country, TimeFrame), 0).

set_happiness(Country, TimeFrame, Value) ->
  ValuesMap = get_values(Country, TimeFrame),
  set_values(Country, TimeFrame, maps:put("value", Value, ValuesMap)).

set_total(Country, TimeFrame, Value) ->
  ValuesMap = get_values(Country, TimeFrame),
  set_values(Country, TimeFrame, maps:put("total", Value, ValuesMap)).
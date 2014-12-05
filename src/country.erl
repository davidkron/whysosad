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
-export([getHappiness/2, setHappiness/3, setTotal/3, getTotal/2]).

setCountryData(Country, TimeFrame, Key, Value) ->
  CountriesMap = database:fetchMap("countries"),
  CountryMap = maps:get(Country, CountriesMap, #{}),
  TimeFrameMap = maps:get(TimeFrame, CountryMap, #{}),
  NewTimeFrameMap = maps:put(Key, Value, TimeFrameMap),
  NewCountryMap = maps:put(TimeFrame, NewTimeFrameMap, CountryMap),
  NewCountriesMap = maps:put(Country, NewCountryMap, CountriesMap),
  database:store("countries", NewCountriesMap).

getCountryData(Country, TimeFrame, Key) ->
  CountriesMap = database:fetchMap("countries"),
  CountryMap = maps:get(Country, CountriesMap, #{}),
  TimeFrameMap = maps:get(TimeFrame, CountryMap, #{}),
  maps:get(Key, TimeFrameMap, 0).

getHappiness(Country, TimeFrame) -> getCountryData(Country, TimeFrame, "value").

setHappiness(Country, TimeFrame, Value) -> setCountryData(Country, TimeFrame, "value", Value).

setTotal(Country, TimeFrame, Value) -> setCountryData(Country, TimeFrame, "total", Value).

getTotal(Country, TimeFrame) -> getCountryData(Country, TimeFrame, "total").

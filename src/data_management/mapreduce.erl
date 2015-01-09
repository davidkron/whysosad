%%%-------------------------------------------------------------------
%%% @author Simeon
%%% @copyright (C) 2015, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 09. Jan 2015 02:45
%%%-------------------------------------------------------------------
-module(mapreduce).
-author("Simeon").

%% API
-export([countries_happiness_map/3, countries_happiness_reduce/2]).

countries_happiness_map(O, _, _) ->
  Map = binary_to_term(riakc_obj:get_value(O)),
  CountryHappiness = maps:get("happiness", Map, 0),
  CountryName = string:sub_string(binary_to_list(riakc_obj:bucket(O)), 9),
  [{CountryName, CountryHappiness}].

%% just return the reduced list
%% can be achieved using only the map function
%% for educational purposes
countries_happiness_reduce(List, _) -> List.

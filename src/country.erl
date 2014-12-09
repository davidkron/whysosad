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
-export([get_happiness/2, set_happiness/3, set_total/3, get_total/2, get_score/2, decrease_happiness/2, increase_happiness/2, increase_total/2]).

get_score(Country, TimeFrame) ->
 Total = db_countries:get_total(Country, TimeFrame),
 case Total of
  0 -> 0.0;
  _ -> db_countries:get_happiness(Country, TimeFrame) / Total
 end.

get_happiness(Country, TimeFrame) -> db_countries:get_happiness(Country, TimeFrame).
get_total(Country, TimeFrame) -> db_countries:get_total(Country, TimeFrame).
set_happiness(Country, TimeFrame, Value) -> db_countries:set_happiness(Country, TimeFrame, Value).
set_total(Country, TimeFrame, Value) -> db_countries:set_total(Country, TimeFrame, Value).

increase_total(Country, TimeFrame) -> set_total(Country, TimeFrame, get_total(Country, TimeFrame) + 1).
increase_happiness(Country, TimeFrame) -> set_happiness(Country, TimeFrame, get_happiness(Country, TimeFrame) + 1).
decrease_happiness(Country, TimeFrame) -> set_happiness(Country, TimeFrame, get_happiness(Country, TimeFrame) - 1).

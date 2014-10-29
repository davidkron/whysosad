%%%-------------------------------------------------------------------
%%% @author David
%%% @copyright (C) 2014, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 29. okt 2014 07:09
%%%-------------------------------------------------------------------
-module(betting).
-author("David").

%% API
-export([]).

place_bet(Country,Time,Happiness)-> database:put({bets,{Country,Time,Happiness}}).

get_odds(Country,Time,Hapiness)->
 database:count({bets,{Country,Time,Hapiness}})
 /
 database:count({bets,{Country,Time,1-Hapiness}})
.


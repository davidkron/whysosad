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

current_time() -> {_, Time, _} = now(), Time.

place_bet(Country,TargetTime,sadder)-> 
 PlacedTime = current_time(),
 database:put({bets,{Country,PlacedTime,TargetTime,happier}}).

place_bet(Country,TargetTime,happier)-> 
 PlacedTime = current_time(),
 database:put({bets,{Country,PlacedTime,TargetTime,happier}}).

get_users_bets()-> [{bets,{"Sweden",1,1}}]. %Not implemented

get_all_bet_status(UserName) ->
 Bets = get_users_bets(),
 Statuses = [get_bet_status(Country,PlacedTime,TargetTime,TargetHappiness) 
  || {bets,{Country,PlacedTime,TargetTime,TargetHappiness}<-Bets],
 Statuses.

get_bet_status(Country,PlacedTime,TargetTime,TargetHappiness) when TargetTime < current_time() -> inprogress,  
get_bet_status(Country,PlacedTime,Time,TargetHappiness) ->
 Curr = getHappiness(Country, Time) / getTotal(Country, Time),
 Prev = getHappiness(Country, PlacedTime) / getTotal(Country, PlacedTime)
 get_bet_status(Prev,Curr,TargetHappiness).
get_bet_status(Prev,Curr,sadder) when Prev < Curr -> won;
get_bet_status(Prev,Curr,sadder) when Prev > Curr -> loose,
get_bet_status(Prev,Curr,happier) when Prev < Curr -> loose;
get_bet_status(Prev,Curr,happier) when Prev > Curr -> won,
get_bet_status(Prev,Prev,sadder) -> tie,
get_bet_status(Prev,Prev,happier) -> tie,

get_odds(Country,Time,Hapiness)->
 database:count({bets,{Country,Time,Hapiness}})
 /
 database:count({bets,{Country,Time,1-Hapiness}}).


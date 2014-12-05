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

place_bet(Country,TargetTime,TargetStatus) when (TargetStatus /= happier) and (TargetStatus /= sadder) ->
erlang:error(please_use_happier_or_sadder_as_targetstatus);

place_bet(Country,TargetTime,TargetStatus)->
PlacedTime = current_time(),
database:put({bets,{Country,PlacedTime,TargetTime,TargetStatus}}).

get_users_bets()-> [{bets,{"Sweden",1,10,happier}}]. %Not implemented

get_all_bet_status(UserName) ->
Bets = get_users_bets(),
Statuses = [get_bet_status(Country,PlacedTime,TargetTime,TargetHappiness,checktime) || {bets,{Country,PlacedTime,TargetTime,TargetHappiness}}<-Bets]
,Statuses.

get_bet_status(Country,PlacedTime,TargetTime,TargetHappiness,checktime) ->
CurrentTime = current_time(),
if
 TargetTime < CurrentTime -> inprogress;
 true -> get_bet_status(Country,PlacedTime,TargetTime,TargetHappiness)
end.

get_bet_status(Country,PlacedTime,Time,TargetHappiness) ->
Curr = country:getHappiness(Country, Time) / country:getTotal(Country, Time),
Prev = country:getHappiness(Country, PlacedTime) / country:getTotal(Country, PlacedTime),
get_bet_status(Prev,Curr,TargetHappiness).

get_bet_status(Prev,Curr,sadder) when Curr < Prev -> won;
get_bet_status(Prev,Curr,sadder) when Curr > Prev  -> loose;
get_bet_status(Prev,Curr,happier) when Curr > Prev -> won;
get_bet_status(Prev,Curr,happier) when Curr < Prev  -> loose;
get_bet_status(Prev,Prev,sadder) -> tie;
get_bet_status(Prev,Prev,happier) -> tie.

get_odds(Country,Time,Hapiness)->
database:count({bets,{Country,Time,Hapiness}})
/
database:count({bets,{Country,Time,1-Hapiness}}).


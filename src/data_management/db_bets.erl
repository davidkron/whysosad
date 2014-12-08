%%%-------------------------------------------------------------------
%%% @author david
%%% @copyright (C) 2014, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 08. Dec 2014 6:41 PM
%%%-------------------------------------------------------------------

-module(db_bets).
-author("david").

%% API
-export([get_bets/1, set_bets/2, create/7]).

get_bets(UserName) ->
  Bets = database:fetchMap("bets"),
  maps:get(UserName, Bets, []).

set_bets(UserName, Bets) ->
  database:store_in_store("bets", UserName, Bets).

create(UserName, Country, PlacedTime, TargetTime, TargetStatus, Stake, Odds) ->
  UserBets = get_bets(UserName),
  Newbet = #{country=>Country, placedtime=>PlacedTime, targettime=>TargetTime,
    targetstatus=>TargetStatus, status=>inprogress, credits=>Stake, odds=>Odds, funded=>false},
  database:store_in_store("bets", UserName, [Newbet | UserBets]).
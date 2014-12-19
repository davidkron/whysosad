%%%-------------------------------------------------------------------
%%% @author david
%%% @copyright (C) 2014, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 08. Dec 2014 6:41 PM
%%%-------------------------------------------------------------------

-module(database_bets).
-author("david").

%% API
-export([get_bets/1, set_bets/2, create/7]).

get_bets(RawUserName) ->
  UserName = string:to_lower(RawUserName),
  database:fetch_map("bets", UserName).

set_bets(RawUserName, Bets) ->
  UserName = string:to_lower(RawUserName),
  database:store("bets", UserName, Bets).

create(RawUserName, Country, PlacedTime, TargetTime, TargetStatus, Stake,
    Odds) ->
  UserName = string:to_lower(RawUserName),
  UserBets = get_bets(UserName),
  Newbet = #{country=>Country, placedtime=>PlacedTime, targettime=>TargetTime,
    targetstatus=>TargetStatus, status=>inprogress, credits=>Stake, odds=>Odds, funded=>false},
  database:store("bets", UserName, [Newbet | UserBets]).
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
-export([place_bet/5, get_all_bet_status/1]).

current_time() -> {_, Time, _} = now(), Time.


place_bet(UserName, Password, Country, TargetTime, TargetStatus) ->
  case users:authenticate(UserName, Password) of
    ok ->
      erlang:display("Ok"),
      Status = case TargetStatus of
                 "happier" -> happier;
                 "sadder" -> sadder;
                 _ -> {false, invalid_targetstatus}
               end,
      PlacedTime = current_time(),
      Bets = database:fetch({bets, UserName}),
      database:store({bets, UserName}, [{Country, PlacedTime, TargetTime, Status} | Bets]), ok;
    Error -> Error
  end.

get_users_bets(UserName) ->
  database:fetch({bets, UserName}).

get_all_bet_status(UserName) ->
Bets = get_users_bets(UserName),
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


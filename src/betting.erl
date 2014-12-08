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
-export([place_bet/6, get_users_bets/2]).

current_time() -> {_, Time, _} = now(), Time.


place_bet(UserName, Password, Country, TargetTime, TargetStatus, Credits) ->
  users:authenticated_action(UserName, Password, fun() ->
      Status = case TargetStatus of
                 "happier" -> happier;
                 "sadder" -> sadder;
                 _ -> {false, invalid_targetstatus}
               end,
    PlacedTime = current_time(), % The time the user placed the bet
    users:fund(UserName, -Credits), % Take away the amount of credits the user is betting for now
    Bets = database:fetchMap("bets"),
    UserBets = maps:get(UserName, Bets, []),
    Newbet =
      #{country=>Country, placedtime=>PlacedTime, targettime=>TargetTime,
        targetstatus=>Status, credits=>Credits, odds=>get_odds(Country, TargetTime, TargetStatus), funded=>false},
    database:store_in_store("bets", UserName, [Newbet | UserBets])
  end).

get_users_bets(UserName, Password) ->
  users:authenticated_action(UserName, Password, fun() ->
    update_users_bets(UserName),
    get_users_bets(UserName)
  end).

get_users_bets(UserName) ->
  Bets = database:fetchMap("bets"),
  maps:get(UserName, Bets, []).

update_users_bets(UserName) ->
  Bets = get_users_bets(UserName),
  Statuses = [get_bet_status(Bet) || Bet <- Bets],

  %Fund any unfunded winning bets, and overwrite the previous bets as "funded"
  NewBets = [fund(UserName, Status, Bet) || Status <- Statuses, Bet <- Bets],
  database:store_in_store("bets", UserName, NewBets).

get_bet_status(Bet) ->
  CurrentTime = current_time(),
  Country = maps:get(country, Bet),
  TargetTime = maps:get(targettime, Bet),
  TargetHappiness = maps:get(targetstatus, Bet),
  PlacedTime = maps:get(placedtime, Bet),
  PlacedTime = maps:get(placedtime, Bet),
  if
    (TargetTime < CurrentTime) -> inprogress;
    true ->
      Later = country:getScore(Country, TargetTime),
      Prev = country:getScore(Country, PlacedTime),
      get_bet_status(Prev, Later, TargetHappiness)
  end.

get_bet_status(Prev, Later, sadder) when Later < Prev -> won;
get_bet_status(Prev, Later, sadder) when Later > Prev -> loose;
get_bet_status(Prev, Later, happier) when Later > Prev -> won;
get_bet_status(Prev, Later, happier) when Later < Prev -> loose;
get_bet_status(Prev,Prev,sadder) -> tie;
get_bet_status(Prev,Prev,happier) -> tie.

fund(Username, Status, Bet) ->
  Funded = maps:get(funded, Bet),
  case Funded of
    false ->
      Newbet = Bet#{funded=>true, status=>Status},
      Credits = maps:get(credits, Bet),
      case Status of
        inprogress -> Newbet;
        tie -> users:fund(Username, Credits), Newbet; % Tie, give user his money back 100%
        won ->
          Odds = maps:get(odds, Bet),
          users:fund(Username, Credits * Odds), Newbet; % win, give odds% of money back
        loose -> Newbet % Loose, user dont get his money back
      end;
    true ->
      Bet
  end.

get_odds(_Country, _Time, _Hapiness) -> 1.5.
%database:count({bets,{Country,Time,Hapiness}}) / database:count({bets,{Country,Time,1-Hapiness}}).

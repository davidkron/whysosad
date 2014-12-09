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


place_bet(UserName, Password, Country, TargetTime, TargetStatus, Stake) ->
  users:authenticated_action(UserName, Password, fun() ->
      Status = case TargetStatus of
                 "happier" -> happier;
                 "sadder" -> sadder;
                 _ -> {false, invalid_targetstatus}
               end,
    PlacedTime = current_time(), % The time the user placed the bet
    users:fund(UserName, -Stake), % Take away the amount of credits the user is betting for now
    db_bets:create(UserName, Country, PlacedTime, TargetTime, Status, Stake,
      get_odds(Country, TargetTime, Status))
  end).

get_users_bets(UserName, Password) ->
  users:authenticated_action(UserName, Password, fun() ->
    update_users_bets(UserName),
    db_bets:get_bets(UserName)
  end).

update_users_bets(UserName) ->
  Bets = db_bets:get_bets(UserName),
  Statuses = [get_bet_status(Bet) || Bet <- Bets],
  %Fund any unfunded winning bets, and overwrite the previous bets as "funded"
  NewBets = [fund(UserName, Status, Bet) || Status <- Statuses, Bet <- Bets],
  db_bets:set_bets(UserName, NewBets).

get_bet_status(Bet) ->
  case maps:get(funded, Bet) of
    true -> maps:get(status, Bet, error);
    _ -> calculate_bet_status(Bet)
  end.

calculate_bet_status(Bet) ->
  CurrentTime = current_time(),
  Country = maps:get(country, Bet),
  TargetTime = maps:get(targettime, Bet),
  TargetHappiness = maps:get(targetstatus, Bet),
  PlacedTime = maps:get(placedtime, Bet),
  if
    (CurrentTime < TargetTime) -> inprogress;
    true ->
      Later = country:get_score(Country, TargetTime),
      Prev = country:get_score(Country, PlacedTime),
      calculate_bet_status(Prev, Later, TargetHappiness)
  end.

calculate_bet_status(Prev, Later, sadder) when Later < Prev -> won;
calculate_bet_status(Prev, Later, sadder) when Later > Prev -> loose;
calculate_bet_status(Prev, Later, happier) when Later > Prev -> won;
calculate_bet_status(Prev, Later, happier) when Later < Prev -> loose;
calculate_bet_status(Prev, Prev, sadder) -> tie;
calculate_bet_status(Prev, Prev, happier) -> tie.

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

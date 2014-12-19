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
-export([place_bet/7, get_users_bets/2]).

get_bet_target_time(TargetHour, TargetMin) ->
  {_, {Hour, Min, _}} = calendar:local_time(),
  Targettime_today_s = (TargetHour * 60 + TargetMin) * 60,
  Currenttime_today_s = (Hour * 60 + Min) * 60,
  Timediff_s = Targettime_today_s - Currenttime_today_s,
  case (Timediff_s < 0) of
    true ->
      util:current_time() + ((Timediff_s + (24 * 60 * 60)) div const:interval_s());
    false ->
      util:current_time() + (Timediff_s div const:interval_s())
  end.


place_bet(UserName, Password, Country, TargetHour, TargetMin, TargetStatus, Stake) ->
  users:authenticated_action(UserName, Password, fun() ->
    TargetTime = get_bet_target_time(TargetHour, TargetMin),
    PlacedTime = util:current_time(), % The time the user placed the bet
    case PlacedTime == TargetTime of
      true -> throw("Cant bet on current time");
      false -> ok
    end,
    Status = case TargetStatus of
               "happier" -> happier;
               "sadder" -> sadder;
               _ -> throw("invalid_targetstatus")
             end,
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
  NewBets = [update_bet(UserName, Bet) || Bet <- Bets],
  db_bets:set_bets(UserName, NewBets).

update_bet(UserName, Bet) ->
  Status = get_bet_status(Bet),
  %Fund any unfunded winning bets, and overwrite the previous bets as "funded"
  NewBet = fund(UserName, Status, Bet),
  NewBet.

get_bet_status(Bet) ->
  case maps:get(funded, Bet) of
    true -> maps:get(status, Bet, error);
    _ -> calculate_bet_status(Bet)
  end.

calculate_bet_status(Bet) ->
  CurrentTime = util:current_time(),
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
      Newbet = Bet#{status=>Status},
      Credits = maps:get(credits, Bet),
      case Status of
        inprogress -> Newbet;
        tie -> users:fund(Username, Credits), Newbet#{funded=>true}; % Tie, give user his money back 100%
        won ->
          Odds = maps:get(odds, Bet),
          users:fund(Username, Credits * Odds), Newbet#{funded=>true}; % win, give odds% of money back
        loose -> Newbet#{funded=>true} % Loose, user dont get his money back
      end;
    true ->
      Bet
  end.

get_odds(_Country, _Time, _Hapiness) -> 1.5.

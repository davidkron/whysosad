%%%-------------------------------------------------------------------
%%% @author david
%%% @copyright (C) 2014, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 09. Dec 2014 7:42 PM
%%%-------------------------------------------------------------------
-module(util).
-author("david").

%% API
-export([current_time/0, timestamp/0]).

floor(X) when X < 0 ->
  T = trunc(X),
  case X - T == 0 of
    true -> T;
    false -> T - 1
  end;
floor(X) ->
  trunc(X) .

idiv(A, B) ->
  floor(A / B) .

current_time() -> {MegaSecs, Secounds, _} = now(), idiv(MegaSecs * 100000.0 + Secounds,  float(const:interval_s())).

timestamp() ->
  {MegaSecs, Seconds, _} = now(),
  MegaSecs * 1000000 + Seconds.
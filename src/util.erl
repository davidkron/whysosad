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
-export([current_time/0]).

current_time() -> {MegaSecs, Secounds, _} = now(), (MegaSecs * 100000 + Secounds) div const:interval_s().
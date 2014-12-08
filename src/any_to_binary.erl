%%%-------------------------------------------------------------------
%%% @author david
%%% @copyright (C) 2014, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 07. Dec 2014 11:07 PM
%%%-------------------------------------------------------------------
-module(any_to_binary).
-author("david").

%% API
-export([encode/1]).


encode(X)->
  if
  jiffy:encode(X).

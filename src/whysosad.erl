%%%-------------------------------------------------------------------
%%% @author David
%%% @copyright (C) 2014, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 29. okt 2014 07:15
%%%-------------------------------------------------------------------
-module(whysosad).
-author("David").

-export([start/0]).

start()->
  application:ensure_all_started(twitterminer),
  URL = "https://stream.twitter.com/1.1/statuses/filter.json",
  Parameters = [{delimited, length},{stall_warnings, true},{track,":)"}],
  twitterminer_source:mine(URL,Parameters),
  httpserver:start().
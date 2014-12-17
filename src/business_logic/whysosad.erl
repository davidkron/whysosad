%%%-------------------------------------------------------------------
%%% @author David
%%% @copyright (C) 2014, Pegasus
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
  Parameters = [{delimited, length},{stall_warnings, true},{track,string:join(const:sad_smileys() ++ const:happy_smileys(),",")}],
  process_flag(trap_exit, true),
  spawn_link(fun ()->httpserver:start() end),
  twitterminer_source:start(),
  twitter_loop(URL,Parameters).

twitter_loop(URL, Parameters)->
    twitterminer_source:mine(URL,Parameters),
    twitter_loop(URL, Parameters).

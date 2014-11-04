%%%-------------------------------------------------------------------
%%% @author David
%%% @copyright (C) 2014, Pegasus
%%% @doc
%%%
%%% @end
%%% Created : 31. okt 2014 15:18
%%%-------------------------------------------------------------------
-module(httpserver).
-author("David").

-export([start/0]).

start() ->
  inets:start(),
  {Httpd_State,Httpd_Pid} = inets:start(httpd, [{port, 8099},
    {server_name, "localhost"}, {document_root, "."},
    {modules,[mod_esi]},{server_root, "."},
    {erl_script_alias, {"/esi", [esi_facade, io]}}]),
  io:format("Webserver started at port 8099").
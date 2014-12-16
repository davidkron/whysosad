%%%-------------------------------------------------------------------
%%% @author Simeon
%%% @copyright (C) 2014, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 15. Dec 2014 17:31
%%%-------------------------------------------------------------------
-module(database_sup).
-author("Simeon").
-behaviour(supervisor).

%% API
-export([init/1, start_link/0]).

start_link() -> supervisor:start_link({local, ?MODULE}, ?MODULE, []).

init([]) ->
  ChildSpecs = {database, {database, start, []}, permanent, 2000, worker,
    [database]},
  {ok, {{one_for_one, 3, 5}, [ChildSpecs]}}.
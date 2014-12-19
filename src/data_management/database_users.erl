%%%-------------------------------------------------------------------
%%% @author David Jensen, Simeon Ivanov
%%% @copyright (C) 2014, Team Pegasus
%%% @doc
%%%
%%% @end
%%% Created : 08. Dec 2014 7:00 PM
%%%-------------------------------------------------------------------
-module(database_users).
-author("david").

%% API
-export([exists/1, create/3, get_credits/1, get_salt/1, get_password/1,
  remove/1, set_password/3, increment_credits/2, decrement_credits/2]).

exists(RawUserName) ->
  UserName = string:to_lower(RawUserName),
  Map = database:fetch_map("users", UserName),
  case Map of
    #{} -> false;
    _ -> true
  end.

create(RawUserName, SecurePassword, Salt) ->
  UserName = string:to_lower(RawUserName),
  Map = database:fetch_map("users", UserName),
  MapPassword = maps:put("password", SecurePassword, Map),
  MapSalt = maps:put("ruid", Salt, MapPassword),
  MapCredits = maps:put("credits", 100, MapSalt),
  database:store("users", UserName, MapCredits).

get_credits(RawUserName) ->
  UserName = string:to_lower(RawUserName),
  Map = database:fetch_map("users", UserName),
  maps:get("credits", Map, 0).

increment_credits(RawUserName, By) ->
  UserName = string:to_lower(RawUserName),
  Map = database:fetch_map("users", UserName),
  Credits = maps:get("credits", Map, 0),
  database:store("users", UserName, maps:put("credits", Credits + By, Map)).

decrement_credits(RawUserName, By) ->
  UserName = string:to_lower(RawUserName),
  Map = database:fetch_map("users", UserName),
  Credits = maps:get("credits", Map, 0),
  database:store("users", UserName, maps:put("credits", Credits - By, Map)).

get_salt(RawUserName) ->
  UserName = string:to_lower(RawUserName),
  Map = database:fetch_map("users", UserName),
  maps:get("ruid", Map).

get_password(RawUserName) ->
  UserName = string:to_lower(RawUserName),
  Map = database:fetch_map("users", UserName),
  maps:get("password", Map).

set_password(RawUserName, SecurePassword, Salt) ->
  UserName = string:to_lower(RawUserName),
  Map = database:fetch_map("users", UserName),
  MapPassword = maps:put("password", SecurePassword, Map),
  MapSalt = maps:put("ruid", Salt, MapPassword),
  database:store("users", UserName, maps:put("credits", 100, MapSalt)).

remove(RawUserName) ->
  UserName = string:to_lower(RawUserName),
  database:remove("users", UserName).
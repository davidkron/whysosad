%%%-------------------------------------------------------------------
%%% @author david
%%% @copyright (C) 2014, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 08. Dec 2014 7:00 PM
%%%-------------------------------------------------------------------
-module(db_users).
-author("david").

%% API
-export([exists/1, create/3, get_credits/1, get_salt/1, get_password/1, set_credits/2, remove/1, set_password/3]).

get_user(UserName) ->
  UsersMap = database:fetchMap("users"),
  User = maps:get(UserName, UsersMap, not_found),
  case User of
    not_found -> throw("user_does_not_exist");
    X -> X
  end.

exists(UserName) ->
  try db_users:get(UserName)
  of _ -> true
  catch "user_does_not_exist" -> false
  end.

create(UserName, SecurePassword, Salt) ->
  NewUser = #{"password" => SecurePassword, "ruid" => Salt, "credits"=>100},
  database:store_in_store("users", UserName, NewUser).

get_credits(UserName) -> maps:get("credits", get_user(UserName), 0).
get_salt(UserName) -> maps:get("ruid", get_user(UserName)).
get_password(UserName) -> maps:get("password", get_user(UserName)).

set_credits(UserName, NewCredits) ->
  NewUser = maps:put("credits", NewCredits, get_user(UserName)),
  database:store_in_store("users", UserName, NewUser).

remove(UserName) ->
  UsersMap = database:fetchMap("users"),
  NewUsersMap = maps:remove(UserName, UsersMap),
  database:store("users", NewUsersMap).


set_password(UserName, SecurePassword, Salt) ->
  User = get_user(UserName),
  NewUser = User#{"password" := SecurePassword, "ruid" := Salt},
  database:store_in_store("users", UserName, NewUser).

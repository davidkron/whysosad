%%%-------------------------------------------------------------------
%%% @author Simeon Ivanov
%%% @copyright (C) 2014, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 20. Nov 2014 11:48 AM
%%%-------------------------------------------------------------------
-module(users).
-author("Simeon").

%% API
-export([add/2, remove/1, changePassword/2, authenticate/2, authenticated_action/3, fund/2, get_credits/2]).

add(RawUserName, Password) ->
  ValidUserName = validateUserName(RawUserName),
  ValidPassword = validatePassword(Password),
  if ValidUserName == false ->
    {false, invalid_username};
    ValidPassword == false ->
      {false, invalid_password};
    true ->
      UserName = string:to_lower(RawUserName),
      UsersMap = database:fetchMap("users"),
      UserExists = maps:get(UserName, UsersMap, false),
      if UserExists =/= false ->
        {false, user_exists};
        true ->
          Salt = binary_to_list(crypto:strong_rand_bytes(64)),
          SecurePassword = crypto:hash(sha512, Password ++ Salt),
          NewUser = #{"password" => SecurePassword, "ruid" => Salt, "credits"=>100},
          database:store_in_store("users", UserName, NewUser)
      end
  end.

get_credits(UserName, Password) ->
  authenticate(UserName, Password),
  Users = database:fetchMap("users"),
  User = maps:get(UserName, Users),
  erlang:display(User),
  Credits = maps:get("credits", User, 0),
  erlang:display(Credits),
  Credits.

fund(UserName, CreditsChange) ->
  UsersMap = database:fetchMap("users"),
  User = maps:get(UserName, UsersMap),
  PreviousCredits = maps:get("credits", User),
  if
    (CreditsChange < 0) and (PreviousCredits + CreditsChange < 0) ->
      throw("Not enough credits for credit change");
    true ->
      NewUser = maps:put("credits", PreviousCredits + CreditsChange, User),
      database:store_in_store("users", UserName, NewUser)
  end.

remove(RawUserName) ->
  UserName = string:to_lower(RawUserName),
  UsersMap = database:fetchMap("users"),
  UserExists = maps:get(UserName, UsersMap, false),
  if UserExists == false ->
    {false, user_does_not_exist};
    true ->
      NewUsersMap = maps:remove(UserName, UsersMap),
      database:store("users", NewUsersMap)
  end.

changePassword(UserName, Password) ->
  ValidPassword = validatePassword(Password),
  if ValidPassword == false ->
    {false, invalid_password};
    true ->
      UsersMap = database:fetchMap("users"),
      UserMap = maps:get(UserName, UsersMap, false),
      if (UsersMap == false) ->
        {false, user_does_not_exist};
        true ->
          Salt = binary_to_list(crypto:strong_rand_bytes(64)),
          SecurePassword = crypto:hash(sha512, Password ++ Salt),
          NewUserMap = UserMap#{"password" := SecurePassword, "ruid" := Salt},
          NewUsersMap = maps:put(UserName, NewUserMap, UsersMap),
          database:store("users", NewUsersMap)
      end
  end.

validateUserName(UserName) ->
  %% May contain only latin alphanumeric, and dot and underscore characters.
  %% Can't contain underscore characters at the beginning and end.
  Pattern = "^^([^._])+([a-zA-Z0-9_.])+([^._])+$",
  Match = re:run(UserName, Pattern),
  if Match == nomatch ->
    false;
    true ->
      ok
  end.

validatePassword(Password) ->
  %$ Must contain at least one lowercase letter, one uppercase letter, one numeric digit, and one special character,
  %% but cannot contain whitespace.
  Pattern = "^(?=.*[0-9])(?=.*[a-z])(?=.*[A-Z])(?=.*[^a-zA-Z0-9])(?!.*\s).+$",
  Match = re:run(Password, Pattern),
  if Match == nomatch ->
    false;
    true ->
      ok
  end.

authenticated_action(UserName, Password, Fun) ->
  case users:authenticate(UserName, Password) of
    ok -> Fun();
    Error -> Error
  end.

authenticate(RawUserName, Password) ->
  UserName = string:to_lower(RawUserName),
  UsersMap = database:fetchMap("users"),
  UserMap = maps:get(UserName, UsersMap, false),
  if (UserMap == false) ->
    throw("user_does_not_exist");
    true ->
      Salt = maps:get("ruid", UserMap),
      SecurePassword = crypto:hash(sha512, Password ++ Salt),
      StoredPassword = maps:get("password", UserMap),
      if (StoredPassword == SecurePassword) ->
        ok;
        true ->
          throw("wrong_password")
      end
  end.
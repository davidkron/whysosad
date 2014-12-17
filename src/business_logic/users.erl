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
  if
    ValidUserName == false -> throw("invalid_username");
    ValidPassword == false -> throw("invalid_password");
    true ->
      UserName = string:to_lower(RawUserName),
      case db_users:exists(UserName) of
        true -> throw("user_allready_exists");
        false ->
          Salt = binary_to_list(crypto:strong_rand_bytes(64)),
          SecurePassword = crypto:hash(sha512, Password ++ Salt),
          db_users:create(UserName, SecurePassword, Salt)
      end
  end.

get_credits(UserName, Password) ->
  authenticate(UserName, Password),
  db_users:get_credits(UserName).

fund(UserName, CreditsChange) ->
  PreviousCredits = db_users:get_credits(UserName),
  if
    (CreditsChange < 0) and (PreviousCredits + CreditsChange < 0) ->
      throw("Not enough credits for credit change");
    true ->
      db_users:set_credits(UserName, PreviousCredits + CreditsChange)
  end.

remove(RawUserName) ->
  UserName = string:to_lower(RawUserName),
  case db_users:exists(UserName) of
    false -> {error, user_does_not_exist};
    true -> db_users:remove(UserName)
  end.

changePassword(UserName, Password) ->
  validatePassword(Password),
  Salt = binary_to_list(crypto:strong_rand_bytes(64)),
  SecurePassword = crypto:hash(sha512, Password ++ Salt),
  db_users:set_password(UserName, SecurePassword, Salt).

validateUserName(UserName) ->
  %% May contain only latin alphanumeric, and dot and underscore characters.
  %% Can't contain underscore characters at the beginning and at the end.
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
  case Match of
    nomatch -> throw("invalid password");
    _ -> ok
  end.

authenticated_action(UserName, Password, Fun) ->
  case users:authenticate(UserName, Password) of
    true -> Fun();
    Error -> Error
  end.

authenticate(RawUserName, Password) ->
  UserName = string:to_lower(RawUserName),
  Salt = db_users:get_salt(UserName),
  SecurePassword = crypto:hash(sha512, Password ++ Salt),
  StoredPassword = db_users:get_password(UserName),
  case (StoredPassword == SecurePassword) of
    true ->
      true;
    false -> throw("wrong_password")
  end.
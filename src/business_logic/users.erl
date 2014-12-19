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
-export([add/2, remove/1, change_password/2, authenticate/2,
  authenticated_action/3, fund/2, get_credits/2, charge/2]).

add(UserName, Password) ->
  ValidUserName = validate_username(UserName),
  ValidPassword = validate_password(Password),
  if
    ValidUserName == false -> throw("invalid_username");
    ValidPassword == false -> throw("invalid_password");
    true ->
      case database_users:exists(UserName) of
        true -> throw("user_already_exists");
        false ->
          Salt = binary_to_list(crypto:strong_rand_bytes(64)),
          SecurePassword = crypto:hash(sha512, Password ++ Salt),
          database_users:create(UserName, SecurePassword, Salt)
      end
  end.

get_credits(UserName, Password) ->
  authenticate(UserName, Password),
  database_users:get_credits(UserName).

fund(UserName, Credits) ->
  database_users:increment_credits(UserName, Credits).

charge(UserName, Credits) ->
  Balance = database_users:get_credits(UserName),
  if Credits > Balance ->
    throw("Not enough credits for credit change.");
  true ->
    database_users:decrement_credits(UserName, Credits)
  end.

remove(UserName) ->
  case database_users:exists(UserName) of
    false -> {error, user_does_not_exist};
    true -> database_users:remove(UserName)
  end.

change_password(UserName, Password) ->
  validate_password(Password),
  Salt = binary_to_list(crypto:strong_rand_bytes(64)),
  SecurePassword = crypto:hash(sha512, Password ++ Salt),
  database_users:set_password(UserName, SecurePassword, Salt).

validate_username(UserName) ->
  %% May contain only latin alphanumeric, and dot and underscore characters.
  %% Can't contain underscore characters at the beginning and at the end.
  Pattern = "^^([^._])+([a-zA-Z0-9_.])+([^._])+$",
  Match = re:run(UserName, Pattern),
  case Match of
    nomatch -> false;
    _ -> ok
  end.

validate_password(Password) ->
  Rule = "Must contain at least one lowercase letter, one uppercase letter,
  one numeric digit, and one special character, but cannot contain whitespace.",
  Pattern = "^(?=.*[0-9])(?=.*[a-z])(?=.*[A-Z])(?=.*[^a-zA-Z0-9])(?!.*\s).+$",
  Match = re:run(Password, Pattern),
  case Match of
    nomatch -> throw(Rule);
    _ -> ok
  end.

authenticated_action(UserName, Password, Fun) ->
  case users:authenticate(UserName, Password) of
    true -> Fun();
    Error -> Error
  end.

authenticate(UserName, Password) ->
  Salt = database_users:get_salt(UserName),
  SecurePassword = crypto:hash(sha512, Password ++ Salt),
  StoredPassword = database_users:get_password(UserName),
  case (StoredPassword == SecurePassword) of
    true -> true;
    false -> throw("wrong_password")
  end.
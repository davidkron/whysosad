%%%-------------------------------------------------------------------
%%% @author Simeon Ivanov
%%% @copyright (C) 2014, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 06. Nov 2014 12:53 PM
%%%-------------------------------------------------------------------
-module(database_riak).
-author("Simeon").

%% API
-export([start/0, stop/0, getMap/1, clearMap/1, getTimestamp/1, setTimestamp/2, getHappiness/2, setHappiness/3, getTotal/2, setTotal/3, addUser/2, changePassword/2, validatePassword/1, validateUserName/1, authenticateUser/2]).

start() ->
  ServerPid = whereis(sts),
  if is_pid(ServerPid) == true ->
    already_started;
  true ->
    spawn(fun() -> init() end),
    started
  end.

init() ->
  process_flag(trap_exit, true),
  {ok, Pid} = riakc_pb_socket:start_link("127.0.0.1", 8087),
  register(sts, Pid),
  receive _ ->
    init()
  end.

stop()-> ServerPid = whereis(sts),
  process_flag(trap_exit, true),
  if is_pid(ServerPid) == true -> exit(ServerPid, kill),
      receive
        _-> stopped
      end;
    true -> already_stopped
  end.

clearMap(Key) ->
  riakc_pb_socket:put(sts,
    riakc_obj:new(
      <<"whysosad">>,
      list_to_binary(Key),
      #{}
    )
  ),
  #{}.

getMap(Key) ->
  try
    {_,{_,_,_,_,[{_,Map}],_,_}} = riakc_pb_socket:get(sts,
      <<"whysosad">>,
      list_to_binary(Key)
    ),
    binary_to_term(Map)
  catch
   % If map doesn't exist, create an empty one
    _:_ -> clearMap(Key)
  end.

setCountryData(Country, TimeFrame, Key, Value) ->
  CountriesMap = getMap("countries"),
  CountryMap = maps:get(Country, CountriesMap, #{}),
  TimeFrameMap = maps:get(TimeFrame, CountryMap, #{}),
  NewTimeFrameMap = maps:put(Key, Value, TimeFrameMap),
  NewCountryMap = maps:put(TimeFrame, NewTimeFrameMap, CountryMap),
  NewCountriesMap = maps:put(Country, NewCountryMap, CountriesMap),
  RiakObject = riakc_obj:new(<<"whysosad">>, list_to_binary("countries"), NewCountriesMap),
  riakc_pb_socket:put(sts, RiakObject).

getCountryData(Country, TimeFrame, Key) ->
  CountriesMap = getMap("countries"),
  CountryMap = maps:get(Country, CountriesMap, #{}),
  TimeFrameMap = maps:get(TimeFrame, CountryMap, #{}),
  maps:get(Key, TimeFrameMap, 0).

getTimestamp(Country) -> getCountryData(Country, "previous", "timestamp").

setTimestamp(Country, Value) -> setCountryData(Country, "previous", "timestamp", Value).

getHappiness(Country, TimeFrame) -> getCountryData(Country, TimeFrame, "value").

setHappiness(Country, TimeFrame, Value) -> setCountryData(Country, TimeFrame, "value", Value).

setTotal(Country, TimeFrame, Value) -> setCountryData(Country, TimeFrame, "total", Value).

getTotal(Country, TimeFrame) -> getCountryData(Country, TimeFrame, "total").

addUser(UserName, Password) ->
  ValidUserName = validateUserName(UserName),
  ValidPassword = validatePassword(Password),
  if ValidUserName == false ->
    {false, invalid_username};
  ValidPassword == false ->
    {false, invalid_password};
  true ->
    UsersMap = getMap("users"),
    UserExists = maps:get(UserName, UsersMap, false),
    if UserExists =/= false ->
      {false, user_exists};
    true ->
      Salt = binary_to_list(crypto:strong_rand_bytes(64)),
      SecurePassword = crypto:hash(sha512, Password ++ Salt),
      NewUsersMap = maps:put(UserName, #{"password" => SecurePassword, "ruid" => Salt}, UsersMap),
      RiakObject = riakc_obj:new(<<"whysosad">>, list_to_binary("users"), NewUsersMap),
      riakc_pb_socket:put(sts, RiakObject)
    end
  end.

changePassword(UserName, Password) ->
  ValidPassword = validatePassword(Password),
  if ValidPassword == false ->
    {false, invalid_password};
  true ->
    UsersMap = getMap("users"),
    UserMap = maps:get(UserName, UsersMap, false),
    if (UsersMap == false) ->
      {false, user_does_not_exist};
    true ->
      Salt = binary_to_list(crypto:strong_rand_bytes(64)),
      SecurePassword = crypto:hash(sha512, Password ++ Salt),
      NewUserMap = UserMap#{"password" := SecurePassword, "ruid" := Salt},
      NewUsersMap = maps:put(UserName, NewUserMap, UsersMap),
      RiakObject = riakc_obj:new(<<"whysosad">>, list_to_binary("users"), NewUsersMap),
      riakc_pb_socket:put(sts, RiakObject)
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

authenticateUser(UserName, Password) ->
  UsersMap = getMap("users"),
  UserMap = maps:get(UserName, UsersMap, false),
  if (UserMap == false) ->
    {false, user_does_not_exist};
  true ->
    Salt = maps:get("ruid", UserMap),
    SecurePassword = crypto:hash(sha512, Password ++ Salt),
    StoredPassword = maps:get("password", UserMap),
    if (StoredPassword == SecurePassword) ->
      ok;
    true ->
      {false, wrong_password}
    end
  end.
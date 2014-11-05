%%%-------------------------------------------------------------------
%%% @author David
%%% @copyright (C) 2014, <Pegasus>
%%% @doc
%%%
%%% @end
%%% Created : 24. okt 2014 17:24
%%%-------------------------------------------------------------------
-module(happines_calculator).
-author("David").
-export([add_tweet/3,start/0]).

start()-> database:start().

string_count(String,SearchString) ->
  Position = string:str(String,SearchString),
  if
    Position > 0 -> string_count(string:substr(String,Position + 1),SearchString) + 1;
    Position == 0 -> 0
  end.

add_tweet(TT,ResultPlace,Time) ->
  case ResultPlace of
    {found,X}->
      case X of
          not_found -> ok;
          null -> ok;
        {L} ->
            Tweet = binary_to_list(TT),
            TimeInMinutes = binary_to_integer(Time) div (60*60),
            %Print Country code
            {_, Country} = lists:keyfind(<<"country_code">>, 1, L),
            CountryString = binary_to_list(Country),
            PreviousHappy = database:getData(CountryString),
            Happy = string_count(Tweet,":)") + string_count(Tweet,"(:"),
            Sadness = string_count(Tweet,"):") + string_count(Tweet,":("),
            if
              Happy > Sadness -> database:setData(CountryString,PreviousHappy+1);
              Sadness > Happy -> database:setData(CountryString,PreviousHappy-1);
              Sadness == Happy -> ok
            end
      end;
    X -> io:format("Something: ~p ~n",X)
  end.


get_happiness(Country) ->
  ok.

put_into_database(happiness,countrycode)->
  database:put(happiness,countrycode).
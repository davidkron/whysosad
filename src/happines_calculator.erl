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
-export([add_tweet/2,start/0]).

start()-> database:start().

string_count(String,SearchString) ->
  Position = string:str(String,SearchString),
  if
    Position > 0 -> string_count(string:substr(String,Position + 1),SearchString) + 1;
    Position == 0 -> 0
  end.

add_tweet(TT,ResultPlace) ->
  case ResultPlace of
    {found,X}->
      case X of
        not_found -> ok;
        null -> ok;
        {L} ->
          Tweet = binary_to_list(TT),
          {_, Country} = lists:keyfind(<<"country_code">>, 1, L),
          CountryString = binary_to_list(Country),
          PreviousHappy = country:getHappiness(CountryString, "current"),
          PreviousTime = country:getTimestamp(CountryString),
          PreviousTotalTweets = country:getTotal(CountryString, "current"),
          {_, Time, _} = now(),
          if Time - PreviousTime >= 60 ->
            country:setTimestamp(CountryString, Time),
            country:setHappiness(CountryString, "previous", PreviousHappy),
            country:setHappiness(CountryString, "current", 0),
            country:setTotal(CountryString, "previous", PreviousTotalTweets),
            country:setTotal(CountryString, "current", 0);
          true ->
            Happy = lists:sum([string_count(Tweet,Smiley) || Smiley <- const:happy_smileys()]),
            Sadness = lists:sum([string_count(Tweet,Smiley) || Smiley <- const:sad_smileys()]),
              if
                Happy > Sadness -> country:setHappiness(CountryString, "current", PreviousHappy + 1);
                Sadness > Happy -> country:setHappiness(CountryString, "current", PreviousHappy - 1);
                Sadness == Happy -> ok
              end,
            country:setTotal(CountryString, "current", PreviousTotalTweets + 1)
          end
      end;
    X -> io:format("Something: ~p ~n",X)
  end.

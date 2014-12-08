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
          {_, Time_ms, _} = now(),
          Time = Time_ms div const:interval_ms(),
          {_, CountryCode} = lists:keyfind(<<"country_code">>, 1, L),
          Country = binary_to_list(CountryCode),
          Happy = lists:sum([string_count(Tweet,Smiley) || Smiley <- const:happy_smileys()]),
          Sadness = lists:sum([string_count(Tweet,Smiley) || Smiley <- const:sad_smileys()]),
          if
            Happy > Sadness -> country:increase_happiness(Country, Time);
            Sadness > Happy -> country:decrease_happiness(Country, Time);
            Sadness == Happy -> ok
          end,
          country:increase_total(Country, Time)
      end;
    X -> io:format("Something: ~p ~n",X)
  end.

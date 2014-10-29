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
-export([add_tweet/4]).

add_tweet(TT,ResultGeo,ResultCoordinates,ResultPlace) ->
  case ResultPlace of
    {found,X}->
      case X of
          not_found -> ok;
          null -> ok;
        {L} ->
            %Print Country code
            {_, Country} = lists:keyfind(<<"country_code">>, 1, L),
            CountryString = binary_to_list(Country),
            io:format(lists:append("~nCountry:", CountryString)),

            %Print tweet text
            io:format("~ntweet: ~ts", TT)
      end;
    X -> io:format("Something: ~p ~n",X)
  end.


get_happiness(Country) ->
  ok.

happiness_of_tweet(tweet) ->
  10.

put_into_database(happiness,countrycode)->
  database:put(happiness,countrycode).
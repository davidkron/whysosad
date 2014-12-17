%%%-------------------------------------------------------------------
%%% @author david
%%% @copyright (C) 2014, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 18. Dec 2014 12:38 AM
%%%-------------------------------------------------------------------
-module(esi_util).
-author("david").
-import(proplists, [get_value/2]).

%% API
-export([map_to_json/1,safe_deliver/2,required_param/2,required_param_int/2]).


required_param_int(Param, Args) -> list_to_integer(required_param(Param, Args)).

required_param(Param, Args) ->
  case get_value(Param, Args) of
    undefined -> throw("Missing parameter '" ++ Param ++ "'");
    X -> X
  end.

to_list(X) when is_list(X) -> X;
to_list(X) when is_atom(X) -> atom_to_list(X);
to_list(X) when is_integer(X) -> integer_to_list(X);
to_list(X) when is_float(X) -> float_to_list(X);
to_list(X) -> erlang:display(X).

map_to_json(Map) ->
  KeyValues = ["\"" ++ to_list(Key) ++ "\"" ++ "\: " ++ to_list(maps:get(Key, Map)) || Key <- maps:keys(Map)],
  "{" ++ string:join(KeyValues, ",") ++ "}".

safe_deliver(Sid, Fun) ->
  try Fun() of
    {error, Error} -> mod_esi:deliver(Sid, "{Error:" ++ atom_to_list(Error) ++ "}");
    true -> mod_esi:deliver(Sid, "Success");
    ok -> mod_esi:deliver(Sid, "Success");
    Result -> mod_esi:deliver(Sid, Result)
  catch
    error:Error -> erlang:display(erlang:get_stacktrace()),
      mod_esi:deliver(Sid, "{Error:" ++ atom_to_list(Error) ++ "}");
    Error -> mod_esi:deliver(Sid, "{Error:" ++ Error ++ "}")
  end.

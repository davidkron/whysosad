%%%-------------------------------------------------------------------
%%% @author Yilmas
%%% @copyright (C) 2014, <Pegasus>
%%% @doc
%%%
%%% @end
%%% Created : 24. okt 2014 19:12
%%%-------------------------------------------------------------------

-module(easyio).
-export([readlines/1,write/2]).

readlines(FileName) ->
  {ok, Device} = file:open(FileName, [read]),
  get_all_lines(Device, []).

get_all_lines(Device, Accum) ->
  case io:get_line(Device, "") of
    eof  -> file:close(Device), lists:reverse(Accum);
    Line -> get_all_lines(Device, [Line|Accum])
  end.

%Where the file is at : C:\Program Files\erl5.10.4\usr
%file_read:write("Words.txt",[1,2,3]).
%file_read:readlines("Words.txt").
write(File,L) ->
  {ok, S} = file:open(File, write),
  lists:foreach( fun(X) -> io:format(S, "~p.~n",[X]) end, L),
  file:close(S).

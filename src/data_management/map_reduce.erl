%% @author lijiaxin
%% @doc @todo Add description to map_reduce.


-module(map_reduce).

%% ====================================================================
%% API functions
%% ====================================================================

-export([reduce_task/2, map_task/2,
         test_map_reduce/0,
        repeat_exec/2]).
%%% The entry point of the map/reduce framework
%%% It first starts all the R number of Reducer processes
%%% Then starts all the M number of Mapper processes, passing them the R reducer processes ids
%%%  For each line of input data, it randomly pick one of the M mapper processes and send the line to it
%%%  Wait until the completion has finished
%%%  Collect result from the R reducer processes
%%%  Return the collected result
map_reduce(M, R, Map_func,Reduce_func, Acc0, List) ->
	io:format("Map_reduce task started~n"),
	io:format("Start all the reducer processes~n"),
 	Reduce_processes =
  	 repeat_exec(R,
    	 fun(_) ->
    	   spawn(map_reduce, reduce_task,[Acc0, Reduce_func])
    	 end),

 io:format("Reduce processes ~w are started~n",
           [Reduce_processes]),

io:format(" Start all mapper processes~n"),
 Map_processes =
   repeat_exec(M,
     fun(_) ->
       spawn(map_reduce, map_task,
             [Reduce_processes, Map_func])
     end),

 io:format("Map processes ~w are started~n",
           [Map_processes]),

 io:format("Send the data to the mapper processes~n"),
 Extract_func =
   fun(N) ->
     Extracted_line = lists:nth(N+1, List),
     Map_proc = find_mapper(Map_processes),
     io:format("Send ~w to map process ~w~n",
               [Extracted_line, Map_proc]),
     Map_proc ! {map, Extracted_line}
   end,

 repeat_exec(length(List), Extract_func),

 timer:sleep(2000), % must be changed to a safe way later!!! 

 %% Collect the result from all reducer processes
 io:format("Collect all data from reduce processes~n"),
 All_results =
   repeat_exec(length(Reduce_processes),
     fun(N) ->
       collect(lists:nth(N+1, Reduce_processes))
     end),
 lists:flatten(All_results).



%%% Testing of Map reduce using word count
test_map_reduce() ->
 M_func = fun(Line) ->
            lists:map(
              fun(Word) ->
                {Word, 1}
              end, Line)
          end,

 R_func = fun(V1, Acc) ->
            Acc + V1
          end,

 map_reduce(3, 5, M_func, R_func, 0,
            [[this, is, a, boy],
           [this, is, a, girl],
             [this, is, lovely, boy]]).
%spawn(map_reduce, reduce_task,
 %           [0, R_func]).
 
%% ====================================================================
%% Internal functions
%% ====================================================================

%%% Execute the function N times,
%%%   and put the result into a list
repeat_exec(N,Func) ->
 lists:map(Func, lists:seq(0, N-1)).

%%% Identify the reducer process by
%%%   using the hashcode of the key
find_reducer(Processes, Key) ->
 Index = erlang:phash(Key, length(Processes)),
 lists:nth(Index, Processes).

%%% Identify the mapper process by random
find_mapper(Processes) ->
 case random:uniform(length(Processes)) of
   0 ->
     find_mapper(Processes);
   N ->
     lists:nth(N, Processes)
 end.

%%% Collect result synchronously from
%%%   a reducer process
collect(Reduce_proc) ->
 Reduce_proc ! {collect, self()},
 receive
   {result, Result} ->
     Result
 end.

%%% The mapper process
%%% Receive the input line
%%% Execute the User provided Map function to turn into a list of key, value pairs
%%% For each key and value, select a reducer process and send the key, value to it
map_task(Reduce_processes, MapFun) ->
%	 io:format("Map task started~n"),
 receive
   {map, Data} ->
     IntermediateResults = MapFun(Data),
     io:format("Map function produce: ~w~n",
               [IntermediateResults ]),
     lists:foreach(
       fun({K, V}) ->
         Reducer_proc =
           find_reducer(Reduce_processes, K),
         Reducer_proc ! {reduce, {K, V}}
       end, IntermediateResults),

     map_task(Reduce_processes, MapFun)
 end.

%%% The reducer process
%%% Receive the key, value from the Mapper process
%%% Get the current accumulated value by the key. If no accumulated value is found, use the initial accumulated value
%%% Invoke the user provided reduce function to calculate the new accumulated value
%%% Store the new accumulated value under the key
reduce_task(Acc0, ReduceFun) ->
%	io:format("Reduce task started~n"),
 receive
   {reduce, {K, V}} ->
     Acc = case get(K) of
             undefined ->
               Acc0;
             Current_acc ->
               Current_acc
           end,
     put(K, ReduceFun(V, Acc)),
     reduce_task(Acc0, ReduceFun);
   {collect, PPid} ->
     PPid ! {result, get()},
     reduce_task(Acc0, ReduceFun)
 end.

-module(esi_facade).
-export([current_happiness/3,happiness_change/3]).

current_happiness(Sid, Env, In) -> mod_esi:deliver(Sid, ["{\"Sweden\":42,\"Denmark\":120,}"]).
happiness_change(Sid, Env, In) -> mod_esi:deliver(Sid, ["{\"Sweden\":-5,\"Denmark\":200,}"]).
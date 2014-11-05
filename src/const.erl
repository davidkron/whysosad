-module(const).
-export([sad_smileys/0,happy_smileys/0]).

happy_smileys()->[":)", "(:", ":D"].

sad_smileys() -> [":/", ":(" ,"):", ":'("].

1.  Compile the dependencies and the package

        $ rebar compile

2.  Run

    Run the Erlang shell from the repo's toplevel directory with additional library path and configuration flags

        $ erl -pa deps/*/ebin -pa ebin -config twitterminer

    Now you are ready to run your example.

    ```erlang
    2> whysosad:start().
    ```

    If everything goes OK, you should see a stream of tweets running for 60 s. If you get a message indicating HTTP response code 401, it probably means authentication error.

## Dependencies

### [erlang-oauth](https://github.com/tim/erlang-oauth/)

erlang-oauth is used to construct signed request parameters required by OAuth.

### [ibrowse](https://github.com/cmullaparthi/ibrowse)

ibrowse is an HTTP client allowing to close a connection while the request is still being serviced. We need this for cancelling Twitter streaming API requests.

### [jiffy](https://github.com/davisp/jiffy)

jiffy is a JSON parser, which uses efficient C code to perform the actual parsing. [mochijson2](https://github.com/bjnortier/mochijson2) is another alternative that could be used here.

## Based on  dit029-twitter-miner by Michal Palka

Fork of derrivation: https://github.com/davidkron/dit029-twitter-miner

* Michal Palka (michalpalka) <michal.palka@chalmers.se>


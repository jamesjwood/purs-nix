%% Erlang FFI implementation
-module(main@foreign).
-export([erlGreet/1, erlMultiply/2]).

%% Simple greeting function
erlGreet(Name) ->
    <<"Hello from Erlang, ", Name/binary, "!">>.

%% Curried multiply function (PureScript style)
erlMultiply(A) ->
    fun(B) -> A * B end.

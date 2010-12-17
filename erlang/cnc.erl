-module(cnc).
-compile(export_all).

% Factorial
fac(N) when N < 2 -> 1;
fac(N)            -> N * fac(N-1).

% Fibonacci Seq.
fib(N) when N =:= 0 -> 0;
fib(N) when N =:= 1 -> 1;
fib(N)              -> fib(N-1) + fib(N-2).

% Add up a list of numbers.
addup([])    -> 0;
addup([H|T]) -> H + addup(T);
addup(N)     -> addup(lists:seq(1,N)).

% Is N evenly divisable by D?
can_evenly_div_by(N,D) -> N rem D =:= 0.

% is N a prime number
is_prime(N) when N < 2 -> false;
is_prime(2)            -> true;
is_prime(N)            ->
    lists:all
    (
        fun(Bool) -> Bool == true end,
        [ not can_evenly_div_by(N,D) || D <- lists:seq(2,N-1)]
    ).

% Compute all primes up to N
primes(N) -> lists:filter(fun(X) -> is_prime(X) end, lists:seq(0,N)).

:- use_module(library(files)).
:- use_module(library(iso_ext)).
:- use_module(library(lists)).
:- use_module(library(os), [setenv/2, getenv/2, shell/2]).

check(Time) :-
    act(Target, Time),
    ground(Target),
    ground(Time).

act(Target, Time) :-
    getenv("TARGET", Target),
    (   file_access_time(Target, Time)
    ;   file_creation_time(Target, Time)
    ;   file_modification_time(Target, Time) ).

main :-
    call_cleanup(
       (setenv("TARGET", "./file_time_test"),
        shell("touch ./file_time_test", 0),
        findall(T, check(T), Ts),
        length(Ts, 3)),
        shell("rm -f ./file_time_test", 0)
    ).

:- initialization(main).

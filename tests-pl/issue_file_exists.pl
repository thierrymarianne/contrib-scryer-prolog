:- use_module(library(files)).
:- use_module(library(iso_ext)).
:- use_module(library(os), [setenv/2, getenv/2, shell/2]).

check :-
    act(Target),
    ground(Target),
    write(Target).

act(Target) :-
    getenv("TARGET", Target),
    file_exists(Target).

main :-
    call_cleanup(
       (setenv("TARGET", "./file_exists_test"),
        shell("touch ./file_exists_test", 0),
        check),
        shell("rm -f ./file_exists_test", 0)
    ).

:- initialization(main).

:- use_module(library(files)).
:- use_module(library(iso_ext)).
:- use_module(library(lists)).
:- use_module(library(os), [setenv/2, getenv/2, shell/2]).

check :-
    act(Target, Size),
    ground(Target),
    integer(Size).

act(Target, Size) :-
    getenv("TARGET", Target),
	file_size(Target, Size).

main :-
    call_cleanup(
       (setenv("TARGET", "./file_size_test"),
        shell("echo '1' > ./file_size_test", 0),
        check),
        shell("rm -f ./file_size_test", 0)
    ).

:- initialization(main).

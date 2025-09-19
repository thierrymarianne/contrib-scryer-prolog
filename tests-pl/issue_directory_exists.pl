:- use_module(library(files)).
:- use_module(library(os), [setenv/2, getenv/2]).

check :-
    act(TargetDir),
    ground(TargetDir).

act(Dir) :-
    getenv("TARGET_DIRECTORY", Dir),
	\+ directory_exists(Dir),
	throw(existence_error(directory,Dir)).
act(Dir) :-
    getenv("TARGET_DIRECTORY", Dir),
    directory_exists(Dir).

main :-
	setenv("TARGET_DIRECTORY", "./"),
	check.

:- initialization(main).

:- use_module(library(lists)).
:- use_module(library(files)).
:- use_module(library(os)).
:- use_module(library(time)).
:- use_module('./examples/lptp.pl').

main :-
    working_directory(Dir, Dir),
    append(Dir, "/lptp", LptpDir),
	setenv("LPTP_ROOT_DIR", LptpDir),
	consult('examples/taut/taut.pr').

:- initialization(main).

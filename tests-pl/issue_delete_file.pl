:- use_module(library(files)).
:- use_module(library(iso_ext)).
:- use_module(library(os), [setenv/2, getenv/2, shell/2]).

check :-
    act(Target),
    ground(Target).

act(File) :-
    getenv("TARGET", File),
	delete_file(File),
	\+ shell("ls delete_file_test", 1),
	throw(system_error).
act(File) :-
    getenv("TARGET", File),
	shell("ls delete_file_test", 1),
    write(file_deleted).

main :-
    call_cleanup(
       (setenv("TARGET", "delete_file_test"),
        shell("touch delete_file_test", 0),
        check),
        shell("test -e delete_file_test && rm delete_file_test || true", 0)
    ).

:- initialization(main).

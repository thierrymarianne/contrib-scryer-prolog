:- use_module(library(files)).
:- use_module(library(iso_ext)).
:- use_module(library(os), [setenv/2, getenv/2, shell/2]).

check :-
    act(TargetDir),
    ground(TargetDir).

act(Dir) :-
    getenv("TARGET_DIRECTORY", Dir),
	make_directory(Dir),
	shell("ls ./make_directory_test", 1),
	throw(system_error).
act(Dir) :-
    getenv("TARGET_DIRECTORY", Dir),
	shell("ls ./make_directory_test", 0),
    write(directory_made).

main :-
    call_cleanup(
       (setenv("TARGET_DIRECTORY", "./make_directory_test"),
        check),
        shell("test -d ./make_directory_test && rmdir ./make_directory_test || true", 0)
    ).

:- initialization(main).

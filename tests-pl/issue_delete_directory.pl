:- use_module(library(files)).
:- use_module(library(iso_ext)).
:- use_module(library(os), [setenv/2, getenv/2, shell/2]).

check :-
    act(TargetDir),
    ground(TargetDir).

act(Dir) :-
    getenv("TARGET_DIRECTORY", Dir),
	delete_directory(Dir),
	\+ shell("ls ./delete_directory_test", 1),
	throw(system_error).
act(Dir) :-
    getenv("TARGET_DIRECTORY", Dir),
	shell("ls ./delete_directory_test", 1),
    write(directory_deleted).

main :-
    call_cleanup(
       (setenv("TARGET_DIRECTORY", "./delete_directory_test"),
        shell("mkdir ./delete_directory_test", 0),
        check),
        shell("test -d ./delete_directory_test && rmdir ./delete_directory_test || true", 0)
    ).

:- initialization(main).

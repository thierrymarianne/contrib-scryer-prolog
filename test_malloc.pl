:- use_module(library(ffi)).
:- use_module(library(lists)).

test_malloc :-
    Candidates = [
        "libzenroom.dylib",          % String path
        "./libzenroom.dylib",        % Explicit path
        'libzenroom.dylib',          % Atom path
        '/usr/lib/libSystem.B.dylib', % MacOS system lib
        '/lib/x86_64-linux-gnu/libc.so.6', % Linux
        '/lib/libc.so.6'             % Linux fallback
    ],
    try_load(Candidates).

try_load([]) :-
    write('FATAL: Could not load malloc from any candidate library.'), nl,
    halt(1).

try_load([Lib|Rest]) :-
    write('Trying library: '), write(Lib), nl,
    catch(
        (
            use_foreign_module(Lib, [
                malloc([uint64], ptr),
                free([ptr], void)
            ]),
            write('SUCCESS: Loaded malloc/free from '), write(Lib), nl,
            malloc(1024, Ptr),
            write('Allocated pointer: '), write(Ptr), nl,
            free(Ptr),
            write('Freed pointer'), nl,
            halt(0)
        ),
        E,
        (
             write('Failed to load '), write(Lib), write(': '), write(E), nl,
             try_load(Rest)
        )
    ).

:- initialization(test_malloc).

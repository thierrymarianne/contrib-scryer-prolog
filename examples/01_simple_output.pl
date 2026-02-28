% Example 1: Simple String Output
% This example shows how to execute a basic Zencode script

:- use_module(library(zenroom)).

example_simple_output :-
    Script = "Given nothing\nThen print the 'string' 'Hello from Zenroom!'",
    zencode_exec(Script, "", "", Output, Errors),
    write('Output: '), write(Output), nl,
    write('Errors: '), write(Errors), nl.

% Run the example
:- initialization(example_simple_output).

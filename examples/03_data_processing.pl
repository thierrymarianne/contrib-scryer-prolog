% Example 3: Data Processing
% This example shows how to pass data to Zencode scripts

:- use_module(library(zenroom)).

example_data_processing :-
    % Zencode script that processes input data
    Script = "Given I have a 'string' named 'message'\n\
              and I have a 'string' named 'sender'\n\
              Then print the 'message'\n\
              and print the 'sender'",
    
    % Input data as JSON
    Data = "{\"message\":\"Hello Zenroom from Prolog!\",\"sender\":\"Alice\"}",
    
    zencode_exec(Script, "", Data, Output, Errors),
    
    write('=== Data Processing Example ==='), nl,
    write('Input data: '), write(Data), nl,
    write('Output: '), write(Output), nl,
    (Errors \= "" -> 
        (write('Errors: '), write(Errors), nl)
    ;   true
    ).

% Run the example
:- initialization(example_data_processing).

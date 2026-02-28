% Example 2: ECDH Keypair Generation
% This example generates an ECDH keypair for Alice

:- use_module(library(zenroom)).

example_ecdh_keypair :-
    Script = "Scenario 'ecdh': Create keypair\n\
              Given that I am known as 'Alice'\n\
              When I create the ecdh key\n\
              Then print my 'keyring'",
    
    zencode_exec(Script, "", "", Output, Errors),
    
    write('=== ECDH Keypair Generation ==='), nl,
    write('Alice\'s keyring:'), nl,
    write(Output), nl,
    (Errors \= "" -> 
        (write('Errors: '), write(Errors), nl)
    ;   write('No errors.'), nl
    ).

% Run the example
:- initialization(example_ecdh_keypair).

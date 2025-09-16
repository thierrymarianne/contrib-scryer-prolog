
main :-
    one(pattern, Form),
    write(Form).

one(X, Form) :-
    Form = [pattern|[]],
    two(Form).

two([p|_]).       % panicks here
two([(pattern)|_]).

:- initialization(main).

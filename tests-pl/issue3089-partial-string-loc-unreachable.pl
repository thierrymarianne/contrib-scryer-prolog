
main :-
    one(pattern, Form),
    ground(Form).

one(_X, Form) :-
    Form = [pattern|[]],
    two(Form).

two([p|_]).       % panicks here
two([pattern|_]).

:- initialization(main).

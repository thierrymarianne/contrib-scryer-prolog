
test :-
	open('./learn/test-page.dj',read,Stream),
	assertz(stream('test',Stream)).

:- initialization(test).

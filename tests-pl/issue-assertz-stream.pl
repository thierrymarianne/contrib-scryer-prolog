
test :-
	open('./learn/test-page.dj',read,Stream,[alias('test')]),
	assertz(stream('test',Stream)).

:- initialization(test).

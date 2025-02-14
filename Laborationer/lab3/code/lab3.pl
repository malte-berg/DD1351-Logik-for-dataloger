% Load model, initial state and formula from file.
verify(Input) :-
    see(Input), read(T), read(L), read(S), read(F), seen,
    check(T, L, S, [], F).
    % check(T, L, S, U, F)
    % T - The transitions in form of adjacency lists
    % L - The labeling
    % S - Current state
    % U - Currently recorded states
    % F - CTL Formula to check.
    %
    % Should evaluate to true iff the sequent below is valid.
    %
    % (T,L), S |- F
    % U
    % To execute: consult('your_file.pl'). verify('input.txt').
    % Literals DONE
    %check(_, L, S, [], X) :- ...
    %check(_, L, S, [], neg(X)) :- ...
    % And DONE
    %check(T, L, S, [], and(F,G)) :- ...
    % Or DONE
    % AX DONE
    % EX DONE
    % AG DONE
    % EG DONE
    % EF DONE
    % AF DONE

% ------- Literals -------
check(_, L, S, [], X) :-
    member([S, Labels], L),
    member(X, Labels).

check(_, L, S, [], neg(X)) :-
    member([S, Labels], L),
    \+ member(X, Labels).

% ----------- And -----------
check(T, L, S, [], and(F,G)) :-
    check(T, L, S, [], F), %F is found in labels at current node
    check(T, L, S, [], G). %G -||-

% ----------- Or -----------
check(T, L, S, [], or(F,G)) :-
    check(T, L, S, [], F); check(T, L, S, [], G).

% ----------- AF -----------
check(T, L, S, U, af(X)) :-
    \+ member(S, U), % Common rule for both AF1 and AF2
    (
        check(T, L, S, [], X) % AF1
        ;
        % AF2
        member([S, Subnodes], T),
        forall(member(Snew, Subnodes), check(T, L, Snew, [S|U], af(X)))
    ).

% ----------- EF -----------
check(T, L, S, U, ef(X)) :-
    \+ member(S, U), % Common rule for both EF1 and EF2
    (
        check(T, L, S, [], X) % EF1
        ;
        % EF2
        member([S, Subnodes], T),
        member(Snew, Subnodes),
        check(T, L, Snew, [S|U], ef(X))
    ).

% ----------- AX -----------
check(T, L, S, [], ax(X)) :-
    member([S, Subnodes], T),
    forall(member(Snew, Subnodes), check(T, L, Snew, [], X)).

% ----------- EX -----------
check(T, L, S, [], ex(X)) :-
    member([S, Subnodes], T),
    member(Snew, Subnodes),
    check(T, L, Snew, [], X).

% ----------- EG -----------
check(T, L, S, U, eg(X)) :-
    (
      member(S, U) % EG1
      ;
      ( % EG2
        \+ member(S, U),
        check(T, L, S, [], X),
        member([S, Subnodes], T),
        member(Snew, Subnodes),
        check(T, L, Snew, [S|U], eg(X))
      )
    ).

% ----------- AG -----------
check(T, L, S, U, ag(X)) :-
(
    member(S, U) % AG1
    ;
    ( % AG2
        check(T, L, S, [], X),
        \+ member(S, U),
        member([S, Subnodes], T),
        forall(member(Snew, Subnodes), check(T, L, Snew, [S|U], ag(X)))
    )
).

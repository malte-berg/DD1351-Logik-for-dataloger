verify(InputFileName):- %Reads a specified file 
    see(InputFileName),
    read(Prems), read(Goal), read(Proof),
    seen,
    (valid_proof(Prems, Goal, Proof, Proof) -> 
        write(' yes')
    ;   
        write(' no'),
        fail
    ). 

% Base case: Last line of proof
valid_proof(Prems, Goal, [X], FullProof):- 
    (isprem(X, Prems); rules(X, FullProof)),
    X = [_,Goal,_]. % Check if last line of proof is Goal
% Recursive case: Not last line of proof
valid_proof(Prems, Goal, [X|T], FullProof):-
    (isprem(X, Prems); rules(X, FullProof); 
    valid_box(Prems, X, FullProof)),
    valid_proof(Prems, Goal, T, FullProof).

% ===================================================================
% ======================Logical Rules, No Boxes======================
% ===================================================================

%Implication Elimination!
rules([LineNum, B, impel(Line1, Line2)], FullProof):-
    LineNum > Line1, LineNum > Line2,
    member([Line1, A , _], FullProof),
    member([Line2, imp(A,B),_], FullProof).

%Negation Elimination!
rules([LineNum, cont, negel(Line1, Line2)], FullProof):-
    LineNum > Line1, LineNum > Line2,
    member([Line1, A, _], FullProof),
    member([Line2, neg(A), _], FullProof).

%And Introduction!
rules([LineNum, and(A,B), andint(Line1, Line2)], FullProof):-
    LineNum > Line1, LineNum > Line2,
    member([Line1, A, _], FullProof),
    member([Line2, B, _], FullProof). 

%Double Negation Elimination!
rules([LineNum, A, negnegel(LineA)], FullProof):-
    LineNum > LineA,
    member([LineA, neg(neg(A)), _], FullProof).

%Double Negation Introduction!
rules([LineNum, neg(neg(A)), negnegint(LineA)], FullProof):-
    LineNum > LineA,
    member([LineA, A, _], FullProof).

%Modus Tollens!
rules([LineNum, neg(A), mt(Line1, Line2)], FullProof):-
    LineNum > Line1, LineNum > Line2,
    member([Line1, imp(A, B), _], FullProof),
    member([Line2, neg(B), _], FullProof).

%LEM!
rules([_, or(A, neg(A)), lem], _).

%Contradiction Elimination!
rules([LineNum, _, contel(LineA)], FullProof):-
    LineNum > LineA,
    member([LineA, cont, _], FullProof).

%Copy!
rules([LineNum, A, copy(LineA)], FullProof):-
    LineNum > LineA,
    member([LineA, A, _], FullProof).

%And Elimination Left!
rules([LineNum, A, andel1(LineA)], FullProof):-
    LineNum > LineA,
    member([LineA, and(A,_), _], FullProof).

%And Elimination Right!
rules([LineNum, A, andel2(LineA)], FullProof):-
    LineNum > LineA,
    member([LineA, and(_,A), _], FullProof). 

%Or Introduction Left!
rules([LineNum, or(A, _), orint1(LineA)], FullProof):-
    LineNum > LineA,
    member([LineA, A, _], FullProof).

%Or Introduction Right!
rules([LineNum, or(_, A), orint2(LineA)], FullProof):-
    LineNum > LineA,
    member([LineA, A, _], FullProof).

% =====================================================================

% =====================================================================
% ======================Logical Rules, With Boxes!=====================
% =====================================================================

%Implication Introduction!
rules([LineNum, imp(A,B), impint(BoxStart,BoxEnd)], FullProof):-
    LineNum > BoxStart, LineNum > BoxEnd,
    member([[BoxStart, A, assumption]|Box], FullProof),
    last_line([_|Box], [BoxEnd, B, _]).

%Negation Introduction!
rules([LineNum, neg(A), negint(BoxStart,BoxEnd)], FullProof):-
    LineNum > BoxStart, LineNum > BoxEnd,
    member([[BoxStart, A, assumption]|Box], FullProof),
    last_line([_|Box], [BoxEnd, cont, _]).

%PBC!
rules([LineNum, A, pbc(BoxStart,BoxEnd)], FullProof):-
    LineNum > BoxStart, LineNum > BoxEnd,
    member([[BoxStart, neg(A), assumption]|Box], FullProof),
    last_line([_|Box], [BoxEnd, cont, _]).

%Or Elimination!
rules([LineNum, X, orel(OrLine,Box1Start,Box1End,Box2Start,Box2End)], FullProof):-
    LineNum > OrLine, LineNum > Box1End, LineNum > Box2End,
    member([OrLine, or(A,B), _], FullProof),
    member([[Box1Start, A, assumption]|Box1], FullProof),
    last_line([_|Box1], [Box1End, X, _]),
    member([[Box2Start, B, assumption]|Box2], FullProof),
    last_line([_|Box2], [Box2End, X, _]).

% ===================================================================

% ===================================================================
% =========================Helper Predicates=========================
% ===================================================================

%Premise!
isprem([_, A, premise], Prems):-
    member(A, Prems).

% Check if valid box! <3
%Base Case!
valid_box(_, [Line], _):-
    Line = [_, _, assumption].
%Recursive Case!
valid_box(Prems, [Line|Rest], FullProof):-
    Line = [_, _, assumption],
    append([Line|Rest], FullProof, SubProof), % Flattens
    valid_proof(Prems, _, Rest, SubProof).

%Used for finding last line!
%Base Case!
last_line([Line], Line).
%Recursive Case!
last_line([_|Rest], LastLine):-
    last_line(Rest, LastLine).

% ===================================================================
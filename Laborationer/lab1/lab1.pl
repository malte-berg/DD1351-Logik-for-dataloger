%reverse_list([], []).

%reverse_list([Head|Tail], ReversedList):-
    %Input list is split into head and tail
    %tail is then sent recursively
%    reverse_list(Tail, ReversedTail),
%    %These are then appended to the reveresedlist in correct order
%    append(ReversedTail, [Head], ReversedList).

%remove_dupes([], []).



%remove_dupes([Head|Tail], [Head|OutputList]):-
%    \+member(Head, Tail),
    %append([Head], OutputList, ), %Create new list which is then appended to output list
%    remove_dupes(Tail, OutputList).

%remove_duplicates(InputList, OutputList):-
%    reverse_list(InputList, Reversed_List),
%    remove_dupes(Reversed_List, OutputList).

% Predicate to reverse a list
reverse_list([], []).

reverse_list([Head|Tail], ReversedList):-
    reverse_list(Tail, ReversedTail),
    append(ReversedTail, [Head], ReversedList).

% Predicate to remove duplicates from a reversed list
remove_dupes([], []).  % Base case: empty list has no duplicates.

remove_dupes([Head|Tail], OutputList):- %Skips head this recursion
    member(Head, Tail),  % If Head is already in the Tail, skip it.
    remove_dupes(Tail, OutputList).

remove_dupes([Head|Tail], [Head|OutputList]):- %Includes head this recursion
    \+ member(Head, Tail),  % If Head is not in Tail, keep it.
    remove_dupes(Tail, OutputList).

% Main predicate to remove duplicates by first reversing the list
remove_duplicates(InputList, OutputList):-
    reverse_list(InputList, ReversedList),
    remove_dupes(ReversedList, R2List),
    reverse_list(R2List, OutputList).

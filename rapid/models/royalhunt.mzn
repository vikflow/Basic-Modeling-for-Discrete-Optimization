%2 pierwsze przechodza



include "inverse.mzn";
include "alldifferent_except_0.mzn";
include "global_cardinality_low_up_closed.mzn";
include "global_cardinality_closed.mzn";

int: n; % number of court members
set of int: COURT = 1..n;
set of int: COURT_D = 0..n;
int: emperor = 1;
array[COURT] of int: rank;
array[COURT] of int: ability;

int: m; % number of horses
set of int: HORSE = 1..m;
set of int: HORSE_D = 0..m;
 
array[HORSE] of int: beauty;
array[HORSE] of int: speed;

array[COURT,HORSE] of int: enjoy;


array[COURT] of var HORSE_D: horse;
array[HORSE] of var COURT_D: member;
array[HORSE] of var 0..1: penalty;


constraint (n > m -> 
              global_cardinality_closed(horse, [h | h in HORSE_D], 
                [n-m] ++ [1 | h in HORSE])) /\
           (n <= m -> 
             global_cardinality_closed(member, [c | c in COURT_D], [m-n] ++ [1 | c in COURT])); 
             
constraint forall(c in COURT, h in HORSE)
(
  horse[c] = h <-> member[h] = c
);

% constraint inverse(member,horse);

% emperor enjoys the most
constraint forall(m in COURT where horse[m] != 0 /\ m != emperor)
(
  enjoy[m, horse[m]] < enjoy[emperor, horse[emperor]]
);

% rank wyzszy to:
constraint forall(m,n in COURT where m != n)
(
  (rank[m] > rank[n]) -> 
    (
      horse[n] = 0
      \/ (horse[m] = 0 /\ horse[n] = 0)
      \/ beauty[horse[m]] >= beauty[horse[n]]
    )
);
constraint forall(h,i in HORSE where h != i)
(
  (speed[h] > speed[i]) -> 
    (
      ability[member[h]] >= ability[member[i]]
      \/ member[h] = 0
      \/ (member[h] = 0 /\ member[i] = 0)
      \/ penalty[i] = 1
    )
);

%If an entry in the array is negative, then the horse cannot be assigned to the court member.
constraint forall(m in COURT where horse[m] != 0)
(
  enjoy[m, horse[m]] > 0
);




var int: obj;
constraint obj = sum([1 | i, j in HORSE where speed[i] < speed[j] /\ horse[j] != 0 /\
                       ((horse[i] != 0 /\ ability[horse[i]] > ability[horse[j]]) \/ horse[i] = 0)]) * 100;


solve maximize obj;


output["horse = \(horse);\n"];
output["obj = \(obj);\n"];
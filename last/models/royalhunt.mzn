int: n; % number of court members
set of int: COURT = 1..n;
int: emperor = 1;
array[COURT] of int: rank;
array[COURT] of int: ability;

int: m; % number of horses
set of int: HORSE = 1..m;
array[HORSE] of int: beauty;
array[HORSE] of int: speed;

array[COURT,HORSE] of int: enjoy;

include "globals.mzn";
%include "global_cardinality_low_up_closed";
%variables 
array[COURT] of var 0..m: horse;
array[HORSE] of var 0..n:court;
var int: obj;
var int: penalty;

%constraints


constraint if n>m then global_cardinality(horse, [i| i in HORSE], [1| i in HORSE]) else 
global_cardinality_low_up_closed(horse,[i|i in HORSE],[0|i in HORSE],[1|i in HORSE]) endif;

constraint obj = sum(i in COURT)(
  if horse[i] > 0 then enjoy[i, horse[i]] else 0 endif
) - penalty*100;

constraint forall(i in COURT where horse[i]!=0) (enjoy[i,horse[i]] >=0 );
%all court members must ride
constraint (sum(i in COURT) (horse[i] > 0) = min(n, m));

%emperor enjoys the most
constraint max(i in COURT where horse[i]!=0 /\ i!=emperor) (enjoy[i, horse[i]]) < 
enjoy[emperor,horse[emperor]];

%constraint forall(i,j in COURT where i!=j) (rank[i]>rank[j] -> (beauty[horse[i]]>=
%beauty[horse[j]] \/ horse[j]=0) );
constraint (forall(i, j in COURT where rank[i] > rank[j])
             (horse[j] = 0 \/
             (horse[i] = 0 /\ horse[j] = 0) \/ 
             (beauty[horse[i]] >= beauty[horse[j]])));


constraint penalty = 
sum(i,j in HORSE where i!=j) (not(speed[i]>speed[j] ->
(ability[court[i]]>=ability[court[j]] \/ court[i]=0 )) );
 
constraint forall(c in COURT, h in HORSE)(
  horse[c] = h <-> court[h] = c
);

constraint forall(i in COURT where horse[i]!=0) (court[horse[i]] = i);
constraint forall(j in COURT where horse[j]!=0) (court[horse[j]] = j);

solve maximize obj;

output ["horse=\(horse);\nobj=\(obj);"];

% assignment 2
% select a set of raiding warrior
enum WARRIOR;
WARRIOR: dummy;
enum CLAN; % the clan they belong too

int: l; % minimum raid party size
int: u; % maximum raid party size
int: m; % limit of hatreds

array[WARRIOR] of int: strength;
array[WARRIOR] of CLAN: clan;

array[CLAN,CLAN] of 0..1: hates;

 %% actual decision variables
array[1..u] of var WARRIOR: party;
var int: obj ;

constraint obj = sum(i in 1..u where party[i] != dummy)(strength[party[i]]);

% Constraints
constraint forall(i in 1..u-1) (party[i] >= party[i + 1] + (party[i] != dummy));
constraint forall(i in 1..l) (party[i] != dummy);
constraint sum(i, j in 1..u where i > j)(hates[clan[party[i]],clan[party[j]]]) <= m;



set of WARRIOR: raid ::output_only = { fix(party[i]) | i in 1..u where fix(party[i]) != dummy };

output ["raid = \(raid);\nobj = \(obj);\n"];

solve maximize obj;



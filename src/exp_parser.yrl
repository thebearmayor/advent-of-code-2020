Nonterminals E T F.
Terminals int '+' '*' '(' ')'.
Rootsymbol E.
E -> E '+' T      : {plus, '$1', '$3'}.
E -> T            : '$1'.
E -> E '*' T      : {mult, '$1', '$3'}.
T -> F            : '$1'.
F -> '(' E ')'    : '$2'.
F -> int          : '$1'. 

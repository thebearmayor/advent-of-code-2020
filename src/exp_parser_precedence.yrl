Nonterminals E.
Terminals int '+' '*' '(' ')'.
Rootsymbol E.
Left 200 '+'.
Left 100 '*'.
E -> E '+' E      : {plus, '$1', '$3'}.
E -> E '*' E      : {mult, '$1', '$3'}.
E -> '(' E ')'    : '$2'.
E -> int          : '$1'. 

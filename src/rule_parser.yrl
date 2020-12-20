Nonterminals K E R.
Terminals int alpha ':' '|'.
Rootsymbol R.

R -> K ':' E      : {'$1', '$3'}.
K -> int          : element(3, '$1').

E -> int int int  : [element(3, '$1'), element(3, '$2'), element(3, '$3')].
E -> int int      : [element(3, '$1'), element(3, '$2')].
E -> int          : [element(3, '$1')].
E -> E '|' E      : {'$1', '$3'}.
E -> alpha        : element(3, '$1').

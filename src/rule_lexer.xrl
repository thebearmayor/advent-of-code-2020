Definitions.

INT        = [0-9]+
ALPHA      = [a-z]
WHITESPACE = [\s\t\n\r]

Rules.

{INT}         : {token, {int, TokenLine, list_to_integer(TokenChars)}}.
{ALPHA}       : {token, {alpha, TokenLine, TokenChars}}.
\|            : {token, {'|', TokenLine}}.
\:            : {token, {':', TokenLine}}.
\"            : skip_token.

{WHITESPACE}+ : skip_token.

Erlang code.

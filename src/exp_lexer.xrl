Definitions.

INT        = [0-9]+
WHITESPACE = [\s\t\n\r]

Rules.

{INT}         : {token, {int, TokenLine, list_to_integer(TokenChars)}}.
\(            : {token, {'(', TokenLine}}.
\)            : {token, {')', TokenLine}}.
\+            : {token, {'+', TokenLine}}.
\*            : {token, {'*', TokenLine}}.
{WHITESPACE}+ : skip_token.

Erlang code.

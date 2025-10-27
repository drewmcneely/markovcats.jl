lexer grammar ExprLexer;

PIPE   : '|' ;
EQ     : '=' ;
COMMA  : ',' ;
SLASH  : '/' ;
SEMI   : ';' ;
TIMES  : '*' ;

SUM    : 'sum_' ;
LPAREN : '(' ;
RPAREN : ')' ;

ID: [a-zA-Z_][a-zA-Z_0-9]* ;
WS: [ \t\n\r\f]+ -> skip ;



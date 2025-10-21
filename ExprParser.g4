parser grammar ExprParser;
options { tokenVocab=ExprLexer; }

program    : statement* EOF ;
obj       : ID (',' ID)* ;
signature : obj ('|' obj)? ;
kernel    : ID '(' signature ')' ;
summation : SUM '(' obj ')' ;
expression : summation? kernel ('*' kernel)* ;
assignment : kernel '=' expression ;
statement  : assignment ';' ;

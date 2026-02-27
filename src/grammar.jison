/* Lexer */
%lex
%%
\s+                                 { /* skip whitespace */; }
[0-9]+[eE][+-]?[0-9]+               { return 'FLOAT';        } /* Modificado */
[0-9]+\.([0-9]+)?([eE][+-]?[0-9]+)? { return 'FLOAT';        } /* Modificado */
[0-9]+                              { return 'NUMBER';       }
"**"                                { return 'OP';           }
[-+*/]                              { return 'OP';           }
<<EOF>>                             { return 'EOF';          }
"//"[^\n]*                              { /* skip commentline */;} /* Modificado */
.                                   { return 'INVALID';      }
/lex 

/* Parser */
%start expressions
%token NUMBER FLOAT
%%

expressions
    : expression EOF
        { return $expression; }
    ;

expression
    : expression OP term
        { $$ = operate($OP, $expression, $term); }
    | term
        { $$ = $term; }
    ;

term
    : NUMBER
        { $$ = Number(yytext); }
    | FLOAT
        { $$ = Number(yytext); }
    ;
%%

function operate(op, left, right) {
    switch (op) {
        case '+': return left + right;
        case '-': return left - right;
        case '*': return left * right;
        case '/': return left / right;
        case '**': return Math.pow(left, right);
    }
}


/* 3.1 Al no devolver ningún token, se reconoce el patrón pero no se devuelve nada. Pero al enviar un token, este hace que participe en la gramática, complicandola más de lo necesario.    */
/* Cuando sabemos que existe una secuencia de caracteres que queremos ignorar, lo mejor es no usar tokens.                                                                                  */
/*   3.2 La secuencia de tokens para 123**45+@ será : (123)NUMBER (**)OP (45)NUMBER (+)OP (@)INVALID EOF.                                                                                   */
/*   3.3 ** debe aparecer antes que [+-/*] en el analizador léxico debido a que este busca la secuencia más larga, y van por orden de aparición en las normas escritas. Debido a que en la  */
/* norma [+-/*] también se busca el caracter *, priorizamos la posibilidad de que existan dos caracteres ** seguidos.                                                                       */
/*   3.4 Se devuelve EOF cuando el lexer llega al final del flujo de entrada y no quedan más caracteres por leer. Este token se obtiene cuando el lexer ha terminado de leer el texto.      */
/*   3.5 Para capturar cualquier caracter no reconocido por las reglas anteriores y evitar que se quede atascado cuando se encuentre con algo que no se haya explicado explícitamente.      */
/*
 * jparse - JSON parser demo tool
 *
 * "Because specs w/o version numbers are forced to commit to their original design flaws." :-)
 *
 * This JSON parser was co-developed by:
 *
 *	@xexyl
 *	https://xexyl.net		Cody Boone Ferguson
 *	https://ioccc.xexyl.net
 * and:
 *	chongo (Landon Curt Noll, http://www.isthe.com/chongo/index.html) /\oo/\
 *
 * "Because sometimes even the IOCCC Judges need some help." :-)
 *
 * "Share and Enjoy!"
 *     --  Sirius Cybernetics Corporation Complaints Division, JSON spec department. :-)
 */


#if !defined(INCLUDE_JPARSE_H)
#    define  INCLUDE_JPARSE_H


#include <stdio.h>

/*
 * dbg - info, debug, warning, error, and usage message facility
 */
#include "dbg.h"

/*
 * util - entry common utility functions for the IOCCC toolkit
 */
#include "util.h"

/*
 * json_parse - JSON parser support code
 */
#include "json_parse.h"

/*
 * json_util - general JSON parser utility support functions
 */
#include "json_util.h"


/*
 * definitions
 */


/*
 * jparse.tab.h - generated by bison
 */
#include "jparse.tab.h"

/*
 * official JSON parser version
 */
#define JSON_PARSER_VERSION "0.10 2022-07-03"		/* format: major.minor YYYY-MM-DD */


/*
 * globals
 */
extern unsigned num_errors;		/* > 0 number of errors encountered */
extern char const *json_parser_version;	/* official JSON parser version */
/* lexer and parser specific variables */
extern int yylineno;			/* line number in lexer */
extern char *yytext;			/* current text */
extern FILE *yyin;			/* input file lexer/parser reads from */
extern unsigned num_errors;		/* > 0 number of errors encountered */
extern int yyleng;
extern int yydebug;


/*
 * lexer specific
 */
extern int yylex(YYSTYPE *yylval_param, YYLTYPE *yylloc_param);

/*
 * function prototypes for jparse.y
 */
extern void yyerror(YYLTYPE *yyltype, struct json **tree, char const *format, ...);

/*
 * function prototypes for jparse.l
 */
extern struct json *parse_json(char const *ptr, size_t len, bool *is_valid);
extern struct json *parse_json_stream(FILE *stream, bool *is_valid);
extern struct json *parse_json_file(char const *filename, bool *is_valid);


#endif /* INCLUDE_JPARSE_H */

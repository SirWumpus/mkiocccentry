/* vim: set tabstop=8 softtabstop=4 shiftwidth=4 noexpandtab : */
/*
 * json_sem - JSON semantics support
 *
 * "Because grammar and syntax alone to not make a complete language." :-)
 *
 * This JSON parser was co-developed by:
 *
 *	@xexyl
 *	https://xexyl.net		Cody Boone Ferguson
 *	https://ioccc.xexyl.net
 * and:
 *	chongo (Landon Curt Noll, http://www.isthe.com/chongo/index.html) /\oo/\
 */


#if !defined(INCLUDE_JSON_SEM_H)
#    define  INCLUDE_JSON_SEM_H


/*
 * util - entry common utility functions for the IOCCC toolkit
 */
#include "util.h"

/*
 * json_parse - JSON parser support code
 */
#include "json_parse.h"


/*
 * definitions
 */

 /*
  * JSON semantical count error
  */
struct json_cnt_err {
    struct json_sem *sem;	/* semantical node in question or NULL (unknown_node == true) */
    unsigned int count;		/* number of times this JSON semantic was matched */
    bool bad_min;		/* true ==> JSON semantical node count under minimum */
    bool bad_max;		/* true ==> JSON semantical node count over maximum */
    bool unknown_node;		/* true ==> JSON node is not known to JSON semantics */
    char *diagnostic;		/* diagnostic message or NULL */
};

/*
 * JSON semantical validation error
 *
 * When validate() returns false, that validating function
 * records information about the validation error in this form.
 */
struct json_val_err {
    struct json *node;		/* JSON parse node in question or NULL */
    unsigned int depth;		/* JSON parse tree node depth */
    struct json_sem *sem;	/* semantical node in question or NULL */
    int val_err;		/* validate function specific error code, 0 ==> not an error */
    char *diagnostic;		/* diagnostic message or NULL */
};

/*
 * JSON semantical node
 *
 * An array of JSON semantics may describe the what is required
 * or allowed in a given valid JSON document.
 */
struct json_sem {
    unsigned int depth;		/* JSON parse tree node depth */
    enum item_type type;	/* type of JSON node */
    unsigned int min;		/* minimum allowed count */
    unsigned int max;		/* maximum allowed count, 0 ==> infinite */
    char *name;			/* when type == JTYPE_MEMBER, match name if name != NULL */
    bool (* validate)(struct json *node, unsigned int depth, struct json_sem *sem, struct json_val_err *val_err);
				/* JSON parse tree node validator, or NULL */
    unsigned int count;		/* number of times this JSON semantic was matched */
};


/*
 * global variables
 */


/*
 * external function declarations
 */


#endif /* INCLUDE_JSON_SEM_H */

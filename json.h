/* vim: set tabstop=8 softtabstop=4 shiftwidth=4 noexpandtab : */
/*
 * json - JSON functions supporting mkiocccentry code
 *
 * JSON related functions to support formation of .info.json files
 * and .author.json files, their related check tools, test code,
 * and string encoding/decoding tools.
 *
 * "Because JSON embodies a commitment to original design flaws." :-)
 *
 * Copyright (c) 2022 by Landon Curt Noll.  All Rights Reserved.
 *
 * Permission to use, copy, modify, and distribute this software and
 * its documentation for any purpose and without fee is hereby granted,
 * provided that the above copyright, this permission notice and text
 * this comment, and the disclaimer below appear in all of the following:
 *
 *       supporting documentation
 *       source copies
 *       source works derived from this source
 *       binaries derived from this source or from derived source
 *
 * LANDON CURT NOLL DISCLAIMS ALL WARRANTIES WITH REGARD TO THIS SOFTWARE,
 * INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS. IN NO
 * EVENT SHALL LANDON CURT NOLL BE LIABLE FOR ANY SPECIAL, INDIRECT OR
 * CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS OF
 * USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR
 * OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR
 * PERFORMANCE OF THIS SOFTWARE.
 *
 * chongo (Landon Curt Noll, http://www.isthe.com/chongo/index.html) /\oo/\
 *
 * Share and enjoy! :-)
 */


#if !defined(INCLUDE_JSON_H)
#    define  INCLUDE_JSON_H


#include <time.h>
#include <stdint.h>


/*
 * byte as octet constants
 */
#define BITS_IN_BYTE (8)	    /* assume 8 bit bytes */
#define MAX_BYTE (0xff)		    /* maximum byte value */
#define BYTE_VALUES (MAX_BYTE+1)    /* number of different combinations of bytes */

/*
 * the next five are for the json_filename() function
 */
#define INFO_JSON	(0)	    /* file is assumed to be a .info.json file */
#define AUTHOR_JSON	(1)	    /* file is assumed to be a .author.json file */
#define INFO_JSON_FILENAME ".info.json"
#define AUTHOR_JSON_FILENAME ".author.json"
#define INVALID_JSON_FILENAME "null"

/* for the formed_UTC check */
#define FORMED_UTC_FMT "%a %b %d %H:%M:%S %Y UTC"   /* format for strptime() of formed_UTC */

/*
 * JSON warn code defines and variables for jwarn()
 */

/*
 * Codes 0 - 99 are reserved for special purposes so all normal codes should be
 * >= JSON_CODE_MIN && <= JSON_CODE_MAX via the JSON_CODE macro.
 */
#define JSON_CODE_RESERVED_MIN (0)	/* reserved code: all normal codes should be >= JSON_CODE_MIN && <= JSON_CODE_MAX via JSON_CODE macro */
#define JSON_CODE_RESERVED_MAX (99)	/* reserved code: all normal codes should be >= JSON_CODE_MIN && <= JSON_CODE_MAX via JSON_CODE macro */
/*
 * The minimum code for jwarn() is the JSON_CODE_RESERVED_MAX (currently 99) + 1.
 * However this does not mean that calls to jwarn() cannot use <= the
 * JSON_CODE_RESERVED_MAX: it's just for special purposes e.g. codes that are
 * used in more than one location.
 */
#define JSON_CODE_MIN (1+JSON_CODE_RESERVED_MAX)
/* The maximum json code for jwarn(). This was arbitrarily selected. */
#define JSON_CODE_MAX (9999)
/* the number of unreserved JSON codes for jwarn(): the max - the min + 1 */
#define NUM_UNRESERVED_JSON_CODES (JSON_CODE_MAX-JSON_CODE_MIN)
/*
 * To distinguish that this is a JSON warn code rather than any other type of
 * number we use these macro.
 */
#define JSON_CODE(x) ((x)+JSON_CODE_RESERVED_MAX)
/* reserved JSON code */
#define JSON_CODE_RESERVED(x) (x)

extern bool show_full_json_warnings;

/*
 * JSON value: a linked list of all values of the same json_field (below)
 */
struct json_value
{
    char *value;

    int line_num;	    /* the 'line number': actually the field number in the list */

    struct json_value *next;
};

#define JSON_NUM	    (0)	    /* json field is supposed to be a number */
#define JSON_BOOL	    (1)	    /* json field is supposed to be a boolean */
#define JSON_CHARS	    (2)	    /* json field is supposed to be a string */
#define JSON_ARRAY	    (3)	    /* json field is supposed to be an array */
#define JSON_ARRAY_NUMBER   (5)	    /* json field is supposed to be a number in an array */
#define JSON_ARRAY_BOOL	    (6)	    /* json field is supposed to be a bool in an array (NB: not used) */
#define JSON_ARRAY_CHARS   (7)	    /* json field is supposed to be a string in an array */
#define JSON_EOT	    (-1)    /* json field is NULL (not null): used internally to mark end of the tables */

/*
 * JSON field: a JSON field consists of the name and all the values (if more
 * than one field of the same name is found in the file).
 */
struct json_field
{
    char *name;			/* field name */
    struct json_value *values;	/* linked list of values */

    /*
     * the below are for the tables: common_json_fields, info_json_fields and
     * author_json_fields:
     *
     * Number of times this field has been seen in the list, how many are
     * actually allowed and whether the field has been found: This is for the
     * tables that say many times a field has been seen, how many times it
     * is allowed and whether or not it's been seen (it is true that this could
     * simply be count > 0 but this is to be more clear, however slight).
     *
     * In other words this is done as part of the checks after the field:value
     * pairs have been extracted.
     *
     * NOTE: A max_count == 0 means that there's no limit and that it's not
     * required.
     */
    size_t count;		/* how many of this field in the list (or how many values) */
    size_t max_count;		/* how many of this field is allowed */
    bool found;			/* if this field was found */

    /*
     * These are used in both checking and parsing: checking that the data is
     * valid and parsing in that certain data types have to be parsed
     * differently.
     *
     * Data type: one of JSON_NUM, JSON_BOOL, JSON_CHARS or
     * JSON_ARRAY_ equivalents.
     */
    int field_type;
    /*
     * Some strings can be empty but others cannot; there are no other values
     * that can currently be empty but this is for all lists so we have to
     * include this bool
     */
    bool can_be_empty;	    /* if the value can be empty */


    /* NOTE: don't add to more than one list */
    struct json_field *next;	/* the next in the whatever list */
};

extern struct json_field common_json_fields[];
extern size_t SIZEOF_COMMON_JSON_FIELDS_TABLE;

/*
 * linked list of the common json fields found in the .info.json and
 * .author.json files.
 *
 * A common json field is a field that is supposed to be in both .info.json and
 * .author.json.
 */
struct json_field *found_common_json_fields;

/*
 * common json fields - for use in mkiocccentry.
 *
 * NOTE: We don't use the json_field or json_value fields because this struct is
 * for mkiocccentry which is in control of what's written whereas for jinfochk
 * and jauthchk we don't have control of what's in the file.
 */
struct json_common
{
    /*
     * version
     */
    char *mkiocccentry_ver;	/* mkiocccentry version (MKIOCCCENTRY_VERSION) */
    char const *iocccsize_ver;	/* iocccsize version (compiled in, same as iocccsize -V) */
    char const *jinfochk_ver;	/* jinfochk version (compiled in, same as jinfochk -V) */
    char const *jauthchk_ver;	/* jautochk version (compiled in, same as jautochk -V) */
    char const *fnamchk_ver;	/* fnamchk version (compiled in, same as fnamchk -V) */
    char const *txzchk_ver;	/* txzchk version (compiled in, same as txzchk -V) */
    /*
     * entry
     */
    char *ioccc_id;		/* IOCCC contest ID */
    int entry_num;		/* IOCCC entry number */
    char *tarball;		/* tarball filename */
    bool test_mode;		/* true ==> test mode entered */

    /*
     * time
     */
    time_t tstamp;		/* seconds since epoch when .info json was formed (see gettimeofday(2)) */
    int usec;			/* microseconds since the tstamp second */
    char *epoch;		/* epoch of tstamp, currently: Thu Jan 1 00:00:00 1970 UTC */
    char *utctime;		/* UTC converted string for tstamp (see strftime(3)) */
};

/*
 * author info
 */
struct author {
    char *name;			/* name of the author */
    char *location_code;	/* author location/country code */
    char const *location_name;	/* name of author location/country */
    char *email;		/* Email address of author or or empty string ==> not provided */
    char *url;			/* home URL of author or or empty string ==> not provided */
    char *twitter;		/* author twitter handle or or empty string ==> not provided */
    char *github;		/* author GitHub username or or empty string ==> not provided */
    char *affiliation;		/* author affiliation or or empty string ==> not provided */
    bool past_winner;		/* true ==> author claimns to have won before, false ==> author claims not a prev winner */
    bool default_handle;	/* true ==> default author_handle accepted, false ==> author_handle entered */
    char *author_handle;	/* IOCCC author handle (for winning entries) */
    int author_num;		/* author number */

    struct json_common common;	/* fields that are common to this struct author and struct info (below) */
};

/*
 * info for JSON
 *
 * Information we will collect in order to form the .info json file.
 */
struct info {
    /*
     * entry
     */
    char *title;		/* entry title */
    char *abstract;		/* entry abstract */
    off_t rule_2a_size;		/* Rule 2a size of prog.c */
    size_t rule_2b_size;	/* Rule 2b size of prog.c */
    bool empty_override;	/* true ==> empty prog.c override requested */
    bool rule_2a_override;	/* true ==> Rule 2a override requested */
    bool rule_2a_mismatch;	/* true ==> file size != rule_count function size */
    bool rule_2b_override;	/* true ==> Rule 2b override requested */
    bool highbit_warning;	/* true ==> high bit character(s) detected */
    bool nul_warning;		/* true ==> NUL character(s) detected */
    bool trigraph_warning;	/* true ==> unknown or invalid tri-graph(s) detected */
    bool wordbuf_warning;	/* true ==> word buffer overflow detected */
    bool ungetc_warning;	/* true ==> ungetc warning detected */
    bool Makefile_override;	/* true ==> Makefile rule override requested */
    bool first_rule_is_all;	/* true ==> Makefile first rule is all */
    bool found_all_rule;	/* true ==> Makefile has an all rule */
    bool found_clean_rule;	/* true ==> Makefile has clean rule */
    bool found_clobber_rule;	/* true ==> Makefile has a clobber rule */
    bool found_try_rule;	/* true ==> Makefile has a try rule */
    bool test_mode;		/* true ==> contest ID is test */
    /*
     * filenames
     */
    char *prog_c;		/* prog.c filename */
    char *Makefile;		/* Makefile filename */
    char *remarks_md;		/* remarks.md filename */
    int extra_count;		/* number of extra files */
    char **extra_file;		/* list of extra filenames followed by NULL */
    /*
     * time
     */

    struct json_common common;	/* fields that are common to this struct info and struct author (above) */
};

/*
 * JSON error codes to ignore
 *
 * When a tool is given command line arguments of the form:
 *
 *	.. -W 123 -W 1345 -W 56 ...
 *
 * this means the tool will ignore {JSON-0123}, {JSON-1345}, and {JSON-0056}.
 * The code_ignore[] table holds the JSON codes to ignore.
 */
#define IGNORE_CODE_CHUNK (64)	/* number of codes to calloc or realloc at a time */

struct ignore_code {
    int next_free;	/* the index of the next allowed but free JSON error code */
    int alloc;		/* number of JSON error codes allocated */
    int *code;		/* pointer to the allocated list of codes, or NULL (not allocated) */
};
extern struct ignore_code *ignore_code_set;


/*
 * external function declarations
 */
extern char *malloc_json_encode(char const *ptr, size_t len, size_t *retlen);
extern char *malloc_json_encode_str(char const *str, size_t *retlen);
extern void jencchk(void);
extern bool json_putc(uint8_t const c, FILE *stream);
extern char *malloc_json_decode(char const *ptr, size_t len, size_t *retlen, bool strict);
extern char *malloc_json_decode_str(char const *str, size_t *retlen, bool strict);

/* jinfochk and jauthchk related */
extern struct json_field *find_json_field_in_table(struct json_field *table, char const *name, size_t *loc);
extern char const *json_filename(int type);
/* checks on the JSON fields tables */
extern void check_json_fields_tables(void);
extern void check_common_json_fields_table(void);
extern void check_author_json_fields_table(void);
extern void check_info_json_fields_table(void);
extern int check_first_json_char(char const *file, char *data, bool strict, char **first, char ch);
extern int check_last_json_char(char const *file, char *data, bool strict, char **last, char ch);
extern struct json_field *add_found_common_json_field(char const *json_filename, char const *name, char const *val, int line_num);
extern bool add_common_json_field(char const *program, char const *json_filename, char *name, char *val, int line_num);
extern int check_found_common_json_fields(char const *program, char const *json_filename, char const *fnamchk, bool test);
extern struct json_field *new_json_field(char const *json_filename, char const *name, char const *val, int line_num);
extern struct json_value *add_json_value(char const *json_filename, struct json_field *field, char const *val, int line_num);
extern void jwarn(int code, const char *program, char const *name, char const *filename, char const *line, int line_num, const char *fmt, ...) \
	__attribute__((format(printf, 7, 8)));		/* 7=format 8=params */
extern void jwarnp(int code, const char *program, char const *name, char const *filename, char const *line, int line_num, const char *fmt, ...) \
	__attribute__((format(printf, 7, 8)));		/* 7=format 8=params */
extern void jerr(int exitcode, char const *program, const char *name, char const *filename, char const *line, int line_num, const char *fmt, ...) \
	__attribute__((noreturn)) __attribute__((format(printf, 7, 8))); /* 7=format 8=params */
extern void jerrp(int exitcode, char const *program, const char *name, char const *filename, char const *line, int line_num, const char *fmt, ...) \
	__attribute__((noreturn)) __attribute__((format(printf, 7, 8))); /* 7=format 8=params */


/* free() functions */
extern void free_json_field_values(struct json_field *field);
extern void free_found_common_json_fields(void);
extern void free_json_field(struct json_field *field);
/* these free() functions are also used in mkiocccentry.c */
extern void free_info(struct info *infop);
extern void free_author_array(struct author *authorp, int author_count);
/* ignore code functions */
extern bool is_code_ignored(int code);
extern void add_ignore_code(int code);


#endif /* INCLUDE_JSON_H */

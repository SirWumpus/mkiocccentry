#!/usr/bin/env make
#
# mkiocccentry and related tools - how to form an IOCCC entry
#
# For mkiocccentry:
#
# Copyright (c) 2021,2022 by Landon Curt Noll.  All Rights Reserved.
#
# Permission to use, copy, modify, and distribute this software and
# its documentation for any purpose and without fee is hereby granted,
# provided that the above copyright, this permission notice and text
# this comment, and the disclaimer below appear in all of the following:
#
#       supporting documentation
#       source copies
#       source works derived from this source
#       binaries derived from this source or from derived source
#
# LANDON CURT NOLL DISCLAIMS ALL WARRANTIES WITH REGARD TO THIS SOFTWARE,
# INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS. IN NO
# EVENT SHALL LANDON CURT NOLL BE LIABLE FOR ANY SPECIAL, INDIRECT OR
# CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS OF
# USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR
# OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR
# PERFORMANCE OF THIS SOFTWARE.
#
# chongo (Landon Curt Noll, http://www.isthe.com/chongo/index.html) /\oo/\
#
# Share and enjoy! :-)
####

####
# For iocccsize:
#
# This IOCCC size tool source file.  See below for the VERSION string.
#
# "You are not expected to understand this" :-)
#
# Public Domain 1992, 2015, 2018, 2019, 2021 by Anthony Howe.  All rights released.
# With IOCCC mods in 2019-2022 by chongo (Landon Curt Noll) ^oo^
####

####
# dbg - example of how to use usage(), dbg(), warn(), err(), vfprintf_usage(), etc.
#
# Copyright (c) 1989,1997,2018-2022 by Landon Curt Noll.  All Rights Reserved.
#
# Permission to use, copy, modify, and distribute this software and
# its documentation for any purpose and without fee is hereby granted,
# provided that the above copyright, this permission notice and text
# this comment, and the disclaimer below appear in all of the following:
#
#       supporting documentation
#       source copies
#       source works derived from this source
#       binaries derived from this source or from derived source
#
# LANDON CURT NOLL DISCLAIMS ALL WARRANTIES WITH REGARD TO THIS SOFTWARE,
# INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS. IN NO
# EVENT SHALL LANDON CURT NOLL BE LIABLE FOR ANY SPECIAL, INDIRECT OR
# CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS OF
# USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR
# OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR
# PERFORMANCE OF THIS SOFTWARE.
#
# chongo (Landon Curt Noll, http://www.isthe.com/chongo/index.html) /\oo/\
#
# Share and enjoy! :-)
####


#############
# utilities #
#############

AWK= awk
BISON = bison
CAT= cat
CC= cc
CP= cp
CTAGS= ctags
FLEX = flex
GREP= grep
INSTALL= install
MAKE= make
MKTEMP= mktemp
MV= mv
PICKY= picky
RM= rm
RPL= rpl
SED= sed
SEQCEXIT= seqcexit
SHELL= bash
SHELLCHECK= shellcheck
TR= tr
TRUE= true


#######################
# Makefile parameters #
#######################

# linker options
#
# We need the following linker options for some systems:
#
#   -lm for floorl() under CentOS 7.
#
# If any more linker options are needed we will try documenting the reason why
# here.
#
LDFLAGS = -lm

# C source standards being used
#
# NOTE: The use of -std=gnu11 is because there are a few older systems
#	in late 2021 that do not have compilers that (yet) support gnu17.
#	While there may be even more out of date systems that do not
#	support gnu11, we have to draw the line somewhere.
#
# NOTE: The -D_* lines in STD_SRC are due to a few older systems in
#	late 2021 that need those defines to compile this code. CentOS
#	7 is such a system.
#
# NOTE: The code in the mkiocccentry repo is to help you form and
#	submit a compressed tarball that meets the IOCCC requirements.
#	Your IOCCC entry is free to require older C standards, or
#	even not specify a C standard at all.  Moreover, your entry's
#	Makefile, can do what it needs to do, perhaps by using the
#	Makefile.example as a basis.
#
# XXX - XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX - XXX
# XXX - In 2024 we will change the STD_SRC line to be just - XXX
# XXX - STD_SRC= -std=gnu17				   - XXX
# XXX - XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX - XXX
#
STD_SRC= -D_DEFAULT_SOURCE -D_ISOC99_SOURCE -D_POSIX_C_SOURCE=200809L -D_XOPEN_SOURCE=600 -std=gnu11

# optimization and debug level
#
#COPT= -O3 -g3
COPT= -O0 -g

# We disable specific warnings for some systems that differ from the others. Not
# all warnings are disabled here because there's at least one warning that only
# is needed in a few rules but others are needed in more. The following is the
# list of the warnings we disable _after_ enabling -Wall -Wextra -Werror:
#
#   -Wno-unused-command-line-argument
#
# This is needed because under CentOS we need -lm for floorl() (as described
# above); however under macOS you will get:
#
#	clang: error: -lm: 'linker' input unused
#	[-Werror,-Wunused-command-line-argument]
#	make: *** [sanity.o] Error 1
#
# for any object that does not need -lm and since many objects need to link in
# json.o (which is where the -lm is needed) we disable the warning here instead
# as it otherwise becomes very tedious.
#
# Additionally, the following are triggered with -Weverything but are entirely
# irrelevant to us. Although we don't enable -Weverything we have it here to
# make it not a problem in case we ever do enable it:
#
#   -Wno-poison-system-directories -Wno-unreachable-code-break -Wno-padded
#
WARN_FLAGS= -Wall -Wextra -Werror -Wno-unused-command-line-argument \
	    -Wno-poison-system-directories -Wno-unreachable-code-break -Wno-padded


# how to compile
#
# We test by forcing warnings to be errors so you don't have to (allegedly :-) )
#
CFLAGS= ${STD_SRC} ${COPT} -pedantic ${WARN_FLAGS} ${LDFLAGS}


# NOTE: If you use ASAN, set this environment var:
#	ASAN_OPTIONS="detect_stack_use_after_return=1"
#
#CFLAGS= ${STD_SRC} -O0 -g -pedantic ${WARN_FLAGS} -fsanitize=address -fno-omit-frame-pointer

# NOTE: For valgrind, run with:
#
#	valgrind --leak-check=yes --track-origins=yes --leak-resolution=high --read-var-info=yes \
#           --leak-check=full --show-leak-kinds=all ./mkiocccentry ...
#
# NOTE: Replace mkiocccentry with whichever tool you want to test and the ...
# with the arguments and options you want.

# where and what to install
#
MANDIR = /usr/local/share/man/man1
DESTDIR= /usr/local/bin
TARGETS= mkiocccentry iocccsize dbg limit_ioccc.sh fnamchk txzchk jauthchk jinfochk \
	jstrencode jstrdecode utf8_test jparse jint jfloat verge

# man pages
#
# Currently we explicitly specify a variable for man page targets as not all
# targets have a man page but probably all targets should have a man page. When
# this is done we can change the below two uncommented lines to be just:
#
#   MANPAGES = $(TARGETS:=.1)
#
# But until then it must be the next two lines (alternatively we could
# explicitly specify the man pages but this makes it simpler). When a new man
# page is written the MAN_TARGETS should have the tool name (without any
# extension) added to it.  Eventually MAN_TARGETS can be removed entirely and
# MANPAGES will act on TARGETS.
MAN_TARGETS = mkiocccentry txzchk fnamchk iocccsize jinfochk jauthchk
MANPAGES= $(MAN_TARGETS:=.1)

TEST_TARGETS= dbg utf8_test dyn_test
OBJFILES= dbg.o util.o mkiocccentry.o iocccsize.o fnamchk.o txzchk.o jauthchk.o jinfochk.o \
	json.o jstrencode.o jstrdecode.o rule_count.o location.o sanity.o \
	utf8_test.o jint.o jint.test.o jfloat.o jfloat.test.o verge.o \
	dyn_array.o dyn_test.o
LESS_PICKY_CSRC= utf8_posix_map.c
LESS_PICKY_OBJ= utf8_posix_map.o
GENERATED_CSRC= jparse.c jparse.tab.c
GENERATED_HSRC= jparse.tab.h
GENERATED_OBJ= jparse.o jparse.tab.o
FLEXFILES= jparse.l
BISONFILES= jparse.y
# This is a simpler way to do:
#
#   SRCFILES =  $(patsubst %.o,%.c,$(OBJFILES))
#
SRCFILES= $(OBJFILES:.o=.c)
ALL_CSRC= ${LESS_PICKY_CSRC} ${GENERATED_CSRC} ${SRCFILES}
H_FILES= dbg.h jauthchk.h jinfochk.h json.h jstrdecode.h jstrencode.h limit_ioccc.h \
	mkiocccentry.h txzchk.h util.h location.h utf8_posix_map.h jparse.h jint.h jfloat.h \
	verge.h sorry.tm.ca.h dyn_array.h dyn_test.h
# This is a simpler way to do:
#
#   DSYMDIRS= $(patsubst %,%.dSYM,$(TARGETS))
#
DSYMDIRS= $(TARGETS:=.dSYM)
SH_FILES= iocccsize-test.sh jstr-test.sh limit_ioccc.sh mkiocccentry-test.sh json-test.sh \
	  jcodechk.sh vermod.sh bfok.sh

# Where bfok.sh looks for bison and flex with a version
#
# The -B arguments specify where to look for bison with a version,
# that is >= the minimum version (see BISON_VERSION in limit_ioccc.sh),
# before searching for bison on $PATH.
#
# The -F arguments specify where to look for flex with a version,
# that is >= the minimum version (see FLEX_VERSION in limit_ioccc.sh),
# before searching for flex on $PATH.
#
# NOTE: If is OK if these directories do not exist.
#
BFOK_DIRS= \
	-B /opt/homebrew/opt/bison/bin \
	-B /opt/homebrew/bin \
	-B /opt/local/bin \
	-B /usr/local/opt \
	-B /usr/local/bin \
	-B . \
	-F /opt/homebrew/opt/flex/bin \
	-F /opt/homebrew/bin \
	-F /opt/local/bin \
	-F /usr/local/opt \
	-F /usr/local/bin \
	-F .


############################################################
# User specific configurations - override Makefile values  #
############################################################

# The directive below retrieves any user specific configurations from makefile.local.
#
# The - before include means it's not an error if the file does not exist.
#
# We put this directive just before the 1st all rule so that you may override
# or modify any of the above Makefile variables.  To override a value, use := symbols.
# For example:
#
#	CC:= gcc
#
-include makefile.local


######################################
# all - default rule - must be first #
######################################

all: ${TARGETS} ${TEST_TARGETS}

# rules, not file targets
#
.PHONY: all configure clean clobber install test reset_min_timestamp rebuild_jint_test \
	rebuild_jfloat_test picky parser


#####################################
# rules to compile and build source #
#####################################

rule_count.o: rule_count.c Makefile
	${CC} ${CFLAGS} -DMKIOCCCENTRY_USE rule_count.c -c

sanity.o: sanity.c sanity.h location.h utf8_posix_map.h Makefile
	${CC} ${CFLAGS} sanity.c -c

mkiocccentry: mkiocccentry.c mkiocccentry.h rule_count.o dbg.o util.o dyn_array.o json.o location.o \
	utf8_posix_map.o sanity.o Makefile
	${CC} ${CFLAGS} mkiocccentry.c rule_count.o dbg.o util.o dyn_array.o json.o location.o \
		utf8_posix_map.o sanity.o -o $@

iocccsize: iocccsize.c rule_count.o dbg.o Makefile
	${CC} ${CFLAGS} -DMKIOCCCENTRY_USE iocccsize.c rule_count.o dbg.o -o $@

dbg: dbg.c Makefile
	${CC} ${CFLAGS} -DDBG_TEST dbg.c -o $@

fnamchk: fnamchk.c fnamchk.h dbg.o util.o dyn_array.o Makefile
	${CC} ${CFLAGS} fnamchk.c dbg.o util.o dyn_array.o -o $@

txzchk: txzchk.c txzchk.h rule_count.o dbg.o util.o dyn_array.o location.o json.o utf8_posix_map.o sanity.o Makefile
	${CC} ${CFLAGS} txzchk.c rule_count.o dbg.o util.o dyn_array.o location.o json.o utf8_posix_map.o sanity.o -o $@

jauthchk: jauthchk.c jauthchk.h json.h rule_count.o json.o dbg.o util.o dyn_array.o sanity.o location.o utf8_posix_map.o Makefile
	${CC} ${CFLAGS} jauthchk.c rule_count.o json.o dbg.o util.o dyn_array.o sanity.o location.o utf8_posix_map.o -o $@

jinfochk: jinfochk.c jinfochk.h rule_count.o json.o dbg.o util.o dyn_array.o sanity.o location.o utf8_posix_map.o Makefile
	${CC} ${CFLAGS} jinfochk.c rule_count.o json.o dbg.o util.o dyn_array.o sanity.o location.o utf8_posix_map.o -o $@

jstrencode: jstrencode.c jstrencode.h dbg.o json.o util.o dyn_array.o Makefile
	${CC} ${CFLAGS} jstrencode.c dbg.o json.o util.o dyn_array.o -o $@

jstrdecode: jstrdecode.c jstrdecode.h dbg.o json.o util.o dyn_array.o Makefile
	${CC} ${CFLAGS} jstrdecode.c dbg.o json.o util.o dyn_array.o -o $@

jint.test.o: jint.test.c Makefile
	${CC} ${CFLAGS} -DJINT_TEST_ENABLED jint.test.c -c

jint: jint.c jint.h dbg.o json.o util.o dyn_array.o jint.test.o Makefile
	${CC} ${CFLAGS} -DJINT_TEST_ENABLED jint.c dbg.o json.o util.o dyn_array.o jint.test.o -o $@

jfloat.test.o: jfloat.test.c Makefile
	${CC} ${CFLAGS} -DJFLOAT_TEST_ENABLED jfloat.test.c -c

jfloat: jfloat.c jfloat.h dbg.o json.o util.o dyn_array.o jfloat.test.o Makefile
	${CC} ${CFLAGS} -DJFLOAT_TEST_ENABLED jfloat.c dbg.o json.o util.o dyn_array.o jfloat.test.o -o $@

jparse.o: jparse.c jparse.h Makefile
	${CC} ${CFLAGS} jparse.c -Wno-unused-function -Wno-unneeded-internal-declaration -c

jparse.tab.o: jparse.tab.c jparse.tab.h Makefile
	${CC} ${CFLAGS} jparse.tab.c -Wno-unused-function -Wno-unneeded-internal-declaration -c

jparse: jparse.o jparse.tab.o util.o dyn_array.o dbg.o sanity.o json.o utf8_posix_map.o location.o Makefile
	${CC} ${CFLAGS} jparse.o jparse.tab.o util.o dyn_array.o dbg.o sanity.o json.o utf8_posix_map.o location.o -o $@

utf8_test: utf8_test.c utf8_posix_map.o dbg.o util.o dyn_array.o Makefile
	${CC} ${CFLAGS} utf8_test.c utf8_posix_map.o dbg.o util.o dyn_array.o -o $@

verge: verge.c verge.h dbg.o util.o dyn_array.o Makefile
	${CC} ${CFLAGS} verge.c dbg.o util.o dyn_array.o -o $@

dyn_array.o: dyn_array.c dyn_array.h Makefile
	${CC} ${CFLAGS} dyn_array.c -c

dyn_test: dbg.o util.o dyn_array.o Makefile
	${CC} ${CFLAGS} dyn_test.c dbg.o util.o dyn_array.o -o $@

limit_ioccc.sh: limit_ioccc.h version.h Makefile
	${RM} -f $@
	@echo '#!/usr/bin/env bash' > $@
	@echo '#' >> $@
	@echo '# Copies of select limit_ioccc.h and version.h values for shell script use' >> $@
	@echo '#' >> $@
	${GREP} -E '^#define (RULE_|MAX_|UUID_|MIN_|IOCCC_)' limit_ioccc.h | \
	    ${AWK} '{print $$2 "=\"" $$3 "\"" ;}' | ${TR} -d '[a-z]()' | \
	    ${SED} -e 's/"_/"/' -e 's/""/"/g' -e 's/^/export /' >> $@
	${GREP} -hE '^#define (.*_VERSION|TIMESTAMP_EPOCH)' version.h limit_ioccc.h | \
	    ${GREP} -v 'UUID_VERSION' | \
	    ${SED} -e 's/^#define/export/' -e 's/ "/="/' -e 's/"[	 ].*$$/"/' >> $@
	-if ${GREP} -q '^#define DIGRAPHS' limit_ioccc.h; then \
	    echo "export DIGRAPHS='yes'"; \
	else \
	    echo "export DIGRAPHS="; \
	fi >> $@
	-if ${GREP} -q '^#define TRIGRAPHS' limit_ioccc.h; then \
	    echo "export TRIGRAPHS='yes'"; \
	else \
	    echo "export TRIGRAPHS="; \
	fi >> $@

# How to create jparse.tab.c and jparse.tab.h
#
# Convert jparse.y into jparse.tab.as well as jparse.tab.c via bison,
# if bison is found and has a recent enough version, otherwise
# use a pre-built reference copies stored in jparse.tab.ref.h and jparse.tab.ref.c.
#
jparse.tab.c jparse.tab.h: jparse.y bfok.sh limit_ioccc.sh verge jparse.tab.ref.c jparse.tab.ref.h Makefile
	${RM} -f jparse.tab.c jparse.tab.h
	@if `./bfok.sh ${BFOK_DIRS} 2>/dev/null`; then \
	    BISON_PATH="`./bfok.sh ${BFOK_DIRS} -p bison 2>/dev/null`"; \
	    TMP_JPARSE_TAB_C="`${MKTEMP} -t jparse.tab.c`"; \
	    TMP_JPARSE_TAB_H="`${MKTEMP} -t jparse.tab.h`"; \
	    if [[ -z $$BISON_PATH || -z $$TMP_JPARSE_TAB_H || -z $$TMP_JPARSE_TAB_C ]]; then \
	        echo "failed to discover the bison path" 1>&2; \
	        echo "will use backup files instead" 1>&2; \
		echo "${CP} -f -v jparse.tab.ref.c jparse.tab.c"; \
		${CP} -f -v jparse.tab.ref.c jparse.tab.c; \
		echo "${CP} -f -v jparse.tab.ref.h jparse.tab.h"; \
		${CP} -f -v jparse.tab.ref.h jparse.tab.h; \
	    else \
		echo "$$BISON_PATH -d jparse.y"; \
		"$$BISON_PATH" -d jparse.y; \
		if [[ -s jparse.tab.c && -s jparse.tab.h ]]; then \
		    echo '# prepending comment and line number reset to jparse.tab.c'; \
		    echo "${CP} -f -v sorry.tm.ca.h $$TMP_JPARSE_TAB_C"; \
		    ${CP} -f -v sorry.tm.ca.h "$$TMP_JPARSE_TAB_C"; \
		    echo "echo '#line 1 \"jparse.tab.c\"' >> $$TMP_JPARSE_TAB_C"; \
		    echo '#line 1 "jparse.tab.c"' >> "$$TMP_JPARSE_TAB_C"; \
		    echo "${CAT} jparse.tab.c >> $$TMP_JPARSE_TAB_C"; \
		    ${CAT} jparse.tab.c >> "$$TMP_JPARSE_TAB_C"; \
		    echo "${MV} -f -v $$TMP_JPARSE_TAB_C jparse.tab.c"; \
		    ${MV} -f -v "$$TMP_JPARSE_TAB_C" jparse.tab.c; \
		    echo '# jparse.tab.c prepended and line number reset'; \
		    echo '# prepending comment and line number reset to jparse.tab.h'; \
		    echo "${CP} -f -v sorry.tm.ca.h $$TMP_JPARSE_TAB_H"; \
		    ${CP} -f -v sorry.tm.ca.h "$$TMP_JPARSE_TAB_H"; \
		    echo "echo '#line 1 \"jparse.tab.h\"' >> $$TMP_JPARSE_TAB_H"; \
		    echo '#line 1 "jparse.tab.h"' >> "$$TMP_JPARSE_TAB_H"; \
		    echo "${CAT} jparse.tab.h >> $$TMP_JPARSE_TAB_H"; \
		    ${CAT} jparse.tab.h >> "$$TMP_JPARSE_TAB_H"; \
		    echo "${MV} -f -v $$TMP_JPARSE_TAB_H jparse.tab.h"; \
		    ${MV} -f -v "$$TMP_JPARSE_TAB_H" jparse.tab.h; \
		    echo '# jparse.tab.h prepended and line number reset'; \
		else \
		    echo "unable to form jparse.tab.h and/or jparse.tab.c"; \
		    echo "will use the backup file jparse.tab.c" 1>&2; \
		    echo "${CP} -f -v jparse.tab.ref.c jparse.tab.c"; \
		    ${CP} -f -v jparse.tab.ref.c jparse.tab.c; \
		    echo "will use the backup file jparse.tab.h" 1>&2; \
		    echo "${CP} -f -v jparse.tab.ref.h jparse.tab.h"; \
		    ${CP} -f -v jparse.tab.ref.h jparse.tab.h; \
		fi; \
	    fi; \
	else \
	    echo "no bison, with version >= BISON_VERSION in limit_ioccc.sh, found" 1>&2; \
	    echo "will move both backup files in place instead" 1>&2; \
	    echo "${CP} -f -v jparse.tab.ref.c jparse.tab.c"; \
	    ${CP} -f -v jparse.tab.ref.c jparse.tab.c; \
	    echo "${CP} -f -v jparse.tab.ref.h jparse.tab.h"; \
	    ${CP} -f -v jparse.tab.ref.h jparse.tab.h; \
	fi

# How to create jparse.c
#
# Convert jparse.l into jparse.c via flex,
# if flex found and has a recent enough version, otherwise
# use a pre-built reference copy stored in jparse.ref.c
#
jparse.c: jparse.l jparse.tab.h bfok.sh limit_ioccc.sh verge jparse.ref.c Makefile
	${RM} -f jparse.c
	@if `./bfok.sh ${BFOK_DIRS} 2>/dev/null`; then \
	    FLEX_PATH="`./bfok.sh ${BFOK_DIRS} -p flex 2>/dev/null`"; \
	    TMP_JPARSE_C="`${MKTEMP} -t jparse.c`"; \
	    if [[ -z $$FLEX_PATH || -z $$TMP_JPARSE_C ]]; then \
	        echo "failed to discover the flex path" 1>&2; \
	        echo "will use backup files" 1>&2; \
		echo "${CP} -f -v jparse.ref.c jparse.c"; \
		${CP} -f -v jparse.ref.c jparse.c; \
	    else \
		echo "$$FLEX_PATH -o jparse.c jparse.l"; \
		"$$FLEX_PATH" -o jparse.c jparse.l; \
		if [[ -s jparse.c ]]; then \
		    echo '# prepending comment and line number reset to jparse.c'; \
		    echo "${CP} -f -v sorry.tm.ca.h $$TMP_JPARSE_C"; \
		    ${CP} -f -v sorry.tm.ca.h "$$TMP_JPARSE_C"; \
		    echo "echo '#line 1 \"jparse.c\"' >> $$TMP_JPARSE_C"; \
		    echo '#line 1 "jparse.c"' >> "$$TMP_JPARSE_C"; \
		    echo "${CAT} jparse.c >> $$TMP_JPARSE_C"; \
		    ${CAT} jparse.c >> "$$TMP_JPARSE_C"; \
		    echo "${MV} -f -v $$TMP_JPARSE_C jparse.c"; \
		    ${MV} -f -v "$$TMP_JPARSE_C" jparse.c; \
		    echo '# jparse.c prepended and line number reset'; \
		else \
		    echo "unable to form jparse.c"; \
		    echo "will use the backup file jparse.ref.c" 1>&2; \
		    echo "${CP} -f -v jparse.ref.c jparse.c"; \
		    ${CP} -f -v jparse.ref.c jparse.c; \
		fi; \
	    fi; \
	else \
	    echo "no flex, with version >= FLEX_VERSION in limit_ioccc.sh, found" 1>&2; \
	    echo "will move both backup file in place instead" 1>&2; \
	    echo "${CP} -f -v jparse.ref.c jparse.c"; \
	    ${CP} -f -v jparse.ref.c jparse.c; \
	fi


###################################################################
# repo tools - rules for those who maintain the mkiocccentry repo #
###################################################################

# things to do before a release, forming a pull, and/or updating the GitHub repo
#
prep:
	@echo "=-=-=-=-= ${MAKE} prep start =-=-=-=-="
	@echo
	@echo "=-=-= ${MAKE} clobber =-=-="
	@echo
	${MAKE} clobber
	@echo
	@echo "=-=-= ${MAKE} seqcexit =-=-="
	@echo
	${MAKE} seqcexit
	@echo
	@echo "=-=-= ${MAKE} use_ref =-=-="
	@echo
	${MAKE} use_ref
	${RM} -f ${GENERATED_OBJ}
	@echo
	@echo "=-=-= ${MAKE} all =-=-="
	@echo
	${MAKE} all
	@echo
	@echo "=-=-= ${MAKE} parser =-=-="
	@echo
	${MAKE} parser
	@echo
	@echo "=-=-= ${MAKE} all (again) =-=-="
	@echo
	${MAKE} all
	@echo
	@echo "=-=-= ${MAKE} shellcheck =-=-="
	@echo
	${MAKE} shellcheck
	@echo
	@echo "=-=-= ${MAKE} picky =-=-="
	@echo
	${MAKE} picky
	@echo
	@echo "=-=-= ${MAKE} test =-=-="
	@echo
	${MAKE} test
	@echo
	@echo "=-=-=-=-= ${MAKE} prep end =-=-=-=-="

# force the rebuild of the JSON parser and form reference copies of JSON parser C code
#
parser: jparse.y jparse.l Makefile
	${RM} -f jparse.tab.c jparse.tab.h
	${MAKE} jparse.tab.c jparse.tab.h
	@if [[ -s jparse.tab.c ]]; then \
	    echo "${RM} -f jparse.tab.ref.c"; \
	    ${RM} -f jparse.tab.ref.c; \
	    echo "${CP} -f -v jparse.tab.c jparse.tab.ref.c"; \
	    ${CP} -f -v jparse.tab.c jparse.tab.ref.c; \
	else \
	    echo "jparse.tab.c is missing or empty, cannot update jparse.tab.ref.c" 1>&2; \
	    exit 1; \
	fi
	@if [[ -s jparse.tab.h ]]; then \
	    echo "${RM} -f jparse.tab.ref.h"; \
	    ${RM} -f jparse.tab.ref.h; \
	    echo "${CP} -f -v jparse.tab.h jparse.tab.ref.h"; \
	    ${CP} -f -v jparse.tab.h jparse.tab.ref.h; \
	else \
	    echo "jparse.tab.h is missing or empty, cannot update jparse.tab.ref.h" 1>&2; \
	    exit 1; \
	fi
	${RM} -f jparse.c
	${MAKE} jparse.c
	@if [[ -s jparse.c ]]; then \
	    echo "${RM} -f jparse.ref.c"; \
	    ${RM} -f jparse.ref.c; \
	    echo "${CP} -f -v jparse.c jparse.ref.c"; \
	    ${CP} -f -v jparse.c jparse.ref.c; \
	else \
	    echo "jparse.c is missing or empty, cannot update jparse.ref.c" 1>&2; \
	    exit 1; \
	fi

# restore reference code that was produced by previous successful make parser
#
# This rule forces the use of reference copies of JSON parser C code.
use_ref: jparse.tab.ref.c jparse.tab.ref.h jparse.ref.c
	${RM} -f jparse.tab.c
	${CP} -f -v jparse.tab.ref.c jparse.tab.c
	${RM} -f jparse.tab.h
	${CP} -f -v jparse.tab.ref.h jparse.tab.h
	${RM} -f jparse.c
	${CP} -f -v jparse.ref.c jparse.c

# rebuild jint.test.c
#
rebuild_jint_test: jint.testset jint.c dbg.o json.o util.o dyn_array.o Makefile
	${RM} -f jint.set.tmp jint_gen
	${CC} ${CFLAGS} jint.c dbg.o json.o util.o dyn_array.o -o jint_gen
	${SED} -n -e '1,/DO NOT REMOVE THIS LINE/p' < jint.test.c > jint.set.tmp
	echo '#if defined(JINT_TEST_ENABLED)' >> jint.set.tmp
	./jint_gen -- $$(<jint.testset) >> jint.set.tmp
	echo '#endif /* JINT_TEST_ENABLED */' >> jint.set.tmp
	${MV} -f jint.set.tmp jint.test.c
	${RM} -f jint_gen

# rebuild jfloat.test.c
#
rebuild_jfloat_test: jfloat.testset jfloat.c dbg.o json.o util.o dyn_array.o Makefile
	${RM} -f jfloat.set.tmp jfloat_gen
	${CC} ${CFLAGS} jfloat.c dbg.o json.o util.o dyn_array.o -o jfloat_gen
	${SED} -n -e '1,/DO NOT REMOVE THIS LINE/p' < jfloat.test.c > jfloat.set.tmp
	echo '#if defined(JFLOAT_TEST_ENABLED)' >> jfloat.set.tmp
	./jfloat_gen -- $$(<jfloat.testset) >> jfloat.set.tmp
	echo '#endif /* JFLOAT_TEST_ENABLED */' >> jfloat.set.tmp
	${MV} -f jfloat.set.tmp jfloat.test.c
	${RM} -f jfloat_gen

# sequence exit codes
#
seqcexit: Makefile
	@HAVE_SEQCEXIT=`command -v ${SEQCEXIT}`; if [[ -z "$$HAVE_SEQCEXIT" ]]; then \
	    echo 'If you have not installed the seqcexit tool, then' 1>&2; \
	    echo 'you may not run this rule.'; 1>&2; \
	    echo ''; 1>&2; \
	    echo 'See the following GitHub repo for seqcexit:'; 1>&2; \
	    echo ''; 1>&2; \
	    echo '    https://github.com/lcn2/seqcexit'; 1>&2; \
	    echo ''; 1>&2; \
	else \
	    echo "${SEQCEXIT} -c -- ${FLEXFILES} ${BISONFILES}"; \
	    ${SEQCEXIT} -c -- ${FLEXFILES} ${BISONFILES}; \
	    echo "${SEQCEXIT} -- ${ALL_CSRC}"; \
	    ${SEQCEXIT} -- ${ALL_CSRC}; \
	fi

picky: ${ALL_CSRC} ${H_FILES} Makefile
	@if ! command -v ${PICKY} >/dev/null 2>&1; then \
	    echo "The picky command not found." 1>&2; \
	    echo "The picky command is required for this rule." 1>&2; \
	    echo "We recommend you install picky v2.6 or later" 1>&2; \
	    echo "from this URL:" 1>&2; \
	    echo 1>&2; \
	    echo "http://grail.eecs.csuohio.edu/~somos/picky.html" 1>&2; \
	    echo 1>&2; \
	else \
	    echo "${PICKY} -w132 -u -s -t8 -v -e -- ${SRCFILES} ${H_FILES}"; \
	    ${PICKY} -w132 -u -s -t8 -v -e -- ${SRCFILES} ${H_FILES}; \
	    echo "${PICKY} -w132 -u -s -t8 -v -e -8 -- ${LESS_PICKY_CSRC}"; \
	    ${PICKY} -w132 -u -s -t8 -v -e -8 -- ${LESS_PICKY_CSRC}; \
	fi

# inspect and verify shell scripts
#
shellcheck: ${SH_FILES} .shellcheckrc Makefile
	@HAVE_SHELLCHECK=`command -v ${SHELLCHECK}`; if [[ -z "$$HAVE_SHELLCHECK" ]]; then \
	    echo 'If you have not installed the shellcheck tool, then' 1>&2; \
	    echo 'you may not run this rule.'; 1>&2; \
	    echo ''; 1>&2; \
	    echo 'See the following GitHub repo for shellcheck:'; 1>&2; \
	    echo ''; 1>&2; \
	    echo '    https://github.com/koalaman/shellcheck.net'; 1>&2; \
	    echo ''; 1>&2; \
	else \
	    echo "${SHELLCHECK} -f gcc -- ${SH_FILES}"; \
	    ${SHELLCHECK} -f gcc -- ${SH_FILES}; \
	fi

# Only run this rule when you wish to invalidate all timestamps
# prior to now, such as when you make a fundamental change to a
# critical JSON format, or make a fundamental change the compressed
# tarball file structure, or make a critical change to limit_ioccc.h
# that is MORE restrictive.
#
# DO NOT run this rule simply for a new IOCCC!
#
# Yes, we make it very hard to run this rule for good reason.
# Only IOCCC judges can perform the ALL the steps needed to complete this action.
#
reset_min_timestamp:
	@HAVE_RPL=`command -v rpl`; if [[ -z "$$HAVE_RPL" ]]; then \
	    echo 'If you have not bothered to install the rpl tool, then' 1>&2; \
	    echo 'you may not run this rule.'; 1>&2; \
	    exit 1; \
	fi
	@echo
	@echo 'Yes, we make it very hard to run this rule for good reasson.'
	@echo 'Only IOCCC judges can perform the ALL the steps needed to complete this action.'
	@echo
	@echo 'WARNING: This rule will invalidate all timestamps prior to now.'
	@echo 'WARNING: Only run this rule when you wish to invalidate all timestamps'
	@echo 'WARNING: because you made a fundamental change to a critical JSON format,'
	@echo 'WARNING: made a fundamental change to the compressed tarball file structure,'
	@echo 'WARNING: or made a critical change to limit_ioccc.h that is MORE restrictive.'
	@echo
	@echo 'WARNING: DO NOT run this rule simply for a new IOCCC!'
	@echo
	@echo 'WARNING: If you wish to do this, please enter the following phrase:'
	@echo
	@echo '    Please invalidate all IOCCC timestamps prior to now'
	@echo
	@read answer && \
	    if [[ "$$answer" != 'Please invalidate all IOCCC timestamps prior to now' ]]; then \
		echo 'Wise choice, MIN_TIMESTAMP was not changed.' 1>&2; \
		exit 2; \
	    fi
	@echo
	@echo 'WARNING: Are you sure you want to invalidate all existing compressed tarballs'
	@echo 'WARNING: and all prior .info.JSON files that have been made,'
	@echo 'WARNING: and all prior .author.JSON files that have been made,'
	@echo 'WARNING: forcing everyone to rebuild their compressed tarball entries?'
	@echo
	@echo 'WARNING: If you really wish to do this, please enter the following phrase:'
	@echo
	@echo '    I understand this'
	@echo
	@echo 'WARNING: followed by the phrase:'
	@echo
	@echo '    and say sorry to those with existing IOCCC compressed tarballs'
	@echo
	@read answer && \
	    if [[ "$$answer" != 'I understand this and say sorry to those with existing IOCCC compressed tarballs' ]]; then \
		echo 'Wise choice, MIN_TIMESTAMP was not changed.' 1>&2; \
		exit 3; \
	    fi
	@echo
	@echo 'WARNING: Enter the phrase that is required (even if you are from that very nice place):'
	@echo
	@read answer && \
	    if [[ "$$answer" != 'Sorry (tm Canada) :=)' ]]; then \
		echo 'Wise choice, MIN_TIMESTAMP was not changed.' 1>&2; \
		exit 4; \
	    fi
	@echo
	@echo -n 'WARNING: Enter the existing value of MIN_TIMESTAMP: '
	@read OLD_MIN_TIMESTAMP &&\
	    now=`/bin/date '+%s'` &&\
	    if ${GREP} "$$OLD_MIN_TIMESTAMP" limit_ioccc.h; then\
		echo; \
		echo "We guess that you do really really do want to change MIN_TIMESTAMP"; \
		echo; \
	        ${TRUE};\
	    else\
	        echo 'Invalid value of MIN_TIMESTAMP' 1>&2;\
		exit 5;\
	    fi &&\
	    ${RPL} -w -p \
	       "#define MIN_TIMESTAMP ((time_t)$$OLD_MIN_TIMESTAMP)"\
	       "#define MIN_TIMESTAMP ((time_t)$$now)" limit_ioccc.h;\
	    echo;\
	    echo "This line in limit_ioccc.h, as it exists now, is:";\
	    echo;\
	    ${GREP} '^#define MIN_TIMESTAMP' limit_ioccc.h;\
	    echo;\
	    echo 'WARNING: You still need to:';\
	    echo;\
	    echo '    make clobber all test';\
	    echo;\
	    echo 'WARNING: And if all is well, commit and push the change to the GitHib repo!';\
	    echo

# perform all of the mkiocccentry repo required tests
#
test: all iocccsize-test.sh dbg mkiocccentry-test.sh jstr-test.sh jint jfloat Makefile
	@chmod +x iocccsize-test.sh mkiocccentry-test.sh jstr-test.sh
	@echo "RUNNING: iocccsize-test.sh"
	./iocccsize-test.sh -v 1
	@echo "PASSED: iocccsize-test.sh"
	@echo
	@echo "This next test is supposed to fail with the error: FATAL[5]: main: simulated error, ..."
	@echo
	@echo "RUNNING: dbg"
	@${RM} -f dbg.out
	@status=`./dbg -e 2 foo bar baz 2>dbg.out; echo "$$?"`; \
	    if [ "$$status" != 5 ]; then \
		echo "exit status of dbg: $$status != 5"; \
		exit 1; \
	    fi
	@${GREP} -q '^FATAL\[5\]: main: simulated error, foo: foo bar: bar errno\[2\]: No such file or directory$$' dbg.out
	@${RM} -f dbg.out
	@echo "PASSED: dbg"
	@echo
	@echo "RUNNING: mkiocccentry-test.sh"
	./mkiocccentry-test.sh
	@echo "PASSED: mkiocccentry-test.sh"
	@echo
	@echo "RUNNING: jstr-test.sh"
	./jstr-test.sh
	@echo "PASSED: jstr-test.sh"
	@echo
	@echo "RUNNING: jint -t"
	./jint -t
	@echo "PASSED: jint -t"
	@echo
	@echo "RUNNING: jfloat -t"
	./jfloat -t
	@echo "PASSED: jfloat -t"
	@echo
	@echo "RUNNING: dyn_test"
	./dyn_test
	@echo "PASSED: dyn_test"
	@echo
	@echo "All tests PASSED"

# run json-test.sh on test_JSON files
#
# Currently this is very chatty but the important parts will also be written to
# json-test.log for evaluation.
#
# NOTE: The verbose and debug options are important to see more information and
# this is important even when all cases are resolved as we want to see if there
# are any problems if new files are added.
#
test-jinfochk: all jinfochk Makefile
	./json-test.sh -t jinfo_only -v 1 -D 1 -d test_JSON


###################################
# standard Makefile utility rules #
###################################

configure:
	@echo nothing to configure

clean:
	${RM} -f ${OBJFILES}
	${RM} -f ${GENERATED_OBJ}
	${RM} -f ${LESS_PICKY_OBJ}
	${RM} -rf ${DSYMDIRS}

clobber: clean
	${RM} -f ${TARGETS} ${TEST_TARGETS}
	${RM} -f ${GENERATED_CSRC} ${GENERATED_HSRC}
	${RM} -f answers.txt j-test.out j-test2.out json-test.log
	${RM} -rf test-iocccsize test_src test_work tags dbg.out
	${RM} -f jint.set.tmp jint_gen
	${RM} -f jfloat.set.tmp jfloat_gen
	${RM} -rf jint_gen.dSYM jfloat_gen.dSYM dyn_test.dSYM

distclean nuke: clobber

install: all
	${INSTALL} -v -m 0555 ${TARGETS} ${DESTDIR}
	${INSTALL} -v -m 0644 ${MANPAGES} ${MANDIR} 2>/dev/null

tags: ${ALL_CSRC} ${H_FILES}
	-${CTAGS} -- ${ALL_CSRC} ${H_FILES} 2>&1 | \
	     ${GREP} -E -v 'Duplicate entry|Second entry ignored'

depend:
	@LINE="`grep -n '^### DO NOT CHANGE' Makefile|awk -F : '{print $$1}'`"; \
        if [ "$$LINE" = "" ]; then                                              \
                echo "Make depend aborted, tag not found in Makefile.";         \
                exit;                                                           \
        fi;                                                                     \
        mv -f Makefile Makefile.orig;head -n $$LINE Makefile.orig > Makefile;   \
        echo "Generating dependencies.";					\
        ${CC} ${CFLAGS} -MM ${ALL_CSRC} >> Makefile
	@echo "Make depend completed.";


###############
# make depend #
###############

### DO NOT CHANGE MANUALLY BEYOND THIS LINE
utf8_posix_map.o: utf8_posix_map.c utf8_posix_map.h util.h dyn_array.h \
  dbg.h limit_ioccc.h version.h
jparse.o: jparse.c jparse.h dbg.h util.h dyn_array.h json.h sanity.h \
  location.h utf8_posix_map.h limit_ioccc.h version.h jparse.tab.h
jparse.tab.o: jparse.tab.c jparse.h dbg.h util.h dyn_array.h json.h \
  sanity.h location.h utf8_posix_map.h limit_ioccc.h version.h \
  jparse.tab.h
dbg.o: dbg.c dbg.h
util.o: util.c dbg.h util.h dyn_array.h limit_ioccc.h version.h
mkiocccentry.o: mkiocccentry.c mkiocccentry.h util.h dyn_array.h dbg.h \
  json.h location.h utf8_posix_map.h sanity.h limit_ioccc.h version.h \
  iocccsize.h
iocccsize.o: iocccsize.c iocccsize_err.h iocccsize.h
fnamchk.o: fnamchk.c fnamchk.h dbg.h util.h dyn_array.h limit_ioccc.h \
  version.h utf8_posix_map.h
txzchk.o: txzchk.c txzchk.h util.h dyn_array.h dbg.h sanity.h location.h \
  utf8_posix_map.h json.h limit_ioccc.h version.h
jauthchk.o: jauthchk.c jauthchk.h dbg.h util.h dyn_array.h json.h \
  sanity.h location.h utf8_posix_map.h limit_ioccc.h version.h
jinfochk.o: jinfochk.c jinfochk.h dbg.h util.h dyn_array.h json.h \
  sanity.h location.h utf8_posix_map.h limit_ioccc.h version.h
json.o: json.c dbg.h util.h dyn_array.h limit_ioccc.h version.h json.h
jstrencode.o: jstrencode.c jstrencode.h dbg.h util.h dyn_array.h json.h \
  limit_ioccc.h version.h
jstrdecode.o: jstrdecode.c jstrdecode.h dbg.h util.h dyn_array.h json.h \
  limit_ioccc.h version.h
rule_count.o: rule_count.c iocccsize_err.h iocccsize.h
location.o: location.c location.h util.h dyn_array.h dbg.h
sanity.o: sanity.c sanity.h util.h dyn_array.h dbg.h location.h \
  utf8_posix_map.h json.h
utf8_test.o: utf8_test.c utf8_posix_map.h util.h dyn_array.h dbg.h \
  limit_ioccc.h version.h
jint.o: jint.c jint.h dbg.h util.h dyn_array.h json.h limit_ioccc.h \
  version.h
jint.test.o: jint.test.c json.h
jfloat.o: jfloat.c jfloat.h dbg.h util.h dyn_array.h json.h limit_ioccc.h \
  version.h
jfloat.test.o: jfloat.test.c json.h
verge.o: verge.c verge.h dbg.h util.h dyn_array.h limit_ioccc.h version.h
dyn_array.o: dyn_array.c dyn_array.h util.h dbg.h
dyn_test.o: dyn_test.c dyn_test.h util.h dyn_array.h dbg.h version.h

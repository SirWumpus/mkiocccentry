#!/usr/bin/env make
#
# mkiocccentry and related tools - how to form an IOCCC entry
#
# For the mkiocccentry utility:
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
# For the iocccsize utility:
#
# This IOCCC size tool source file.  See below for the VERSION string.
#
# "You are not expected to understand this" :-)
#
# Public Domain 1992, 2015, 2018, 2019, 2021 by Anthony Howe.  All rights released.
# With IOCCC mods in 2019-2022 by chongo (Landon Curt Noll) ^oo^
####

####
# For the dbg facility:
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
BASENAME= basename
CAT= cat
CMP= cmp
CUT= cut
CC= cc
CP= cp
CTAGS= ctags
DIFF= diff
FMT= fmt
GIT= git
GREP= grep
HEAD= head
INSTALL= install
MAKE= make
MAN= man
MAN2HTML= man2html
MKTEMP= mktemp
MV= mv
PICKY= picky
RM= rm
RPL= rpl
RSYNC= rsync
SED= sed
SEQCEXIT= seqcexit
SHELL= bash
SHELLCHECK= shellcheck
CHECKNR= checknr
TEE= tee
TR= tr
TRUE= true


#######################
# Makefile parameters #
#######################

# linker options
#
LDFLAGS=

# C source standards being used
#
# This repo supports c11 and later.
#
# NOTE: The use of -std=gnu11 is because there are a few older systems
#	in late 2021 that do not have compilers that (yet) support gnu17.
#	While there may be even more out of date systems that do not
#	support gnu11, we have to draw the line somewhere.
#
#	--------------------------------------------------
#
#	^^ the line is above :-)
#
# TODO - ###################################################################### - TODO #
# TODO - In 2024 we will will support only c17 so C_STD will become -std=gnu17  - TODO #
# TODO - ###################################################################### - TODO #
#
C_STD= -std=gnu11
#C_STD= -std=gnu17

# optimization and debug level
#
#COPT= -O3 -g3	# TODO - this will be the production release value - TODO #
COPT= -O0 -g

# Compiler warnings
#
#WARN_FLAGS= -Wall -Wextra	# TODO - this will be the production release value - TODO #
WARN_FLAGS= -Wall -Wextra -Werror


# how to compile
#
# We test by forcing warnings to be errors so you don't have to (allegedly :-) )
#
CFLAGS= ${C_STD} ${COPT} -pedantic ${WARN_FLAGS} ${LDFLAGS}


# NOTE: If you use ASAN, set this environment var:
#	ASAN_OPTIONS="detect_stack_use_after_return=1"
#
#CFLAGS= ${C_STD} -O0 -g -pedantic ${WARN_FLAGS} ${LDFLAGS} -fsanitize=address -fno-omit-frame-pointer

# NOTE: For valgrind, run with:
#
#	valgrind --leak-check=yes --track-origins=yes --leak-resolution=high --read-var-info=yes \
#           --leak-check=full --show-leak-kinds=all ./mkiocccentry ...
#
# NOTE: Replace mkiocccentry with whichever tool you want to test and the ...
# with the arguments and options you want.

# where and what to install
#
MAN1_DIR= /usr/local/share/man/man1
MAN8_DIR= /usr/local/share/man/man8
MAN3_DIR= /usr/local/share/man/man3
DESTDIR= /usr/local/bin
TARGETS= mkiocccentry iocccsize fnamchk txzchk chkentry jstrencode jstrdecode \
	 jparse/jparse verge jnum_gen jsemtblgen
SH_TARGETS=limit_ioccc.sh

# man pages
#
# We explicitly define the man page targets for more than three reasons:
#
# (0) Currently not all targets have man pages.
# (1) Some of the targets that have man pages are not actually in the TARGETS
#     variable. TEST_TARGETS, for example, has utf8_test, which means
#     utf8_test.1 would be left out.
# (2) Even when all targets have man pages if another target is added without
#     adding a man page make install would fail and even if make install is not
#     that likely to be used we still don't want it to fail in the case it
#     actually is used.
# (3) Along the lines of (2) there are some files that will have man pages
#     (run_bison.sh and run_flex.sh for two examples) that are not targets at
#     all but still important parts of the repo so these would be skipped as
#     well if we directly referred to TARGETS.
#
MAN1_TARGETS= man/mkiocccentry man/txzchk man/fnamchk man/iocccsize man/chkentry man/jstrdecode man/jstrencode \
	      man/jparse man/bug_report man/hostchk man/run_flex man/run_bison
MAN3_TARGETS= dbg/dbg dyn_array/dyn_array
MAN8_TARGETS= man/reset_tstamp man/verge man/iocccsize_test man/ioccc_test man/run_usage man/utf8_test \
	      man/jparse_test man/txzchk_test man/vermod man/mkiocccentry_test man/jstr_test man/jnum_chk \
	      man/jnum_gen man/chkentry_test man/jsemtblgen man/jsemcgen man/all_ref
MAN_TARGETS= ${MAN1_TARGETS} ${MAN3_TARGETS} ${MAN8_TARGETS}
HTML_MAN_TARGETS= $(patsubst %,%.html,$(MAN_TARGETS))
# This is a simpler way to do:
#
#   MAN1PAGES= $(patsubst %,%.1,$(MAN1_TARGETS))
#   MAN3PAGES= $(patsubst %,%.3,$(MAN3_TARGETS))
#   MAN8PAGES= $(patsubst %,%.8,$(MAN8_TARGETS))
#
MAN1PAGES= $(MAN1_TARGETS:=.1)
MAN3PAGES= $(MAN3_TARGETS:=.3)
MAN8PAGES= $(MAN8_TARGETS:=.8)
MANPAGES= ${MAN1PAGES} ${MAN3PAGES} ${MAN8PAGES}

TEST_TARGETS= dbg/dbg_test test_ioccc/utf8_test test_ioccc/dyn_test test_ioccc/jnum_chk
OBJFILES= dbg/dbg.o util.o mkiocccentry.o iocccsize.o fnamchk.o txzchk.o chkentry.o \
	json_parse.o jstrencode.o jstrdecode.o rule_count.o location.o sanity.o verge.o \
	dyn_array/dyn_array.o test_ioccc/dyn_test.o dbg/dbg_test.o test_ioccc/jnum_chk.o jnum_gen.o test_ioccc/jnum_test.o \
	json_util.o jparse_main.o entry_util.o jsemtblgen.o soup/chk_sem_auth.o soup/chk_sem_info.o \
	soup/chk_validate.o json_sem.o entry_time.o
LESS_PICKY_CSRC= utf8_posix_map.c foo.c
LESS_PICKY_H_FILES= oebxergfB.h
LESS_PICKY_OBJ= utf8_posix_map.o foo.o
GENERATED_CSRC= jparse.c jparse.tab.c
GENERATED_HSRC= jparse.tab.h jparse.lex.h
GENERATED_OBJ= jparse.o jparse.tab.o
FLEXFILES= jparse.l
BISONFILES= jparse.y
# This is a simpler way to do:
#
#   SRCFILES=  $(patsubst %.o,%.c,$(OBJFILES))
#
SRCFILES= $(OBJFILES:.o=.c)
ALL_CSRC= ${LESS_PICKY_CSRC} ${GENERATED_CSRC} ${SRCFILES}
H_FILES= dbg/dbg.h chkentry.h json_parse.h jstrdecode.h jstrencode.h limit_ioccc.h \
	mkiocccentry.h txzchk.h util.h location.h utf8_posix_map.h jparse.h \
	verge.h sorry.tm.ca.h dyn_array/dyn_array.h test_ioccc/dyn_test.h json_util.h test_ioccc/jnum_chk.h \
	jnum_gen.h jparse_main.h entry_util.h jsemtblgen.h soup/chk_sem_auth.h \
	soup/chk_sem_info.h soup/chk_validate.h json_sem.h foo.h entry_time.h
# This is a simpler way to do:
#
#   DSYMDIRS= $(patsubst %,%.dSYM,$(TARGETS))
#
DSYMDIRS= $(TARGETS:=.dSYM)
SH_FILES= test_ioccc/iocccsize_test.sh test_ioccc/jstr_test.sh limit_ioccc.sh test_ioccc/mkiocccentry_test.sh \
	  vermod.sh prep.sh run_bison.sh run_flex.sh reset_tstamp.sh test_ioccc/ioccc_test.sh \
	  test_ioccc/jparse_test.sh test_ioccc/txzchk_test.sh hostchk.sh jsemcgen.sh \
	  run_usage.sh bug_report.sh soup/all_ref.sh test_ioccc/chkentry_test.sh soup/fmt_depend.sh
BUILD_LOG= build.log
TXZCHK_LOG= test_ioccc/txzchk_test.log

# RUN_O_FLAG - determine if the bison and flex backup files should be used
#
# RUN_O_FLAG=		use bison and flex backup files,
#			    if bison and/or flex not found or too old
# RUN_O_FLAG= -o	do not use bison and flex backup files,
#			    instead fail if bison and/or flex not found or too old
#
RUN_O_FLAG=
#RUN_O_FLAG= -o

# the basename of bison (or yacc) to look for
#
BISON_BASENAME= bison
#BISON_BASENAME= yacc

# Where run_bison.sh will search for bison with a recent enough version
#
# The -B arguments specify where to look for bison with a version,
# that is >= the minimum version (see MIN_BISON_VERSION in limit_ioccc.sh),
# before searching for bison on $PATH.
#
# NOTE: If is OK if these directories do not exist.
#
BISON_DIRS= \
	-B /opt/homebrew/opt/bison/bin \
	-B /usr/local/opt/bison/bin \
	-B /opt/homebrew/bin \
	-B /opt/local/bin \
	-B /usr/local/opt \
	-B /usr/local/bin \
	-B .

# Additional flags to pass to bison
#
# For --report all it will generate upon execution (if bison successfully
# generates the code) the file jparse.output. With --report all --html it will
# generate a html file which is easier to follow but I'm not sure how portable
# this is; under CentOS (which does not have the right version but actually
# normally generates code fine) the error:
#
#   jparse.y: error: xsltproc failed with status 127
#
# is thrown and since this could happen on other systems even with the
# appropriate version I have not enabled this.
#
# For the -Wcounterexamples it gives counter examples if there are ever
# shift/reduce conflicts in the grammar. The other warnings are of use as well.
#
BISON_FLAGS= -Werror -Wcounterexamples -Wmidrule-values -Wprecedence -Wdeprecated \
	      --report all --header

# the basename of flex (or lex) to look for
#
FLEX_BASENAME= flex
#FLEX_BASENAME= lex

# Where run_flex.sh will search for flex with a recent enough version
#
# The -F arguments specify where to look for flex with a version,
# that is >= the minimum version (see MIN_FLEX_VERSION in limit_ioccc.sh),
# before searching for bison on $PATH.
#
# NOTE: If is OK if these directories do not exist.
#
FLEX_DIRS= \
	-F /opt/homebrew/opt/flex/bin \
	-F /usr/local/opt/flex/bin \
	-F /opt/homebrew/bin \
	-F /opt/local/bin \
	-F /usr/local/opt \
	-F /usr/local/bin \
	-F .

# flags to pass to flex
#
FLEX_FLAGS= -8

############################################################
# User specific configurations - override Makefile values  #
############################################################

# The directive below retrieves any user specific configurations from makefile.local.
#
# The - before include means it's not an error if the file does not exist.
#
# We put this directive just before the first all rule so that you may override
# or modify any of the above Makefile variables.  To override a value, use := symbols.
# For example:
#
#	CC:= gcc
#
-include makefile.local


######################################
# all - default rule - must be first #
######################################

all: dbg soup fast_hostchk just_all

# The original make all that bypasses running hostchk.sh
#
just_all: ${TARGETS}

# fast build environment sanity check
#
fast_hostchk: hostchk.sh
	@-./hostchk.sh -f -v 0; status="$$?"; if [ "$$status" -ne 0 ]; then \
	    ${MAKE} hostchk_warning; \
	fi

bug_report: bug_report.sh
	@-./bug_report.sh -v 1

# slower more verbose build environment sanity check
#
hostchk: hostchk.sh
	@-./hostchk.sh -v 1; status="$$?"; if [ "$$status" -ne 0 ]; then \
	    ${MAKE} hostchk_warning; \
	fi

# get the users attention when hostchk.sh finds a problem
#
hostchk_warning:
	@echo 1>&2
	@echo '=-= WARNING WARNING WARNING =-=' 1>&2
	@echo '=-= hostchk exited non-zero =-=' 1>&2
	@echo 1>&2
	@echo '=-= WARNING WARNING WARNING =-=' 1>&2
	@echo '=-= your build environment may not be able to compile =-=' 1>&2
	@echo '=-= mkiocccentry and friends =-=' 1>&2
	@echo 1>&2
	@echo '=-= WARNING WARNING WARNING =-=' 1>&2
	@echo '=-= For hints as to what might be wrong try running:' 1>&2
	@echo 1>&2
	@echo '    ./hostchk.sh -v 1' 1>&2
	@echo 1>&2
	@echo '=-= WARNING WARNING WARNING =-=' 1>&2
	@echo '=-= If you think this is a bug, consider filing a bug report via:' 1>&2
	@echo 1>&2
	@echo '    ./bug_report.sh' 1>&2
	@echo 1>&2
	@echo '=-= about to sleep 10 seconds =-=' 1>&2
	@echo 1>&2
	@sleep 10
	@echo '=-= Letting the compile continue in hopes it might be OK, =-=' 1>&2
	@echo '=-= even though we doubt it will be OK. =-=' 1>&2
	@echo 1>&2

# rules, not file targets
#
.PHONY: all just_all fast_hostchk hostchk hostchk_warning all_ref all_ref_ptch mkchk_sem bug_report.sh build \
	checknr clean clean_generated_obj clean_mkchk_sem clobber configure depend hostchk bug_report.sh \
	install test_ioccc legacy_clobber man2html mkchk_sem parser parser-o picky prep prep_clobber \
        pull rebuild_jnum_test release reset_min_timestamp seqcexit shellcheck tags test test-chkentry use_ref \
	dbg soup dyn_array jparse


#####################################
# rules to compile and build source #
#####################################

rule_count.o: rule_count.c Makefile
	${CC} ${CFLAGS} -DMKIOCCCENTRY_USE rule_count.c -c

sanity.o: sanity.c Makefile
	${CC} ${CFLAGS} sanity.c -c

entry_util.o: entry_util.c Makefile
	${CC} ${CFLAGS} entry_util.c -c

entry_time.o: entry_time.c Makefile
	${CC} ${CFLAGS} entry_time.c -c

dbg: dbg/dbg.h dbg/dbg.c
	@${MAKE} -C dbg CFLAGS="${CFLAGS}"
	@${CP} -f dbg/dbg.3 man/dbg.3

mkiocccentry.o: mkiocccentry.c Makefile
	${CC} ${CFLAGS} mkiocccentry.c -c

mkiocccentry: mkiocccentry.o rule_count.o dbg/dbg.o util.o dyn_array/dyn_array.o json_parse.o entry_util.o \
	json_util.o entry_time.o location.o utf8_posix_map.o sanity.o json_sem.o
	${CC} ${CFLAGS} $^ -lm -o $@

iocccsize.o: iocccsize.c Makefile
	${CC} ${CFLAGS} -DMKIOCCCENTRY_USE iocccsize.c -c

iocccsize: iocccsize.o rule_count.o dbg/dbg.o Makefile
	${CC} ${CFLAGS} iocccsize.o rule_count.o dbg/dbg.o -o $@

fnamchk.o: fnamchk.c fnamchk.h Makefile
	${CC} ${CFLAGS} fnamchk.c -c

fnamchk: fnamchk.o dbg/dbg.o util.o dyn_array/dyn_array.o Makefile
	${CC} ${CFLAGS} fnamchk.o dbg/dbg.o util.o dyn_array/dyn_array.o -o $@

txzchk.o: txzchk.c txzchk.h Makefile
	${CC} ${CFLAGS} txzchk.c -c

txzchk: txzchk.o dbg/dbg.o util.o dyn_array/dyn_array.o location.o \
	utf8_posix_map.o sanity.o Makefile
	${CC} ${CFLAGS} txzchk.o dbg/dbg.o util.o dyn_array/dyn_array.o location.o \
	     utf8_posix_map.o sanity.o -o $@

soup: soup/chk.auth.head.c soup/chk.auth.ptch.h soup/chk.info.head.c soup/chk.info.ptch.h \
	soup/chk_sem_auth.c  soup/chk_sem_info.h soup/chk.auth.head.h soup/chk.auth.tail.c \
	soup/chk.info.head.h soup/chk.info.tail.c soup/chk_sem_auth.h  soup/chk_validate.c \
	soup/chk.auth.ptch.c soup/chk.auth.tail.h soup/chk.info.ptch.c soup/chk.info.tail.h \
	soup/chk_sem_info.c  soup/chk_validate.h
	@${MAKE} -C soup CFLAGS="${CFLAGS}"

chkentry.o: chkentry.c chkentry.h jparse.tab.h Makefile
	${CC} ${CFLAGS} -Isoup chkentry.c -c

chkentry: chkentry.o dbg/dbg.o util.o sanity.o utf8_posix_map.o dyn_array/dyn_array.o jparse.o jparse.tab.o json_parse.o \
	json_util.o soup/chk_validate.o entry_util.c json_sem.o foo.o location.o soup/chk_sem_info.o \
	soup/chk_sem_auth.o Makefile
	${CC} ${CFLAGS} chkentry.o dbg/dbg.o util.o sanity.o utf8_posix_map.o jparse.o jparse.tab.o dyn_array/dyn_array.o json_parse.o \
		json_util.o soup/chk_validate.o entry_util.o entry_time.o json_sem.o foo.o location.o soup/chk_sem_info.o \
		soup/chk_sem_auth.o -lm -o $@

jstrencode.o: jstrencode.c jstrencode.h json_util.h json_util.c Makefile
	${CC} ${CFLAGS} jstrencode.c -c

jstrencode: jstrencode.o dbg/dbg.o json_parse.o json_util.o util.o dyn_array/dyn_array.o Makefile
	${CC} ${CFLAGS} jstrencode.o dbg/dbg.o json_parse.o json_util.o util.o dyn_array/dyn_array.o -lm -o $@

jstrdecode.o: jstrdecode.c jstrdecode.h json_util.h json_parse.h Makefile
	${CC} ${CFLAGS} jstrdecode.c -c

jstrdecode: jstrdecode.o dbg/dbg.o json_parse.o json_util.o util.o dyn_array/dyn_array.o Makefile
	${CC} ${CFLAGS} jstrdecode.o dbg/dbg.o json_parse.o json_util.o util.o dyn_array/dyn_array.o -lm -o $@

jnum_gen.o: jnum_gen.c jnum_gen.h Makefile
	${CC} ${CFLAGS} jnum_gen.c -c

jnum_gen: jnum_gen.o dbg/dbg.o json_parse.o json_util.o util.o dyn_array/dyn_array.o Makefile
	${CC} ${CFLAGS} jnum_gen.o dbg/dbg.o json_parse.o json_util.o util.o dyn_array/dyn_array.o -lm -o $@

jparse.o: jparse.c jparse.h Makefile
	${CC} ${CFLAGS} -Wno-unused-but-set-variable -Wno-unused-function -Wno-unneeded-internal-declaration jparse.c -c

json_sem.o: json_sem.c Makefile
	${CC} ${CFLAGS} json_sem.c -c

json_util.o: json_util.c json_util.h Makefile
	${CC} ${CFLAGS} -Wno-unused-function -Wno-unneeded-internal-declaration json_util.c -c

json_parse.o: json_parse.c Makefile
	${CC} ${CFLAGS} json_parse.c -c

jparse.tab.o: jparse.tab.c Makefile
	${CC} ${CFLAGS} -Wno-unused-function -Wno-unneeded-internal-declaration jparse.tab.c -c

jparse_main.o: jparse_main.c Makefile
	${CC} ${CFLAGS} jparse_main.c -c

jparse/jparse: jparse.o jparse.tab.o util.o dyn_array/dyn_array.o dbg/dbg.o json_parse.o \
	json_util.o jparse_main.o Makefile
	${CC} ${CFLAGS} jparse.o jparse.tab.o util.o dyn_array/dyn_array.o dbg/dbg.o json_parse.o \
			json_util.o jparse_main.o -lm -o $@

jparse: jparse/jparse
	@:

jsemtblgen.o: jsemtblgen.c Makefile
	${CC} ${CFLAGS} jsemtblgen.c -c

jsemtblgen: jsemtblgen.o jparse.o jparse.tab.o util.o dyn_array/dyn_array.o dbg/dbg.o json_parse.o \
	    json_util.o rule_count.o Makefile
	${CC} ${CFLAGS} jsemtblgen.o jparse.o jparse.tab.o util.o dyn_array/dyn_array.o dbg/dbg.o json_parse.o \
			json_util.o rule_count.o -lm -o $@

verge.o: verge.c verge.h Makefile
	${CC} ${CFLAGS} verge.c -c

verge: verge.o dbg/dbg.o util.o dyn_array/dyn_array.o Makefile
	${CC} ${CFLAGS} verge.o dbg/dbg.o util.o dyn_array/dyn_array.o -o $@

dyn_array: dyn_array/dyn_array.h dyn_array/dyn_array.c
	@${MAKE} -C dyn_array CFLAGS="${CFLAGS}"
	@${CP} -f dyn_array/dyn_array.3 man/dyn_array.3

foo.o: foo.c oebxergfB.h Makefile
	${CC} ${CFLAGS} foo.c -c

limit_ioccc.sh: limit_ioccc.h version.h dbg/dbg.h dyn_array/dyn_array.h test_ioccc/dyn_test.h jparse.h jparse_main.h \
		Makefile
	${RM} -f $@
	@echo '#!/usr/bin/env bash' > $@
	@echo '#' >> $@
	@echo '# Copies of select limit_ioccc.h and version.h values for shell script use' >> $@
	@echo '#' >> $@
	${GREP} -E '^#define (RULE_|MAX_|UUID_|MIN_|IOCCC_)' limit_ioccc.h | \
	    ${AWK} '{print $$2 "=\"" $$3 "\"" ;}' | ${TR} -d '[a-z]()' | \
	    ${SED} -e 's/"_/"/' -e 's/""/"/g' -e 's/^/export /' >> $@
	${GREP} -hE '^#define (.*_VERSION|TIMESTAMP_EPOCH|JSON_PARSING_DIRECTIVE_)' \
		     version.h limit_ioccc.h dbg/dbg.h dyn_array/dyn_array.h test_ioccc/dyn_test.h jparse.h jparse_main.h | \
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
# Convert jparse.y into jparse.tab.c and jparse.tab.c via bison, if bison is
# found and has a recent enough version. Otherwise, if RUN_O_FLAG is NOT
# specified use a pre-built reference copies stored in jparse.tab.ref.h and
# jparse.tab.ref.c. If it IS specified it is an error.
#
# NOTE: The value of RUN_O_FLAG depends on what rule called this rule.
jparse.tab.c jparse.tab.h bison: jparse.y jparse.h sorry.tm.ca.h run_bison.sh limit_ioccc.sh \
	verge jparse.tab.ref.c jparse.tab.ref.h Makefile
	./run_bison.sh -b ${BISON_BASENAME} ${BISON_DIRS} -p jparse -v 1 ${RUN_O_FLAG} -- \
		       ${BISON_FLAGS}

# How to create jparse.c and jparse.lex.h
#
# Convert jparse.l into jparse.c via flex, if flex found and has a recent enough
# version. Otherwise, if RUN_O_FLAG is NOT set use the pre-built reference copy
# stored in jparse.ref.c. If it IS specified it is an error.
#
# NOTE: The value of RUN_O_FLAG depends on what rule called this rule.
jparse.c jparse.lex.h flex: jparse.l jparse.h sorry.tm.ca.h jparse.tab.h run_flex.sh limit_ioccc.sh \
	       verge jparse.ref.c jparse.lex.ref.h Makefile
	./run_flex.sh -f ${FLEX_BASENAME} ${FLEX_DIRS} -p jparse -v 1 ${RUN_O_FLAG} -- \
		      ${FLEX_FLAGS} -o jparse.c


###################################################################
# repo tools - rules for those who maintain the mkiocccentry repo #
###################################################################

#
# make build release pull
#
# Things to do before a release, forming a pull request and/or updating the
# GitHub repo.
#
# This runs through all of the prep steps, exiting on the first failure.
#
# NOTE: The reference copies of the JSON parser C code will NOT be used
# so if bison and/or flex is not found or too old THIS RULE WILL FAIL!
#
# NOTE: Please try this rule BEFORE make prep.
#
build release pull: prep.sh
	${RM} -f ${BUILD_LOG}
	@echo "./prep.sh -e -o 2>&1 | ${TEE} ${BUILD_LOG}"
	@./prep.sh -e -o 2>&1 | ${TEE} "${BUILD_LOG}"; \
	    EXIT_CODE="$${PIPESTATUS[0]}"; \
	    if [[ $$EXIT_CODE -ne 0 ]]; then \
		echo "=-=-=-=-= Warning: prep.sh error code: $$EXIT_CODE =-=-=-=-=" 1>&2; \
		echo 1>&2; \
		echo "NOTE: The above details were saved in the file: ${BUILD_LOG}"; \
		echo 1>&2; \
		exit 1; \
	    else \
		echo "NOTE: The above details were saved in the file: ${BUILD_LOG}"; \
	    fi

#
# make prep
#
# Things to do before a release, forming a pull request and/or updating the
# GitHub repo.
#
# This runs through all of the prep steps.  If some step failed along the way,
# exit non-zero at the end.
#
# NOTE: This rule is useful if for example you're not working on the parser and
# you're on a system without the proper versions of flex and/or bison but you
# still want to work on the repo. Another example use is if you don't have
# shellcheck and/or picky and you want to work on the repo.
#
# The point is: if you're working on this repo and make build fails, try this
# rule instead.
#
prep: prep.sh
	${RM} -f ${BUILD_LOG}
	@echo "./prep.sh 2>&1 | ${TEE} ${BUILD_LOG}"
	@-./prep.sh 2>&1 | ${TEE} "${BUILD_LOG}"; \
	    EXIT_CODE="$${PIPESTATUS[0]}"; \
	    if [[ $$EXIT_CODE -ne 0 ]]; then \
		echo "=-=-=-=-= Warning: prep.sh error code: $$EXIT_CODE =-=-=-=-=" 1>&2; \
		echo 1>&2; \
	    fi
	@echo NOTE: The above details were saved in the file: ${BUILD_LOG}

#
# make parser
#
# Force the rebuild of the JSON parser and then form the reference copies of
# JSON parser C code (if recent enough version of flex and bison are found).
#
parser: jparse.y jparse.l Makefile
	${RM} -f jparse.tab.c jparse.tab.h
	${MAKE} jparse.tab.c jparse.tab.h
	${MAKE} jparse.tab.o
	${RM} -f jparse.c jparse.lex.h
	${MAKE} jparse.c jparse.lex.h
	${MAKE} jparse.o
	${RM} -f jparse.tab.ref.c
	${CP} -f -v jparse.tab.c jparse.tab.ref.c
	${RM} -f jparse.tab.ref.h
	${CP} -f -v jparse.tab.h jparse.tab.ref.h
	${RM} -f jparse.ref.c
	${CP} -f -v jparse.c jparse.ref.c
	${RM} -f -v jparse.lex.ref.h
	${CP} -f -v jparse.lex.h jparse.lex.ref.h
	${MAKE} all

#
# make parser-o: Force the rebuild of the JSON parser.
#
# NOTE: This does NOT use the reference copies of JSON parser C code.
#
parser-o: jparse.y jparse.l Makefile
	${MAKE} parser RUN_O_FLAG='-o'

# restore reference code that was produced by previous successful make parser
#
# This rule forces the use of reference copies of JSON parser C code.
use_ref: jparse.tab.ref.c jparse.tab.ref.h jparse.ref.c jparse.lex.ref.h
	${RM} -f jparse.tab.c
	${CP} -f -v jparse.tab.ref.c jparse.tab.c
	${RM} -f jparse.tab.h
	${CP} -f -v jparse.tab.ref.h jparse.tab.h
	${RM} -f jparse.c
	${CP} -f -v jparse.ref.c jparse.c
	${RM} -f jparse.lex.h
	${CP} -f -v jparse.lex.ref.h jparse.lex.h

# use jnum_gen to regenerate test jnum_chk test suite
#
rebuild_jnum_test: jnum_gen test_ioccc/jnum.testset jnum_header.c Makefile
	${RM} -f test_ioccc/jnum_test.c
	${CP} -f -v jnum_header.c test_ioccc/jnum_test.c
	./jnum_gen test_ioccc/jnum.testset >> test_ioccc/jnum_test.c

# Form unpatched semantic tables, without headers and trailers, from the reference info and auth JSON files
#
# rule used by prep.sh
#
all_ref: jsemtblgen jsemcgen.sh test_ioccc/test_JSON/info.json/good test_ioccc/test_JSON/auth.json/good soup/all_ref.sh
	rm -rf soup/ref
	mkdir -p soup/ref
	./soup/all_ref.sh -v 1 \
	    soup/chk.info.head.c soup/chk.info.tail.c soup/chk.info.head.h soup/chk.info.tail.h \
	    soup/chk.auth.head.c soup/chk.auth.tail.c soup/chk.auth.head.h soup/chk.auth.tail.h \
	    test_ioccc/test_JSON/info.json/good test_ioccc/test_JSON/auth.json/good soup/ref

# form chk.????.ptch.{c,h} files
#
# Given a correct set of soup/chk_sem_????.{c,h} files, we form chk.????.ptch.{c,h}
# diff patch relative to the ref/*.reference.json.{c,h} files.
#
# rule should never be invoked by prep.sh
#
# This rule is run by the repo maintainers only AFTER soup/chk_sem_????.{c,h} files
# are updated by hand.
#
all_ref_ptch: soup/ref/info.reference.json.c soup/ref/info.reference.json.h \
	      soup/ref/auth.reference.json.c soup/ref/auth.reference.json.h
	rm -f soup/chk.info.ptch.c
	-diff -u soup/ref/info.reference.json.c soup/chk_sem_info.c > soup/chk.info.ptch.c
	rm -f soup/chk.info.ptch.h
	-diff -u soup/ref/info.reference.json.h soup/chk_sem_info.h > soup/chk.info.ptch.h
	rm -f soup/chk.auth.ptch.c
	-diff -u soup/ref/auth.reference.json.c soup/chk_sem_auth.c > soup/chk.auth.ptch.c
	rm -f soup/chk.auth.ptch.h
	-diff -u soup/ref/auth.reference.json.h soup/chk_sem_auth.h > soup/chk.auth.ptch.h

# Form the soup/chk_sem_????.{c,h} files
#
# rule used by prep.sh
#
mkchk_sem: soup/chk_sem_auth.c soup/chk_sem_auth.h soup/chk_sem_info.c soup/chk_sem_info.h

soup/chk_sem_auth.c: jsemtblgen jsemcgen.sh test_ioccc/test_JSON/auth.json/good/auth.reference.json \
		soup/chk.auth.head.c soup/chk.auth.ptch.c soup/chk.auth.tail.c Makefile
	@${RM} -f $@
	./jsemcgen.sh -N sem_auth -P chk -- \
	    test_ioccc/test_JSON/auth.json/good/auth.reference.json soup/chk.auth.head.c soup/chk.auth.ptch.c soup/chk.auth.tail.c $@

soup/chk_sem_auth.h: jsemtblgen jsemcgen.sh test_ioccc/test_JSON/auth.json/good/auth.reference.json \
		soup/chk.auth.head.h soup/chk.auth.ptch.h soup/chk.auth.tail.h Makefile
	@${RM} -f $@
	./jsemcgen.sh -N sem_auth -P chk -I -- \
	    test_ioccc/test_JSON/auth.json/good/auth.reference.json soup/chk.auth.head.h soup/chk.auth.ptch.h soup/chk.auth.tail.h $@

soup/chk_sem_info.c: jsemtblgen jsemcgen.sh test_ioccc/test_JSON/info.json/good/info.reference.json \
		soup/chk.info.head.c soup/chk.info.ptch.c soup/chk.info.tail.c Makefile
	@${RM} -f $@
	./jsemcgen.sh -N sem_info -P chk -- \
	    test_ioccc/test_JSON/info.json/good/info.reference.json soup/chk.info.head.c soup/chk.info.ptch.c soup/chk.info.tail.c $@

soup/chk_sem_info.h: jsemtblgen jsemcgen.sh test_ioccc/test_JSON/info.json/good/info.reference.json \
		soup/chk.info.head.h soup/chk.info.ptch.h soup/chk.info.tail.h Makefile
	@${RM} -f $@
	./jsemcgen.sh -N sem_info -P chk -I -- \
	    test_ioccc/test_JSON/info.json/good/info.reference.json soup/chk.info.head.h soup/chk.info.ptch.h soup/chk.info.tail.h $@

# sequence exit codes
#
seqcexit: Makefile
	@HAVE_SEQCEXIT="`type -P ${SEQCEXIT}`"; if [[ -z "$$HAVE_SEQCEXIT" ]]; then \
	    echo 'The seqcexit tool could not be found.' 1>&2; \
	    echo 'The seqcexit tool is required for this rule.'; 1>&2; \
	    echo ''; 1>&2; \
	    echo 'See the following GitHub repo for seqcexit:'; 1>&2; \
	    echo ''; 1>&2; \
	    echo '    https://github.com/lcn2/seqcexit'; 1>&2; \
	    echo ''; 1>&2; \
	    exit 1; \
	else \
	    echo "${SEQCEXIT} -c -D werr_sem_val -D werrp_sem_val -- ${FLEXFILES} ${BISONFILES}"; \
	    ${SEQCEXIT} -c -D werr_sem_val -D werrp_sem_val -- ${FLEXFILES} ${BISONFILES}; \
	    echo "${SEQCEXIT} -D werr_sem_val -D werrp_sem_val -- ${ALL_CSRC}"; \
	    ${SEQCEXIT} -D werr_sem_val -D werrp_sem_val -- ${ALL_CSRC}; \
	fi

picky: ${ALL_CSRC} ${H_FILES} ${LESS_PICKY_H_FILES} ${FLEXFILES} ${BISONFILES} Makefile
	@if ! type -P ${PICKY} >/dev/null 2>&1; then \
	    echo "The picky tool could not be found." 1>&2; \
	    echo "The picky tool is required for this rule." 1>&2; \
	    echo "We recommend you install picky v2.6 or later" 1>&2; \
	    echo "from this URL:" 1>&2; \
	    echo 1>&2; \
	    echo "http://grail.eecs.csuohio.edu/~somos/picky.html" 1>&2; \
	    echo 1>&2; \
	    exit 1; \
	else \
	    echo "${PICKY} -w132 -u -s -t8 -v -e -- ${SRCFILES} ${H_FILES} ${FLEXFILES} ${BISONFILES}"; \
	    ${PICKY} -w132 -u -s -t8 -v -e -- ${SRCFILES} ${H_FILES} ${FLEXFILES} ${BISONFILES}; \
	    echo "${PICKY} -w132 -u -s -t8 -v -e -8 -- ${LESS_PICKY_CSRC} ${LESS_PICKY_H_FILES}"; \
	    ${PICKY} -w132 -u -s -t8 -v -e -8 -- ${LESS_PICKY_CSRC} ${LESS_PICKY_H_FILES}; \
	    echo "${PICKY} -w -u -s -t8 -v -e -8 -- ${SH_FILES}"; \
	    ${PICKY} -w -u -s -t8 -v -e -8 -- ${SH_FILES}; \
	fi

# inspect and verify shell scripts
#
shellcheck: ${SH_FILES} .shellcheckrc Makefile
	@HAVE_SHELLCHECK="`type -P ${SHELLCHECK}`"; if [[ -z "$$HAVE_SHELLCHECK" ]]; then \
	    echo 'The shellcheck command could not be found.' 1>&2; \
	    echo 'The shellcheck command is required to run this rule.'; 1>&2; \
	    echo ''; 1>&2; \
	    echo 'See the following GitHub repo for shellcheck:'; 1>&2; \
	    echo ''; 1>&2; \
	    echo '    https://github.com/koalaman/shellcheck.net'; 1>&2; \
	    echo ''; 1>&2; \
	    echo 'Or use the package manager in your OS to install it.' 1>&2; \
	    exit 1; \
	else \
	    echo "${SHELLCHECK} -f gcc -- ${SH_FILES}"; \
	    ${SHELLCHECK} -f gcc -- ${SH_FILES}; \
	fi

# inspect and verify man pages
#
checknr: ${MANPAGES}
	@HAVE_CHECKNR="`type -P ${CHECKNR}`"; if [[ -z "$$HAVE_CHECKNR" ]]; then \
	    echo 'The checknr command could not be found.' 1>&2; \
	    echo 'The checknr command is required to run this rule.'; 1>&2; \
	    echo ''; 1>&2; \
	    exit 1; \
	else \
	    echo "${CHECKNR} -c.BR.SS.BI ${MANPAGES}"; \
	    ${CHECKNR} -c.BR.SS.BI ${MANPAGES}; \
	fi

man2html: ${MANPAGES}
	@HAVE_MAN2HTML="`type -P ${MAN2HTML}`"; \
	 HAVE_MAN="`type -P ${MAN}`"; \
	if [[ -z "$$HAVE_MAN2HTML" ]]; then \
	    echo 'The man2html command could not be found.' 1>&2; \
	    echo 'The man2html command is required to run this rule.'; 1>&2; \
	fi; \
	if [[ -z "$$HAVE_MAN" ]]; then \
	    echo 'The man command could not be found.' 1>&2; \
	    echo 'The man command is required to run this rule.'; 1>&2; \
	fi; \
	if [[ -z "$$HAVE_MAN2HTML" || -z "$$HAVE_MAN" ]]; then \
	    echo ''; 1>&2; \
	    exit 1; \
	fi
	@for i in ${MAN1_TARGETS}; do \
	    echo ${RM} -f "$$i.html"; \
	    ${RM} -f "$$i.html"; \
	    echo "${MAN} ./$$i.1 | ${MAN2HTML} -compress -title $$i > man/$$i.html"; \
	    ${MAN} "./$$i.1" | ${MAN2HTML} -compress -title "$$i" > man/"$$i.html"; \
	done
	@for i in ${MAN3_TARGETS}; do \
	    echo ${RM} -f "$$i.html"; \
	    ${RM} -f "$$i.html"; \
	    echo "${MAN} ./$$i.3 | ${MAN2HTML} -compress -title $$i > man/$$i.html"; \
	    ${MAN} "./$$i.3" | ${MAN2HTML} -compress -title "$$i" > man/"$$i.html"; \
	done
	@for i in ${MAN8_TARGETS}; do \
	    echo ${RM} -f "$$i.html"; \
	    ${RM} -f "$$i.html"; \
	    echo "${MAN} ./$$i.8 | ${MAN2HTML} -compress -title $$i > man/$$i.html"; \
	    ${MAN} "./$$i.8" | ${MAN2HTML} -compress -title "$$i" > man/"$$i.html"; \
	done

# Only run this rule when you wish to invalidate all timestamps
# prior to now, such as when you make a fundamental change to a
# critical JSON format, or make a fundamental change the compressed
# tarball file structure, or make a critical change to limit_ioccc.h
# that is MORE restrictive.
#
# DO NOT run this rule simply for a new IOCCC!
#
# Yes, we make it very hard to run this rule for good reason.
# Only IOCCC judges can perform ALL the steps needed to complete this action.
#
reset_min_timestamp: reset_tstamp.sh
	./reset_tstamp.sh

test_ioccc:
	${MAKE} -C test_ioccc


# perform all of the mkiocccentry repo required tests
#
test: dbg all chkentry test_ioccc/ioccc_test.sh test_ioccc/iocccsize_test.sh \
	    test_ioccc/mkiocccentry_test.sh test_ioccc/jstr_test.sh \
	    test_ioccc/txzchk_test.sh txzchk jparse
	${MAKE} -C test_ioccc test
	@echo
	@echo 'All tests PASSED'

# run test-chkentry on test_JSON files
#
test-chkentry: all chkentry test_ioccc/test-chkentry.sh Makefile
	./test_ioccc/test-chkentry.sh -v 1

# rule used by prep.sh and make clean
#
clean_generated_obj:
	${RM} -f ${GENERATED_OBJ}

# rule used by prep.sh
#
clean_mkchk_sem:
	${RM} -f soup/chk_sem_auth.c soup/chk_sem_auth.h soup/chk_sem_auth.o
	${RM} -f soup/chk_sem_info.c soup/chk_sem_info.h soup/chk_sem_info.o

# clobber legacy code and files - files that are no longer needed
#
legacy_clobber:
	${RM} -f jint jfloat
	${RM} -f jint.set.tmp jint_gen
	${RM} -f jfloat.set.tmp jfloat_gen
	${RM} -rf jint_gen.dSYM jfloat_gen.dSYM
	${RM} -f jnumber
	${RM} -rf jnumber.dSYM
	${RM} -f jauthchk
	${RM} -rf jauthchk.dSYM
	${RM} -f jinfochk
	${RM} -rf jinfochk.dSYM
	${RM} -rf ref
	${RM} -f chk.{auth,info}.{head,tail,ptch}.{c,h}
	${RM} -f chk_sem_auth.o chk_sem_info.o chk_validate.o
	${RM} -f jstr_test.out jstr_test2.out
	${RM} -rf test_iocccsize test_src test_work
	${RM} -f dbg_test.c
	${RM} -rf dyn_test.dSYM
	${RM} -f jparse_test.log chkentry_test.log txzchk_test.log
	${RM} -f test_ioccc.log chkentry_test.log jparse_test.log txzchk_test.log
	${RM} -f jnum_chk
	${RM} -rf jnum_chk.dSYM
	${RM} -rf test_iocccsize test_src test_work
	${RM} -f .exit_code.*
	${RM} -f dbg.out
	${RM} -rf ioccc_test test

# rule used by prep.sh and make clobber
#
prep_clobber: legacy_clobber
	${RM} -f ${TARGETS} ${TEST_TARGETS}
	${RM} -f ${GENERATED_CSRC} ${GENERATED_HSRC}
	${RM} -f answers.txt
	${RM} -f test_ioccc/jstr_test.out test_ioccc/jstr_test2.out
	${RM} -rf test_ioccc/test_iocccsize test_ioccc/test_src test_ioccc/test_work
	${RM} -f tags dbg_test.out
	${RM} -f jparse.output jparse.html
	${RM} -f ${TXZCHK_LOG}
	${RM} -f dbg_test.c
	${RM} -rf test_ioccc/dyn_test.dSYM
	${RM} -f test_ioccc/jnum_chk
	${RM} -rf test_ioccc/jnum_chk.dSYM
	${RM} -f jnum_gen
	${RM} -rf jnum_gen.dSYM
	${RM} -rf soup/ref
	${RM} -f legacy_os
	${RM} -rf legacy_os.dSYM


###################################
# standard Makefile utility rules #
###################################

configure:
	@echo nothing to configure

# clean legacy code and files - files that are no longer needed
#
legacy_clean:
	${RM} -f jint.o test_ioccc/jint.test.o jint_gen.o
	${RM} -f jfloat.o test_ioccc/jfloat.test.o jfloat_gen.o
	${RM} -f jauthchk.o jinfochk.o

clean: clean_generated_obj legacy_clean
	${RM} -f ${OBJFILES}
	${RM} -f ${GENERATED_OBJ}
	${RM} -f ${LESS_PICKY_OBJ}
	${RM} -rf ${DSYMDIRS}

clobber: clean prep_clobber
	${RM} -f ${BUILD_LOG}
	${RM} -f test_ioccc/jparse_test.log test_ioccc/chkentry_test.log test_ioccc/txzchk_test.log
	${RM} -f ${HTML_MAN_TARGETS}
	${RM} -f .jsemcgen.out.*
	${RM} -f .all_ref.*
	${RM} -rf .hostchk.work.*
	${RM} -f .sorry.*
	${RM} -f .jsemcgen.*
	${RM} -f .txzchk_test,*
	${RM} -f test_ioccc/test_ioccc.log
	${MAKE} -C dbg clobber
	${MAKE} -C test_ioccc clobber
	${MAKE} -C soup clobber

distclean nuke: clobber

install: all
	# we have to first make sure the directories exist!
	${INSTALL} -v -d -m 0755 ${DESTDIR}
	${INSTALL} -v -d -m 0755 ${MAN1_DIR}
	${INSTALL} -v -d -m 0755 ${MAN3_DIR}
	${INSTALL} -v -d -m 0755 ${MAN8_DIR}
	${INSTALL} -v -m 0555 ${TARGETS} ${SH_TARGETS} ${DESTDIR}
	${INSTALL} -v -m 0644 ${MAN1PAGES} ${MAN1_DIR}
	${INSTALL} -v -m 0644 ${MAN3PAGES} ${MAN3_DIR}
	${INSTALL} -v -m 0644 ${MAN8PAGES} ${MAN8_DIR}

tags: ${ALL_CSRC} ${H_FILES}
	-${CTAGS} ${ALL_CSRC} ${H_FILES} 2>&1 | \
	     ${GREP} -E -v 'Duplicate entry|Second entry ignored'

depend: soup/fmt_depend.sh
	@echo
	@echo "make depend starting"
	@echo
	@${SED} -i.orig -n -e '1,/^### DO NOT CHANGE MANUALLY BEYOND THIS LINE/p' Makefile
	${CC} ${CFLAGS} -MM -Isoup -I. ${ALL_CSRC} | ./soup/fmt_depend.sh >> Makefile
	@-if ${CMP} -s Makefile.orig Makefile; then \
	    ${RM} -f Makefile.orig; \
	else \
	    echo; echo "Makefile dependencies updated"; echo; echo "Previous version may be found in: Makefile.orig"; \
	fi
	@echo
	@${MAKE} -C soup depend
	@echo "make depend completed"


########################################################################
# external repositories - rules to help incorporate other repositories #
########################################################################

# This repo is designed to be a standalone repo.  Even though we use other
# repositories, we prefer to NOT clone them.  We want this repo to depend
# on a specific version of such code so that a change in the code of those
# external repositories will NOT impact this repo.
#
# For that reason, and others, we maintain a private copy of an external
# repository as clone.repo.  The clone.repo directory is excluded from
# out repo via the .gitignore file.  We copy clone.repo/ into repo/ and
# check in those file directly into this repo.
#
# The following rules are used by the people who maintain this repo.
# If you are not someone who maintains this repo, the rules in this section
# are probably not for you.

.PHONY: dbg.clone dbg.diff dbg.fetch dbg.reclone dbg.reload dbg.rsync dbg.status \
        dyn_array/dyn_array.clone dyn_array.diff dyn_array.fetch dyn_array.reclone dyn_array.reload \
	dyn_array.rsync dyn_array.status jparse.clone jparse.diff jparse.fetch jparse.reclone \
	jparse.reload jparse.rsync jparse.status all.clone all.diff all.fetch all.reclone \
	all.reload all.rsync all.status

# dbg external repo
#
dbg.clone:
	${GIT} clone https://github.com/lcn2/dbg.git dbg.clone

dbg.diff: dbg.clone/ dbg/
	${DIFF} -u -r --exclude='.*' dbg.clone dbg

dbg.fetch: dbg.clone/
	cd dbg.clone && ${GIT} fetch
	cd dbg.clone && ${GIT} fetch --prune --tags
	cd dbg.clone && ${GIT} merge --ff-only || ${GIT} rebase --rebase-merges
	${GIT} status dbg.clone

dbg.reclone:
	${RM} -rf dbg.clone
	${MAKE} dbg.clone

dbg.reload: dbg.clone/
	${RM} -rf dbg
	${MAKE} dbg.rsync

dbg.rsync: dbg.clone/
	${RSYNC} -a -S -0 --delete -C --exclude='.*' -v dbg.clone/ dbg

dbg.status: dbg.clone/
	${GIT} status dbg.clone

# dyn_array external repo
#
dyn_array/dyn_array.clone:
	@echo 'rule disabled, enable once dyn_array repo exists'
	@#${GIT} clone https://github.com/lcn2/dyn_array.git dyn_array/dyn_array.clone

dyn_array.diff: dyn_array/dyn_array.clone/ dyn_array/
	@#${DIFF} -u -r --exclude='.*' dyn_array/dyn_array.clone dyn_array

dyn_array.fetch: dyn_array/dyn_array.clone/
	@#cd dyn_array/dyn_array.clone && ${GIT} fetch
	@#cd dyn_array/dyn_array.clone && ${GIT} fetch --prune --tags
	@#cd dyn_array/dyn_array.clone && ${GIT} merge --ff-only || ${GIT} rebase --rebase-merges
	@#${GIT} status dyn_array/dyn_array.clone

dyn_array.reclone:
	@echo 'rule disabled, enable once dyn_array repo exists'
	@#${RM} -rf dyn_array/dyn_array.clone
	@#${MAKE} dyn_array/dyn_array.clone

dyn_array.reload: dyn_array/dyn_array.clone/
	@#${RM} -rf dyn_array
	@#${MAKE} dyn_array.rsync

dyn_array.rsync: dyn_array/dyn_array.clone/
	@#${RSYNC} -a -S -0 --delete -C --exclude='.*' -v dyn_array/dyn_array.clone/ dyn_array

dyn_array.status: dyn_array/dyn_array.clone/
	@#${GIT} status dyn_array/dyn_array.clone

# jparse external repo
#
jparse.clone:
	@echo 'rule disabled, enable once jparse repo exists'
	@#${GIT} clone https://github.com/xexyl/jparse.git jparse.clone

jparse.diff: jparse.clone/ jparse/
	@#${DIFF} -u -r --exclude='.*' jparse.clone jparse

jparse.fetch: jparse.clone/
	@#cd jparse.clone && ${GIT} fetch
	@#cd jparse.clone && ${GIT} fetch --prune --tags
	@#cd jparse.clone && ${GIT} merge --ff-only || ${GIT} rebase --rebase-merges
	@#${GIT} status jparse.clone

jparse.reclone:
	@echo 'rule disabled, enable once jparse repo exists'
	@#${RM} -rf jparse.clone
	@#${MAKE} jparse.clone

jparse.reload: jparse.clone/
	@#${RM} -rf jparse
	@#${MAKE} jparse.rsync

jparse.rsync: jparse.clone/
	@#${RSYNC} -a -S -0 --delete -C --exclude='.*' -v jparse.clone/ jparse

jparse.status: jparse.clone/
	@#${GIT} status jparse.clone


# rules to operate on all external repositories
#
all.clone: dbg.clone dyn_array/dyn_array.clone jparse.clone

all.diff: dbg.diff dyn_array.diff jparse.diff

all.fetch: dbg.fetch dyn_array.fetch jparse.fetch

all.reclone: dbg.reclone dyn_array.reclone jparse.reclone

all.reload: dbg.reload dyn_array.reload jparse.reload

all.rsync: dbg.rsync dyn_array.rsync jparse.rsync

all.status: dbg.status dyn_array.status jparse.status


###############
# make depend #
###############

### DO NOT CHANGE MANUALLY BEYOND THIS LINE
utf8_posix_map.o: utf8_posix_map.c utf8_posix_map.h util.h dyn_array/dyn_array.h \
	dyn_array/../dbg/dbg.h dbg/dbg.h limit_ioccc.h version.h
foo.o: foo.c foo.h dbg/dbg.h oebxergfB.h
jparse.o: jparse.c jparse.h dbg/dbg.h util.h dyn_array/dyn_array.h dyn_array/../dbg/dbg.h \
	json_parse.h json_util.h jparse.tab.h
jparse.tab.o: jparse.tab.c jparse.h dbg/dbg.h util.h dyn_array/dyn_array.h dyn_array/../dbg/dbg.h \
	json_parse.h json_util.h jparse.tab.h jparse.lex.h
dbg.o: dbg/dbg.c dbg/dbg.h
util.o: util.c dbg/dbg.h util.h dyn_array/dyn_array.h dyn_array/../dbg/dbg.h limit_ioccc.h version.h
mkiocccentry.o: mkiocccentry.c mkiocccentry.h util.h dyn_array/dyn_array.h dyn_array/../dbg/dbg.h \
	dbg/dbg.h location.h utf8_posix_map.h limit_ioccc.h version.h sanity.h iocccsize.h json_util.h \
	json_parse.h entry_util.h json_sem.h
iocccsize.o: iocccsize.c iocccsize_err.h iocccsize.h
fnamchk.o: fnamchk.c fnamchk.h dbg/dbg.h util.h dyn_array/dyn_array.h dyn_array/../dbg/dbg.h \
	limit_ioccc.h version.h utf8_posix_map.h
txzchk.o: txzchk.c txzchk.h util.h dyn_array/dyn_array.h dyn_array/../dbg/dbg.h dbg/dbg.h sanity.h \
	location.h utf8_posix_map.h limit_ioccc.h version.h entry_util.h json_parse.h json_sem.h json_util.h
chkentry.o: chkentry.c chkentry.h dbg/dbg.h json_util.h dyn_array/dyn_array.h dyn_array/../dbg/dbg.h \
	json_parse.h util.h jparse.h jparse.tab.h json_sem.h soup/chk_sem_info.h soup/../json_sem.h \
	soup/chk_sem_auth.h foo.h sanity.h location.h utf8_posix_map.h limit_ioccc.h version.h
json_parse.o: json_parse.c dbg/dbg.h util.h dyn_array/dyn_array.h dyn_array/../dbg/dbg.h \
	json_parse.h json_util.h
jstrencode.o: jstrencode.c jstrencode.h dbg/dbg.h util.h dyn_array/dyn_array.h \
	dyn_array/../dbg/dbg.h json_parse.h limit_ioccc.h version.h
jstrdecode.o: jstrdecode.c jstrdecode.h dbg/dbg.h util.h dyn_array/dyn_array.h \
	dyn_array/../dbg/dbg.h json_parse.h limit_ioccc.h version.h
rule_count.o: rule_count.c iocccsize_err.h iocccsize.h
location.o: location.c location.h util.h dyn_array/dyn_array.h dyn_array/../dbg/dbg.h dbg/dbg.h
sanity.o: sanity.c sanity.h util.h dyn_array/dyn_array.h dyn_array/../dbg/dbg.h dbg/dbg.h location.h \
	utf8_posix_map.h limit_ioccc.h version.h
verge.o: verge.c verge.h dbg/dbg.h util.h dyn_array/dyn_array.h dyn_array/../dbg/dbg.h limit_ioccc.h \
	version.h
dyn_array.o: dyn_array/dyn_array.c dyn_array/dyn_array.h dyn_array/../dbg/dbg.h
dyn_test.o: test_ioccc/dyn_test.c test_ioccc/dyn_test.h test_ioccc/../util.h dyn_array/dyn_array.h \
	dyn_array/../dbg/dbg.h test_ioccc/../dbg/dbg.h test_ioccc/../dyn_array/dyn_array.h
dbg_test.o: dbg/dbg_test.c dbg/dbg.h
jnum_chk.o: test_ioccc/jnum_chk.c test_ioccc/jnum_chk.h test_ioccc/../dbg/dbg.h test_ioccc/../util.h \
	dyn_array/dyn_array.h dyn_array/../dbg/dbg.h json_parse.h util.h json_util.h test_ioccc/../version.h
jnum_gen.o: jnum_gen.c jnum_gen.h dbg/dbg.h util.h dyn_array/dyn_array.h dyn_array/../dbg/dbg.h \
	json_parse.h json_util.h limit_ioccc.h version.h
jnum_test.o: test_ioccc/jnum_test.c json_parse.h util.h dyn_array/dyn_array.h dyn_array/../dbg/dbg.h
json_util.o: json_util.c dbg/dbg.h json_parse.h util.h dyn_array/dyn_array.h dyn_array/../dbg/dbg.h \
	json_util.h
jparse_main.o: jparse_main.c jparse_main.h dbg/dbg.h util.h dyn_array/dyn_array.h \
	dyn_array/../dbg/dbg.h jparse.h json_parse.h json_util.h jparse.tab.h
entry_util.o: entry_util.c dbg/dbg.h util.h dyn_array/dyn_array.h dyn_array/../dbg/dbg.h version.h \
	limit_ioccc.h entry_util.h json_parse.h json_sem.h json_util.h entry_time.h location.h
jsemtblgen.o: jsemtblgen.c jsemtblgen.h dbg/dbg.h util.h dyn_array/dyn_array.h \
	dyn_array/../dbg/dbg.h json_util.h json_parse.h jparse.h jparse.tab.h json_sem.h iocccsize.h
chk_sem_auth.o: soup/chk_sem_auth.c soup/chk_sem_auth.h soup/../json_sem.h util.h \
	dyn_array/dyn_array.h dyn_array/../dbg/dbg.h json_parse.h json_util.h
chk_sem_info.o: soup/chk_sem_info.c soup/chk_sem_info.h soup/../json_sem.h util.h \
	dyn_array/dyn_array.h dyn_array/../dbg/dbg.h json_parse.h json_util.h
chk_validate.o: soup/chk_validate.c soup/chk_validate.h soup/../entry_util.h json_parse.h util.h \
	dyn_array/dyn_array.h dyn_array/../dbg/dbg.h json_sem.h json_util.h soup/../json_sem.h \
	soup/chk_sem_auth.h soup/chk_sem_info.h entry_time.h location.h dbg/dbg.h
json_sem.o: json_sem.c dbg/dbg.h json_sem.h util.h dyn_array/dyn_array.h dyn_array/../dbg/dbg.h \
	json_parse.h json_util.h
entry_time.o: entry_time.c dbg/dbg.h json_util.h dyn_array/dyn_array.h dyn_array/../dbg/dbg.h \
	json_parse.h util.h entry_time.h limit_ioccc.h version.h

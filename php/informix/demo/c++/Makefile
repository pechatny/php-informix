#############################################################################
#
#                                IBM INC.
#
#                            PROPRIETARY DATA
#
#  Licensed Material - Property Of IBM
#
#  "Restricted Materials of IBM"
#
#  IBM Informix Client SDK
#
#  (c)  Copyright IBM Corporation 1997, 2005. All rights reserved.
#
# ############################################################################
#

CPPIFDIR	= $(INFORMIXDIR)
CCHOME		= /usr

CCPP		= $(CCHOME)/bin/g++
CCPLUS		= $(CCPP) $(HEADEROPTS)
CCPPFLAGS 	= -I$(INFORMIXDIR)/incl/dmi -I$(INFORMIXDIR)/incl \
	-I$(INFORMIXDIR)/incl/esql
CCPLINK		= $(CCPLUS) $(CCFLAGS) $(CCPPFLAGS)
CC		= $(CCHOME)/bin/gcc
C-COMPILE-FLAGS	= $(CCFLAGS)
CCDEFS		= -DLINUX -DIT_HAS_DISTINCT_LONG_DOUBLE \
	-DIT_COMPILER_HAS_LONG_LONG -DIT_DLLIB -DMITRACE_OFF -fPIC
CCFLAGS		= -g $(CCDEFS) -fsigned-char

ESQL		= $(INFORMIXDIR)/bin/esql

RANLIB		= echo

LOCALINCL	= -I$(CPPIFDIR)/incl/c++

LIBS_SYSTEM	= -lm -ldl -lcrypt -lnsl
LIBS_ESQL	= -L$(INFORMIXDIR)/lib/esql -L$(INFORMIXDIR)/lib -lifsql \
 -lifasf -lifgen -lifos -lifgls -lifglx $(INFORMIXDIR)/lib/esql/checkapi.o
LIBS_LIBMI	= -L$(INFORMIXDIR)/lib/dmi -lifdmi 
LIBS_CPPIF	= -L$(CPPIFDIR)/lib/c++ -lifc++
LIBS		= $(LIBS_CPPIF) $(LIBS_LIBMI) $(LIBS_ESQL) $(LIBS_SYSTEM) 

PROGRAMS	= blobload cnvex contain contain2 csql csql2 csql3 \
	curstst cursupd deldrv dtex fsexamp1 loadtab loex1 loex2 queryex \
	rawval routine rowset sysname tabcnt

.SUFFIXES: .cc .o .hdr .cpp

.cc.o:
	@rm -f $@
	$(CCPLUS) $(CCFLAGS) $(LOCALINCL) $(CCPPFLAGS) -c $<

.cpp.o:
	@rm -f $@
	$(CCPLUS) $(CCFLAGS) $(LOCALINCL) $(CCPPFLAGS) -c $<

all: 	testtype.so $(PROGRAMS)

setup: all
	csql2 <cleanup.sql
	csql2 <setup.sql
	blobload -u -f sample.txt -d ${USER} -t regresstab -b byte_val -k boolean_val t

blobload: blobload.ec
	$(ESQL) blobload.ec -o blobload 

cnvex: cnvex.o
	$(CCPLINK) -o cnvex cnvex.o $(SUBSYSTEMS.link) $(LIBS)

contain: contain.o ifval.o
	$(CCPLINK) -o contain contain.o ifval.o $(SUBSYSTEMS.link) $(LIBS)

contain2: contain.o rowref.o
	$(CCPLINK) -o contain2 contain.o rowref.o $(SUBSYSTEMS.link) $(LIBS)

csql: csql.o simpval.o
	$(CCPLINK) -o csql csql.o simpval.o $(SUBSYSTEMS.link) $(LIBS)

csql2: csql2.o
	$(CCPLINK) -o csql2 csql2.o $(SUBSYSTEMS.link) $(LIBS)

csql3: csql3.o
	$(CCPLINK) -o csql3 csql3.o $(SUBSYSTEMS.link) $(LIBS)

curstst: curstst.o
	$(CCPLINK) -o curstst curstst.o $(SUBSYSTEMS.link) $(LIBS)

cursupd: cursupd.o
	$(CCPLINK) -o cursupd cursupd.o $(SUBSYSTEMS.link) $(LIBS)

deldrv: deldrv.o delegate.o
	$(CCPLINK) -o deldrv deldrv.o delegate.o $(SUBSYSTEMS.link) $(LIBS)

dtex: dtex.o
	$(CCPLINK) -o dtex dtex.o $(SUBSYSTEMS.link) $(LIBS)

fsexamp1: fsexamp1.o
	$(CCPLINK) -o fsexamp1 fsexamp1.o $(SUBSYSTEMS.link) $(LIBS)

loadtab: loadtab.o
	$(CCPLINK) -o loadtab loadtab.o $(SUBSYSTEMS.link) $(LIBS)

loex1: loex1.o
	$(CCPLINK) -o loex1 loex1.o $(SUBSYSTEMS.link) $(LIBS)

loex2: loex2.o
	$(CCPLINK) -o loex2 loex2.o $(SUBSYSTEMS.link) $(LIBS)

queryex: queryex.o
	$(CCPLINK) -o queryex queryex.o $(SUBSYSTEMS.link) $(LIBS)

rawval: rawval.o
	$(CCPLINK) -o rawval rawval.o $(SUBSYSTEMS.link) $(LIBS)

routine: routine.o
	$(CCPLINK) -o routine routine.o $(SUBSYSTEMS.link) $(LIBS)

rowset: rowset.o
	$(CCPLINK) -o rowset rowset.o $(SUBSYSTEMS.link) $(LIBS)

sysname: sysname.o
	$(CCPLINK) -o sysname sysname.o $(SUBSYSTEMS.link) $(LIBS)

tabcnt: tabcnt.o
	$(CCPLINK) -o tabcnt tabcnt.o $(SUBSYSTEMS.link) $(LIBS)

testtype.so: testtype.o
	$(CCPP) -shared -o testtype.so testtype.o

clean:
	$(RM) *.o $(PROGRAMS) core testtype.so blobload.c

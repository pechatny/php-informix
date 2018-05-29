############################################################################
#	Licensed Materials - Property of IBM
#
#
#	"Restricted Materials of IBM"
#
#
#
#	IBM Informix Client SDK
#
#
#	(C) Copyright IBM Corporation 1997, 2010 All rights reserved.
#
#
#
#
#**************************************************************************
#
#
#       Title:          makefile
#       Description:    Makefile for the ODBC demos
#
#**************************************************************************

SHELL = /bin/sh

CC        = gcc
RM        = rm -f

# CFLAGS, SYSLIBES and INFMX_LIBS should be changed based on
# the platform.
# for solaris these are: 
CFLAGS    = -fsigned-char -DNO_WIN32 -O
SYSLIBES  = -lifcli -lifdmr -L$(INFORMIXDIR)/lib/esql -lifgls -lifglx -lm -lnsl
ODBCLIB   = -L$(INFORMIXDIR)/lib/cli -L$(INFORMIXDIR)/lib/esql
INCL      = -I$(INFORMIXDIR)/incl/cli -I$(INFORMIXDIR)/incl/esql -I$(INFORMIXDIR)/incl/dmi
ODBCLIBDIR    =   -L$(INFORMIXDIR)/lib/cli
ODBCLIBS      =   -lifcli -lifdmr
ODBCTHLIBS    =   -lthcli -lifdmr -lixcli
GLSLIB        =   -L$(INFORMIXDIR)/lib/esql -lifgls -lifglx
SOLIBSUFFIX   =  so

UNIXLIB= \
	${INFORMIXDIR}/lib/esql/isqls09b.$(SOLIBSUFFIX)

# Targets
BLKINSRT = blkinsrt
CATALOG  = catalog
DBCREATE = dbcreate
DBDROP   = dbdrop
DESC     = desc
DISTSEL  = distsel
LOCREATE = locreate
LOINFO   = loinfo
LOSELECT = loselect
POSUPDT  = posupdt
PROC     = proc
RCCREATE = rccreate
RCSELECT = rcselect
RCUPDATE = rcupdate
RSETINFO = rsetinfo
TRANSACT = transact
OUTINOUTPARAMBLOB = OutInOutParamBlob
BLKINSRTw = blkinsrtW
CATALOGw  = catalogW
DBCREATEw = dbcreateW
DBDROPw   = dbdropW
DESCw     = descW
DISTSELw  = distselW
LOCREATEw = locreateW
LOINFOw   = loinfoW
LOSELECTw = loselectW
POSUPDTw  = posupdtW
PROCw     = procW
RCCREATEw = rccreateW
RCSELECTw = rcselectW
RCUPDATEw = rcupdateW
RSETINFOw = rsetinfoW
TRANSACTw = transactW
OUTINOUTPARAMBLOBw = OutInOutParamBlobW

DEMOS     = $(BLKINSRT) $(CATALOG) $(DBCREATE) $(DBDROP) $(DESC) \
            $(DISTSEL) $(LOCREATE) $(LOINFO) $(LOSELECT) $(POSUPDT) \
            $(PROC) $(RCCREATE) $(RCSELECT) $(RCUPDATE) $(RSETINFO) \
            $(TRANSACT) $(OUTINOUTPARAMBLOB)

UNICODE   = $(BLKINSRTw) $(CATALOGw) $(DBCREATEw) $(DBDROPw) \
            $(DESCw) $(DISTSELw) $(LOCREATEw) $(LOINFOw) $(LOSELECTw) \
            $(POSUPDTw) $(PROCw) $(RCCREATEw) $(RCSELECTw) $(RCUPDATEw) \
            $(RSETINFOw) $(TRANSACTw) $(OUTINOUTPARAMBLOBw)


all: $(DEMOS)

UnicodeDemo: $(UNICODE)

unixxa: unixOnePhaseCommitRollback.exe


# Rules
unixOnePhaseCommitRollback.exe: OnePhaseCommitRollback.o
	$(CC) $(LDFLAGS) OnePhaseCommitRollback.o $(ODBCLIBDIR) $(UNIXLIB) \
	$(GLSLIB) $(SYSLIBES) $(ODBCLIBS) -o OnePhaseCommitRollback.exe

OnePhaseCommitRollback.o: OnePhaseCommitRollback.c
	$(CC) $(CFLAGS) -c $(INCL) OnePhaseCommitRollback.c


.c.o:
	$(RM) $*.o; \
	$(CC) -c $(CFLAGS) $(INCL) $*.c

# Dependencies
$(BLKINSRT): $(BLKINSRT).o
	$(CC) -o $(BLKINSRT) $(BLKINSRT).o $(ODBCLIB) $(SYSLIBES)

$(CATALOG): $(CATALOG).o
	$(CC) -o $(CATALOG) $(CATALOG).o $(ODBCLIB) $(SYSLIBES)

$(DBCREATE): $(DBCREATE).o
	$(CC) -o $(DBCREATE) $(DBCREATE).o $(ODBCLIB) $(SYSLIBES)

$(DBDROP): $(DBDROP).o
	$(CC) -o $(DBDROP) $(DBDROP).o $(ODBCLIB) $(SYSLIBES)

$(DESC): $(DESC).o
	$(CC) -o $(DESC) $(DESC).o $(ODBCLIB) $(SYSLIBES)

$(DISTSEL): $(DISTSEL).o
	$(CC) -o $(DISTSEL) $(DISTSEL).o $(ODBCLIB) $(SYSLIBES)

$(LOCREATE): $(LOCREATE).o
	$(CC) -o $(LOCREATE) $(LOCREATE).o $(ODBCLIB) $(SYSLIBES)

$(LOINFO): $(LOINFO).o
	$(CC) -o $(LOINFO) $(LOINFO).o $(ODBCLIB) $(SYSLIBES)

$(LOSELECT): $(LOSELECT).o
	$(CC) -o $(LOSELECT) $(LOSELECT).o $(ODBCLIB) $(SYSLIBES)

$(POSUPDT): $(POSUPDT).o
	$(CC) -o $(POSUPDT) $(POSUPDT).o $(ODBCLIB) $(SYSLIBES)

$(PROC): $(PROC).o
	$(CC) -o $(PROC) $(PROC).o $(ODBCLIB) $(SYSLIBES)

$(RCCREATE): $(RCCREATE).o
	$(CC) -o $(RCCREATE) $(RCCREATE).o $(ODBCLIB) $(SYSLIBES)

$(RCSELECT): $(RCSELECT).o
	$(CC) -o $(RCSELECT) $(RCSELECT).o $(ODBCLIB) $(SYSLIBES)

$(RCUPDATE): $(RCUPDATE).o
	$(CC) -o $(RCUPDATE) $(RCUPDATE).o $(ODBCLIB) $(SYSLIBES)

$(RSETINFO): $(RSETINFO).o
	$(CC) -o $(RSETINFO) $(RSETINFO).o $(ODBCLIB) $(SYSLIBES)

$(TRANSACT): $(TRANSACT).o
	$(CC) -o $(TRANSACT) $(TRANSACT).o $(ODBCLIB) $(SYSLIBES)

$(OUTINOUTPARAMBLOB): $(OUTINOUTPARAMBLOB).o
	$(CC) -o $(OUTINOUTPARAMBLOB) $(OUTINOUTPARAMBLOB).o $(ODBCLIB) $(SYSLIBES)

$(BLKINSRTw): $(BLKINSRTw).o
	$(CC) -o $(BLKINSRTw) $(BLKINSRTw).o $(ODBCLIB) $(SYSLIBES)

$(CATALOGw): $(CATALOGw).o
	$(CC) -o $(CATALOGw) $(CATALOGw).o $(ODBCLIB) $(SYSLIBES)

$(DBCREATEw): $(DBCREATEw).o
	$(CC) -o $(DBCREATEw) $(DBCREATEw).o $(ODBCLIB) $(SYSLIBES)

$(DBDROPw): $(DBDROPw).o
	$(CC) -o $(DBDROPw) $(DBDROPw).o $(ODBCLIB) $(SYSLIBES)

$(DESCw): $(DESCw).o
	$(CC) -o $(DESCw) $(DESCw).o $(ODBCLIB) $(SYSLIBES)

$(DISTSELw): $(DISTSELw).o
	$(CC) -o $(DISTSELw) $(DISTSELw).o $(ODBCLIB) $(SYSLIBES)

$(LOCREATEw): $(LOCREATEw).o
	$(CC) -o $(LOCREATEw) $(LOCREATEw).o $(ODBCLIB) $(SYSLIBES)

$(LOINFOw): $(LOINFOw).o
	$(CC) -o $(LOINFOw) $(LOINFOw).o $(ODBCLIB) $(SYSLIBES)

$(LOSELECTw): $(LOSELECTw).o
	$(CC) -o $(LOSELECTw) $(LOSELECTw).o $(ODBCLIB) $(SYSLIBES)

$(POSUPDTw): $(POSUPDTw).o
	$(CC) -o $(POSUPDTw) $(POSUPDTw).o $(ODBCLIB) $(SYSLIBES)

$(PROCw): $(PROCw).o
	$(CC) -o $(PROCw) $(PROCw).o $(ODBCLIB) $(SYSLIBES)

$(RCCREATEw): $(RCCREATEw).o
	$(CC) -o $(RCCREATEw) $(RCCREATEw).o $(ODBCLIB) $(SYSLIBES)

$(RCSELECTw): $(RCSELECTw).o
	$(CC) -o $(RCSELECTw) $(RCSELECTw).o $(ODBCLIB) $(SYSLIBES)

$(RCUPDATEw): $(RCUPDATEw).o
	$(CC) -o $(RCUPDATEw) $(RCUPDATEw).o $(ODBCLIB) $(SYSLIBES)

$(RSETINFOw): $(RSETINFOw).o
	$(CC) -o $(RSETINFOw) $(RSETINFOw).o $(ODBCLIB) $(SYSLIBES)

$(TRANSACTw): $(TRANSACTw).o
	$(CC) -o $(TRANSACTw) $(TRANSACTw).o $(ODBCLIB) $(SYSLIBES)

$(OUTINOUTPARAMBLOBw): $(OUTINOUTPARAMBLOBw).o
	$(CC) -o $(OUTINOUTPARAMBLOBw) $(OUTINOUTPARAMBLOBw).o $(ODBCLIB) $(SYSLIBES)

clean:
	$(RM) $(DEMOS) $(UNICODE)
	$(RM) $(BLKINSRT).o $(CATALOG).o $(DBCREATE).o \
	$(DBDROP).o $(DESC).o $(DISTSEL).o $(LOCREATE).o $(LOINFO).o \
	$(LOSELECT).o $(POSUPDT).o $(PROC).o $(RCCREATE).o $(RCSELECT).o \
	$(RCUPDATE).o $(RSETINFO).o $(TRANSACT).o $(OUTINOUTPARAMBLOB).o
	$(RM) $(BLKINSRTw).o $(CATALOGw).o $(DBCREATEw).o $(DBDROPw).o $(DESCw).o \
	$(DISTSELw).o $(LOCREATEw).o $(LOINFOw).o 
	$(RM) $(LOSELECTw).o $(POSUPDTw).o $(PROCw).o $(RCCREATEw).o $(RCSELECTw).o \
	$(RCUPDATEw).o $(RSETINFOw).o $(TRANSACTw).o $(OUTINOUTPARAMBLOBw).o
	$(RM) OnePhaseCommitRollback.exe OnePhaseCommitRollback.o


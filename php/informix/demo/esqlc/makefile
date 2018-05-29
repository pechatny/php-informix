#############################################################################
#  Licensed Material - Property Of IBM
# 
#  "Restricted Materials of IBM"
# 
#  IBM Informix Client SDK
# 
#  (c)  Copyright IBM Corporation 1997, 2013. All rights reserved.
# 
# ############################################################################
# 

ECHO=echo

INCL=-I$(INFORMIXDIR)/incl -I$(INFORMIXDIR)/incl/esql

ESQL = $(INFORMIXDIR)/bin/esql

RM = rm -f

# targets
BLOBLOAD = blobload
BYCMPR = bycmpr
BYCOPY = bycopy
BYFILL = byfill
BYLENG = byleng
COLLECT = collect
DECADD = decadd
DECCMP = deccmp
DECCOPY = deccopy
DECCVASC = deccvasc
DECCVDBL = deccvdbl
DECCVINT = deccvint
DECCVLONG = deccvlong
DECDIV = decdiv
DECECVT = dececvt
DECFCVT = decfcvt
DECMUL = decmul
DECROUND = decround
DECSUB = decsub
DECTOASC = dectoasc
DECTODBL = dectodbl
DECTOINT = dectoint
DECTOLONG = dectolong
DECTRUNC = dectrunc
DEMO1 = demo1
DEMO2 = demo2
DEMO3 = demo3
DEMO4 = demo4
DISPCAT_PIC = dispcat_pic
DTADDINV = dtaddinv
DTCURRENT = dtcurrent
DTCVASC = dtcvasc
DTCVFMTASC = dtcvfmtasc
DTEXTEND = dtextend
DTSUB = dtsub
DTSUBINV = dtsubinv
DTTOASC = dttoasc
DTTOFMTASC = dttofmtasc
DYN_SQL = dyn_sql
GETCD_ME = getcd_me
GETCD_NF = getcd_nf
GETCD_OF = getcd_of
GETDIAG = getdiag
INCVASC = incvasc
INCVFMTASC = incvfmtasc
INT8ADD = int8add
INT8CVASC = int8cvasc
INT8CVDEC = int8cvdec
INT8DIV = int8div
INT8SUB = int8sub
INT8TOASC = int8toasc
INT8TODEC = int8todec
INTOASC = intoasc
INTOFMTASC = intofmtasc
INVDIVDBL = invdivdbl
INVDIVINV = invdivinv
INVEXTEND = invextend
INVMULDBL = invmuldbl
LDCHAR = ldchar
LVARPTR = lvarptr
PAMDEMO = pamdemo
RDAYOFWEEK = rdayofweek
RDEFMTDATE = rdefmtdate
RDOWNSHIFT = rdownshift
RFMTDATE = rfmtdate
RFMTDEC = rfmtdec
RFMTDOUBLE = rfmtdouble
RFMTLONG = rfmtlong
RGETLMSG = rgetlmsg
RGETMSG = rgetmsg
RISNULL = risnull
RJULMDY = rjulmdy
RLEAPYEAR = rleapyear
RMDYJUL = rmdyjul
RSETNULL = rsetnull
RSTOD = rstod
RSTOI = rstoi
RSTOL = rstol
RSTRDATE = rstrdate
RTODAY = rtoday
RTYPALIGN = rtypalign
RTYPMSIZE = rtypmsize
RTYPNAME = rtypname
RTYPWIDTH = rtypwidth
RUPSHIFT = rupshift
SQGETDBS = sqgetdbs
SQDETACHDEMO = sqldetachdemo 
STCAT = stcat
STCHAR = stchar
STCMPR = stcmpr
STCOPY = stcopy
STLENG = stleng
TIMEOUT = timeout
UNLOAD = unload
UPDCD_ME = updcd_me
UPDCD_NF = updcd_nf
UPDCD_OF = updcd_of
VARCHAR = varchar
CREATE_CLOB = create_clob
GET_LO_INFO = get_lo_info
UPD_LO_DESCR = upd_lo_descr

TARGET    = $(BLOBLOAD) $(BYCMPR) $(BYCOPY) $(BYFILL) $(BYLENG) \
	$(COLLECT) $(DECADD) $(DECCMP) $(DECCOPY) $(DECCVASC) \
	$(DECCVDBL) $(DECCVINT) $(DECCVLONG) $(DECDIV) $(DECECVT) \
	$(DECFCVT) $(DECMUL) $(DECROUND) $(DECSUB) $(DECTOASC) \
	$(DECTODBL) $(DECTOINT) $(DECTOLONG) $(DECTRUNC) $(DEMO1) \
	$(DEMO2) $(DEMO3) $(DEMO4) $(DISPCAT_PIC) $(DTADDINV) \
	$(DTCURRENT) $(DTCVASC) $(DTCVFMTASC) $(DTEXTEND) $(DTSUB) \
	$(DTSUBINV) $(DTTOASC) $(DTTOFMTASC) $(DYN_SQL) $(GETCD_ME) \
	$(GETCD_NF) $(GETCD_OF) $(GETDIAG) $(INCVASC) $(INCVFMTASC) \
	$(INT8ADD) $(INT8CVASC) $(INT8CVDEC) $(INT8DIV) $(INT8SUB) \
	$(INT8TOASC) $(INT8TODEC) $(INTOASC) $(INTOFMTASC) $(INVDIVDBL) \
	$(INVDIVINV) $(INVEXTEND) $(INVMULDBL) $(LDCHAR) $(LVARPTR) $(PAMDEMO) \
	$(RDAYOFWEEK) $(RDEFMTDATE) $(RDOWNSHIFT) $(RFMTDATE) $(RFMTDEC) \
	$(RFMTDOUBLE) $(RFMTLONG) $(RGETLMSG) $(RGETMSG) $(RISNULL) \
	$(RJULMDY) $(RLEAPYEAR) $(RMDYJUL) $(RSETNULL) $(RSTOD) \
	$(RSTOI) $(RSTOL) $(RSTRDATE) $(RTODAY) $(RTYPALIGN) \
	$(RTYPMSIZE) $(RTYPNAME) $(RTYPWIDTH) $(RUPSHIFT) $(SQLDETACHDEMO) \
  $(SQGETDBS) $(STCAT) $(STCHAR) $(STCMPR) $(STCOPY) $(STLENG) \
	$(TIMEOUT) $(UNLOAD) $(UPDCD_ME) $(UPDCD_NF) $(UPDCD_OF) \
	$(VARCHAR) $(CREATE_CLOB) $(UPD_LO_DESCR) $(GET_LO_INFO)

all: $(TARGET)
	$(ECHO) "All Demos Compiled Successfully"

$(BLOBLOAD): $(BLOBLOAD).ec
	$(ESQL) -o $(BLOBLOAD) $(INCL) $(BLOBLOAD).ec

$(BYCMPR): $(BYCMPR).ec
	$(ESQL) -o $(BYCMPR) $(INCL) $(BYCMPR).ec

$(BYCOPY): $(BYCOPY).ec
	$(ESQL) -o $(BYCOPY) $(INCL) $(BYCOPY).ec

$(BYFILL): $(BYFILL).ec
	$(ESQL) -o $(BYFILL) $(INCL) $(BYFILL).ec

$(BYLENG): $(BYLENG).ec
	$(ESQL) -o $(BYLENG) $(INCL) $(BYLENG).ec

$(CREATE_CLOB): $(CREATE_CLOB).ec
	$(ESQL) -o $(CREATE_CLOB) $(INCL) $(CREATE_CLOB).ec

$(COLLECT): $(COLLECT).ec
	$(ESQL) -o $(COLLECT) $(INCL) $(COLLECT).ec

$(DECADD): $(DECADD).ec
	$(ESQL) -o $(DECADD) $(INCL) $(DECADD).ec

$(DECCMP): $(DECCMP).ec
	$(ESQL) -o $(DECCMP) $(INCL) $(DECCMP).ec

$(DECCOPY): $(DECCOPY).ec
	$(ESQL) -o $(DECCOPY) $(INCL) $(DECCOPY).ec

$(DECCVASC): $(DECCVASC).ec
	$(ESQL) -o $(DECCVASC) $(INCL) $(DECCVASC).ec

$(DECCVDBL): $(DECCVDBL).ec
	$(ESQL) -o $(DECCVDBL) $(INCL) $(DECCVDBL).ec

$(DECCVINT): $(DECCVINT).ec
	$(ESQL) -o $(DECCVINT) $(INCL) $(DECCVINT).ec

$(DECCVLONG): $(DECCVLONG).ec
	$(ESQL) -o $(DECCVLONG) $(INCL) $(DECCVLONG).ec

$(DECDIV): $(DECDIV).ec
	$(ESQL) -o $(DECDIV) $(INCL) $(DECDIV).ec

$(DECECVT): $(DECECVT).ec
	$(ESQL) -o $(DECECVT) $(INCL) $(DECECVT).ec

$(DECFCVT): $(DECFCVT).ec
	$(ESQL) -o $(DECFCVT) $(INCL) $(DECFCVT).ec

$(DECMUL): $(DECMUL).ec
	$(ESQL) -o $(DECMUL) $(INCL) $(DECMUL).ec

$(DECROUND): $(DECROUND).ec
	$(ESQL) -o $(DECROUND) $(INCL) $(DECROUND).ec

$(DECSUB): $(DECSUB).ec
	$(ESQL) -o $(DECSUB) $(INCL) $(DECSUB).ec

$(DECTOASC): $(DECTOASC).ec
	$(ESQL) -o $(DECTOASC) $(INCL) $(DECTOASC).ec

$(DECTODBL): $(DECTODBL).ec
	$(ESQL) -o $(DECTODBL) $(INCL) $(DECTODBL).ec

$(DECTOINT): $(DECTOINT).ec
	$(ESQL) -o $(DECTOINT) $(INCL) $(DECTOINT).ec

$(DECTOLONG): $(DECTOLONG).ec
	$(ESQL) -o $(DECTOLONG) $(INCL) $(DECTOLONG).ec

$(DECTRUNC): $(DECTRUNC).ec
	$(ESQL) -o $(DECTRUNC) $(INCL) $(DECTRUNC).ec

$(DEMO1): $(DEMO1).ec
	$(ESQL) -o $(DEMO1) $(INCL) $(DEMO1).ec

$(DEMO2): $(DEMO2).ec
	$(ESQL) -o $(DEMO2) $(INCL) $(DEMO2).ec

$(DEMO3): $(DEMO3).ec
	$(ESQL) -o $(DEMO3) $(INCL) $(DEMO3).ec

$(DEMO4): $(DEMO4).ec
	$(ESQL) -o $(DEMO4) $(INCL) $(DEMO4).ec

$(DISPCAT_PIC): $(DISPCAT_PIC).ec
	$(ESQL) -o $(DISPCAT_PIC) $(INCL) $(DISPCAT_PIC).ec

$(DTADDINV): $(DTADDINV).ec
	$(ESQL) -o $(DTADDINV) $(INCL) $(DTADDINV).ec

$(DTCURRENT): $(DTCURRENT).ec
	$(ESQL) -o $(DTCURRENT) $(INCL) $(DTCURRENT).ec

$(DTCVASC): $(DTCVASC).ec
	$(ESQL) -o $(DTCVASC) $(INCL) $(DTCVASC).ec

$(DTCVFMTASC): $(DTCVFMTASC).ec
	$(ESQL) -o $(DTCVFMTASC) $(INCL) $(DTCVFMTASC).ec

$(DTEXTEND): $(DTEXTEND).ec
	$(ESQL) -o $(DTEXTEND) $(INCL) $(DTEXTEND).ec

$(DTSUB): $(DTSUB).ec
	$(ESQL) -o $(DTSUB) $(INCL) $(DTSUB).ec

$(DTSUBINV): $(DTSUBINV).ec
	$(ESQL) -o $(DTSUBINV) $(INCL) $(DTSUBINV).ec

$(DTTOASC): $(DTTOASC).ec
	$(ESQL) -o $(DTTOASC) $(INCL) $(DTTOASC).ec

$(DTTOFMTASC): $(DTTOFMTASC).ec
	$(ESQL) -o $(DTTOFMTASC) $(INCL) $(DTTOFMTASC).ec

$(DYN_SQL): $(DYN_SQL).ec
	$(ESQL) -o $(DYN_SQL) $(INCL) $(DYN_SQL).ec

$(GETCD_ME): $(GETCD_ME).ec
	$(ESQL) -o $(GETCD_ME) $(INCL) $(GETCD_ME).ec

$(GETCD_NF): $(GETCD_NF).ec
	$(ESQL) -o $(GETCD_NF) $(INCL) $(GETCD_NF).ec

$(GETCD_OF): $(GETCD_OF).ec
	$(ESQL) -o $(GETCD_OF) $(INCL) $(GETCD_OF).ec

$(GETDIAG): $(GETDIAG).ec
	$(ESQL) -o $(GETDIAG) $(INCL) $(GETDIAG).ec

$(GET_LO_INFO): $(GET_LO_INFO).ec
	$(ESQL) -o $(GET_LO_INFO) $(INCL) $(GET_LO_INFO).ec

$(INCVASC): $(INCVASC).ec
	$(ESQL) -o $(INCVASC) $(INCL) $(INCVASC).ec

$(INCVFMTASC): $(INCVFMTASC).ec
	$(ESQL) -o $(INCVFMTASC) $(INCL) $(INCVFMTASC).ec

$(INT8ADD): $(INT8ADD).ec
	$(ESQL) -o $(INT8ADD) $(INCL) $(INT8ADD).ec

$(INT8CVASC): $(INT8CVASC).ec
	$(ESQL) -o $(INT8CVASC) $(INCL) $(INT8CVASC).ec

$(INT8CVDEC): $(INT8CVDEC).ec
	$(ESQL) -o  $(INT8CVDEC) $(INCL) $(INT8CVDEC).ec

$(INT8DIV): $(INT8DIV).ec
	$(ESQL) -o $(INT8DIV) $(INCL) $(INT8DIV).ec

$(INT8SUB): $(INT8SUB).ec
	$(ESQL) -o $(INT8SUB) $(INCL) $(INT8SUB).ec

$(INT8TOASC): $(INT8TOASC).ec
	$(ESQL) -o $(INT8TOASC) $(INCL) $(INT8TOASC).ec

$(INT8TODEC): $(INT8TODEC).ec
	$(ESQL) -o $(INT8TODEC) $(INCL) $(INT8TODEC).ec

$(INTOASC): $(INTOASC).ec
	$(ESQL) -o $(INTOASC) $(INCL) $(INTOASC).ec

$(INTOFMTASC): $(INTOFMTASC).ec
	$(ESQL) -o $(INTOFMTASC) $(INCL) $(INTOFMTASC).ec

$(INVDIVDBL): $(INVDIVDBL).ec
	$(ESQL) -o $(INVDIVDBL) $(INCL) $(INVDIVDBL).ec

$(INVDIVINV): $(INVDIVINV).ec
	$(ESQL) -o $(INVDIVINV) $(INCL) $(INVDIVINV).ec

$(INVEXTEND): $(INVEXTEND).ec
	$(ESQL) -o $(INVEXTEND) $(INCL) $(INVEXTEND).ec

$(INVMULDBL): $(INVMULDBL).ec
	$(ESQL) -o $(INVMULDBL) $(INCL) $(INVMULDBL).ec

$(LDCHAR): $(LDCHAR).ec
	$(ESQL) -o $(LDCHAR) $(INCL) $(LDCHAR).ec

$(LVARPTR): $(LVARPTR).ec
	$(ESQL) -o $(LVARPTR) $(INCL) $(LVARPTR).ec

$(PAMDEMO): $(PAMDEMO).ec
	$(ESQL) -o $(PAMDEMO) $(INCL) $(PAMDEMO).ec

$(RDAYOFWEEK): $(RDAYOFWEEK).ec
	$(ESQL) -o $(RDAYOFWEEK) $(INCL) $(RDAYOFWEEK).ec

$(RDEFMTDATE): $(RDEFMTDATE).ec
	$(ESQL) -o $(RDEFMTDATE) $(INCL) $(RDEFMTDATE).ec

$(RDOWNSHIFT): $(RDOWNSHIFT).ec
	$(ESQL) -o $(RDOWNSHIFT) $(INCL) $(RDOWNSHIFT).ec

$(RFMTDATE): $(RFMTDATE).ec
	$(ESQL) -o $(RFMTDATE) $(INCL) $(RFMTDATE).ec

$(RFMTDEC): $(RFMTDEC).ec
	$(ESQL) -o $(RFMTDEC) $(INCL) $(RFMTDEC).ec

$(RFMTDOUBLE): $(RFMTDOUBLE).ec
	$(ESQL) -o $(RFMTDOUBLE) $(INCL) $(RFMTDOUBLE).ec

$(RFMTLONG): $(RFMTLONG).ec
	$(ESQL) -o $(RFMTLONG) $(INCL) $(RFMTLONG).ec

$(RGETLMSG): $(RGETLMSG).ec
	$(ESQL) -o $(RGETLMSG) $(INCL) $(RGETLMSG).ec

$(RGETMSG): $(RGETMSG).ec
	$(ESQL) -o $(RGETMSG) $(INCL) $(RGETMSG).ec

$(RISNULL): $(RISNULL).ec
	$(ESQL) -o $(RISNULL) $(INCL) $(RISNULL).ec

$(RJULMDY): $(RJULMDY).ec
	$(ESQL) -o $(RJULMDY) $(INCL) $(RJULMDY).ec

$(RLEAPYEAR): $(RLEAPYEAR).ec
	$(ESQL) -o $(RLEAPYEAR) $(INCL) $(RLEAPYEAR).ec

$(RMDYJUL): $(RMDYJUL).ec
	$(ESQL) -o $(RMDYJUL) $(INCL) $(RMDYJUL).ec

$(RSETNULL): $(RSETNULL).ec
	$(ESQL) -o $(RSETNULL) $(INCL) $(RSETNULL).ec

$(RSTOD): $(RSTOD).ec
	$(ESQL) -o $(RSTOD) $(INCL) $(RSTOD).ec

$(RSTOI): $(RSTOI).ec
	$(ESQL) -o $(RSTOI) $(INCL) $(RSTOI).ec

$(RSTOL): $(RSTOL).ec
	$(ESQL) -o $(RSTOL) $(INCL) $(RSTOL).ec

$(RSTRDATE): $(RSTRDATE).ec
	$(ESQL) -o $(RSTRDATE) $(INCL) $(RSTRDATE).ec

$(RTODAY): $(RTODAY).ec
	$(ESQL) -o $(RTODAY) $(INCL) $(RTODAY).ec

$(RTYPALIGN): $(RTYPALIGN).ec
	$(ESQL) -o $(RTYPALIGN) $(INCL) $(RTYPALIGN).ec

$(RTYPMSIZE): $(RTYPMSIZE).ec
	$(ESQL) -o $(RTYPMSIZE) $(INCL) $(RTYPMSIZE).ec

$(RTYPNAME): $(RTYPNAME).ec
	$(ESQL) -o $(RTYPNAME) $(INCL) $(RTYPNAME).ec

$(RTYPWIDTH): $(RTYPWIDTH).ec
	$(ESQL) -o $(RTYPWIDTH) $(INCL) $(RTYPWIDTH).ec

$(RUPSHIFT): $(RUPSHIFT).ec
	$(ESQL) -o $(RUPSHIFT) $(INCL) $(RUPSHIFT).ec

$(SQGETDBS): $(SQGETDBS).ec
	$(ESQL) -o $(SQGETDBS) $(INCL) $(SQGETDBS).ec

$(SQDETACHDEMO): $(SQLDETACHDEMO).ec
	$(ESQL) -o $(SQLDETACHDEMO) $(INCL) $(SQLDETACHDEMO).ec

$(STCAT): $(STCAT).ec
	$(ESQL) -o $(STCAT) $(INCL) $(STCAT).ec

$(STCHAR): $(STCHAR).ec
	$(ESQL) -o $(STCHAR) $(INCL) $(STCHAR).ec

$(STCMPR): $(STCMPR).ec
	$(ESQL) -o $(STCMPR) $(INCL) $(STCMPR).ec

$(STCOPY): $(STCOPY).ec
	$(ESQL) -o $(STCOPY) $(INCL) $(STCOPY).ec

$(STLENG): $(STLENG).ec
	$(ESQL) -o $(STLENG) $(INCL) $(STLENG).ec

$(TIMEOUT): $(TIMEOUT).ec
	$(ESQL) -o $(TIMEOUT) $(INCL) $(TIMEOUT).ec

$(UNLOAD): $(UNLOAD).ec
	$(ESQL) -o $(UNLOAD) $(INCL) $(UNLOAD).ec

$(UPDCD_ME): $(UPDCD_ME).ec
	$(ESQL) -o $(UPDCD_ME) $(INCL) $(UPDCD_ME).ec

$(UPDCD_NF): $(UPDCD_NF).ec
	$(ESQL) -o $(UPDCD_NF) $(INCL) $(UPDCD_NF).ec

$(UPDCD_OF): $(UPDCD_OF).ec
	$(ESQL) -o $(UPDCD_OF) $(INCL) $(UPDCD_OF).ec

$(UPD_LO_DESCR): $(UPD_LO_DESCR).ec
	 $(ESQL) -o $(UPD_LO_DESCR) $(INCL) $(UPD_LO_DESCR).ec 

$(VARCHAR): $(VARCHAR).ec
	$(ESQL) -o $(VARCHAR) $(INCL) $(VARCHAR).ec


cleanup:
	$(RM) $(TARGET)
	$(RM) *.o
	$(RM) $(BLOBLOAD).c $(BYCMPR).c $(BYCOPY).c $(BYFILL).c $(BYLENG).c \
	$(COLLECT).c $(DECADD).c $(DECCMP).c $(DECCOPY).c $(DECCVASC).c \
	$(DECCVDBL).c $(DECCVINT).c $(DECCVLONG).c $(DECDIV).c $(DECECVT).c \
	$(DECFCVT).c $(DECMUL).c $(DECROUND).c $(DECSUB).c $(DECTOASC).c \
	$(DECTODBL).c $(DECTOINT).c $(DECTOLONG).c $(DECTRUNC).c $(DEMO1).c \
	$(DEMO2).c $(DEMO3).c $(DEMO4).c $(DISPCAT_PIC).c $(DTADDINV).c \
	$(DTCURRENT).c $(DTCVASC).c $(DTCVFMTASC).c $(DTEXTEND).c $(DTSUB).c \
	$(DTSUBINV).c $(DTTOASC).c $(DTTOFMTASC).c $(DYN_SQL).c $(GETCD_ME).c \
	$(GETCD_NF).c $(GETCD_OF).c $(GETDIAG).c $(INCVASC).c $(INCVFMTASC).c \
	$(INT8ADD).c $(INT8CVASC).c $(INT8CVDEC).c $(INT8DIV).c $(INT8SUB).c \
	$(INT8TOASC).c $(INT8TODEC).c $(INTOASC).c $(INTOFMTASC).c $(INVDIVDBL).c \
	$(INVDIVINV).c $(INVEXTEND).c $(INVMULDBL).c $(LDCHAR).c $(LVARPTR).c $(PAMDEMO).c \
	$(RDAYOFWEEK).c $(RDEFMTDATE).c $(RDOWNSHIFT).c $(RFMTDATE).c $(RFMTDEC).c \
	$(RFMTDOUBLE).c $(RFMTLONG).c $(RGETLMSG).c $(RGETMSG).c $(RISNULL).c \
	$(RJULMDY).c $(RLEAPYEAR).c $(RMDYJUL).c $(RSETNULL).c $(RSTOD).c \
	$(RSTOI).c $(RSTOL).c $(RSTRDATE).c $(RTODAY).c $(RTYPALIGN).c \
	$(RTYPMSIZE).c $(RTYPNAME).c $(RTYPWIDTH).c $(RUPSHIFT).c $(SQLDETACHDEMO).c \
  $(SQGETDBS).c $(STCAT).c $(STCHAR).c $(STCMPR).c $(STCOPY).c $(STLENG).c \
	$(TIMEOUT).c $(UNLOAD).c $(UPDCD_ME).c $(UPDCD_NF).c $(UPDCD_OF).c \
	$(VARCHAR).c


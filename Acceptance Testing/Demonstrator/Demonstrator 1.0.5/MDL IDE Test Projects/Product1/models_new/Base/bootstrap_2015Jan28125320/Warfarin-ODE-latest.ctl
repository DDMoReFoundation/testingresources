; Script generated by the pharmML2Nmtran Converter v.1.0.0
; Source	: PharmML 0.3.1
; Target	: NMTRAN 7.2.0
; Model 	: Warfarin-ODE-latest
; Dated 	: Wed Jan 28 11:21:34 GMT 2015

$PROBLEM "Warfarin-ODE-latest - generated by MDL2PharmML v.6.0"

$INPUT ID TIME WT AMT DVID DV MDV LOGTWT
$DATA warfarin_conc.csv IGNORE=@
$SUBS ADVAN13 TOL=9

$MODEL
COMP (GUT)
COMP (CENTRAL)

$PK
POP_CL = THETA(1)
POP_V = THETA(2)
POP_KA = THETA(3)
POP_TLAG = THETA(4)
RUV_PROP = THETA(5)
RUV_ADD = THETA(6)
BETA_CL_WT = THETA(7)
BETA_V_WT = THETA(8)

ETA_CL = ETA(1)
ETA_V = ETA(2)
ETA_KA = ETA(3)
ETA_TLAG = ETA(4)

MU_1 = LOG(POP_CL)+BETA_CL_WT * logtWT;
CL = EXP(MU_1 + ETA(1));

MU_2 = LOG(POP_V)+BETA_V_WT * logtWT;
V = EXP(MU_2 + ETA(2));

MU_3 = LOG(POP_KA);
KA = EXP(MU_3 + ETA(3));

MU_4 = LOG(POP_TLAG);
TLAG = EXP(MU_4 + ETA(4));

$DES
GUT = A(1)
CENTRAL = A(2)

RATEIN =   0.0;
IF (T.GE.TLAG) THEN
	RATEIN =  (GUT * KA) 
ELSE
	RATEIN =  0 
ENDIF

CC_DES =  (CENTRAL / V)
DADT(1) = -(RATEIN)
DADT(2) = (RATEIN - ((CL * CENTRAL) / V))

$ERROR
CC =  (A(2) / V)

IPRED = CC
W = RUV_ADD+RUV_PROP*IPRED
Y = IPRED+W*EPS(1)
IRES = DV - IPRED
IWRES = IRES/ W

$THETA
( 0.0010 , 0.1 )	;POP_CL
( 0.0010 , 8.0 )	;POP_V
( 0.0010 , 0.362 )	;POP_KA
( 0.0010 , 1.0 )	;POP_TLAG
( 0.1 )	;RUV_PROP
( 0.1 )	;RUV_ADD
( 0.75  FIX )	;BETA_CL_WT
( 1.0  FIX )	;BETA_V_WT

$OMEGA BLOCK(2) CORRELATION SD
( 0.1 )	;PPV_CL
( 0.01 )	;CORR_PPV_CL_V
( 0.1 )	;PPV_V

$OMEGA
( 0.1 SD )	;PPV_KA
( 0.1 SD )	;PPV_TLAG

$SIGMA
1.0 FIX

$EST METHOD=SAEM INTER CTYPE=3 NITER=1000 NBURN=4000 NOPRIOR=1 CITER=10
  CALPHA=0.05 IACCEPT=0.4 ISCALE_MIN=1.0E-06 ISCALE_MAX=1.0E+06
  ISAMPLE_M1=2 ISAMPLE_M1A=0 ISAMPLE_M2=2 ISAMPLE_M3=2
  CONSTRAIN=1 EONLY=0 ISAMPLE=2 PRINT=50

$TABLE ID TIME WT AMT DVID MDV LOGTWT PRED IPRED RES IRES WRES IWRES Y DV NOAPPEND NOPRINT FILE=sdtab

$TABLE ID CL V KA TLAG ETA_CL ETA_V ETA_KA ETA_TLAG NOAPPEND NOPRINT FILE=patab

$TABLE ID LOGTWT NOAPPEND NOPRINT FILE=cotab



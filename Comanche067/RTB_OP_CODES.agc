### FILE="Main.annotation"
## Copyright:   Public domain.
## Filename:    RTB_OP_CODES.agc
## Purpose:	Part of the source code for Comanche 67 (Colossus 2C),
##		the one-and-only software release for the Apollo Guidance 
##		Computer (AGC) of Apollo 12's command module.  In the 
##		absence of a contemporary assembly listing for Comanche 67, 
##		the intention is to reconstruct the source code from a 
##		Comanche 55 (Colossus 2A, Apollo 11 CM) baseline and 
##		contemporary documentation describing the differences 
##		between the two.  Page numbers listed in the program 
##		comments follow Comanche 55 unless otherwise noted.
## Assembler:	yaYUL
## Contact:	Ron Burkey <info@sandroid.org>.
## Website:	www.ibiblio.org/apollo.
## Mod history: 2020-12-25 RSB	Began adaptation from Comanche 55 baseline.

## Page 1508
		BANK	22
		SETLOC	RTBCODES
		BANK

		EBANK=	XNB
		COUNT*	$$/RTB

# LOAD TIME2, TIME1 INTO MPAC:

LOADTIME	EXTEND
		DCA	TIME2
		TCF	SLOAD2

# CONVERT THE SINGLE PRECISION 2'S COMPLEMENT NUMBER ARRIVING IN MPAC (SCALED IN HALF-REVOLUTIONS) TO A
# DP 1'S COMPLEMENT NUMBER SCALED IN REVOLUTIONS.

CDULOGIC	CCS	MPAC
		CAF	ZERO
		TCF	+3
		NOOP
		CS	HALF

		TS	MPAC +1
		CAF	ZERO
		XCH	MPAC
		EXTEND
		MP	HALF
		DAS	MPAC
		TCF	DANZIG		# MODE IS ALREADY AT DOUBLE-PRECISION
		
# READ THE PIPS INTO MPAC WITHOUT CHANGING THEM:

READPIPS	INHINT
		CA	PIPAX
		TS	MPAC
		CA	PIPAY
		TS	MPAC +3
		CA	PIPAZ
		RELINT
		TS	MPAC +5
		
		CAF	ZERO
		TS	MPAC +1
		TS	MPAC +4
		TS	MPAC +6
VECMODE		TCF	VMODE

# FORCE TP SIGN AGREEMENT IN MPAC:

SGNAGREE	TC	TPAGREE
		
## Page 1509
		
		TCF	DANZIG

# CONVERT THE DP 1'S COMPLEMENT ANGLE SCALED IN REVOLUTIONS TO A SINGLE PRECISION 2'S COMPLEMENT ANGLE
# SCALED IN HALF-REVOLUTIONS.

1STO2S		TC	1TO2SUB
		CAF	ZERO
		TS	MPAC +1
		TCF	NEWMODE

# DO 1STO2S ON A VECTOR OF ANGLES:

V1STO2S		TC	1TO2SUB		# ANSWER ARRIVES IN A AND MPAC.

		DXCH	MPAC +5
		DXCH	MPAC
		TC	1TO2SUB
		TS	MPAC +2

		DXCH	MPAC +3
		DXCH	MPAC
		TC	1TO2SUB
		TS	MPAC +1

		CA	MPAC +5
		TS	MPAC

TPMODE		CAF	ONE		# MODE IS TP.
		TCF	NEWMODE

# V1STO2S FOR 2 COMPONENT VECTOR. USED BY RR.

2V1STO2S	TC	1TO2SUB
		DXCH	MPAC +3
		DXCH	MPAC
		TC	1TO2SUB
		TS	L
		CA	MPAC +3
		TCF	SLOAD2

# SUBROUTINE TO DO DOUBLING AND 1'S TO 2'S CONVERSION:

1TO2SUB		DXCH	MPAC		# FINAL MPAC +1 UNSPECIFIED.
		DDOUBL
		CCS	A
		AD	ONE
		TCF	+2
		COM			# THIS WAS REVERSE OF MSU.

		TS	MPAC		# AND SKIP ON OVERFLOW.
## Page 1510
		TC	Q

		INDEX	A		# OVERFLOW UNCORRECT AND IN MSU.
		CAF	LIMITS
		ADS	MPAC
		TC	Q

## Page 1511
# SUBROUTINE TO INCREMENT CDUS

INCRCDUS	CAF	LOCTHETA
		TS	BUF		# PLACE ADRES(THETA) IN BUF.
		CAE	MPAC		# INCREMENT IN 1S COMPL.
		TC	CDUINC
		
		INCR	BUF
		CAE	MPAC +3
		TC	CDUINC
		
		INCR	BUF
		CAE	MPAC +5
		TC	CDUINC
		
		TCF	VECMODE
		
LOCTHETA	ADRES	THETAD

# THE FOLLOWING ROUTINE INCREMENTS IN 2S COMPLEMENT THE REGISTER WHOSE ADDRESS IS IN BUF BY THE 1S COMPL.
# QUANTITY FOUND IN TEM2.  THIS MAY BE USED TO INCREMENT DESIRED IMU AND OPTICS CDU ANGLES OR ANY OTHER 2S COMPL.
# (+0 UNEQUAL TO -0) QUANTITY.  MAY BE CALLED BY BANKCALL/SWCALL.

CDUINC		TS	TEM2		# 1S COMPL. QUANT. ARRIVES IN ACC.  STORE IT
		INDEX	BUF
		CCS	0		# CHANGE 2S COMPL. ANGLE (IN BUF) INTO 1S
		AD	ONE
		TCF	+4
		AD	ONE
		AD	ONE		# OVERFLOW HERE IF 2S COMPL. IS 180 DEG.
		COM

		AD	TEM2		# SULT MOVES FROM 2ND TO 3D QUAD. (OR BACK)
		CCS	A		# BACK TO 2S COMPL.
		AD	ONE
		TCF	+2
		COM
		TS	TEM2		# STORE 14BIT QUANTITY WITH PRESENT SIGN
		TCF	+4
		INDEX	A		# SIGN.
		CAF	LIMITS		# FIX IT, BY ADDING IN 37777 OR 40000
		AD	TEM2

		INDEX	BUF
		TS	0		# STORE NEW ANGLE IN 2S COMPLEMENT.
		TC	Q

## Page 1512
# RTB TO TORQUE GYROS, EXCEPT FOR THE CALL TO IMUSTALL.  ECADR OF COMMANDS ARRIVES IN X1.

PULSEIMU	INDEX	FIXLOC		# ADDRESS OF GYRO COMMANDS SHOULD BE IN X1
		CA	X1
		TC	BANKCALL
		CADR	IMUPULSE
		TCF	DANZIG

## Page 1513
# EACH ROUTINE TAKES A 3X3 MATRIX STORED IN DOUBLE PRECISION IN A FIXED AREA OF ERASABLE MEMORY AND REPLACES IT
# WITH THE TRANSPOSE MATRIX.  TRANSP1 USES LOCATIONS XNB+0,+1 THROUGH XNB+16D, 17D AND TRANSP2 USES LOCATIONS
# XNB1+0,+1 THROUGH XNB1+16D, 17D.  EACH MATRIX IS STORED BY ROWS.

XNBEB		ECADR	XNB
XNB1EB		ECADR	XNB1

		EBANK=	XNB
		
TRANSP1		CAF	XNBEB
		TS	EBANK
		DXCH	XNB +2
		DXCH	XNB +6
		DXCH	XNB +2
		
		DXCH	XNB +4
		DXCH	XNB +12D
		DXCH	XNB +4
		
		DXCH	XNB +10D
		DXCH	XNB +14D
		DXCH	XNB +10D
		TCF	DANZIG
		EBANK=	XNB1
		
TRANSP2		CAF	XNB1EB
		TS	EBANK
		DXCH	XNB1 +2
		DXCH	XNB1 +6
		DXCH	XNB1 +2
		
		DXCH	XNB1 +4
		DXCH	XNB1 +12D
		DXCH	XNB1 +4
		
		DXCH	XNB1 +10D
		DXCH	XNB1 +14D
		DXCH	XNB1 +10D
		TCF	DANZIG

## Page 1514
# THE SUBROUTINE SIGNMPAC SETS C(MPAC, MPAC +1) TO SIGN(MPAC).
# FOR THIS, ONLY THE CONTENTS OF MPAC ARE EXAMINED.  ALSO +0 YIELDS POSMAX AND -0 YIELDS NEGMAX.
#
# ENTRY MAY BE BY EITHER OF THE FOLLOWING:
#	1.	LIMIT THE SIZE OF MPAC ON INTERPRETIVE OVERFLOW:
#		ENTRY:		BOVB
#					SIGNMPAC
#	2.	GENERATE IN MPAC THE SIGNUM FUNCTION OF MPAC:
#		ENTRY:		RTB
#					SIGNMPAC
# IN EITHER CASE, RETURN IS TO THE NEXT INTERPRETIVE INSTRUCTION IN THE CALLING SEQUENCE.

SIGNMPAC	EXTEND
		DCA	DPOSMAX
		DXCH	MPAC
		CCS	A
DPMODE		CAF	ZERO		# SETS MPAC +2 TO ZERO IN THE PROCESS
		TCF	SLOAD2 +2
		TCF	+1
		EXTEND
		DCS	DPOSMAX
		TCF	SLOAD2

# RTB OP CODE NORMUNIT IS LIKE INTERPRETIVE INSTRUCTION UNIT, EXCEPT THAT IT CAN BE DEPENDED ON NOT TO BLOW
# UP WHEN THE VECTOR BEING UNITIZED IS VERY SMALL -- IT WILL BLOW UP WHEN ALL COMPONENTS ARE ZERO.  IF NORMUNIT
# IS USED AND THE UPPER ORDER HALVES OF ALL COMPONENTS ARE ZERO, THE MAGNITUDE RETURNED IN 36D WILL BE TOO LARGE
# BY A FACTOR OF 2(13) AND THE SQUARED MAGNITUDE RETURNED AT 34D WILL BE TOO BIG BY A FACTOR OF 2(26).

NORMUNX1	CAF	ONE
		TCF	NORMUNIT +1
NORMUNIT	CAF	ZERO
		AD	FIXLOC
		TS	MPAC +2
		TC	BANKCALL	# GET SIGN AGREEMENT IN ALL COMPONENTS
		CADR	VECAGREE
		CCS	MPAC
		TCF	NOSHIFT
		TCF	+2
		TCF	NOSHIFT
		CCS	MPAC +3
		TCF	NOSHIFT
		TCF	+2
		TCF	NOSHIFT
		CCS	MPAC +5
		TCF	NOSHIFT
		TCF	+2
		TCF	NOSHIFT
## Page 1515
		CA	MPAC +1		# SHIFT ALL COMPONENTS LEFT 13
		EXTEND
		MP	BIT14
		DAS	MPAC		# DAS GAINS A LITTLE ACCURACY
		CA	MPAC +4
		EXTEND
		MP	BIT14
		DAS	MPAC +3
		CA	MPAC +6
		EXTEND
		MP	BIT14
		DAS	MPAC +5
		CAF	THIRTEEN
		INDEX	MPAC +2
		TS	37D
OFFTUNIT	TC	POSTJUMP
		CADR	UNIT +1		# SKIP THE "TC VECAGREE" DONE AT UNIT

NOSHIFT		CAF	ZERO
		TCF	OFFTUNIT -2

# RTB VECSGNAG ... FORCES SIGN AGREEMENT OF VECTOR IN MPAC.

VECSGNAG	TC	BANKCALL
		CADR	VECAGREE
		TC	DANZIG

## Page 1516
# MODULE CHANGE FOR NEW LUNAR GRAVITY MODEL
		SETLOC	MODCHG3
		BANK
QUALITY1	BOF	DLOAD
			MOONFLAG
			NBRANCH
			URPV
		DSQ	GOTO
			QUALITY2
## `QUALITY2` has been _temporarily_ stashed in a different bank simply because there's room
## for it there, but isn't room for it in bank 12 where it was originally. 
## Undoubtedly we'll have to eventually move it elsewhere. 
		BANK	16
QUALITY2	PDDL	DSQ		# SQUARE INTO 2D, B2
			URPV	+2	# Y COMPONENT, B1
		DSU
		DMP	VXSC		# 5(Y**2-X**2)UR
			5/8		# CONSTANT, 5B3
			URPV		# VECTOR, RESULT MAXIMUM IS 5, SCALING
					# HERE B6
		VSL3	PDDL		# STORE SCALED B3 IN 2D, 4D, 6D FOR XYZ
			URPV		# X COMPONENT, B1
		SR1	DAD		# 2 X X COMPONENT FOR B3 SCALING
			2D		# ADD TO VECTOR X COMPONENT OF ANSWER.
					# SAME AS MULTIPLYING BY UNITX.  MAX IS 7.
		STODL	2D
			URPV	+2	# Y COMPONENT, B1
		SR1	BDSU		# 2 X Y COMPONENT FOR B3 SCALING
			4D		# SUBTRACT FROM VECTOR Y COMPONENT OF
					# ANSWER, SAME AS MULTIPLYING BY UNITY.
					# MAX IS 7.
		STORE 	4D		# 2D HAS VECTOR, B3.
		SLOAD	VXSC		# MULTIPLY COEFFIECIENT TIMES VECTOR IN 2D
			E3J22R2M
		PDDL	RVQ		# J22 TERM X R**4 IN 2D, SCALED B61
			COSPHI/2	# SAME AS URPV +4, Z COMPONENT

## <b>Reconstruction:</b>  The <code>TIMEOPT</code> subroutine has been copied
## directly out of Artemis 71, due to PCR 799.  If you refer to the 
## <a href="http://www.ibiblio.org/apollo/Documents/E-2456-2D.pdf#page=1027&view=FitV">
## Colossus 2C flowchart for V82, sheet 5</a>, you'll notice that almost the entire
## sheet, from "DSPTEMX<sub>D</sub>&larr;+0<sub>D</sub> through STRTDEC1, does not 
## appear in the <a href="http://www.ibiblio.org/apollo/Documents/E-2456-2C.pdf#page=326&view=FitV">
## corresponding sheet 6 of the Colossus 2 flowchart for V82</a>, and that 
## furthermore, that block of the flowchart closely matches the code in 
## <code>TIMEOPT</code. In Artemis, <code>TIMEOPT</code> simply appears in 
## bank 23 along with the subroutine <code>V82CALL</code> that calls it.
## That positioning is no good in Comanche 67, since bank 23 isn't big enough.
## Either <code>TIMEOPT</code> must have been put in some other bank, or else
## some other code must have moved to a different bank to make room for 
## <code>TIMEOPT</code>.  The former makes more sense.  I simply chose
## a bank that had enough space in it, but also had a relatively poor
## checksum diff compared to the few other available banks.
		BANK	16
		
TIMEOPT		STORE	DSPTEMX
 +1		STQ	EXIT
			VEHRET
		CAF	V06N16X
		TC	BANKCALL
		CADR	GOXDSPF 
		TC	ENDEXT
		TC	+2
		TC	-5
## Page 519	
		TC	INTPRET
		DLOAD	BZE
			DSPTEMX
			GETNOW
STRTDEC1  	STCALL	TDEC1 
			VEHRET
GETNOW		RTB	GOTO
			LOADTIME
			STRTDEC1
V06N16X		VN	0616
## <b>Reconstruction:</b>  Allocation of <code>VEHRET</code>
## a potential error. There are two possibilities:
## <ul>
## <li>It may be allocated in E0, E1, or E2 in such a way that erasable pad
## load addresses are not affected.  This would require it to be in E0
## from 0111-0377, or in E3 from 01353-01377.</li>
## <li>It may share a previously-allocated location for a routine not used
## simultaneously with V82.</li>
## </ul>
## In Artemis, it's actually a standalone variable (i.e., the first of the
## two options above). That makes little sense to me in Comanche 67,
## since it's only needed for temporary storage of <code>TIMEOPT</code>'s 
## return address above.  (It may make a little more sense in Artemis, 
## since in Artemis <code>TIMEOPT</code> is called through V90 in addition
## to V82.  I don't know.  But the positioning used in Artemis isn't 
## possible in Comanche 67 due to the affect on erasable pad load addresses.)
## <br></br>
## So the second option, shared storage, seems much more natural to me.  
## Unfortunately, that doesn't really narrow it down too 
## much.  One thing I notice about <code>TIMEOPT</code> is that it also uses the
## temporary variable <code>DSPTEMX</code>, which is itself aliased in 
## ERASABLE ASSIGMENTS as the last 2 words of the 3-word area <code>DSPTEM2</code>
## It seems not unreasonable that the 1st word of <code>DSPTEM2</code> might have
## been originally used for <code>VEHRET</code> and then only later turned into
## a standalone variable in Artemis for reasons I don't know.
## <br><br>
## However, ultimately this is little more than a guess, so it is likely to
## be very wrong, and needs to be revisited later. 
VEHRET		EQUALS	DSPTEM2
			
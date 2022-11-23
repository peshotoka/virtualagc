### FILE="Main.annotation"
## Copyright:	Public domain.
## Filename:	EXECUTIVE.agc
## Purpose:	Part of the source code for Solarium build 55. This
##		is for the Command Module's (CM) Apollo Guidance
##		Computer (AGC), for Apollo 6.
## Assembler:	yaYUL --block1
## Contact:	Jim Lawton <jim DOT lawton AT gmail DOT com>
## Website:	www.ibiblio.org/apollo/index.html
## Mod history:	2009-09-19 JL	Created.
##		2016-08-18 RSB	Some fixes.
## 		2016-12-28 RSB	Proofed comment text using octopus/ProoferComments,
##				and fixed errors found.


# EXECUTIVE PROGRAMS
# --------- --------



		BANK	1
FINDVAC		TS	NEWPRIO		# PROGRAM TO FIND AN AVAILABLE VAC
		XCH	Q
		TC	EXECCOM		# COMMON FF EXECUTIVE SUBROUTINE.
		TC	FINDVAC2	# OFF TO EXECUTIVE BANK.

NOVAC		TS	NEWPRIO		# ENTRY EXCLUSIVELY FOR BASIC JOBS NOT
		XCH	Q		# REQUIRING A VAC AREA.
		TC	EXECCOM		# COMMON FF EXECUTIVE SUBROUTINE.
		CAF	ZERO		# ZERO PD FIELD IN PUSHLOC.
		TS	EXECTEM3
		TC	NOVAC2

JOBWAKE		TS	EXECTEM2	# ENTRY HERE TO RE-ACTIVATE A SLEEPING JOB
		CCS	Q		# RETURN ADDRESS - 1 TO WTEXIT.
		TS	WTEXIT		# SHARES FINAL PORTION OF FINDVAC, NOVAC.
		TC	EXECSW		# COMMON EXEC BANK-SWITCH SUBROUTINE.
		TC	JOBWAKE2

EXECCOM		TS	WTEXIT		# EXIT ADDRESS
		INDEX	A		# PICK UP JOB OR TASK ADDRESS.
		CAF	0		#   (USED BY FINDVAC, NOVAC, AND WAITLIST)
		TS	EXECTEM2

EXECSW		CAF	EXECBANK
		XCH	BANKREG		# CALL IN EXEC BANK, SAVING RETURN.
		TS	EXECTEM1
		TC	Q

EXECBANK	CADR	FINDVAC2

FOUNDVAC	TS	BANKREG		# COMES HERE TO RETURN FROM FINDVAC,
		INDEX	WTEXIT		# NOVAC, OR JOBWAKE.
		TC	1


#		CALLS TO FINDVAC BEGIN HERE, SNATCHING AN AVAILABLE VAC AREA.

		SETLOC	10000		# EXEC/WAITLIST BANK.

SLAPB		TC	SLAP1

KEYRUPTC	TC	KEYRUPT1	# STANDARD LOC, DONT MOVE

MODROUTB	TC	MODROUT		# STANDARD LOC, DONT MOVE

FINDVAC2	CCS	VAC1USE		# C(VAC1USE) =  TC VAC1USE  IF VAC1 IS
		TC	FV1		# AVAILABLE, OR +0 IF IT IS IN USE.
		CCS	VAC2USE
		TC	FV1		# THE FIRST CCS WITH +0 JUMPS TO THE
		CCS	VAC3USE		#   CORRESPONDING TC ORDER.
		TC	FV1
		CCS	VAC4USE
		TC	FV1
		CCS	VAC5USE
		TC	FV1

		TC	ABORT		# NO VAC AREAS AVAILABLE.
		OCT	01201

FV1		AD	TWO		# TO FORM ADDRESS OF ASSIGNED VAC AREA.
		TS	EXECTEM3
		AD	NEWPRIO		# )  STORE ADDRESS OF VAC1 IN LOW-ORDER
		TS	NEWPRIO		# )    9 BITS OF NEWPRIO.

		CAF	ZERO		# )
		INDEX	EXECTEM3	# )  STORE +0 IN VAC1USE, INDICATING USE.
		TS	0 -1		# )

NOVAC2		CAF	LASTADR		# RELATIVE ADDRESS OF LAST REGISTER SET.
		TS	LOCCTR
		CCS	A
		TC	+5		# PNZ AND -0 ONLY.

12BITSOK	CS	EXECTEM2	# COMES HERE IF JOB ADDRESS LESS THAN 6K.
		TC	LOCSET

		TC	ABORT		# NO REGISTER SETS AVAILABLE.
		OCT	01202

 +5		INDEX	LOCCTR		# THIS LOOP FINDS THE FIRST AVAILABLE
		CCS	PRIORITY	#   STORAGE AREA FOR CORE REGISTERS FOR
		TC	NOVAC3		# THE NEW JOB.
LASTADR		DEC	56		# EIGHT SETS OF EIGHT REGISTERS.
		TC	NOVAC3		# NNZ MEANS JOB ASLEEP HERE.


#	NOW THAT REGISTER SETS HAVE BEEN FOUND FOR THE NEW JOB, INITIALIZE THEM AND SET NEWJOB IF CALLED FOR.

CORSW		INDEX	LOCCTR		# (COMES HERE WITH C(A) = 0). TURN OFF OVF
		TS	OVFIND

		AD	NEWPRIO		# SET UP PRIORITY FOR NEW JOB.
JOBWAKE4	INDEX	LOCCTR		# JOB WAKING ENTERS HERE TO FINISH UP.
		TS	PRIORITY	# STORE NEW PRIORITY
		CAF	BANKMASK
		MASK	EXECTEM2
		AD	EXECTEM3	# PUSHLOC
		INDEX	LOCCTR
		TS	PUSHLOC

		CAF	EXEC70K		# CREATE PROPER 12 BIT ADDRESS.
		MASK	EXECTEM2	# SEE IF HIGH THREE BITS ZERO.
		CCS	A
		TC	+2		# NEEDS SPECIAL TREATMENT IF C(A) NOT ZERO
		TC	12BITSOK

		XCH	EXECTEM2
		MASK	LOW10
		AD	6K
		COM
LOCSET		INDEX	LOCCTR
		TS	LOC

		INDEX	NEWJOB
		CS	PRIORITY	# TEST WHETHER NEW JOB HAS HIGHER
		AD	NEWPRIO		# PRIORITY THAN PREVIOUS HIGHEST
		CCS	A
		CS	LOCCTR		# NEW JOB HAS HIGHER PRIORITY.
		TC	NEWHIGH		# SET NEWJOB, LEAVING LOCCTR UNCHANGED.

		TC	+1		# -0 IF PRIORITIES = AND BOTH ARE NOVACS.
NOWAKE2		XCH	EXECTEM1
ENDFIND		TC	FOUNDVAC

NEWHIGH		COM			# SET NEWJOB AND RETURN TO CALLER.
		TS	NEWJOB
		TC	ENDFIND -1

NOVAC3		CS	EIGHT		# COMES HERE TO EXAMINE NEXT REGISTER SET.
		AD	LOCCTR
		TC	NOVAC2 +1


#	THE  JOBWAKE  ROUTINE REACTIVES A SLEEPING JOB, SETTING IT TO BEGIN AT THE GIVEN WAKE ADDRESS.

JOBWAKE2	CAF	LASTADR		# BEGIN SEARCH FOR REGISTER SET CONTAINING
		TS	LOCCTR		# SLEEPING JOB. WAKE ADDRESS IS IN  LOC IN
		CCS	A		# CADR FORM, AS PLACED THERE BY  JOBSLEEP.
		INDEX	LOCCTR		# PNZ AND -0 ONLY. SEE IF THIS JOB ASLEEP.
		CCS	PRIORITY	# THIS CCS CANT GO TO  TC NOWAKE  .
		TC	JOBWAKE3	# PNZ - ACTIVE JOB PRESENT. +0 IMPOSSIBLE.

		TC	NOWAKE		# ALARM - SLEEPING JOB NOT FOUND.

		TC	+2		# INACTIVE JOB FOUND.
		TC	JOBWAKE3	# -0 - NOT IN USE.

 +2		CS	EXECTEM2	# SEE IF THIS IS THE DESIRED SLEEPING JOB.
		INDEX	LOCCTR
		AD	LOC
		CCS	A
		TC	JOBWAKE3	# SEARCH NEXT SET IF NOT AT END.
		SETLOC	+1
		TC	JOBWAKE3

		CAF	LOW10		# SET UP EXECTEM3 AND PRIORITY SO WE CAN
		INDEX	LOCCTR		# FINISH AT STANDARD  CORSW  .
		MASK	PUSHLOC		# PROTECT PD SETTING.
		TS	EXECTEM3

		INDEX	LOCCTR		# RE-COMPLEMENT PRIORITY AND FINISH UP.
		CS	PRIORITY
		TS	NEWPRIO
		TC	JOBWAKE4

JOBWAKE3	CS	EIGHT		# ADVANCE TO NEXT REGISTER SET.
		AD	LOCCTR
		TC	JOBWAKE2 +1

NOWAKE		TS	LOCCTR		# SET LOCCTR = +0 TO SHOW NO JOB WAS
		TC	NOWAKE2		#  AWAKENED.


# A NEW JOB, OF HIGHER PRIORITY THAN THE PRESENT ONE, CAUSES THE RELA-
# TIVE ADDRESS (9, 18, ..., 63) OF THE NEW JOB CORE REGISTERS TO BE
# PLACED IN REGISTER  NEWJOB , WHERE IT IS TESTED BY THE INTERPRETER.
# THE RESULTING BRANCH TO CHANJOB, BELOW, CAUSES A TRADE BETWEEN THE
# CORE REGISTERS OF THE PRESENT AND NEW JOBS.

		SETLOC	FOUNDVAC +3

CHANG1		INHINT			# BASIC JOBS COME HERE WHEN C(NEWJOB)
		CAF	EXECBANK	# NON-ZERO. START BY CALLING IN EXECUTIVE
		XCH	BANKREG		# BANK AND SAVING RETURN BANK CODE.
		COM
		TS	BANKSET
		XCH	PUSHLOC		# BLANK OUT THE HIGH-ORDER 4 BITS IN
		MASK	LOW10		# PUSHLOC SO THE BANK BITS CAN BE PACKED
		TS	PUSHLOC		# WITH IT
		CS	Q		# FOR RETURN, SHOWING THIS WAS A BASIC JOB
		TC	CHANJOB		# OFF TO BANK 0

CHANG2		CCS	NEWEQIND	# INTERPRETIVE INTERRUPTS START HERE, 
		TC	Q		# PROVIDED THE LOAD INDICATOR ISNT ON

		INHINT
		CAF	EXECBANK	# CALL IN EXECUTIVE BANK.
		TS	BANKREG
		XCH	LOC
		TC	CHANJOB		# WITH C(A) PNZ, SHOWING WE WERE IN INTERP
					# RETER
		SETLOC	NOWAKE +2
CHANJOB		INDEX	NEWJOB		# TO BEGIN SWAP OF CORE REGISTERS
		XCH	LOC
		TS	LOC		# SAVE PROPER 12 BIT ADDRESS
		
		XCH	PRIORITY
		INDEX	NEWJOB
		XCH	PRIORITY
		TS	PRIORITY
		MASK	LOW9		# TO GET FIXLOC
		TS	FIXLOC
		AD	BIT6		# SET UP VACLOC ( = FIXLOC + 32D )
		TS	VACLOC
		
		CS	BANKSET		# SAVE BANK
		AD	PUSHLOC		# AND PUSHLOC IN SAME WORD
		INDEX	NEWJOB
		XCH	PUSHLOC
		TS	PUSHLOC
		MASK	LOW10
		XCH	PUSHLOC
		COM
		AD	PUSHLOC		# WE NOW HAVE COMPLEMNT OF BANK BITS
		TS	BANKSET
		
		CS	ADRLOC		# SAVE MODE AND COMPLEMENT OF ADRLOC IN
		DOUBLE			# SAME WORD. ADRLOC MUST BE SHIFTED 2
		DOUBLE			# PLACES TO MAKE ROOM FOR MODE
		AD	MODE		# -0, -1, OR -2
		INDEX	NEWJOB
		XCH	ADRLOC
		TS	SR
		MASK	THREE		# SAVE LOW 2 BITS
		AD	NEG3		# THIS RESULTS IN EITHER -0, -1, OR -2
		TS	MODE
		CS	SR
		CS	SR
		TS	ADRLOC

		CCS	OVFIND		# SAVE C(ORDER) POSITIVE IF C(OVFIND) = 0
		TC	+2		# AND NEGATIVE OTHERWISE
		TC	+3
		CS	ORDER
		TC	+2
		XCH	ORDER
		INDEX	NEWJOB
		XCH	OVFIND
		TS	ORDER
		CCS	A		# DETERMINE NEW SETTING OF OVFIND
		CAF	ZERO		# TO ZERO
		TC	OVFSET
		CS	ORDER		# ORDER WAS NEGATIVE, MAKE IT POSITIVE
		TS	ORDER
		CAF	ONE		# TO SET OVFIND
OVFSET		TS	OVFIND

		XCH	MPAC		# TRADE C(MPAC TO MPAC+2)
		INDEX	NEWJOB
		XCH	MPAC
		TS	MPAC
		XCH	MPAC +1
		INDEX	NEWJOB
		XCH	MPAC +1
		TS	MPAC +1
		XCH	MPAC +2
		INDEX	NEWJOB
		XCH	MPAC +2
		TS	MPAC +2

		CAF	ZERO
		TS	NEWEQIND	# MAKE SURE LOAD INDICATOR OFF.
SETNJ		TS	NEWJOB
		RELINT			# ENABLE INTERRUPT
		CCS	LOC		# C(LOC) PNZ FOR INTERPRETIVE JOBS.
		CAF	ZERO
		TC	DANZIG +2	# RETURN TO INTERPRETER
		AD	ONE		# GET ABS(LOC) AND RETURN TO BASIC
		TS	ADDRWD
		CS	BANKSET		# GET DESIRED BANKBITS
ENDCHANG	TC	BASICALL

		SETLOC	CHANG2 +7D	# TAKE UP WHERE WE LEFT OFF IN FIXED-FIXED

BASICALL	TS	BANKREG
		TC	ADDRWD

ENDOFJOB	CAF	EXECBANK	# NORMAL ENDJOB ENTRY.
		TS	BANKREG
		TC	ENDJOB1

JOBSLEEP	TS	LOC		# ENTRY HERE TO DE-ACTIVE THIS JOB.
		CAF	EXECBANK	# LOC IS SET TO THE AWAKENING ADDRESS
		TS	BANKREG		# SO THE SUBSEQUENT JOBWAKE CAN FIND
		TC	JOBSLP1		# THE PROPER REGISTER SET.

		SETLOC	ENDCHANG +1

ENDJOB1		INHINT			# INTERPRETIVE JOBS FINISH WITH RTB
		CS	ZERO		# TO ENDJOB1
		TS	BUF +1		# ENDJOB USES BUF, BUF +1, AND BUF +2.
		XCH	PRIORITY
		MASK	LOW9		# RESTORE AVAILABILITY OF VAC1 BY SETTING
		CCS	A		# C(VAC1USE) NON-ZERO
		INDEX	A
		TS	0

		TC	EJSCAN		# ENDJOB NEED NOT EXAMINE FIRST REG. SET.

JOBSLP1		INHINT			# FINISH JOB SLEEP AND START ENDJOB-TYPE
		CS	PRIORITY	# SCAN. COMPLEMENTED PRIORITY REGISTER
		TS	PRIORITY	# SHOWS JOB IS ASLEEP.
		CS	ZERO		# INITIALIZE SEARCH FOR HIGHEST PRIORITY. 
		TS	BUF +1


#	SCAN FOR THE ACTIVE JOB OF HIGHEST PRIORITY.

EJSCAN		CCS	PRIORITY +8D	# EACH PRIORITY REGISTER (PRIORITY +8N)
		TC	EJ1		# IS SCANNED. ITS CONTENTS ARE EITHER
		SETLOC	+1
		TC	+1		#    2. NNZ - AN INACTIVE PRIORITY NUMBER.

		CCS	PRIORITY +16D	# OR 3. -0 - NOT IN USE.
		TC	EJ1		# IF PNZ, CONTROL IS TRANSFERRED TO EJ1
		SETLOC	+1
		TC	+1		# PARED WITH THE PREVIOUS HIGHEST

		CCS	PRIORITY +24D	# PRIORITY FOUND. THE CONTENTS OF Q
		TC	EJ1		# SERVE TO LOCATE THE CCS WHICH WAS
		SETLOC	+1
		TC	+1		# NEWJOB IS SET TO THE RELATIVE ADDRESS

		CCS	PRIORITY +32D	# OF THE REGISTER SET WITH THE HIGHTEST 
		TC	EJ1		# ACTIVE PRIORITY AT THE END OF THE SCAN.
		SETLOC	+1
		TC	+1

		CCS	PRIORITY +40D
		TC	EJ1
EXEC70K		OCT	70000
		TC	+1

		CCS	PRIORITY +48D
		TC	EJ1
-CCSPR         -CCS	PRIORITY
		TC	+1

		CCS	PRIORITY +56D
		TC	EJ1
		SETLOC	+1
		TC	+1

		INDEX	BUF		# PICK UP CCS INSTRUCTION TO GET NEWJOB
		CAF	0 -2		# SELECT CCS INSTRUCTION.
		AD	-CCSPR
		TS	NEWJOB		# RELATIVE ADDRESS ONLY.
		XCH	LOC		# (NO MEANING FOR ENDOFJOB).
		TC	CHANJOB



EJ1		TS	BUF +2		# STORE NEW PRIORITY
		AD	BUF +1		# - OLD PRIORITY
		CCS	A
		XCH	Q		# IF NEW PRIORITY IS LARGER
		TC	EJ2
		NOOP			# IF OLD PRIORITY IS LARGER
		INDEX	Q		#   OR EQUAL
		TC	2

EJ2		TS	BUF		# SAVE C(Q) TO LOCATE HIGHEST PRIORITY
		CS	BUF +2		#   JOB AT END OF SCAN.
		TS	BUF +1
		INDEX	BUF
		TC	2

# FIXME

PRIO1		EQUALS	BIT10
PRIO2		EQUALS	BIT11
PRIO3		EQUALS
PRIO4		EQUALS	BIT12
PRIO5		EQUALS
EQUALS
PRIO6		EQUALS	6K
PRIO7		EQUALS
PRIO10		EQUALS	BIT13
PRIO11		EQUALS
PRIO12		EQUALS
PRIO13		EQUALS
PRIO14		EQUALS
PRIO15		EQUALS
PRIO16		EQUALS
PRIO17		EQUALS
PRIO20		EQUALS	BIT14
PRIO21		EQUALS
PRIO22		EQUALS
PRIO23		EQUALS
PRIO24		EQUALS
PRIO25		EQUALS
PRIO26		EQUALS
PRIO27		EQUALS
PRIO31		EQUALS
PRIO32		EQUALS
PRIO33		EQUALS
PRIO34		EQUALS
PRIO35		EQUALS
PRIO36		EQUALS
PRIO37		EQUALS

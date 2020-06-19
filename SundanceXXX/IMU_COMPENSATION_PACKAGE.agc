### FILE="Main.annotation"
## Copyright:   Public domain.
## Filename:    IMU_COMPENSATION_PACKAGE.agc
## Purpose:     A section of a reconstructed, mixed version of Sundance
##              It is part of the reconstructed source code for the Lunar
##              Module's (LM) Apollo Guidance Computer (AGC) for Apollo 9.
##              No original listings of this program are available;
##              instead, this file was created via disassembly of dumps
##              of various revisions of Sundance core rope modules.
## Reference:   pp. 339-350
## Assembler:   yaYUL
## Contact:     Ron Burkey <info@sandroid.org>.
## Website:     www.ibiblio.org/apollo/index.html
## Mod history: 2020-06-17 MAS  Created from Luminary 69.

                BANK    7
                SETLOC  IMUCOMP
                BANK
                
                EBANK=  NBDX
                
                COUNT*  $$/ICOMP
1/PIPA          CAF     LGCOMP          # SAVE EBANK OF CALLING PROGRAM
                XCH     EBANK
                TS      MODE
                
                CCS     GCOMPSW         # BYPASS IF GCOMPSW NEGATIVE
                TCF     +3
                TCF     +2
                TCF     IRIG1           # RETURN
                
1/PIPA1         CAF     FOUR            # PIPAZ, PIPAY, PIPAX
                TS      BUF +2
                
                INDEX   BUF +2
                CA      PIPASCF         # (P.P.M.) X 2(-9)
                EXTEND
                INDEX   BUF +2
                MP      DELVX           # (PP) X 2(+14) NOW (PIPA PULSES) X 2(+5)
                TS      Q               # SAVE MAJOR PART
                
                CA      L               # MINOR PART
                EXTEND
                MP      BIT6            # SCALE 2(+9)   SHIFT RIGHT 9
                INDEX   BUF +2
                TS      DELVX +1        # FRACTIONAL PIPA PULSES SCALED 2(+14)
                
                CA      Q               # MAJOR PART
                EXTEND
                MP      BIT6            # SCALE 2(+9)   SHIFT RIGHT 9
                INDEX   BUF +2  
                DAS     DELVX           # (PIPAI) + (PIPAI)(SFE)

## Lines from here to the bottom of the page angle and start to overlap. The code until the MP BIT4 is legible.
## It is assumed that the illegible portions are identical to their Luminary 99 counterparts. - RRB 2017
## <br>The comments are legible, except that the last line is rather tricky, and can be verified directly. - RSB 2017
                INDEX   BUF +2
                CS      PIPABIAS        # (PIPA PULSES)/(CS) X 2(-5)             *
                EXTEND
                MP      1/PIPADT        # (CS) X 2(+8) NOW (PIPA PULSES) X 2(+3) *
                EXTEND
                MP      BIT4            # SCALE 2(+11) SHIFT RIGHT 11            *
                INDEX   BUF +2
                DAS     DELVX           # (PIPAI) + (PIPAI)(SFE) - (BIAS)(DELTAT)
                
                CCS     BUF +2          # PIPAZ, PIPAY, PIPAX
                AD      NEG1
                TCF     1/PIPA1 +1
                NOOP                    # LESS THAN ZERO IMPOSSIBLE

IRIGCOMP        TS      GCOMPSW         # INDICATE COMMANDS 2 PULSES OR LESS.
                TS      BUF             # INDEX COUNTER . IRIGX, IRIGY, IRIGZ.
                
                TC      IRIGX           # COMPENSATE ACCELERATION TERMS
                
                CS      NBDX            # (GYRO PULSES)/(CS) X 2(-5)
                TC      DRIFTSUB        # -(NBOX)(DELTAT)   (GYRO PULSES) X 2(+14)
                
                TC      IRIGY           # COMPENSATE ACCELERATION TERMS
                
                CS      NBDY            # (GYRO PULSES)/(CS) X 2(-5)
                TC      DRIFTSUB        # -(NBDY)(DELTAT)   (GYRO PULSES) X 2(+14)
                
                TC      IRIGZ           # COMPENSATE ACCELERATION TERMS
                
                CA      NBDZ            # (GYRO PULSES)/(CS) X 2(-5)
                TC      DRIFTSUB        # +(NBDZ)(DELTAT)   (GYRO PULSES) X 2(+14)
                
                CCS     GCOMPSW         # ARE GYRO COMMANDS GREATER THAN 2 PULSES
                TCF     +2              # YES   SEND OUT GYRO TORQUING COMMANDS.
                TCF     IRIG1           # NO    RETURN
                
                CA      PRIO21          # PRIO GREATER THAN SERVICER
                TC      NOVAC           # SEND OUT GYRO TORQUING COMMANDS.
                EBANK=  NBDX
                2CADR   1/GYRO
                
                RELINT
IRIG1           CA      MODE            # RESTORE CALLERS EBANK
                TS      EBANK
                TCF     SWRETURN
                
IRIGX           EXTEND  
                QXCH    MPAC +2         # SAVE Q
                EXTEND
                DCS     DELVX           # (PIPA PULSES) X 2(+14)
                DXCH    MPAC
                CA      ADIAX           # (GYRO PULSES)/(PIPA PULSE) X 2(-6)            *
                TC      GCOMPSUB        # -(ADIAX)(PIPAX)          (GYRO PULSES) X 2(+14)
                
                EXTEND                  # 
                DCS     DELVY           #       (PIPA PULSES) X 2(+14)
                DXCH    MPAC            # 
                CS      ADSRAX          #       (GYRO PULSES)/(PIPA PULSE) X 2(-6)      *
                TC      GCOMPSUB        #       -(ADSRAX)(PIPAY)   (GYRO PULSES) X 2(+14)

#               EXTEND                  ***
#               DCS     DELVZ           ***     (PIPA PULSES) X 2(+14)
#               DXCH    MPAC            ***
#               CA      ADOAX           ***     (GYRO PULSES)/(PIPA PULSE) X 2(-6)      *
#               TC      GCOMPSUB        ***     -(ADOAX)(PIPAZ)    (GYRO PULSES) X 2(+14)

                TC      MPAC +2

IRIGY           EXTEND
                QXCH    MPAC +2         # SAVE Q
                EXTEND
                DCS     DELVY           # (PIPA PULSES) X 2(+14)
                DXCH    MPAC
                CA      ADIAY           # (GYRO PULSES)/(PIPA PULSE) X 2(-6)            *
                TC      GCOMPSUB        # -(ADIAY)(PIPAY)          (GYRO PULSES) X 2(+14)

                EXTEND
                DCS     DELVZ           # (PIPA PULSES) X 2(+14)
                DXCH    MPAC
                CS      ADSRAY          # (GYRO PULSES)/(PIPA PULSE) X 2(-6)            *
                TC      GCOMPSUB        # +(ADSRAY)(PIPAZ)              (GYRO PULSES) X 2(+14)

#               EXTEND                  ***
#               DCS     DELVX           ***     (PIPA PULSES) X 2(+14)
#               DXCH    MPAC            ***
#               CA      ADOAY           ***     (GYRO PULSES)/(PIPA PULSE) X 2(-6)      *
#               TC      GCOMPSUB        ***     -(ADOAY)(PIPAX)   (GYRO PULSES) X 2(+14)

                TC      MPAC +2

IRIGZ           EXTEND
                QXCH    MPAC +2         # SAVE Q
                EXTEND
                DCS     DELVY           # (PIPA PULSES) X 2(+14)
                DXCH    MPAC
                CA      ADSRAZ          # (GYRO PULSES)/(PIPA PULSE) X 2(-6)            *
                TC      GCOMPSUB        # -(ADSRAZ)(PIPAY)        (GYRO PULSES) X 2(+14)
                
                EXTEND
                DCS     DELVZ           # (PIPA PULSES) X 2(+14)
                DXCH    MPAC
                CA      ADIAZ           # (GYRO PULSES)/(PIPA PULSE) X 2(-6)            *
                TC      GCOMPSUB        # -(ADIAZ)(PIPAZ)          (GYRO PULSES) X 2(+14)
                
#               EXTEND                  ***
#               DCS     DELVX           ***     (PIPA PULSE) X 2(+14)
#               DXCH    MPAC            ***
#               CS      ADOAZ           ***     (GYRO PULSES)/(PIPA PULSE) X 2(-6)      *
#               TC      GCOMPSUB        ***     +(ADOAZ)(PIPAX)    (GYRO PULSES) X 2(+14)

                TC      MPAC +2

GCOMPSUB        XCH     MPAC            # ADIA OR ADSRA COEFFICIENT ARRIVES IN A
                EXTEND                  # C(MPAC) = (PIPA PULSES) X 2(+14)
                MP      MPAC            # (GYRO PULSES)/(PIPA PULSE) X 2(-6)            *
                DXCH    VBUF            # NOW = (GYRO PULSES) X 2(+8)                   *

                CA      MPAC +1         # MINOR PART PIPA PULSES
                EXTEND
                MP      MPAC            # ADIA OR ADSRA
                TS      L
                CAF     ZERO
                DAS     VBUF            # NOW = (GYRO PULSES) X 2(+8)                   *

                CA      VBUF            # PARTIAL RESULT - MAJOR
                EXTEND
                MP      BIT9            # SCALE 2(+6)   SHIFT RIGHT 6                   *
                INDEX   BUF             # RESULT = (GYRO PULSES) X 2(+14)
                DAS     GCOMP           # HI(ADIA)(PIPAI) OR HI(ADSRA)(PIPAI)

                CA      VBUF +1         # PARTIAL RESULT - MINOR
                EXTEND
                MP      BIT9            # SCALE 2(+6)   SHIFT RIGHT 6                   *
                TS      L
                CAF     ZERO
                INDEX   BUF             # RESULT = (GYRO PULSES) X 2(+14)
                DAS     GCOMP           # (ADIA)(PIPAI) OR (ADSRA)(PIPAI)

                TC      Q

DRIFTSUB        EXTEND
                QXCH    BUF +1

                EXTEND                  # C(A) = NBD    (GYRO PULSES)/(CS) X 2(-5)
                MP      1/PIPADT        # (CS) X 2(+8)  NOW (GYRO PULSES) X 2(+3)
                LXCH    MPAC +1         # SAVE FOR FRACTIONAL COMPENSATION
                EXTEND
                MP      BIT4            # SCALE 2(+11)  SHIFT RIGHT 11
                INDEX   BUF
                DAS     GCOMP           # HI(NBD)(DELTAT)       (GYRO PULSES) X 2(+14)
                
                CA      MPAC +1         # NOW MINOR PART
                EXTEND
                MP      BIT4            # SCALE 2(+11)          SHIFT RIGHT 11
                TS      L
                CAF     ZERO
                INDEX   BUF             # ADD IN FRACTIONAL COMPENSATION
                DAS     GCOMP           # (NBD)(DELTAT)         (GYRO PULSES) X 2(+14)
                
DRFTSUB2        CAF     TWO             # PIPAX, PIPAY, PIPAZ
                AD      BUF
                XCH     BUF
                INDEX   A
                CCS     GCOMP           # ARE GYRO COMMANDS 1 PULSE OR GREATER
                TCF     +2              # YES
                TC      BUF +1          # NO
                
                MASK    COMPCHK         # DEC -1
                CCS     A               # ARE GYRO COMMANDS GREATER THAN 2 PULSES
                TS      GCOMPSW         # YES - SET GCOMPSW POSITIVE
                TC      BUF +1          # NO
                
1/GYRO          CAF     FOUR            # PIPAZ, PIPAY, PIPAX
                TS      BUF
                
                INDEX   BUF             # SCALE GYRO COMMANDS FOR IMUPULSE
                CA      GCOMP +1        # FRACTIONAL PULSES
                EXTEND
                MP      BIT8            # SHIFT RIGHT 7
                INDEX   BUF
                TS      GCOMP +1        # FRACTIONAL PULSES SCALED
                
                CAF     ZERO            # SET GCOMP = 0 FOR DAS INSTRUCTION
                INDEX   BUF
                XCH     GCOMP           # GYRO PULSES
                EXTEND
                MP      BIT8            # SHIFT RIGHT 7
                INDEX   BUF
                DAS     GCOMP           # ADD THESE TO FRACTIONAL PULSES ABOVE
                
                CCS     BUF             # PIPAZ, PIPAY, PIPAX
                AD      NEG1
                TCF     1/GYRO +1
LGCOMP          ECADR   GCOMP           # LESS THAN ZERO IMPOSSIBLE

                CAF     LGCOMP
                TC      BANKCALL
                CADR    IMUPULSE        # CALL GYRO TORQUING ROUTINE
                TC      BANKCALL
                CADR    IMUSTALL        # WAIT FOR PULSES TO GET OUT
                TCF     ENDOFJOB        # TEMPORARY
                
GCOMP1          CAF     FOUR            # PIPAZ, PIPAY, PIPAX
                TS      BUF
                
                INDEX   BUF             # RESCALE
                CA      GCOMP +1
                EXTEND
                MP      BIT8            # SHIFT MINOR PART LEFT 7 - MAJOR PART = 0
                INDEX   BUF
                LXCH    GCOMP +1        # BITS 8-14 OF MINOR PART WERE = 0
                
                CCS     BUF             # PIPAZ, PIPAY, PIPAX
                AD      NEG1
                TCF     GCOMP1 +1
COMPCHK         DEC     -1              # LESS THAN ZERO IMPOSSIBLE
                TCF     ENDOFJOB
                
NBDONLY         CCS     GCOMPSW         # BYPASS IF GCOMPSW NEGATIVE
                TCF     +3
                TCF     +2
                TCF     ENDOFJOB

                INHINT
                CCS     FLAGWRD2        # PREREAD T3RUPT MAY COINCIDE
                TCF     ENDOFJOB
                TCF     ENDOFJOB
                TCF     +1
                
                CA      FLAGWRD8        # IF SURFACE FLAG IS SET, SET TEM1
                MASK    BIT8            # POSITIVE SO THAT THE ACCELERATION TERMS
                TS      TEM1            # WILL BE COMPENSATED.
                EXTEND
                BZF     +3              # ARE WE ON THE SURFACE
                
                TC      IBNKCALL        # ON THE SURFACE
                CADR    PIPASR +3       # READ PIPAS, BUT DO NOT SCALE THEM
                
                CA      TIME1           # (CS) X 2(+14)
                XCH     1/PIPADT        # PREVIOUS TIME
                RELINT
                COM
                AD      1/PIPADT        # PRESENT TIME - PREVIOUS TIME
NBD2            AD      HALF            # CORRECT FOR POSSIBLE TIME1 TICK
                AD      HALF
                XCH     L               # IF TIME1 DID NOT TICK, REMOVE RESULTING
                XCH     L               # OVERFLOW.
                
NBD3            EXTEND                  # C(A) = DELTAT         (CS) X 2(+14)
                MP      BIT10           # SHIFT RIGHT 5
                DXCH    VBUF +2
                
                CA      ZERO
                TS      GCOMPSW         # INDICATE COMMANDS 2 PULSES OR LESS.
                TS      BUF             # INDEX  X, Y, Z.
                
                CCS     TEM1            # IF SURFACE FLAG IS SET,
                TC      IRIGX           # COMPENSATE ACCELERATION TERMS.
                
                EXTEND
                DCA     VBUF +2
                DXCH    MPAC            # DELTAT NOW SCALED (CS) X 2(+19)
                
                CS      NBDX            # (GYRO PULSES)/(CS) X 2(-5)
                TC      FBIASSUB        # -(NBOX)(DELTAT)       (GYRO PULSES) X 2(+14)
                
                CCS     TEM1            # IF SURFACE FLAG IS SET,
                TC      IRIGY           # COMPENSATE ACCELERATION TERMS.
                EXTEND
                DCS     VBUF +2
                DXCH    MPAC            # DELTAT SCALED (CS) X 2(+19)
                CA      NBDY            # (GYRO PULSES)/(CS) X 2(-5)
                TC      FBIASSUB        # -(NBDY)(DELTAT)       (GYRO PULSES) X 2(+14)
                
                CCS     TEM1            # IF SURFACE FLAG IS SET,
                TC      IRIGZ           # COMPENSATE ACCELERATION TERMS
                
                EXTEND
                DCS     VBUF +2
                DXCH    MPAC            # DELTAT SCALED (CS) X 2(+19)
                CS      NBDZ            # (GYRO PULSES)/(CS) X 2(-5)
                TC      FBIASSUB        # +(NBDZ)(DELTAT)       (GYRO PULSES) X 2(+14)
                
                CCS     GCOMPSW         # ARE GYRO COMMANDS GREATER THAN 2 PULSES
                TCF     1/GYRO          # YES
                TCF     ENDOFJOB        # NO

FBIASSUB        XCH     Q
                TS      BUF +1
                
                CA      Q               # NBD SCALED (GYRO PULSES)/(CS) X 2(-5)
                EXTEND
                MP      MPAC            # DELTAT SCALED (CS) X 2(+19)
                INDEX   BUF
                DAS     GCOMP           # HI(NBD)(DELTAT)       (GYRO PULSES) X 2(+14)
                
                CA      Q               # NOW FRACTIONAL PART
                EXTEND
                MP      MPAC +1
                TS      L
                CAF     ZERO
                INDEX   BUF
                DAS     GCOMP           # (NBD)(DELTAT)         (GYRO PULSES) X 2(+14)
                
                TCF     DRFTSUB2        # CHECK MAGNITUDE OF COMPENSATION


NORMBIAS        CAF     TWO
                TC      NEWPHASE
                OCT     5
                INHINT
                CAF     PRIO20
                TC      FINDVAC
                EBANK=  DVCNTR
                2CADR   NORMLIZE
                
LASTBIAS        TC      BANKCALL
                CADR    PIPUSE1
                
                CCS     GCOMPSW
                TCF     +3
                TCF     +2
                TCF     ENDOFJOB
                
                CA      FLAGWRD8        # IF SURFACE FLAG IS SET, SET TEM1
                MASK    SURFFBIT        # POSITIVE SO THAT THE ACCELERATION TERMS
                TS      TEM1            # WILL BE COMPENSATED.

                CAF     PRIO31          # 2 SECONDS SCALED (CS) X 2(+8)
                XCH     1/PIPADT
                COM
                AD      PIPTIME +1
                TCF     NBD2
                
GCOMPZER        CAF     LGCOMP          # ROUTINE TO ZERO GCOMP BEFORE FIRST
                XCH     EBANK           # CALL TO 1/PIPA
                TS      MODE
                
                CAF     ZERO
                TS      GCOMPSW
                TS      GCOMP
                TS      GCOMP +1
                TS      GCOMP +2
                TS      GCOMP +3
                TS      GCOMP +4
                TS      GCOMP +5
                
                TCF     IRIG1           # RESTORE EBANK AND RETURN
                

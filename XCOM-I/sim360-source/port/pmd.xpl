   /********************************************************************
   *                                                                   *
   *                  STONY BROOK PASCAL 360 COMPILER                  *
   *                   POST MORTEM ANALYSIS ROUTINES                   *
   *                                                                   *
   ********************************************************************/

   /*

   COPYRIGHT (C) 1976 DEPARTMENT OF COMPUTER SCIENCE, SUNY AT STONY BROOK.

   */



   /* THE FOLLOWING VARIABLES ARE INITIALIZED FROM THE STATUS BLOCK, WHOSE
         ADDRESS IS INSERTED BY THE RUN MONITOR INTO MONITOR_LINK(3):
      AR_BASE_ADDR IS THE ADDRESS OF THE GLOBAL ACTIVATION RECORD.
      ORIGIN_ADDR IS THE ADDRESS OF THE ORG SEGMENT.
      TRANSFER_VECTOR_BASE_ADDR IS THE ADDRESS OF THE ORG SEGMENT TRANSFER
         VECTOR, WHICH CONTAINS THE ADDRESS OF EACH PASCAL BLOCK ENTRY POINT.
      CODE_SEG_BASE_ADDR IS THE ADDRESS OF THE PASCAL CODE SEGMENT, OVER WHICH
         THIS CODE IS OVERLAYED.
      EXECUTION_TIME IS THE CPU TIME, IN UNITS OF 0.01 SECONDS, USED BY THE
         PASCAL PROGRAM.
      ERROR_LINE IS THE SOURCE LINE NUMBER CORRESPONDING TO A RUN ERROR;
         ZERO IF THE PASCAL PROGRAM TERMINATED NORMALLY.
      CORETOP IS THE LAST ADDRESS IN THE REGION.  THE VALUE OF CORETOP
         BECOMES 'FREELIMIT' AT FLOW_SUMMARY TIME, THUS CLOBBERING THE
         ACTIVATION RECORD STACK AS WELL AS THE HEAP.
      ERROR_ADDRESS IS THE ADDRESS CORRESPONDING TO A RUN ERROR;
         UNDEFINED IF THE PASCAL PROGRAM TERMINATED NORMALLY.
   */
DECLARE (AR_BASE_ADDR, ORIGIN_ADDR, TRANSFER_VECTOR_BASE_ADDR,
   CODE_SEG_BASE_ADDR, EXECUTION_TIME, ERROR_LINE, CORETOP,
   ERROR_ADDRESS) FIXED;

   /* PASCAL_REGS IS THE ADDRESS OF A LOCATION IN THE ORG SEGMENT WHERE THE
         PASCAL REGISTERS ARE SAVED IN THE ORDER 11..15, 0..10.
      BLOCK_COUNTER_BASE_ADDR IS THE ADDRESS OF ANOTHER LOCATION IN THE ORG
         SEGMENT, WHERE THE BASIC BLOCK EXECUTION COUNTERS USED IN THE FLOW
         SUMMARY ARE FOUND.
   */
DECLARE (PASCAL_REGS, BLOCK_COUNTER_BASE_ADDR) FIXED;

   /* THE VALUES OF THE ABOVE VARIABLES ARE SET IN INITIALIZE, AND REMAIN
      CONSTANT THEREAFTER.
   */

   /* SOME COMMONLY USED EUPHAMISMS */
DECLARE FALSE LITERALLY '0', TRUE LITERALLY '1', FOREVER LITERALLY 'WHILE 1',
   REAL LITERALLY 'FIXED', FPR LITERALLY '6', NULL LITERALLY '-1',
   PRINT_BLANK_LINE LITERALLY 'OUTPUT = ''''',
   DEBUG_LEVEL LITERALLY 'MONITOR_LINK(2)';

   /* MAX_STRING_LENGTH IS THE MAXIMUM LENGTH OF AN XPL CHARACTER STRING.
   */
DECLARE MAX_STRING_LENGTH LITERALLY '256';

   /* SOME COMMONLY USED CONSTANT STRINGS */
DECLARE X1 CHARACTER INITIAL(' '), X70 CHARACTER INITIAL(
   '                                                                      ');
DECLARE HEX_DIGITS CHARACTER INITIAL('0123456789ABCDEF');

   /* THE FLOATING-POINT POWERS OF TEN(LONG).  TWO ADJACENT ENTRIES IN 'POWERS'
      (EVEN-ODD) FORM ONE DOUBLE-PRECISION REAL.
   */
DECLARE POWERS(307) REAL INITIAL(
   "001DA48C", "E468E7C7", "011286D8", "0EC190DC", "01B94470", "938FA898",
   "0273CAC6", "5C39C960", "03485EBB", "F9A41DDC", "042D3B35", "7C0692AA",
   "051C4501", "6D841BAA", "0611AB20", "E472914A", "06B0AF48", "EC79ACE8",
   "076E6D8D", "93CC0C10", "08450478", "7C5F878C", "092B22CB", "4DBBB4B6",
   "0A1AF5BF", "109550F2", "0B10D997", "6A5D5297", "0BA87FEA", "27A539E8",
   "0C694FF2", "58C74434", "0D41D1F7", "777C8AA0", "0E29233A", "AAADD6A4",
   "0F19B604", "AAACA626", "101011C2", "EAABE7D8", "10A0B19D", "2AB70E70",
   "11646F02", "3AB26904", "123EC561", "64AF81A4", "13273B5C", "DEEDB106",
   "1418851A", "0B548EA4", "14F53304", "714D9268", "15993FE2", "C6D07B80",
   "165FC7ED", "BC424D30", "173BDCF4", "95A9703E", "18256A18", "DD89E626",
   "1917624F", "8A762FD8", "19E9D71B", "689DDE70", "1A922671", "2162AB08",
   "1B5B5806", "B4DDAAE4", "1C391704", "310A8ACE", "1D23AE62", "9EA696C2",
   "1E164CFD", "A3281E39", "1EDF01E8", "5F912E38", "1F8B6131", "3BBABCE0",
   "20571CBE", "C554B60C", "213671F7", "3B54F1C8", "2222073A", "8515171E",
   "23154484", "932D2E72", "23D4AD2D", "BFC3D078", "2484EC3C", "97DA6248",
   "255313A5", "DEE87D70", "2633EC47", "AB514E66", "272073AC", "CB12D100",
   "2814484B", "FEEBC2A0", "28CAD2F7", "F5359A38", "297EC3DA", "F9418064",
   "2A4F3A68", "DBC8F040", "2B318481", "895D9628", "2C1EF2D0", "F5DA7DD9",
   "2D1357C2", "99A88EA7", "2DC16D9A", "00959288", "2E78E480", "405D7B98",
   "2F4B8ED0", "283A6D3C", "302F3942", "19248446", "311D83C9", "4FB6D2AC",
   "3212725D", "D1D243AC", "32B877AA", "3236A4B8", "33734ACA", "5F6226F0",
   "34480EBE", "7B9D5858", "352D0937", "0D425736", "361C25C2", "68497682",
   "37119799", "812DEA11", "37AFEBFF", "0BCB24A8", "386DF37F", "675EF6EC",
   "3944B82F", "A09B5A54", "3A2AF31D", "C4611874", "3B1AD7F2", "9ABCAF48",
   "3C10C6F7", "A0B5ED8D", "3CA7C5AC", "471B4788", "3D68DB8B", "AC710CB4",
   "3E418937", "4BC6A7F0", "3F28F5C2", "8F5C28F6", "40199999", "9999999A",
   "41100000", "00000000", "41A00000", "00000000", "42640000", "00000000",
   "433E8000", "00000000", "44271000", "00000000", "45186A00", "00000000",
   "45F42400", "00000000", "46989680", "00000000", "475F5E10", "00000000",
   "483B9ACA", "00000000", "492540BE", "40000000", "4A174876", "E8000000",
   "4AE8D4A5", "10000000", "4B9184E7", "2A000000", "4C5AF310", "7A400000",
   "4D38D7EA", "4C680000", "4E2386F2", "6FC10000", "4F163457", "85D8A000",
   "4FDE0B6B", "3A764000", "508AC723", "0489E800", "5156BC75", "E2D63100",
   "523635C9", "ADC5DEA0", "5321E19E", "0C9BAB24", "54152D02", "C7E14AF6",
   "54D3C21B", "CECCEDA0", "55845951", "61401488", "5652B7D2", "DCC80CD4",
   "5733B2E3", "C9FD0804", "58204FCE", "5E3E2502", "591431E0", "FAE6D721",
   "59C9F2C9", "CD046750", "5A7E37BE", "2022C090", "5B4EE2D6", "D415B85C",
   "5C314DC6", "448D9338", "5D1ED09B", "EAD87C03", "5E134261", "72C74D82",
   "5EC097CE", "7BC90718", "5F785EE1", "0D5DA46C", "604B3B4C", "A85A86C4",
   "612F050F", "E938943A", "621D6329", "F1C35CA5", "63125DFA", "371A19E7",
   "63B7ABC6", "27050308", "6472CB5B", "D86321E4", "6547BF19", "673DF530",
   "662CD76F", "E086B93C", "671C06A5", "EC5433C6", "68118427", "B3B4A05C",
   "68AF298D", "050E4398", "696D79F8", "2328EA3C", "6A446C3B", "15F99268",
   "6B2AC3A4", "EDBBFB80", "6C1ABA47", "14957D30", "6D10B46C", "6CDD6E3E",
   "6DA70C3C", "40A64E70", "6E6867A5", "A867F104", "6F4140C7", "8940F6A4",
   "7028C87C", "B5C89A26", "71197D4D", "F19D6057", "71FEE50B", "7025C368",
   "729F4F27", "26179A20", "73639178", "77CEC054", "743E3AEB", "4AE13836",
   "7526E4D3", "0ECCC322", "76184F03", "E93FF9F5", "76F31627", "1C7FC390",
   "7797EDD8", "71CFDA38", "785EF4A7", "4721E864", "793B58E8", "8C75313E",
   "7A251791", "57C93EC8", "7B172EBA", "D6DDC73D", "7BE7D34C", "64A9C860",
   "7C90E40F", "BEEA1D38", "7D5A8E89", "D7525244", "7E389916", "2693736A",
   "7F235FAD", "D81C2822");

  /* THESE VARIABLES ARE USED BY FLOATING POINT INSTRUCTIONS WHICH REQUIRE
     DOUBLEWORD ALIGNMENT.  HOWEVER XPL DOES NOT SUPPORT DOUBLEWORD ALIGNMENT.
     THE VARIABLES ARE INDEX BY BYTE_OFFSET AND FLOAT_INDEX:
     BYTE_OFFSET - HOLDS THE NUMBER ZERO OR FOUR DEPENDING ON ALIGNMENT.
     FLOAT_INDEX - HOLDS THE NUMBER ZERO OR ONE DEPENDING ON ALIGNMENT.
     THE DOUBLEWORD VARIABLES MAY SPILL OVER INTO THE MUST_BE_LAST() ARRAY.
     ADDITIONAL VARIABLES SHOULD BE INSERTED BEFORE MUST_BE_LAST().
  */
DECLARE (BYTE_OFFSET, FLOAT_INDEX) FIXED,
   WORK(1) REAL,
   ZERO(1) REAL,
   MUST_BE_LAST(2) REAL;


   /*   P R O C E D U R E S   */

PAD:
PROCEDURE(STRING, WIDTH) CHARACTER;
   DECLARE STRING CHARACTER, (WIDTH, L) FIXED;

   L = WIDTH - LENGTH(STRING);
   DO WHILE L >= LENGTH(X70);
      STRING = STRING || X70;
      L = L - LENGTH(X70);
   END;
   IF L <= 0 THEN RETURN STRING;
   RETURN STRING || SUBSTR(X70, 0, L);
END PAD;

HEX:
PROCEDURE(X) CHARACTER;
   DECLARE S CHARACTER, (I, X) FIXED;

   S = '';
   DO I = 0 TO 28 BY 4;
      S = S || SUBSTR(HEX_DIGITS, SHR(X, 28 - I) & 15, 1);
   END;
   RETURN S;
END HEX;

Z_FORMAT:
PROCEDURE(NUMBER, WIDTH) CHARACTER;
   DECLARE (NUMBER, WIDTH, L) FIXED, STRING CHARACTER;
   STRING = NUMBER;
   L = LENGTH(STRING);
   IF L >= WIDTH THEN RETURN STRING;
   RETURN SUBSTR('00000000000', 0, WIDTH - L) || STRING;
END Z_FORMAT;

LOAD_FLOAT:
PROCEDURE(NUMBER);
   DECLARE NUMBER REAL;
   CALL INLINE("2B", FPR, FPR);                  /* SDR  FPR,FPR           */
   CALL INLINE("78", FPR, 0, NUMBER);            /* LE   FPR,NUMBER        */
END LOAD_FLOAT;

DIVIDE_BY_POWER:
PROCEDURE(X);
   DECLARE X FIXED;
   /* DIVIDE THE NUMBER IN FPR BY POWERS(X) */
   WORK(FLOAT_INDEX) = POWERS(X);
   WORK(FLOAT_INDEX + 1) = POWERS(X + 1);
   CALL INLINE("58", 2, 0, BYTE_OFFSET);         /* L    2,BYTE_OFFSET     */
   CALL INLINE("6D", FPR, 2, WORK);              /* DD   FPR,WORK(2)       */
   CALL INLINE("60", FPR, 2, WORK);              /* STD  FPR,WORK(2)       */
END DIVIDE_BY_POWER;

CONVERT_TO_INTEGER:
PROCEDURE FIXED;
   /* CONVERT THE FLOATING POINT NUMBER IN FPR TO AN INTEGER.  */
   CALL INLINE("58", 2, 0, BYTE_OFFSET);         /* L    2,BYTE_OFFSET     */
   CALL INLINE("6E", FPR, 2, ZERO);              /* AW   FPR,ZERO(2)       */
   CALL INLINE("60", FPR, 2, WORK);              /* STD  FPR,WORK(2)       */
   RETURN WORK(FLOAT_INDEX + 1);
END CONVERT_TO_INTEGER;

E_FORMAT:
PROCEDURE(NUMBER, WIDTH) CHARACTER;
   DECLARE (NUMBER, MANTISSA) FIXED;
   DECLARE (WIDTH, EXPONENT, I, J, X) BIT(16);
   DECLARE (S, S1) CHARACTER;
   DECLARE ROUND(14) FIXED INITIAL(0, 0, 0, 0, 0, 0, 0, 0, 
      500000, 50000, 5000, 500, 50, 5, 0);

   /* MINIMUM FIELD IS B+9.9E+99 */
   IF WIDTH < 9 THEN WIDTH = 9;
   /* MAXIMUM 7 SIGNIFICANT DIGITS */
   IF WIDTH > 13 THEN
      DO;
         X = WIDTH - 12;
         WIDTH = 13;
      END;
   ELSE X = 1;  /* MUST HAVE ONE LEADING BLANK */
   IF NUMBER < 0 THEN
      DO;
         S = SUBSTR(X70, 0, X) || '-';
         NUMBER = NUMBER & "7FFFFFFF";
      END;
   ELSE S = SUBSTR(X70, 0, X + 1);
   IF (NUMBER & "00FFFFFF") = 0 THEN
      RETURN S || SUBSTR('0.0000000', 0, WIDTH - 6) || 'E+00';
   CALL LOAD_FLOAT(NUMBER);
   IF NUMBER < POWERS(12)  /* 10**-72 */ THEN
      DO;
         CALL DIVIDE_BY_POWER(0);
         NUMBER = WORK(FLOAT_INDEX);
         /* NUMBER = NUMBER / 10**-78 */
         EXPONENT = -78;
      END;
   ELSE EXPONENT = 0;
   /* NOW BINARY-SEARCH THE ARRAY POWERS TO FIND X SUCH THAT
            10**X  <=  NUMBER  <  10**(X+1)  .   */
   I = 0;   J = 306;   X = 152;
   DO WHILE I <= J;
      IF POWERS(X) <= NUMBER THEN I = X + 2;
      ELSE J = X - 2;
      X = SHR(I + J, 1) & "FFFE";
   END;
   CALL DIVIDE_BY_POWER(X - 12);
   MANTISSA = CONVERT_TO_INTEGER + ROUND(WIDTH);
   EXPONENT = EXPONENT + SHR(X, 1) - 78;
   S1 = Z_FORMAT(MANTISSA, 7);
   I = LENGTH(S1) - 6;
   S1 = SUBSTR(S1, 0, I) || '.' || SUBSTR(S1, I);
   S = S || SUBSTR(S1, 0, WIDTH - 6);
   IF EXPONENT >= 0 THEN S = S || 'E+';
   ELSE
      DO;
         S = S || 'E-';
         EXPONENT = -EXPONENT;
      END;
   IF EXPONENT < 10 THEN RETURN S || '0' || EXPONENT;
   ELSE RETURN S || EXPONENT;
END E_FORMAT;

REWIND:
PROCEDURE(IS_OUTPUT_FILE, FILE#);
   DECLARE IS_OUTPUT_FILE BIT(1), FILE# FIXED;
   CALL INLINE("1B", 0, 0);                     /* SR   0,0              */
   CALL INLINE("43", 0, 0, IS_OUTPUT_FILE);     /* IC   0,IS_OUTPUT_FILE */
   CALL INLINE("41", 1, 0, 0, 28);              /* LA   1,28             */
   CALL INLINE("58", 2, 0, FILE#);              /* L    2,FILE#          */
   CALL INLINE("05", 12, 15);                   /* BALR 12,15            */
END REWIND;

PRINT_TIME:
PROCEDURE(TIME, MESSAGE);
   DECLARE (TIME, L) FIXED, (MESSAGE, STRING) CHARACTER;
   STRING = Z_FORMAT(TIME, 5);
   L = LENGTH(STRING);
   STRING = SUBSTR(STRING, 0, L - 2) || '.' || SUBSTR(STRING, L - 2, 2);
   OUTPUT = STRING || MESSAGE;
END PRINT_TIME;

SOURCE_LINE:
PROCEDURE(ABSOLUTE_ADDRESS) FIXED;
   DECLARE (ABSOLUTE_ADDRESS, RELATIVE_ADDRESS, LINE#, I) FIXED,
      LINES(19) FIXED, BUFFER CHARACTER;
   DECLARE LINE#_FILE FIXED INITIAL(5);
   LINE# = 0;
   IF (ABSOLUTE_ADDRESS < CODE_SEG_BASE_ADDR)
      | (ABSOLUTE_ADDRESS >= AR_BASE_ADDR) THEN
      RETURN 0;
   RELATIVE_ADDRESS = ABSOLUTE_ADDRESS - CODE_SEG_BASE_ADDR;
   BUFFER = INPUT(LINE#_FILE);
   CALL INLINE("58", 1, 0, BUFFER);              /* L    1,BUFFER         */
   CALL INLINE("41", 2, 0, LINES);               /* LA   2,LINES          */
   CALL INLINE("D2", "4", "F", 2, 0, 1, 0);      /* MVC  0(80,2),0(1)     */
   DO WHILE (BYTE(BUFFER) ~= BYTE('%')) & (LINES(19) <= RELATIVE_ADDRESS);
      LINE# = LINE# + 20;
      BUFFER = INPUT(LINE#_FILE);
      CALL INLINE("58", 1, 0, BUFFER);           /* L    1,BUFFER         */
      CALL INLINE("41", 2, 0, LINES);            /* LA   2,LINES          */
      CALL INLINE("D2", "4", "F", 2, 0, 1, 0);   /* MVC  0(80,2),0(1)     */
   END;
   CALL REWIND(FALSE, LINE#_FILE);
   IF BYTE(BUFFER) = BYTE('%') THEN
      RETURN LINE#;
   I = 18;
   DO WHILE (I >= 0) & (LINES(I) > RELATIVE_ADDRESS);
      I = I - 1;
   END;
   RETURN LINE# + I + 1;
END SOURCE_LINE;

INITIALIZE:
PROCEDURE;
   DECLARE I FIXED;
   I = SHR(MONITOR_LINK(3), 2);
   AR_BASE_ADDR = COREWORD(I);
   ORIGIN_ADDR = COREWORD(I + 1);
   TRANSFER_VECTOR_BASE_ADDR = COREWORD(I + 2);
   CODE_SEG_BASE_ADDR = COREWORD(I + 3);
   EXECUTION_TIME = COREWORD(I + 4);
   ERROR_LINE = COREWORD(I + 5);
   CORETOP = COREWORD(I + 6);
   ERROR_ADDRESS = COREWORD(I + 7);
   IF ERROR_LINE = "7FFFFFFF" THEN
      ERROR_LINE = SOURCE_LINE(ERROR_ADDRESS);
   PASCAL_REGS = ORIGIN_ADDR + 208;
   BLOCK_COUNTER_BASE_ADDR = ORIGIN_ADDR + 308;

   BYTE_OFFSET = ADDR(WORK) & 7;
   FLOAT_INDEX = SHR(BYTE_OFFSET, 2);
   ZERO(FLOAT_INDEX) = "4E000000";
   ZERO(FLOAT_INDEX + 1) = 0;
END INITIALIZE;

POST_MORTEM_DUMP:
PROCEDURE;
   /* THE PMD TABLES */
   DECLARE SYTSIZE LITERALLY '255';
   DECLARE IDENTITY(SYTSIZE) CHARACTER,
      DATATYPE(SYTSIZE) BIT(16),
      VAR_TYPE(SYTSIZE) BIT(16),
      STRUCTYPE(SYTSIZE) BIT(16),
      STORAGE_LNGTH(SYTSIZE) BIT(16),
      S_LIST(SYTSIZE) BIT(16),
      DISPLACEMENT(SYTSIZE) FIXED,
      VALUE(SYTSIZE) FIXED;
   DECLARE PROCMAX LITERALLY '127';
   DECLARE PROC_HEAD(PROCMAX) FIXED;

   /* VAR_TYPE CODES ENCOUNTERED IN PMD TABLES */
   DECLARE VARIABLE BIT(16) INITIAL(1),
      CONSTANT      BIT(16) INITIAL(2),
      TYPE          BIT(16) INITIAL(4),
      PROC          BIT(16) INITIAL(5);

   /* STRUCTYPE CODES ENCOUNTERED IN PMD TABLES */
   DECLARE STATEMENT BIT(16) INITIAL(0),
      SCALAR         BIT(16) INITIAL(1),
      SUBRANGE       BIT(16) INITIAL(2),
      POINTER        BIT(16) INITIAL(3),
      ARRAY          BIT(16) INITIAL(4),
      ARITHMETIC     BIT(16) INITIAL(14);

   /* POINTERS INTO THE PMD TABLES TO THE PREDECLARED TYPES */
   DECLARE INTPTR BIT(16) INITIAL(2),
      BOOLPTR     BIT(16) INITIAL(3),
      REALPTR     BIT(16) INITIAL(4),
      CHARPTR     BIT(16) INITIAL(5);

   DECLARE FATAL_ERROR BIT(1),
      (THIS_PROC, N_DECL_SYMB, PROC_SEQUENCE_NUMBER) BIT(16),
      (CBR, ARBASE, GLOBAL_ARBASE, CALLED_FROM_ADDR) FIXED;

INITIALIZE_PMD_TABLES:
   PROCEDURE;
      DECLARE PMD_FILE BIT(16) INITIAL(6),
         BUFFER CHARACTER,
         I FIXED;

   NEXT_SYMBOL:
      PROCEDURE CHARACTER;
         DECLARE S CHARACTER;
         IF LENGTH(BUFFER) < 12 THEN
            BUFFER = BUFFER || INPUT(PMD_FILE);
         S = SUBSTR(BUFFER, 0, 12);
         BUFFER = SUBSTR(BUFFER, 12);
         RETURN S;
      END NEXT_SYMBOL;

   READ_COLUMN:
      PROCEDURE(ARRAY_ADDR, BYTES_PER_ITEM, LIMIT);
         DECLARE (BYTES_PER_ITEM, LIMIT) BIT(16),
            (ARRAY_ADDR, INCREMENT, I, J, K) FIXED,
            MOVE(2) BIT(16) INITIAL("D200", "2000", "1000");
         INCREMENT = 80 / BYTES_PER_ITEM;
         J = ARRAY_ADDR;
         I = 0;
         DO WHILE I + INCREMENT <= LIMIT;
            CALL INLINE("58", 1, 0, BUFFER);        /* L    1,BUFFER          */
            CALL INLINE("58", 2, 0, J);             /* L    2,J               */
          CALL INLINE("D2", "4", "F", 2, 0, 1, 0);  /* MVC  0(80,2),0(1)      */
            I = I + INCREMENT;
            J = J + 80;
            BUFFER = INPUT(PMD_FILE);
         END;
         K = (LIMIT - I + 1) * BYTES_PER_ITEM - 1;
         CALL INLINE("58", 1, 0, BUFFER);        /* L    1,BUFFER          */
         CALL INLINE("58", 2, 0, J);             /* L    2,J               */
         CALL INLINE("58", 3, 0, K);             /* L    3,K               */
         CALL INLINE("44", 3, 0, MOVE);          /* EX   3,MOVE            */
         BUFFER = INPUT(PMD_FILE);
      END READ_COLUMN;

      N_DECL_SYMB, PROC_SEQUENCE_NUMBER = 0;
      BUFFER = INPUT(PMD_FILE);
      IF SUBSTR(BUFFER, 0, 5) ~= '%PMD ' THEN
         DO;
            OUTPUT = '%PMD CARD EXPECTED';
            FATAL_ERROR = TRUE;
            RETURN;
         END;
      DO I = 5 TO 9;
         IF BYTE(BUFFER, I) ~= BYTE(' ') THEN
            N_DECL_SYMB = 10 * N_DECL_SYMB + BYTE(BUFFER, I) - BYTE('0');
      END;
      DO I = 10 TO 14;
         IF BYTE(BUFFER, I) ~= BYTE(' ') THEN
            PROC_SEQUENCE_NUMBER =
               10 * PROC_SEQUENCE_NUMBER + BYTE(BUFFER, I) - BYTE('0');
      END;
      IF (N_DECL_SYMB > SYTSIZE) | (PROC_SEQUENCE_NUMBER > PROCMAX) THEN
         DO;
            OUTPUT = 'PMD TABLE OVERFLOW';
            FATAL_ERROR = TRUE;
            RETURN;
         END;
      BUFFER = INPUT(PMD_FILE);
      DO I = 0 TO N_DECL_SYMB;
         IDENTITY(I) = NEXT_SYMBOL;
      END;
      BUFFER = INPUT(PMD_FILE);
      CALL READ_COLUMN(ADDR(DATATYPE), 2, N_DECL_SYMB);
      CALL READ_COLUMN(ADDR(VAR_TYPE), 2, N_DECL_SYMB);
      CALL READ_COLUMN(ADDR(STRUCTYPE), 2, N_DECL_SYMB);
      CALL READ_COLUMN(ADDR(STORAGE_LNGTH), 2, N_DECL_SYMB);
      CALL READ_COLUMN(ADDR(S_LIST), 2, N_DECL_SYMB);
      CALL READ_COLUMN(ADDR(DISPLACEMENT), 4, N_DECL_SYMB);
      CALL READ_COLUMN(ADDR(VALUE), 4, N_DECL_SYMB);
      CALL READ_COLUMN(ADDR(PROC_HEAD), 4, PROC_SEQUENCE_NUMBER);
      IF SUBSTR(BUFFER, 0, 4) ~= '%END' THEN
         DO;
            OUTPUT = '%END CARD EXPECTED';
            FATAL_ERROR = TRUE;
         END;
   END INITIALIZE_PMD_TABLES;

INITIALIZE_PMD_POINTERS:
   PROCEDURE;
      GLOBAL_ARBASE = AR_BASE_ADDR;
      ARBASE = COREWORD(SHR(PASCAL_REGS, 2)) & "00FFFFFF";
      CBR = COREWORD(SHR(PASCAL_REGS, 2) + 1) & "00FFFFFF";
      FATAL_ERROR = (CBR < CODE_SEG_BASE_ADDR) | (CBR > GLOBAL_ARBASE)
         | (ARBASE < GLOBAL_ARBASE)
         | (ARBASE >= CORETOP);
   END INITIALIZE_PMD_POINTERS;

FINDPROC:
   PROCEDURE(CBR) BIT(16);
      /* RETURNS SEQUENCE # OF CODE BLOCK WHOSE ENTRY POINT ADDRESS
            IS IN CBR. */
      DECLARE CBR FIXED, SEQ# BIT(16);
      DO SEQ# = 0 TO PROC_SEQUENCE_NUMBER;
         /* SEARCH THE TRANSFER VECTOR. */
         IF CBR = COREWORD(SHR(TRANSFER_VECTOR_BASE_ADDR, 2) + SEQ#) THEN
            RETURN SEQ#;
      END;
      /* CBR IS NOT A VALID ENTRY POINT. */
      RETURN NULL;
   END FINDPROC;

DUMP_LOCAL_VARIABLES:
   PROCEDURE(SEQ#);
      DECLARE (SEQ#, #ACTIVATIONS, VAR_PTR, PROC_PTR, L) BIT(16),
         (VAR_VALUE, VAR_ADDR, I, B) FIXED,
         (LINE, S) CHARACTER,
         MAX_DUMPS LITERALLY '5';

   TAB:
      PROCEDURE;
         /* AFTER EXECUTION OF THIS PROCEDURE,
               LENGTH(LINE) IN (.1, 33, 65, 97.) */
         DECLARE (L1, L2) BIT(16);
         L1 = LENGTH(LINE);
         L2 = (L1 - 1) MOD 32;
         IF (L1 < 97) & (L2 ~= 0) THEN
            LINE = LINE || SUBSTR(X70, 0, 32 - L2);
         ELSE IF L1 > 97 THEN
            DO;
               OUTPUT = LINE;
               LINE = X1;
            END;
      END TAB;

      #ACTIVATIONS = SHR(PROC_HEAD(SEQ#), 16);
      IF #ACTIVATIONS = MAX_DUMPS THEN
         DO;   /* WRITE ELLIPSES */
            OUTPUT = '. . .';
            PRINT_BLANK_LINE;
         END;
      #ACTIVATIONS = #ACTIVATIONS + 1;
      PROC_HEAD(SEQ#) = (PROC_HEAD(SEQ#) & "FFFF") | SHL(#ACTIVATIONS, 16);
      IF #ACTIVATIONS > MAX_DUMPS THEN RETURN;
      PROC_PTR = PROC_HEAD(SEQ#) & "FFFF";
      IF SEQ# = 0 THEN
         LINE = '=> PROGRAM BLOCK ';
      ELSE IF STRUCTYPE(PROC_PTR) = STATEMENT THEN
         LINE = '=> PROCEDURE BLOCK ';
      ELSE LINE = '=> FUNCTION BLOCK ';
      OUTPUT = LINE || IDENTITY(PROC_PTR);
      VAR_PTR = S_LIST(PROC_PTR);
      IF VAR_PTR = NULL THEN
         OUTPUT(1) =
            '0  NO LOCAL SCALAR, SUBRANGE, POINTER OR STRING VARIABLES';
      ELSE OUTPUT(1) = '0  VALUE OF LOCAL VARIABLES:';
      LINE = X1;
      DO WHILE VAR_PTR ~= NULL;
         VAR_ADDR = ARBASE + DISPLACEMENT(VAR_PTR);
         S = X1 || IDENTITY(VAR_PTR);
         L = LENGTH(S) - 1;
         DO WHILE BYTE(S, L) = BYTE(' ');
            L = L - 1;
         END;
         S = SUBSTR(S, 0, L + 1) || ' = ';
         IF STRUCTYPE(VAR_PTR) ~= ARRAY THEN
            DO;  /* FETCH VALUE FROM ACTIVATION RECORD */
               VAR_VALUE = 0;
               DO I = 0 TO STORAGE_LNGTH(VAR_PTR) - 1;
                  VAR_VALUE = SHL(VAR_VALUE, 8) + COREBYTE(VAR_ADDR + I);
               END;
               VAR_VALUE = VAR_VALUE + VALUE(VAR_PTR);
               IF (DATATYPE(VAR_PTR) = CHARPTR)
                  & (STRUCTYPE(VAR_PTR) ~= POINTER) THEN
                  DO;
                     S = S || '''X''';
                     BYTE(S, LENGTH(S) - 2) = VAR_VALUE;
                  END;
               ELSE IF STRUCTYPE(DATATYPE(VAR_PTR)) = SCALAR THEN
                  DO;
                     I = S_LIST(DATATYPE(VAR_PTR)) + VAR_VALUE;
                     IF (DATATYPE(I) = DATATYPE(VAR_PTR))
                        & (VAR_TYPE(I) = CONSTANT) THEN
                        S = S || IDENTITY(I);
                     ELSE S = S || '?';
                  END;
               ELSE IF STRUCTYPE(VAR_PTR) = POINTER THEN
                  DO;
                     IF VAR_VALUE = 0 THEN S = S || 'UNDEFINED';
                     ELSE IF VAR_VALUE = "FBFBFBFB" THEN S = S || 'NIL';
                     ELSE S = S || '(DEFINED)';
                  END;
               ELSE IF DATATYPE(VAR_PTR) = REALPTR THEN
                  S = S || E_FORMAT(VAR_VALUE, 14);
               ELSE S = S || VAR_VALUE;
               IF (STRUCTYPE(VAR_PTR) ~= POINTER) &
                  (VAR_VALUE = VALUE(VAR_PTR)) THEN
                  DO;   /* POSSIBLY UNDEFINED VARIABLE */
                     L = LENGTH(S) - 1;
                     DO WHILE BYTE(S, L) = BYTE(' ');
                        L = L - 1;
                     END;
                     S = SUBSTR(S, 0, L + 1) || ' (OR UNDEFINED)';
                  END;
               LINE = LINE || S;
               CALL TAB;
            END;
         ELSE   /* CHARACTER ARRAY */
            DO;
               IF LENGTH(LINE) + LENGTH(S) + STORAGE_LNGTH(VAR_PTR) > 130 THEN
                  DO;
                     IF LENGTH(LINE) > 1 THEN OUTPUT = LINE;
                     LINE = X1;
                  END;
               LINE = LINE || S;
               L = STORAGE_LNGTH(VAR_PTR);
               IF LENGTH(LINE) + L > 130 THEN L = 130 - LENGTH(LINE);
               S = PAD('X', L);
               DO I = 0 TO L - 1;
                  B = COREBYTE(VAR_ADDR + I);
                  IF B < 32 THEN B = BYTE('?');  /* THIS IS QUESTIONABLE */
                  BYTE(S, I) = B;
               END;
               LINE = LINE || '''' || S || '''';
               CALL TAB;
            END;
         /* S_LIST(VAR_PTR) = NULL OR VAR_PTR < S_LIST(VAR_PTR) <= N_DECL_SYMB
            AND VAR_TYPE(S_LIST(VAR_PTR)) = VARIABLE */
         VAR_PTR = S_LIST(VAR_PTR);
      END;  /* WHILE */
      IF LENGTH(LINE) > 1 THEN OUTPUT = LINE;
      PRINT_BLANK_LINE;
      IF SEQ# = 0 THEN RETURN;
      LINE = '  ' || IDENTITY(PROC_PTR);
      L = LENGTH(LINE) - 1;
      DO WHILE BYTE(LINE, L) = BYTE(' ');
         L = L - 1;
      END;
      OUTPUT = SUBSTR(LINE, 0, L + 1) || ' WAS CALLED NEAR LINE '
         || SOURCE_LINE(CALLED_FROM_ADDR);
      PRINT_BLANK_LINE;
   END DUMP_LOCAL_VARIABLES;

   /****   POST MORTEM DUMP STARTS HERE   ****/
   FATAL_ERROR = FALSE;
   CALL INITIALIZE_PMD_POINTERS;
   IF FATAL_ERROR THEN RETURN;
   CALL INITIALIZE_PMD_TABLES;
   IF FATAL_ERROR THEN RETURN;
   OUTPUT(1) = '1=> TRACE OF ACTIVE BLOCKS';
   PRINT_BLANK_LINE;
   DO FOREVER;
      THIS_PROC = FINDPROC(CBR);   /* RETURNS SEQ# */
      IF THIS_PROC = NULL THEN RETURN;
      CALLED_FROM_ADDR = (COREWORD(SHR(ARBASE, 2) + 1) & "00FFFFFF") - 2;
      CALL DUMP_LOCAL_VARIABLES(THIS_PROC);
      CBR = COREWORD(SHR(ARBASE, 2) + 3);
      IF ARBASE ~= GLOBAL_ARBASE THEN
         ARBASE = COREWORD(SHR(ARBASE, 2) + 2);
      ELSE RETURN;
   END;
END POST_MORTEM_DUMP;

BLOCK_COUNT:
PROCEDURE(BLOCK#) CHARACTER;
   DECLARE (A, I, S, BLOCK#, V) FIXED;
   DECLARE (STRING, FILLER) CHARACTER;

   /* CONVERT A PACKED DECIMAL TO A CHARACTER STRING */
   A = BLOCK_COUNTER_BASE_ADDR + SHL(BLOCK#, 2);
   STRING, FILLER = X1;
   S = 4;
   DO I = 0 TO 6;
      V = COREBYTE(A + SHR(I, 1));
      V = SHR(V, S) & 15;
      S = 4 - S;
      IF (V = 0) & (I < 6) THEN DO;
            STRING = STRING || FILLER;
         END;
      ELSE DO;
            STRING = STRING || SUBSTR(HEX_DIGITS, V, 1);
            FILLER = '0';
         END;
   END;
   RETURN STRING;
END BLOCK_COUNT;

FLOW_SUMMARY:
PROCEDURE(ERROR_LINE);
   DECLARE ERROR_LINE FIXED;
   DECLARE DGNS#_FILE_NO FIXED INITIAL(3);
   DECLARE READING BIT(1), BLOCK# BIT(16);
   DECLARE I FIXED;

DGNS#_DUMP:
   PROCEDURE(BLOCK_NUMBER);
      /* DUMP ONE SUMMARY BLOCK */
      DECLARE (POS, I, LAST_LINE, LINE_NUMBER, BLOCK_NUMBER,
         INDENTATION) FIXED,
         SUMMARY_1(7200) BIT(8),  /* MUST BE FULLWORD-ALLIGNED */
         (TEMP_STRING, EXTRA_STR, S) CHARACTER,
         COUNTER# BIT(16);

   DECODE:
      PROCEDURE(POS) CHARACTER;
         /* DECODE ONE LINE OF PARAGRAPHED TEXT */
         DECLARE (POS, I, J) FIXED, EXTRA_STR CHARACTER;
         EXTRA_STR = X1;
         DO I = 1 TO SUMMARY_1(POS + 1);
            EXTRA_STR = EXTRA_STR || X1;
            /* J PREVENTS "***ERROR, USED ALL ACCUMULATORS." */
            J = SUMMARY_1(POS + I + 5);
            BYTE(EXTRA_STR, I) = J;
         END;
         RETURN EXTRA_STR;
      END DECODE;

      SUMMARY_1 = FILE(DGNS#_FILE_NO, BLOCK_NUMBER);
      READING = SUMMARY_1(0);
      POS = 1;
      DO WHILE POS < 7200;
         /* MAKE SURE THE BLOCK DOES NOT END PREMATURELY */
         IF SUMMARY_1(POS + 1) = 0 THEN
            POS = 7200;
         ELSE
            DO;
               LAST_LINE = LINE_NUMBER;
               LINE_NUMBER = SHL(SUMMARY_1(POS + 2), 8) + SUMMARY_1(POS + 3);
               IF ERROR_LINE > 0 THEN
                  IF ((LAST_LINE < ERROR_LINE) & (LINE_NUMBER >= ERROR_LINE))
                     | ((LAST_LINE = ERROR_LINE) & (LINE_NUMBER > ERROR_LINE))
                     THEN
                OUTPUT = '---- ERROR -------------------------------------------
------------------------------------------------------------------------------';
               EXTRA_STR = DECODE(POS);
               IF EXTRA_STR = '  ' THEN PRINT_BLANK_LINE;
               ELSE DO;
                     TEMP_STRING = Z_FORMAT(LINE_NUMBER, 4);
                     COUNTER# = SHL(SUMMARY_1(POS + 4), 8) + SUMMARY_1(POS + 5);
                     IF COUNTER# ~= NULL THEN
                        S = BLOCK_COUNT(COUNTER#) || '.--|     ';
                     ELSE S = '           |     ';
                     INDENTATION = SUMMARY_1(POS) + 4;
                     OUTPUT = PAD(TEMP_STRING, INDENTATION) || S || EXTRA_STR;
               END;
            END;
         POS = POS + SUMMARY_1(POS + 1) + 6;
      END;
   END DGNS#_DUMP;

   /* FIRST EXECUTABLE STATEMENT OF FLOW_SUMMARY */
   READING = TRUE;
   BLOCK# = 0;
   OUTPUT(1) = '1=> EXECUTION FLOW SUMMARY';
   PRINT_BLANK_LINE;
   DO WHILE READING;
      CALL DGNS#_DUMP(BLOCK#);
      BLOCK# = BLOCK# + 1;
   END;
END FLOW_SUMMARY;



MAIN_PROCEDURE:
PROCEDURE;

   CALL INITIALIZE;

   IF (DEBUG_LEVEL > 0) & (ERROR_LINE ~= 0) THEN
      CALL POST_MORTEM_DUMP;

   IF DEBUG_LEVEL > 1 THEN
      DO;
         FREELIMIT = CORETOP - MAX_STRING_LENGTH;
         CALL FLOW_SUMMARY(ERROR_LINE & "00FFFFFF");
      END;

   CALL PRINT_TIME(EXECUTION_TIME, ' SECONDS IN EXECUTION.');

END MAIN_PROCEDURE;


CALL MAIN_PROCEDURE;

RETURN 1;  /* STOP THE SIMULATOR FROM FURTHER EXECUTION */

EOF EOF EOF
      *-----------------------
       IDENTIFICATION DIVISION.
      *-----------------------
       PROGRAM-ID.    BLD0010
       AUTHOR.        CKD
      *--------------------
       ENVIRONMENT DIVISION.
      *--------------------
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT CUSTF ASSIGN TO FCUST.
      *     SELECT LAST-NAME  ASSIGN TO LNAMES.
      *     SELECT FIRST-LAST ASSIGN TO COMBINED.
      *-------------
       DATA DIVISION.
      *-------------
       FILE SECTION.
       FD  CUSTF RECORDING MODE F.
       01  CUST-REC.
        05  CUST-KEY.
         10 CUST-BUS-UNIT     PIC X(07).                *>1
         10 CUST-BUS-UNIT-R   REDEFINES CUST-BUS-UNIT.  *>1
          15 CUST-BANK        PIC X(03).                *>1
          15 CUST-BRANCH      PIC 9(04).                *>1
         10  CUST-NO          PIC X(05).                *>8
        05  CUST-ID-NO        PIC X(10).                *>13
        05  CUST-NAME         PIC X(10).                *>23
        05  CUST-BALANCE      PIC 9(11)V99.             *>33
        05  CUST-FILLER       PIC X(35).                *>46
                                                        *>81
      *
      *FD  LAST-NAME RECORDING MODE F.
      * 01  LAST-REC.
      *     05  LAST-IN        PIC X(15).
      *     05  FILLER         PIC X(65).
      *
      * FD  FIRST-LAST RECORDING MODE F.
      * 01  FIRST-LAST-REC.
      *     05  FIRST-OUT      PIC X(10).
      *     05  LAST-OUT       PIC X(15).
      *     05  FILLER         PIC X(55).
      *
       WORKING-STORAGE SECTION.
       01 FLAGS.
         05 LASTREC           PIC X VALUE SPACE.
         05 FLG-AREA.
          10 FLG-CUST         PIC X(01).
          10 FLG-RD           PIC X(01).
          10 FLG-WR           PIC X(01).
          10 FLG-RW           PIC X(01).
         05 WS-CNT-AREA.
          10 WS-RD-CNT        PIC 9(05).
          10 WS-WR-CNT        PIC 9(05).
         05 WS-SUM-AREA.
          10 WS-SUM-CNT       PIC 9(05).
          10 WS-SUM-BAL       PIC 9(11)V99.

        *>POINTER
         01 CUSTP1-REC-PTR      USAGE POINTER.

         COPY CUSTP1.

      *  01 CUSTP1-REC.
      *   10 CUSTP1-BUS-UNIT     PIC X(07).                *>1
      *   10 CUSTP1-BUS-UNIT-R   REDEFINES CUSTP1-BUS-UNIT.  *>1
      *    15 CUSTP1-BANK        PIC X(03).                *>1
      *   15 CUSTP1-BRANCH      PIC 9(04).                *>1
      *   10  CUSTP1-NO          PIC X(05).                *>8
      *   10  CUSTP1-ID-NO        PIC X(10).                *>13
      *   10  CUSTP1-NAME         PIC X(10).                *>23
      *   10  CUSTP1-BALANCE      PIC 9(11)V99.             *>33
      *   10  CUSTP1-FILLER       PIC X(35).

       LINKAGE SECTION.
      *  01 CUSTP-REC.
      *   10 CUSTP-BUS-UNIT     PIC X(07).                *>1
      *   10 CUSTP-BUS-UNIT-R   REDEFINES CUSTP-BUS-UNIT.  *>1
      *    15 CUSTP-BANK        PIC X(03).                *>1
      *    15 CUSTP-BRANCH      PIC 9(04).                *>1
      *   10  CUSTP-NO          PIC X(05).                *>8
      *   10  CUSTP-ID-NO        PIC X(10).                *>13
      *   10  CUSTP-NAME         PIC X(10).                *>23
      *   10  CUSTP-BALANCE      PIC 9(11)V99.             *>33
      *   10  CUSTP-FILLER       PIC X(35).

      *-- ----------------
       PROCEDURE DIVISION.
      *------------------
       0000-MAIN-PROC.

            PERFORM 1000-INIT THRU 1000-EXIT.
            PERFORM 2000-PROC THRU 2000-EXIT.
            PERFORM 3000-END  THRU 3000-EXIT.

            GOBACK.

      *-----------------
      * 1000-INIT
      *-----------------
       1000-INIT.

           DISPLAY '1000 START...'.

       1000-EXIT.
           EXIT.

      *-----------------
      * 2000-PROC
      *-----------------
       2000-PROC.

           DISPLAY '2000 START...'

           *>SET POINTER
           SET CUSTP1-REC-PTR TO ADDRESS OF CUSTP1-REC.
      *    SET ADDRESS OF CUSTP-REC TO CUSTP1-REC-PTR.

           PERFORM 2100-WRITE-FILE THRU 2100-EXIT.
           PERFORM 2200-SUM-PROC THRU 2200-EXIT.

       2000-EXIT.
           EXIT.
      *-----------------
      * 2100-WRITE-FILE
      *-----------------
       2100-WRITE-FILE.
           DISPLAY '2100-START...'

           OPEN EXTEND CUSTF.

           *>WRITE
           INITIALIZE  CUST-REC.
           MOVE 'H060066' TO cUST-BUS-UNIT.
           MOVE '00006'   TO CUST-NO.
0          MOVE 'H000000006' TO CUST-ID-NO.
0          MOVE 'CKD6'       TO CUST-NAME.
0          MOVE 6000         TO CUST-BALANCE.

           DISPLAY ' B WR OK=' CUST-NO.

           *>DISPLAY ADDRESS OF
           DISPLAY ' B CUSTPTR...'
           MOVE CUST-REC TO CUSTP1-REC.
           SET CUSTP1-REC-PTR TO ADDRESS OF CUSTP1-REC.

           DISPLAY '  PTR BUS-UNIT=' CUSTP1-BUS-UNIT.
           DISPLAY '      CUST-NO =' CUSTP1-NO.
           DISPLAY '      ID-NO   =' CUSTP1-ID-NO.
           CALL 'CUSTPTR' USING CUSTP1-REC-PTR.
           DISPLAY ' A CUSTPTR...'

           MOVE SPACE TO FLG-RW.
0          WRITE CUST-REC INVALID MOVE 'Y' TO FLG-RW
           END-WRITE.
           IF FLG-RW = 'Y' THEN
             DISPLAY 'BLD0010-2100 WR ERR' CUST-KEY
           END-IF.

            *>WRITE
           INITIALIZE  CUST-REC.
           MOVE 'H060066' TO cUST-BUS-UNIT.
           MOVE '00007'   TO CUST-NO.
           MOVE 'H000000007' TO CUST-ID-NO.
           MOVE 'CKD7'       TO CUST-NAME.
           MOVE 7000         TO CUST-BALANCE.

           DISPLAY '  B WR OK=' CUST-NO.

           MOVE SPACE TO FLG-RW.
           WRITE CUST-REC INVALID MOVE 'Y' TO FLG-RW
           END-WRITE.

           *>DISPLAY '  A WR OK=' CUST-NO.
           IF FLG-RW = 'Y' THEN
             DISPLAY 'BLD0010-2100 WRITE ERR=' CUST-KEY
           END-IF.

           CLOSE CUSTF.

       2100-EXIT.
           EXIT.
      *------------------
      * 2200-SUM-PROC
      *------------------
       2200-SUM-PROC.

           DISPLAY '2200 START'

           OPEN INPUT CUSTF.

           MOVE SPACE TO FLG-CUST.
           READ CUSTF AT END MOVE 'Y' TO FLG-CUST
           END-READ.

           *>
           PERFORM UNTIL FLG-CUST = 'Y'
              *>READ CNT
              ADD 1 TO WS-RD-CNT
              *>SUM BALANCE
              ADD 1 TO WS-SUM-CNT
              ADD CUST-BALANCE TO WS-SUM-BAL
              *>READ NEXT
              READ CUSTF AT END MOVE 'Y' TO FLG-CUST
              END-READ
           END-PERFORM.

           CLOSE CUSTF.

       2200-EXIT.
           EXIT.
      *---------------------
      * 3000-END
      *---------------------
       3000-END.
            DISPLAY 'FROM 3270 '
            DISPLAY '3000 START...'

            DISPLAY '   RD CNT=' WS-RD-CNT.
            DISPLAY '   SUM CNT=' WS-SUM-CNT.
            DISPLAY '   SUM BAL=' WS-SUM-BAL.

            *>CLOSE CUSTF.

       3000-EXIT.
           EXIT.

       IDENTIFICATION DIVISION.

       PROGRAM-ID. RPT6000.
      *****************************************************************
      *  Programmers: Tristan Joubert and 
      *  Date.......: 2 April 2026
      *  GitHub URL.: https://github.com/bstearns07/RPT6000
      *  Description: The RPT6000 program is an enhanced COBOL
      *               reporting tool. It serves as a data processing
      *               utility that reads customer financial records
      *               from a master input file (CUSTMAST) and
      *               generates a formatted, multi-columnar
      *               Year-To-Date (YTD) Sales Report. This also shows
      *               the branch totals and SalesRep Total
      *****************************************************************
       ENVIRONMENT DIVISION.

       INPUT-OUTPUT SECTION.

       FILE-CONTROL.
           SELECT CUSTMAST ASSIGN TO CUSTMAST.
           SELECT OUTPUT-RPT6000 ASSIGN TO RPT6000.

       DATA DIVISION.
       FILE SECTION.
       FD  CUSTMAST
           RECORDING MODE IS F
           LABEL RECORDS ARE STANDARD
           RECORD CONTAINS 130 CHARACTERS
           BLOCK CONTAINS 130 CHARACTERS.
       01  CUSTOMER-MASTER-RECORD.
           05  CM-BRANCH-NUMBER        PIC 9(2).
           05  CM-SALESREP-NUMBER      PIC 9(2).
           05  CM-CUSTOMER-NUMBER      PIC 9(5).
           05  CM-CUSTOMER-NAME        PIC X(20).
           05  CM-SALES-THIS-YTD       PIC S9(5)V9(2).
           05  CM-SALES-LAST-YTD       PIC S9(5)V9(2).
           05  FILLER                  PIC X(87).

       FD  OUTPUT-RPT6000
           RECORDING MODE IS F
           LABEL RECORDS ARE STANDARD
           RECORD CONTAINS 130 CHARACTERS
           BLOCK CONTAINS 130 CHARACTERS.
       01  PRINT-AREA      PIC X(130).

       WORKING-STORAGE SECTION.
       01  SWITCHES.
           05  CUSTMAST-EOF-SWITCH     PIC X    VALUE "N".
               88 CUSTMAST-EOF                  VALUE "Y".
           05  FIRST-RECORD-SWITCH     PIC X    VALUE "Y".
               88 FIRST-RECORD                  VALUE "Y" FALSE "N".

       01 CONTROL-FIELDS.
           05 OLD-SALESREP-NUMBER      PIC 99.
           05 OLD-BRANCH-NUMBER        PIC 99.

       01  PRINT-FIELDS                    PACKED-DECIMAL.
           05  PAGE-COUNT      PIC S9(3)   VALUE ZERO.
           05  LINES-ON-PAGE   PIC S9(3)   VALUE +55.
           05  LINE-COUNT      PIC S9(3)   VALUE +99.
           05  SPACE-CONTROL   PIC S9.

       01  TOTAL-FIELDS                              PACKED-DECIMAL.
           05  SALESREP-TOTAL-THIS-YTD   PIC S9(6)V99   VALUE ZERO.
           05  SALESREP-TOTAL-LAST-YTD   PIC S9(6)V99   VALUE ZERO.
           05  BRANCH-TOTAL-THIS-YTD  PIC S9(6)V99   VALUE ZERO.
           05  BRANCH-TOTAL-LAST-YTD  PIC S9(6)V99   VALUE ZERO.
           05  GRAND-TOTAL-THIS-YTD   PIC S9(7)V99   VALUE ZERO.
           05  GRAND-TOTAL-LAST-YTD   PIC S9(7)V99   VALUE ZERO.
           05  GRAND-TOTAL-CHANGE-AMT PIC S9(7)V99   VALUE ZERO.
           05  GRAND-TOTAL-CHANGE-PCT PIC S9(3)V9    VALUE ZERO.

       01  CALCULATION-FIELDS         PACKED-DECIMAL.
           05  WS-CHANGE-AMOUNT       PIC S9(7)V99   VALUE ZERO.
           05  WS-CHANGE-PERCENT      PIC S9(3)V9    VALUE ZERO.
           05  WS-CHANGE-PERCENT-R    REDEFINES WS-CHANGE-PERCENT 
                                      PIC X(6).
           

       01  CURRENT-DATE-AND-TIME.
           05  CD-YEAR         PIC 9999.
           05  CD-MONTH        PIC 99.
           05  CD-DAY          PIC 99.
           05  CD-HOURS        PIC 99.
           05  CD-MINUTES      PIC 99.
           05  FILLER          PIC X(9).

       01  HEADING-LINE-1.
           05  FILLER          PIC X(7)    VALUE "DATE:  ".
           05  HL1-MONTH       PIC 9(2).
           05  FILLER          PIC X(1)    VALUE "/".
           05  HL1-DAY         PIC 9(2).
           05  FILLER          PIC X(1)    VALUE "/".
           05  HL1-YEAR        PIC 9(4).
           05  FILLER          PIC X(22)   VALUE SPACE.
           05  FILLER     PIC X(25)   VALUE "YEAR-TO-DATE SALES REPORT".
           05  FILLER          PIC X(19)   VALUE "           PAGE: ".
           05  HL1-PAGE-NUMBER PIC ZZZ9.
           05  FILLER          PIC X(49)   VALUE SPACE.

       01  HEADING-LINE-2.
           05  FILLER          PIC X(7)    VALUE "TIME:  ".
           05  HL2-HOURS       PIC 9(2).
           05  FILLER          PIC X(1)    VALUE ":".
           05  HL2-MINUTES     PIC 9(2).
           05  FILLER          PIC X(63)   VALUE SPACE.
           05  FILLER          PIC X(10)   VALUE "RPT6000".
           05  FILLER          PIC X(36)   VALUE SPACE.

       01  HEADING-LINE-3.
           05  FILLER PIC X(13) VALUE "BRANCH SALES ".
           05  FILLER PIC X(31) VALUE "CUST  ".
           05  FILLER PIC X(14) VALUE "SALES       ".
           05  FILLER PIC X(14) VALUE "SALES    ".
           05  FILLER PIC X(14) VALUE "CHANGE      ".
           05  FILLER PIC X(7)  VALUE "CHANGE ".
           05  FILLER PIC X(47) VALUE SPACE.

       01  HEADING-LINE-4.
           05  FILLER PIC X(13) VALUE " NUM   REP   ".
           05  FILLER PIC X(31) VALUE "NUM    CUSTOMER NAME".
           05  FILLER PIC X(14) VALUE "THIS YTD    ".
           05  FILLER PIC X(14) VALUE "LAST YTD      ".
           05  FILLER PIC X(14) VALUE "AMOUNT      ".
           05  FILLER PIC X(7)  VALUE "PERCENT".
           05  FILLER PIC X(34) VALUE SPACE.

       01  HEADING-LINE-5.
           05  FILLER PIC X(6)  VALUE ALL "-".
           05  FILLER PIC X(1)  VALUE SPACE.
           05  FILLER PIC X(5)  VALUE ALL "-".
           05  FILLER PIC X(1)  VALUE SPACE.
           05  FILLER PIC X(5)  VALUE ALL "-".
           05  FILLER PIC X(2)  VALUE SPACE.
           05  FILLER PIC X(20) VALUE ALL "-".
           05  FILLER PIC X(3)  VALUE SPACE.
           05  FILLER PIC X(10) VALUE ALL "-".
           05  FILLER PIC X(4)  VALUE SPACE.
           05  FILLER PIC X(10) VALUE ALL "-".
           05  FILLER PIC X(4)  VALUE SPACE.
           05  FILLER PIC X(10) VALUE ALL "-".
           05  FILLER PIC X(3)  VALUE SPACE.
           05  FILLER PIC X(7)  VALUE ALL "-".
           05  FILLER PIC X(39) VALUE SPACE.

       01  CUSTOMER-LINE.
           05  FILLER              PIC X(2)    VALUE SPACE.
           05  CL-BRANCH-NUMBER    PIC X(2).
           05  FILLER              PIC X(4)    VALUE SPACE.
           05  CL-SALESREP-NUMBER  PIC X(2).
           05  FILLER              PIC X(3)    VALUE SPACE.
           05  CL-CUSTOMER-NUMBER  PIC 9(5).
           05  FILLER              PIC X(2)    VALUE SPACE.
           05  CL-CUSTOMER-NAME    PIC X(20).
           05  FILLER              PIC X(4)    VALUE SPACE.
           05  CL-SALES-THIS-YTD   PIC ZZ,ZZ9.99-.
           05  FILLER              PIC X(4)    VALUE SPACE.
           05  CL-SALES-LAST-YTD   PIC ZZ,ZZ9.99-.
           05  FILLER              PIC X(4)    VALUE SPACE.
           05  CL-CHANGE-AMOUNT    PIC ZZ,ZZ9.99-.
           05  FILLER              PIC X(4)    VALUE SPACE.
           05  CL-CHANGE-PERCENT   PIC ---9.9.
           05  CL-CHANGE-PERCENT-R REDEFINES CL-CHANGE-PERCENT PIC x(6).
           05  FILLER              PIC X(48)   VALUE SPACE.

       01  SALESREP-TOTAL-LINE.
           05  FILLER              PIC X(23)   VALUE SPACE.
           05  FILLER              PIC X(20)   VALUE "SALESREP TOTAL".
           05  STL-SALES-THIS-YTD  PIC $$$,$$$.99-.
           05  FILLER              PIC X(3)    VALUE SPACE.
           05  STL-SALES-LAST-YTD  PIC $$$,$$$.99-.
           05  FILLER              PIC X(3)    VALUE SPACE.
           05  STL-CHANGE-AMOUNT   PIC $$$,$$$.99-.
           05  FILLER              PIC X(4)    VALUE SPACE.
           05  STL-CHANGE-PERCENT  PIC +++9.9.
           05  STL-CHANGE-PERCENT-R REDEFINES 
                       STL-CHANGE-PERCENT PIC X(6).
           05  FILLER              PIC X(40)   VALUE "  *".

       01  BRANCH-TOTAL-LINE.
           05  FILLER              PIC X(23)   VALUE SPACE.
           05  FILLER              PIC X(20)   VALUE "BRANCH TOTAL".
           05  BTL-SALES-THIS-YTD  PIC $$$,$$$.99-.
           05  FILLER              PIC X(3)    VALUE SPACE.
           05  BTL-SALES-LAST-YTD  PIC $$$,$$$.99-.
           05  FILLER              PIC X(3)    VALUE SPACE.
           05  BTL-CHANGE-AMOUNT   PIC $$$,$$$.99-.
           05  FILLER              PIC X(4)    VALUE SPACE.
           05  BTL-CHANGE-PERCENT  PIC +++9.9.
           05  BTL-CHANGE-PERCENT-R REDEFINES 
                       BTL-CHANGE-PERCENT PIC X(6).
           05  FILLER              PIC X(40)   VALUE " **".

       01  BLANK-LINE.
           05  FILLER              PIC X(130)   VALUE SPACE.

       01  GRAND-TOTAL-LINE-1.
           05  FILLER              PIC X(23)   VALUE SPACE.
           05  FILLER              PIC X(20)   VALUE "GRAND TOTAL".
           05  FILLER              PIC X(10)   VALUE ALL "=".
           05  FILLER              PIC X(4)    VALUE SPACE.
           05  FILLER              PIC X(10)   VALUE ALL "=".
           05  FILLER              PIC X(5)    VALUE SPACE.
           05  FILLER              PIC X(10)   VALUE ALL "=".
           05  FILLER              PIC X(3)    VALUE SPACE.
           05  FILLER              PIC X(7)    VALUE ALL "=".
           05  FILLER              PIC X(37)   VALUE "   ".

       01  GRAND-TOTAL-LINE-2.
           05  FILLER              PIC X(41)   VALUE SPACE.
           05  GTL-SALES-THIS-YTD  PIC Z,ZZZ,ZZ9.99-.
           05  FILLER              PIC X(1)    VALUE SPACE.
           05  GTL-SALES-LAST-YTD  PIC Z,ZZZ,ZZ9.99-.
           05  FILLER              PIC X(1)    VALUE SPACE.
           05  GTL-CHANGE-AMOUNT   PIC Z,ZZZ,ZZ9.99-.
           05  FILLER              PIC X(4)    VALUE SPACE.
           05  GTL-CHANGE-PERCENT  PIC ZZ9.9-.
           05  FILLER              PIC X(37)   VALUE "***".

       PROCEDURE DIVISION.
       000-PREPARE-SALES-REPORT.
           OPEN INPUT  CUSTMAST
                OUTPUT OUTPUT-RPT6000.
           PERFORM 100-FORMAT-REPORT-HEADING.
           PERFORM 300-PREPARE-SALES-LINES
               UNTIL CUSTMAST-EOF.
           PERFORM 500-PRINT-GRAND-TOTALS.
           CLOSE CUSTMAST
                 OUTPUT-RPT6000.
           STOP RUN.

       100-FORMAT-REPORT-HEADING.
           MOVE FUNCTION CURRENT-DATE TO CURRENT-DATE-AND-TIME.
           MOVE CD-MONTH   TO HL1-MONTH.
           MOVE CD-DAY     TO HL1-DAY.
           MOVE CD-YEAR    TO HL1-YEAR.
           MOVE CD-HOURS   TO HL2-HOURS.
           MOVE CD-MINUTES TO HL2-MINUTES.

       300-PREPARE-SALES-LINES.
           PERFORM 310-READ-CUSTOMER-RECORD.
           EVALUATE TRUE
               WHEN CUSTMAST-EOF
                   PERFORM 355-PRINT-SALESREP-LINE
                   PERFORM 360-PRINT-BRANCH-LINE
               WHEN FIRST-RECORD
                   PERFORM 320-PRINT-CUSTOMER-LINE
                   SET FIRST-RECORD TO FALSE
                   MOVE CM-SALESREP-NUMBER TO OLD-SALESREP-NUMBER
                   MOVE CM-BRANCH-NUMBER TO OLD-BRANCH-NUMBER
               WHEN CM-BRANCH-NUMBER > OLD-BRANCH-NUMBER
                   PERFORM 355-PRINT-SALESREP-LINE
                   PERFORM 360-PRINT-BRANCH-LINE
                   PERFORM 320-PRINT-CUSTOMER-LINE
                   MOVE CM-SALESREP-NUMBER TO OLD-SALESREP-NUMBER
                   MOVE CM-BRANCH-NUMBER TO OLD-BRANCH-NUMBER
               WHEN CM-SALESREP-NUMBER > OLD-SALESREP-NUMBER
                   PERFORM 355-PRINT-SALESREP-LINE
                   PERFORM 320-PRINT-CUSTOMER-LINE
                   MOVE CM-SALESREP-NUMBER TO OLD-SALESREP-NUMBER
               WHEN OTHER
                   PERFORM 320-PRINT-CUSTOMER-LINE
           END-EVALUATE.


       310-READ-CUSTOMER-RECORD.
           READ CUSTMAST
               AT END
                   SET CUSTMAST-EOF TO TRUE.

       320-PRINT-CUSTOMER-LINE.
           IF LINE-COUNT >= LINES-ON-PAGE
               PERFORM 330-PRINT-HEADING-LINES.

           IF FIRST-RECORD
              MOVE CM-BRANCH-NUMBER TO CL-BRANCH-NUMBER
              MOVE CM-SALESREP-NUMBER TO CL-SALESREP-NUMBER
           ELSE
              IF CM-BRANCH-NUMBER > OLD-BRANCH-NUMBER
                 MOVE CM-BRANCH-NUMBER TO CL-BRANCH-NUMBER
                 MOVE CM-SALESREP-NUMBER TO CL-SALESREP-NUMBER
              ELSE
                 MOVE SPACE TO CL-BRANCH-NUMBER
                 IF CM-SALESREP-NUMBER > OLD-SALESREP-NUMBER
                    MOVE CM-SALESREP-NUMBER TO CL-SALESREP-NUMBER
                 ELSE
                    MOVE SPACE TO CL-SALESREP-NUMBER.

           MOVE CM-CUSTOMER-NUMBER TO CL-CUSTOMER-NUMBER.
           MOVE CM-CUSTOMER-NAME   TO CL-CUSTOMER-NAME.
           MOVE CM-SALES-THIS-YTD  TO CL-SALES-THIS-YTD.
           MOVE CM-SALES-LAST-YTD  TO CL-SALES-LAST-YTD.

           SUBTRACT CM-SALES-LAST-YTD FROM CM-SALES-THIS-YTD
               GIVING WS-CHANGE-AMOUNT.
           MOVE WS-CHANGE-AMOUNT TO CL-CHANGE-AMOUNT.

           IF CM-SALES-LAST-YTD = ZERO
               MOVE "  N/A " TO WS-CHANGE-PERCENT-R
           ELSE
               COMPUTE WS-CHANGE-PERCENT =
                   (WS-CHANGE-AMOUNT / CM-SALES-LAST-YTD) * 100
                     ON SIZE ERROR
                          MOVE "OVRFLW" TO WS-CHANGE-PERCENT-R
           END-IF.
           MOVE WS-CHANGE-PERCENT TO CL-CHANGE-PERCENT.

           MOVE CUSTOMER-LINE TO PRINT-AREA.
           PERFORM 350-WRITE-REPORT-LINE.
           MOVE 1 TO SPACE-CONTROL.
           ADD CM-SALES-THIS-YTD TO SALESREP-TOTAL-THIS-YTD.
           ADD CM-SALES-LAST-YTD TO SALESREP-TOTAL-LAST-YTD.
           ADD CM-SALES-THIS-YTD TO GRAND-TOTAL-THIS-YTD.
           ADD CM-SALES-LAST-YTD TO GRAND-TOTAL-LAST-YTD.
           ADD WS-CHANGE-AMOUNT  TO GRAND-TOTAL-CHANGE-AMT.

           MOVE 1 TO SPACE-CONTROL.

       330-PRINT-HEADING-LINES.
           ADD 1 TO PAGE-COUNT.
           MOVE PAGE-COUNT     TO HL1-PAGE-NUMBER.
           MOVE HEADING-LINE-1 TO PRINT-AREA.
           PERFORM 340-WRITE-PAGE-TOP-LINE.
           MOVE HEADING-LINE-2 TO PRINT-AREA.
           PERFORM 350-WRITE-REPORT-LINE.
           MOVE HEADING-LINE-3 TO PRINT-AREA.
           PERFORM 350-WRITE-REPORT-LINE.
           MOVE HEADING-LINE-4 TO PRINT-AREA.
           PERFORM 350-WRITE-REPORT-LINE.
           MOVE ZERO TO LINE-COUNT.
           MOVE 2 TO SPACE-CONTROL.

       340-WRITE-PAGE-TOP-LINE.
           WRITE PRINT-AREA.
           MOVE 1 TO LINE-COUNT.

       350-WRITE-REPORT-LINE.
           WRITE PRINT-AREA.

       355-PRINT-SALESREP-LINE.
           MOVE SALESREP-TOTAL-THIS-YTD TO STL-SALES-THIS-YTD.
           MOVE SALESREP-TOTAL-LAST-YTD TO STL-SALES-LAST-YTD.
           COMPUTE WS-CHANGE-AMOUNT =
                    SALESREP-TOTAL-THIS-YTD - SALESREP-TOTAL-LAST-YTD.
           MOVE WS-CHANGE-AMOUNT TO STL-CHANGE-AMOUNT.
           IF SALESREP-TOTAL-LAST-YTD = ZERO
                MOVE "  N/A " TO STL-CHANGE-PERCENT-R
           ELSE
              COMPUTE STL-CHANGE-PERCENT ROUNDED =
                 WS-CHANGE-AMOUNT * 100 / SALESREP-TOTAL-LAST-YTD
                  ON SIZE ERROR
                      MOVE "OVRFLW" TO STL-CHANGE-PERCENT-R.
           MOVE SALESREP-TOTAL-LINE  TO PRINT-AREA.
           MOVE 1 TO SPACE-CONTROL.
           PERFORM 350-WRITE-REPORT-LINE.
           MOVE 2 TO SPACE-CONTROL.
           ADD SALESREP-TOTAL-THIS-YTD TO BRANCH-TOTAL-THIS-YTD.
           ADD SALESREP-TOTAL-LAST-YTD TO BRANCH-TOTAL-LAST-YTD.
           MOVE ZERO TO SALESREP-TOTAL-THIS-YTD.
           MOVE ZERO TO SALESREP-TOTAL-LAST-YTD.

       360-PRINT-BRANCH-LINE.

           MOVE BRANCH-TOTAL-THIS-YTD TO BTL-SALES-THIS-YTD.
           MOVE BRANCH-TOTAL-LAST-YTD TO BTL-SALES-LAST-YTD.
           COMPUTE WS-CHANGE-AMOUNT =
                    BRANCH-TOTAL-THIS-YTD - BRANCH-TOTAL-LAST-YTD.
           MOVE WS-CHANGE-AMOUNT TO BTL-CHANGE-AMOUNT.
           IF BRANCH-TOTAL-LAST-YTD = ZERO
                MOVE "  N/A " TO BTL-CHANGE-PERCENT-R
           ELSE
              COMPUTE BTL-CHANGE-PERCENT ROUNDED =
                 WS-CHANGE-AMOUNT * 100 / BRANCH-TOTAL-LAST-YTD
                  ON SIZE ERROR
                      MOVE "OVRFLW"TO BTL-CHANGE-PERCENT-R.
           MOVE BRANCH-TOTAL-LINE  TO PRINT-AREA.
           MOVE 1 TO SPACE-CONTROL.
           PERFORM 350-WRITE-REPORT-LINE.
           MOVE 2 TO SPACE-CONTROL.
           ADD BRANCH-TOTAL-THIS-YTD TO GRAND-TOTAL-THIS-YTD.
           ADD BRANCH-TOTAL-LAST-YTD TO GRAND-TOTAL-LAST-YTD.
           MOVE ZERO TO BRANCH-TOTAL-THIS-YTD.
           MOVE ZERO TO BRANCH-TOTAL-LAST-YTD.
           MOVE BLANK-LINE TO PRINT-AREA.
           PERFORM 350-WRITE-REPORT-LINE.

       500-PRINT-GRAND-TOTALS.
           MOVE GRAND-TOTAL-LINE-1 TO PRINT-AREA.
           WRITE PRINT-AREA.

           IF GRAND-TOTAL-LAST-YTD = ZERO
               MOVE 999.9 TO GRAND-TOTAL-CHANGE-PCT
           ELSE
               COMPUTE GRAND-TOTAL-CHANGE-PCT =
                   (GRAND-TOTAL-CHANGE-AMT / GRAND-TOTAL-LAST-YTD) * 100
           END-IF.

           MOVE GRAND-TOTAL-THIS-YTD TO GTL-SALES-THIS-YTD.
           MOVE GRAND-TOTAL-LAST-YTD TO GTL-SALES-LAST-YTD.
           MOVE GRAND-TOTAL-CHANGE-AMT TO GTL-CHANGE-AMOUNT.
           MOVE GRAND-TOTAL-CHANGE-PCT TO GTL-CHANGE-PERCENT.

           MOVE GRAND-TOTAL-LINE-2 TO PRINT-AREA.
           MOVE 2 TO SPACE-CONTROL.
           PERFORM 350-WRITE-REPORT-LINE.

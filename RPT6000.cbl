      *****************************************************************
      * Title..........: RPT6000 - Future Value Calculator
      * Programmer.....: Ben Stearns and Tristan Joubert
      * Date...........: 4-6-26
      * GitHub URL.....: https://github.com/bstearns07/RPT6000
      * Program Desc...: Updates RPT5000 with more COBOL features
      *                  such as INITIALIZE and PACKED-DECIMAL. Also
      *                  reads in a file as a table for looking up
      *                  a sales rep's name based on their id number
      * File Desc......: Defines the sole source code for application
      *****************************************************************
       IDENTIFICATION DIVISION.

       PROGRAM-ID. RPT6000.

       ENVIRONMENT DIVISION.

       INPUT-OUTPUT SECTION.

       FILE-CONTROL.
           SELECT CUSTMAST ASSIGN TO CUSTMAST.
           SELECT INPUT-SALESREP ASSIGN TO SALESREP.
           SELECT OUTPUT-RPT6000 ASSIGN TO RPT6000.


       DATA DIVISION.

       FILE SECTION.

       FD  CUSTMAST
           RECORDING MODE IS F
           LABEL RECORDS ARE STANDARD
           RECORD CONTAINS 130 CHARACTERS
           BLOCK CONTAINS 130 CHARACTERS.
       COPY CUSTMAST.

       FD INPUT-SALESREP
           RECORDING MODE IS F
           LABEL RECORDS ARE STANDARD
           RECORD CONTAINS 130 CHARACTERS
           BLOCK CONTAINS 130 CHARACTERS.
       COPY SALESREP.

       FD  OUTPUT-RPT6000
           RECORDING MODE IS F
           LABEL RECORDS ARE STANDARD
           RECORD CONTAINS 130 CHARACTERS
           BLOCK CONTAINS 130 CHARACTERS.
       01  PRINT-AREA      PIC X(130).

       WORKING-STORAGE SECTION.

      *****************************************************************
      * Variable and field definitions for the report
      *****************************************************************
      * Defines a table that stores the sales rep's names and ids
       01  SALESREP-TABLE.
           05  SALESREP-GROUP OCCURS 100 TIMES
                              INDEXED BY SRT-INDEX.
               10  SALESREP-NUMBER PIC 9(2).
               10  SALESREP-NAME   PIC X(10).

      * Determines when end of file or a branch record is reached
       01  SWITCHES.
           05  SALESREP-EOF-SWITCH     PIC X    VALUE "N".
              88  SALESREP-EOF                  VALUE "Y".
           05  CUSTMAST-EOF-SWITCH     PIC X    VALUE "N".
              88  CUSTMAST-EOF                  VALUE "Y".
           05  FIRST-RECORD-SWITCH     PIC X    VALUE "Y".
              88 FIRST-RECORD                   VALUE "Y"
                                                  FALSE "N".

      * Stores the old brach number
       01  CONTROL-FIELDS.
           05  OLD-SALESREP-NUMBER PIC 99.
           05  OLD-BRANCH-NUMBER   PIC 99.

      * Controls spacing on the report and when to print heading lines
       01  PRINT-FIELDS        PACKED-DECIMAL.
           05  PAGE-COUNT      PIC S9(3)   VALUE ZERO.
           05  LINES-ON-PAGE   PIC S9(3)   VALUE +55.
           05  LINE-COUNT      PIC S9(3)   VALUE +99.
           05  SPACE-CONTROL   PIC S9.

      * Totals for the report
       01  TOTAL-FIELDS                  PACKED-DECIMAL.
           05  SALESREP-TOTAL-THIS-YTD   PIC S9(6)V99   VALUE ZERO.
           05  SALESREP-TOTAL-LAST-YTD   PIC S9(6)V99   VALUE ZERO.
           05  BRANCH-TOTAL-THIS-YTD     PIC S9(6)V99   VALUE ZERO.
           05  BRANCH-TOTAL-LAST-YTD     PIC S9(6)V99   VALUE ZERO.
           05  GRAND-TOTAL-THIS-YTD      PIC S9(6)V99   VALUE ZERO.
           05  GRAND-TOTAL-LAST-YTD      PIC S9(7)V99   VALUE ZERO.
           05  GRAND-TOTAL-CHANGE        PIC S9(7)V99   VALUE ZERO.

      * Current date and time fields
       01  CURRENT-DATE-AND-TIME.
           05  CD-YEAR         PIC 9999.
           05  CD-MONTH        PIC 99.
           05  CD-DAY          PIC 99.
           05  CD-HOURS        PIC 99.
           05  CD-MINUTES      PIC 99.
           05  FILLER          PIC X(9).

      * Calculated fields for YTD change amount and percent change
       01  CALCULATED-FIELDS   PACKED-DECIMAL.
           05  CHANGE-AMOUNT   PIC S9(5)V99         VALUE ZERO.
           05  CHANGE-PERCENT  PIC S9(3)V9          VALUE ZERO.

      *****************************************************************
      * Define all lines printed on the report
      *****************************************************************
       01  HEADING-LINE-1.
           05  FILLER          PIC X(7)   VALUE "DATE:  ".
           05  HL1-MONTH       PIC 9(2).
           05  FILLER          PIC X(1)   VALUE "/".
           05  HL1-DAY         PIC 9(2).
           05  FILLER          PIC X(1)   VALUE "/".
           05  HL1-YEAR        PIC 9(4).
           05  FILLER          PIC X(24)  VALUE SPACE.
           05  FILLER          PIC X(20)  VALUE "YEAR-TO-DATE SALES R".
           05  FILLER          PIC X(31)  VALUE "EPORT".
           05  FILLER          PIC X(6)   VALUE "PAGE: ".
           05  Hl1-PAGE-NUMBER PIC ZZZ9.
           05  FILLER          PIC X(28)  VALUE SPACE.

       01  HEADING-LINE-2.
           05  FILLER          PIC X(7)   VALUE "TIME:  ".
           05  HL2-HOURS       PIC 9(2).
           05  FILLER          PIC X(1)   VALUE ":".
           05  HL2-MINUTES     PIC 9(2).
           05  FILLER          PIC X(83)  VALUE SPACE.
           05  FILLER          PIC X(7)  VALUE "RPT6000".
           05  FILLER          PIC X(28)  VALUE SPACE.

       01  HEADING-LINE-3.
           05  FILLER           PIC X(54)  VALUE SPACES.
           05  FILLER           PIC X(19)  VALUE "SALES         SALES".
           05  FILLER           PIC X(9)   VALUE SPACES.
           05  FILLER           PIC X(18)  VALUE "CHANGE      CHANGE".
           05  FILLER           PIC X(31)  VALUE SPACE.

       01  HEADING-LINE-4.
           05  FILLER         PIC X(17)  VALUE "BRANCH   SALESREP".
           05  FILLER         PIC X(13)  VALUE SPACES.
           05  FILLER         PIC X(8)   VALUE "CUSTOMER".
           05  FILLER         PIC X(14)  VALUE SPACES.
           05  FILLER         PIC X(22)  VALUE "THIS YTD      LAST YTD".
           05  FILLER         PIC X(8)   VALUE SPACES.
           05  FILLER         PIC X(19)  VALUE "AMOUNT      PERCENT".
           05  FILLER         PIC X(30)  VALUE SPACE.

       01  HEADING-LINE-5.
           05  FILLER           PIC X(6)   VALUE ALL '-'.
           05  FILLER           PIC X(1)   VALUE SPACE.
           05  FILLER           PIC X(13)  VALUE ALL '-'.
           05  FILLER           PIC X(1)   VALUE SPACE.
           05  FILLER           PIC X(26)   VALUE ALL '-'.
           05  FILLER           PIC X(4)   VALUE SPACE.
           05  FILLER           PIC X(11)  VALUE ALL '-'.
           05  FILLER           PIC X(3)   VALUE SPACE.
           05  FILLER           PIC X(11)  VALUE ALL '-'.
           05  FILLER           PIC X(4)   VALUE SPACE.
           05  FILLER           PIC X(11)  VALUE ALL '-'.
           05  FILLER           PIC X(3)   VALUE SPACE.
           05  FILLER           PIC X(8)   VALUE ALL '-'.
           05  FILLER           PIC X(30)  VALUE SPACE.

       01 HEADING-LINE-6.
           05  FILLER           PIC X(130) VALUE SPACE.

       01 HEADING-LINE-7.
           05  FILLER      PIC X(51)            VALUE SPACE.
           05  FILLER      PIC X(13)            VALUE ALL "=".
           05  FILLER      PIC X(1)             VALUE SPACE.
           05  FILLER      PIC X(13)            VALUE ALL "=".
           05  FILLER      PIC X(1)             VALUE SPACE.
           05  FILLER      PIC X(13)            VALUE ALL "=".
           05  FILLER      PIC X(2)             VALUE SPACE.
           05  FILLER      PIC X(8)             VALUE ALL "=".
           05  FILLER      PIC X(27)            VALUE SPACE.

       01  CUSTOMER-LINE.
           05  FILLER               PIC X(2)       VALUE SPACE.
           05  CL-BRANCH-NUMBER     PIC X(2).
           05  FILLER               PIC X(3)       VALUE SPACE.
           05  CL-SALESREP-NUMBER   PIC X(2).
           05  FILLER               PIC X(1)       VALUE SPACE.
           05  CL-SALESREP-NAME     PIC X(10).
           05  FILLER               PIC X(1)       VALUE SPACE.
           05  CL-CUSTOMER-NUMBER   PIC X(5).
           05  FILLER               PIC X(1)       VALUE SPACE.
           05  CL-CUSTOMER-NAME     PIC X(20).
           05  FILLER               PIC X(6)       VALUE SPACE.
           05  CL-SALES-THIS-YTD    PIC ZZ,ZZ9.99-.
           05  FILLER               PIC X(4)       VALUE SPACE.
           05  CL-SALES-LAST-YTD    PIC ZZ,ZZ9.99-.
           05  FILLER               PIC X(4)       VALUE SPACE.
           05  CL-CHANGE-AMOUNT     PIC ZZ,ZZ9.99-.
           05  FILLER               PIC X(2)       VALUE SPACE.
           05  CL-CHANGE-PERCENT    PIC +++9.9.
           05  CL-CHANGE-PERCENT-R  REDEFINES  CL-CHANGE-PERCENT
                                    PIC X(6).
           05  FILLER               PIC X(31)      VALUE SPACE.

       01  SALESREP-TOTAL-LINE.
           05  FILLER               PIC X(36)   VALUE SPACE.
           05  FILLER               PIC X(16)   VALUE "SALESREP TOTAL".
           05  STL-SALES-THIS-YTD   PIC $$$,$$9.99-.
           05  FILLER               PIC X(3)    VALUE SPACE.
           05  STL-SALES-LAST-YTD   PIC $$$,$$9.99-.
           05  FILLER               PIC X(3)    VALUE SPACE.
           05  STL-CHANGE-AMOUNT    PIC $$$,$$9.99-.
           05  FILLER               PIC X(2)    VALUE SPACE.
           05  STL-CHANGE-PERCENT   PIC +++9.9.
           05  STL-CHANGE-PERCENT-R REDEFINES STL-CHANGE-PERCENT
                                    PIC X(6).
           05  FILLER               PIC X(31)   VALUE "*".

       01  BRANCH-TOTAL-LINE.
           05  FILLER               PIC X(36)   VALUE SPACE.
           05  FILLER               PIC X(16)   VALUE "  BRANCH TOTAL".
           05  BTL-SALES-THIS-YTD   PIC $$$,$$9.99-.
           05  FILLER               PIC X(3)    VALUE SPACE.
           05  BTL-SALES-LAST-YTD   PIC $$$,$$9.99-.
           05  FILLER               PIC X(3)    VALUE SPACE.
           05  BTL-CHANGE-AMOUNT    PIC $$$,$$9.99-.
           05  FILLER               PIC X(2)    VALUE SPACE.
           05  BTL-CHANGE-PERCENT   PIC +++9.9.
           05  BTL-CHANGE-PERCENT-R REDEFINES BTL-CHANGE-PERCENT
                                    PIC X(6).
           05  FILLER               PIC X(31)   VALUE "**".

       01  GRAND-TOTAL-LINE.
           05  FILLER               PIC X(36)    VALUE SPACE.
           05  FILLER               PIC X(14)    VALUE "   GRAND TOTAL".
           05  GTL-SALES-THIS-YTD   PIC $,$$$,$$9.99-.
           05  FILLER               PIC X(1)     VALUE SPACE.
           05  GTL-SALES-LAST-YTD   PIC $,$$$,$$9.99-.
           05  FILLER               PIC X(1)     VALUE SPACE.
           05  GTL-CHANGE-AMOUNT    PIC $,$$$,$$9.99-.
           05  FILLER               PIC X(2)     VALUE SPACE.
           05  GTL-CHANGE-PERCENT   PIC +++9.9.
           05  GTL-CHANGE-PERCENT-R REDEFINES GTL-CHANGE-PERCENT
                                    PIC X(6).
           05  FILLER               PIC X(30)    VALUE "***".


       PROCEDURE DIVISION.

      *****************************************************************
      * Main processing logic for app
      *****************************************************************
       000-PREPARE-SALES-REPORT.
           INITIALIZE SALESREP-TABLE.
      * Open the customer master file and the report output file
      * Loop through the customer master file until the end is reached
           OPEN INPUT  CUSTMAST
                INPUT  INPUT-SALESREP
                OUTPUT OUTPUT-RPT6000.
           PERFORM 100-FORMAT-REPORT-HEADING.
           PERFORM 200-LOAD-SALESREP-TABLE.
           PERFORM 300-PREPARE-SALES-LINES
                WITH TEST AFTER
                UNTIL CUSTMAST-EOF.
           PERFORM 500-PRINT-GRAND-TOTALS.
           CLOSE CUSTMAST
                INPUT-SALESREP
                OUTPUT-RPT6000.
           STOP RUN.

      *****************************************************************
      * Get current data and time for heading
      *****************************************************************
       100-FORMAT-REPORT-HEADING.

           MOVE FUNCTION CURRENT-DATE TO CURRENT-DATE-AND-TIME.
           MOVE CD-MONTH   TO HL1-MONTH.
           MOVE CD-DAY     TO HL1-DAY.
           MOVE CD-YEAR    TO HL1-YEAR.
           MOVE CD-HOURS   TO HL2-HOURS.
           MOVE CD-MINUTES TO HL2-MINUTES.

       200-LOAD-SALESREP-TABLE.

           PERFORM
              WITH TEST AFTER
              VARYING SRT-INDEX FROM 1 BY 1
              UNTIL SALESREP-EOF
                OR SRT-INDEX > 100
                    PERFORM 210-READ-SALESREP-RECORD
                    IF NOT SALESREP-EOF
                       MOVE SM-SALESREP-NUMBER
                          TO SALESREP-NUMBER (SRT-INDEX)
                       MOVE SM-SALESREP-NAME
                          TO SALESREP-NAME (SRT-INDEX)
                    END-IF
           END-PERFORM.

       210-READ-SALESREP-RECORD.
           READ INPUT-SALESREP
                AT END
                     SET SALESREP-EOF TO TRUE
                END-READ.

      *****************************************************************
      * Prepares each customer line until the end of CUSTMAST reachec
      *****************************************************************
       300-PREPARE-SALES-LINES.

           PERFORM 310-READ-CUSTOMER-RECORD.

      *    Updated logic using EVALUATE TRUE to control what lines to
      *    to prepare for printing based on the current and previous
      *    sales rep and branch numbers
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

      *****************************************************************
      * Procedure for reading the CUSTMAST data file until EOF
      *****************************************************************
       310-READ-CUSTOMER-RECORD.

           READ CUSTMAST
               AT END
                   SET CUSTMAST-EOF TO TRUE
               END-READ.

      *****************************************************************
      * Gets the data for each customer line, calculates change amount
      * and percent change, and prints the line. Also controls when to
      * print the heading lines based on the number of lines printed on
      *****************************************************************
       320-PRINT-CUSTOMER-LINE.

           IF LINE-COUNT >= LINES-ON-PAGE
              PERFORM 330-PRINT-HEADING-LINES
           END-IF

           EVALUATE TRUE
      *        When the first record of CUSTMAST is read or branch #
      *        changes, print the branch and sales rep #'s + rep name
               WHEN FIRST-RECORD OR CM-BRANCH-NUMBER > OLD-BRANCH-NUMBER
                   MOVE CM-BRANCH-NUMBER   TO CL-BRANCH-NUMBER
                   MOVE CM-SALESREP-NUMBER TO CL-SALESREP-NUMBER
                   PERFORM 325-MOVE-SALESREP-NAME
      *        Otherwise print a blank branch number and determine if
      *        the sales rep number should be printed based on if it is
      *        greater than the previous sales rep number
               WHEN OTHER
                   MOVE SPACES TO CL-BRANCH-NUMBER
                   IF CM-SALESREP-NUMBER > OLD-SALESREP-NUMBER
                       MOVE CM-SALESREP-NUMBER TO CL-SALESREP-NUMBER
                       PERFORM 325-MOVE-SALESREP-NAME
                   ELSE
                       MOVE SPACES TO CL-SALESREP-NUMBER
                       MOVE SPACE TO CL-SALESREP-NAME
                   END-IF
           END-EVALUATE
      *    Move resultiing data to the customer line
           MOVE CM-CUSTOMER-NUMBER TO CL-CUSTOMER-NUMBER
           MOVE CM-CUSTOMER-NAME   TO CL-CUSTOMER-NAME
           MOVE CM-SALES-THIS-YTD  TO CL-SALES-THIS-YTD
           MOVE CM-SALES-LAST-YTD  TO CL-SALES-LAST-YTD
      *    Compute change amount and percent change and move to line
           COMPUTE CHANGE-AMOUNT =
               CM-SALES-THIS-YTD - CM-SALES-LAST-YTD
           MOVE CHANGE-AMOUNT TO CL-CHANGE-AMOUNT

           IF CM-SALES-LAST-YTD = ZERO
               MOVE "  N/A " TO CL-CHANGE-PERCENT-R
           ELSE
               COMPUTE CL-CHANGE-PERCENT ROUNDED =
                   CHANGE-AMOUNT * 100 / CM-SALES-LAST-YTD
                   ON SIZE ERROR
                       MOVE "OVRFLW" TO CL-CHANGE-PERCENT-R
           END-IF

           ADD CM-SALES-THIS-YTD TO SALESREP-TOTAL-THIS-YTD
           ADD CM-SALES-LAST-YTD TO SALESREP-TOTAL-LAST-YTD
           ADD CM-SALES-THIS-YTD TO GRAND-TOTAL-THIS-YTD
           ADD CM-SALES-LAST-YTD TO GRAND-TOTAL-LAST-YTD

           MOVE CUSTOMER-LINE TO PRINT-AREA
           WRITE PRINT-AREA

           ADD 1 TO LINE-COUNT
           MOVE 1 TO SPACE-CONTROL.

      ******************************************************************
      * Looks up a sales rep's name in the sales rep table and moves it
      * to the print area for printing in place of their id number
      ******************************************************************
       325-MOVE-SALESREP-NAME.
           SET SRT-INDEX TO 1.
           SEARCH SALESREP-GROUP
                AT END
                    MOVE "UNKNOWN" TO CL-SALESREP-NAME
                WHEN SALESREP-NUMBER (SRT-INDEX) = CM-SALESREP-NUMBER
                    MOVE SALESREP-NAME (SRT-INDEX) TO CL-SALESREP-NAME
           END-SEARCH.

      *****************************************************************
      * Prints the heading lines at the top of the report and when the
      * number of lines printed on the page reaches the limit. Also
      * resets the line count and controls spacing on the report
      *****************************************************************
       330-PRINT-HEADING-LINES.

           ADD 1 TO PAGE-COUNT.
           MOVE PAGE-COUNT     TO HL1-PAGE-NUMBER.
           MOVE HEADING-LINE-1 TO PRINT-AREA.
           WRITE PRINT-AREA.
           MOVE HEADING-LINE-2 TO PRINT-AREA.
           WRITE PRINT-AREA.
           MOVE HEADING-LINE-6 TO PRINT-AREA.
           WRITE PRINT-AREA.
           MOVE HEADING-LINE-3 TO PRINT-AREA.
           WRITE PRINT-AREA.
           MOVE HEADING-LINE-4 TO PRINT-AREA.
           WRITE PRINT-AREA.
           MOVE HEADING-LINE-5 TO PRINT-AREA.
           WRITE PRINT-AREA.
           MOVE ZERO TO LINE-COUNT.
           MOVE 2 TO SPACE-CONTROL.

      *****************************************************************
      * Procedure for writing a line to the report
      *****************************************************************
       350-WRITE-REPORT-LINE.

           WRITE PRINT-AREA.
           ADD SPACE-CONTROL TO LINE-COUNT.

      *****************************************************************
      * Procedure for printing the sales rep totals line
      * Calculated the same as the branch totals line
      *****************************************************************
       355-PRINT-SALESREP-LINE.

           MOVE SALESREP-TOTAL-THIS-YTD TO STL-SALES-THIS-YTD.
           MOVE SALESREP-TOTAL-LAST-YTD TO STL-SALES-LAST-YTD.
           COMPUTE CHANGE-AMOUNT =
                SALESREP-TOTAL-THIS-YTD - SALESREP-TOTAL-LAST-YTD.
           MOVE CHANGE-AMOUNT TO STL-CHANGE-AMOUNT.
           IF SALESREP-TOTAL-LAST-YTD = ZERO
              MOVE "  N/A " TO STL-CHANGE-PERCENT-R
           ELSE
                COMPUTE STL-CHANGE-PERCENT ROUNDED =
                        CHANGE-AMOUNT * 100 / SALESREP-TOTAL-LAST-YTD
                        ON SIZE ERROR
                            MOVE "OVRFLW" TO STL-CHANGE-PERCENT-R.

      *     MOVE HEADING-LINE-6 TO PRINT-AREA.
      *     PERFORM 350-WRITE-REPORT-LINE.
           MOVE SALESREP-TOTAL-LINE TO PRINT-AREA.
           MOVE 1 TO SPACE-CONTROL.
           PERFORM 350-WRITE-REPORT-LINE.
      *     MOVE HEADING-LINE-6 TO PRINT-AREA.
      *     PERFORM 350-WRITE-REPORT-LINE.
           MOVE 2 TO SPACE-CONTROL.
           ADD SALESREP-TOTAL-THIS-YTD TO BRANCH-TOTAL-THIS-YTD.
           ADD SALESREP-TOTAL-LAST-YTD TO BRANCH-TOTAL-LAST-YTD.
           INITIALIZE SALESREP-TOTAL-THIS-YTD
                      SALESREP-TOTAL-LAST-YTD.

      *****************************************************************
      * Procedure for printing the branch totals line
      * Computes change amount and percentage of change in sales for a
      * branch compared to the same period last year. Also adds the
      * branch totals to the grand totals and resets the branch totals
      *****************************************************************
       360-PRINT-BRANCH-LINE.

           MOVE BRANCH-TOTAL-THIS-YTD TO BTL-SALES-THIS-YTD.
           MOVE BRANCH-TOTAL-LAST-YTD TO BTL-SALES-LAST-YTD.
           COMPUTE CHANGE-AMOUNT =
                BRANCH-TOTAL-THIS-YTD - BRANCH-TOTAL-LAST-YTD.
           MOVE CHANGE-AMOUNT TO BTL-CHANGE-AMOUNT.
           IF BRANCH-TOTAL-LAST-YTD = ZERO
              MOVE "  N/A " TO BTL-CHANGE-PERCENT-R
           ELSE
                COMPUTE BTL-CHANGE-PERCENT ROUNDED =
                        CHANGE-AMOUNT * 100 / BRANCH-TOTAL-LAST-YTD
                        ON SIZE ERROR
                            MOVE "OVRFLW" TO BTL-CHANGE-PERCENT-R.
           MOVE BRANCH-TOTAL-LINE TO PRINT-AREA.
           MOVE 1 TO SPACE-CONTROL.
           PERFORM 350-WRITE-REPORT-LINE.
           MOVE HEADING-LINE-6 TO PRINT-AREA
           PERFORM 350-WRITE-REPORT-LINE
           MOVE 2 TO SPACE-CONTROL.
           ADD BRANCH-TOTAL-THIS-YTD TO GRAND-TOTAL-THIS-YTD.
           ADD BRANCH-TOTAL-LAST-YTD TO GRAND-TOTAL-LAST-YTD.
           INITIALIZE BRANCH-TOTAL-THIS-YTD
                      BRANCH-TOTAL-LAST-YTD.

      *****************************************************************
      * Get grand totals, compute change amount and % change
      * and print the grand total line at the end of the report
      *****************************************************************
       500-PRINT-GRAND-TOTALS.
           MOVE GRAND-TOTAL-THIS-YTD TO GTL-SALES-THIS-YTD.
           MOVE GRAND-TOTAL-LAST-YTD TO GTL-SALES-LAST-YTD.
           COMPUTE CHANGE-AMOUNT =
                GRAND-TOTAL-THIS-YTD - GRAND-TOTAL-LAST-YTD.
           MOVE CHANGE-AMOUNT TO GTL-CHANGE-AMOUNT.
           IF GRAND-TOTAL-LAST-YTD = ZERO
              MOVE 999.99 TO GTL-CHANGE-PERCENT
           ELSE
                COMPUTE GTL-CHANGE-PERCENT ROUNDED =
                        CHANGE-AMOUNT * 100 / GRAND-TOTAL-LAST-YTD
                        ON SIZE ERROR
                            MOVE 999.9 TO GTL-CHANGE-PERCENT.
           MOVE HEADING-LINE-7 TO PRINT-AREA
           MOVE 1 TO SPACE-CONTROL
           PERFORM 350-WRITE-REPORT-LINE
           MOVE GRAND-TOTAL-LINE TO PRINT-AREA.
           MOVE 2 TO SPACE-CONTROL.
           PERFORM 350-WRITE-REPORT-LINE.
; Unfortunately we have not YET installed Windows or Linux on the LC-3,
; so we are going to have to write some operating system code to enable
; keyboard interrupts. The OS code does three things:
;
;    (1) Initializes the interrupt vector table with the starting
;        address of the interrupt service routine. The keyboard
;        interrupt vector is x80 and the interrupt vector table begins
;        at memory location x0100. The keyboard interrupt service routine
;        begins at x1000. Therefore, we must initialize memory location
;        x0180 with the value x1000.
;    (2) Sets bit 14 of the KBSR to enable interrupts.
;    (3) Pushes a PSR and PC to the system stack so that it can jump
;        to the user program at x3000 using an RTI instruction.

            .ORIG   x800
            ; (1) Initialize interrupt vector table.
            LD      R0, VEC
            LD      R1, ISR
            STR     R1, R0, #0
    
            ; (2) Set bit 14 of KBSR.
            LDI     R0, KBSR
            LD      R1, MASK
            NOT     R1, R1
            AND     R0, R0, R1
            NOT     R1, R1
            ADD     R0, R0, R1
            STI     R0, KBSR
    
            ; (3) Set up system stack to enter user space.
            LD      R0, PSR
            ADD     R6, R6, #-1
            STR     R0, R6, #0
            LD      R0, PC
            ADD     R6, R6, #-1
            STR     R0, R6, #0
            ; Enter user space.
            RTI
        
VEC         .FILL   x0180
ISR         .FILL   x1000
KBSR        .FILL   xFE00
MASK        .FILL   x4000
PSR         .FILL   x8002
PC          .FILL   x3000
            .END



            .ORIG   x3000
            ; *** Begin user program code here ***
            ; YOUR CODE HERE
            LEA     R0, STU_ID                   ; print student id
INF_LOOP    PUTS                                 
            JSR     DELAY                        ; delay before printing the next 
            LDI     R1, ADDR_N                   ; R1 <- M[x3FFF]
            BRn     INF_LOOP                     ; if R1 < 0 (i.e. R1 is still xFFFF), continue loop

            ; factorial 
            LD      R0, ZERO_                    ; R0 <- '0'
            ADD     R0, R1, R0                   ; R0 <- N + '0'
            OUT                                  ; print N
            ADD     R1, R1, #-8                  ; R1 <- R1 - 8 
            BRzp    ERROR                        ; N == 8 or 9
            LEA     R0, EQUAL                    ; print "! = "
            PUTS

            LEA     R0, SEVEN                    
            ADD     R1, R1, #1
            BRz     PRINT_RES                    ; N == 7
            LEA     R0, SIX                      
            ADD     R1, R1, #1
            BRz     PRINT_RES                    ; N == 6
            LEA     R0, FIVE
            ADD     R1, R1, #1
            BRz     PRINT_RES                    ; N == 5
            LEA     R0, FOUR
            ADD     R1, R1, #1
            BRz     PRINT_RES                    ; N == 4
            LEA     R0, THREE
            ADD     R1, R1, #1   
            BRz     PRINT_RES                    ; N == 3
            LEA     R0, TWO
            ADD     R1, R1, #1
            BRz     PRINT_RES                    ; N == 2
            LEA     R0, ONE                      ; N == 1 or 0

PRINT_RES   PUTS                                 ; print result
            HALT

ERROR       LEA     R0, ERROR_STR                ; print "! is too large for LC-3."
            PUTS
            HALT


            ; code of delay
DELAY       ST      R1, SAVE_1                   ; save R1
            LD      R1, COUNT
REP         ADD     R1, R1, #-1                  ; count down
            BRp     REP
            LD      R1, SAVE_1                   ; restore R1
            RET


STU_ID      .STRINGZ "PB22000197 "
EQUAL       .STRINGZ "! = "
ERROR_STR   .STRINGZ "! is too large for LC-3."
FULL_STOP   .FILL   x2E                          ; '.'
SAVE_1      .BLKW	1                            ; location to save the 1st param
COUNT       .FILL   2500
ADDR_N      .FILL   x3FFF
ZERO_       .FILL   #48                          ; '0'
ONE         .STRINGZ "1."                        ; 0! or 1!
TWO         .STRINGZ "2."                        ; 2!
THREE       .STRINGZ "6."                        ; 3!
FOUR        .STRINGZ "24."                       ; 4!
FIVE        .STRINGZ "120."                      ; 5!
SIX         .STRINGZ "720."                      ; 6!
SEVEN       .STRINGZ "5040."                     ; 7!


            ; *** End user program code here ***
            .END


            .ORIG   x3FFF
            ; *** Begin factorial data here ***
FACT_N      .FILL   xFFFF
            ; *** End factorial data here ***
            .END


            .ORIG   x1000
            ; *** Begin interrupt service routine code here ***
            ; YOUR CODE HERE
            ST      R0, SAVE_R0                 ; save R0
            ST      R1, SAVE_R1                 ; save R1
            ST      R7, SAVE_R7_1               ; save R7

            LD      R0, LF                      ; R0 <- x0A
            JSR     POLL_OUT                    ; print '\n'

; POLL_IN     LDI     R0, KBSR_                   ; R0 <- M[xFE00]
;             BRzp    POLL_IN                     ; if KBSR[15] == 0, continue polling
            LDI     R0, KBDR                    ; R0 <- M[xFE02]
            JSR     POLL_OUT                    ; echo the input char

            LD      R1, NINE                    ; R1 <- -'9'
            ADD     R1, R0, R1                  ; R1 <- R0 - '9'
            BRp     NOT_DECIMAL                 ; if R0 > '9', then it's not a decimal
            LD      R1, ZERO                    ; R1 <- -'0'
            ADD     R1, R0, R1                  ; R1 <- R0 - '0'
            BRn     NOT_DECIMAL                 ; if R0 < '0', then it's not a decimal
            STI     R1, ADDR_N_                 ; M[x3FFF] <- R1 (R0 - '0')
            LEA     R1, DEC                     ; print " is a decimal digit."
            JSR     PRINT_STR
            BR      RETURN

NOT_DECIMAL LEA     R1, NOT_DEC                 ; print " is not a decimal digit."
            JSR     PRINT_STR

RETURN      LD      R7, SAVE_R7_1               ; restore R7
            LD      R1, SAVE_R1                 ; restore R1
            LD      R0, SAVE_R0                 ; restore R0
            RTI     

            ; print a string whose location is started at R1
PRINT_STR   ST      R7, SAVE_R7_2               ; save R7 
PRINT_LOOP  LDR     R0, R1, #0                  ; R0 <- char to be printed
            BRz     PRINT_END                   ; R0 == '\0', end
            JSR     POLL_OUT                    ; print
            ADD     R1, R1, #1                  ; R1 <- R1 + 1
            BR      PRINT_LOOP                  ; continue loop
PRINT_END   LD      R7, SAVE_R7_2               ; restore R7
            RET

            ; print the char stored in R0
POLL_OUT    LDI     R2, DSR                     ; R1 <- M[xFE04]
            BRzp    POLL_OUT                    ; if DSR[15] == 0, continue polling
            STI     R0, DDR                     ; M[FE06] <- R0
            RET


KBSR_       .FILL   xFE00
KBDR        .FILL   xFE02
DSR         .FILL   xFE04
DDR         .FILL   xFE06
LF          .FILL   x0A                          ; line feed
NOT_DEC     .STRINGZ " is not a decimal digit.\n"
DEC         .STRINGZ " is a decimal digit.\n"
ZERO        .FILL   #-48                         ; -'0'
NINE        .FILL   #-57                         ; -'9'
ADDR_N_     .FILL   x3FFF
SAVE_R0     .BLKW	1
SAVE_R1     .BLKW	1
SAVE_R7_1   .BLKW	1
SAVE_R7_2   .BLKW	1

            ; *** End interrupt service routine code here ***
            .END
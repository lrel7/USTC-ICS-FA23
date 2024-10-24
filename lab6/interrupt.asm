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
            ; LD      R6, USP                      ; initialize USP


            ; YOUR CODE HERE
            LEA     R0, STU_ID                   ; print student id
INF_LOOP    PUTS                                 
            JSR     DELAY                        ; delay before printing the next 
            LDI     R1, ADDR_N                   ; R1 <- M[x3FFF]
            BRn     INF_LOOP                     ; if R1 < 0 (i.e. R1 is still xFFFF), continue loop

            ; factorial subroutine, R1 <- FACTORIAL(R1)
            LD      R4, ZERO_                    ; R4 <- '0'
            ADD     R0, R1, R4                   ; R0 <- N + '0'
            ADD     R2, R1, #-7                  ; R2 <- R1 - 7 
            BRp     ERROR                        ; N == 8 or 9
            ADD     R2, R1, #0                   ; R2 <- R1
FACT_LOOP   BRz     PRINT_RES                    ; if R2 == 0, end
            ADD     R2, R2, #-1                  ; R2 <- R2 - 1
            JSR     MUL                          ; R1 <- R1 * R2
            BR      FACT_LOOP

PRINT_RES   OUT                                  ; print N
            LEA     R0, RESULT                   ; print "! = "
            PUTS
            ADD     R0, R1, R4                   ; print N!
            OUT
            LD      R0, FULL_STOP                ; print '.'
            OUT
            HALT

ERROR       OUT                                  ; print N
            LEA     R0, ERROR_STR                ; print "! is too large for LC-3."
            PUTS
            HALT


            ; code of multiplication: R1 <- R1 * R2 (R2 > 0)
MUL         ST     R2, SAVE_1                    ; save R2
            ADD    R3, R1, #0                    ; R3 <- R1
MUL_LOOP    ADD    R1, R1, R3                    ; R1 <- R1 + R3                    
            ADD    R2, R2, #-1                   ; R2 <- R2 - 1
            BRp    MUL_LOOP                      ; IF R2 > 0, continue loop
            LD     R2, SAVE_1                    ; restore R2
            RET


            ; code of delay
DELAY       ST      R1, SAVE_1                   ; save R1
            LD      R1, COUNT
REP         ADD     R1, R1, #-1                  ; count down
            BRp     REP
            LD      R1, SAVE_1                   ; restore R1
            RET


STU_ID      .STRINGZ "PB22000197 "
RESULT      .STRINGZ "! = "
ERROR_STR   .STRINGZ "! is too large for LC-3."
FULL_STOP   .FILL   x2E                          ; '.'
SAVE_1      .BLKW	1                            ; location to save the 1st param
SAVE_2      .BLKW	1                            ; location to save the 2nd param
COUNT       .FILL   2500
ADDR_N      .FILL   x3FFF
ZERO_       .FILL   #48                          ; '0'


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
POLL_IN     LDI     R0, KBSR_                   ; R0 <- M[xFE00]
            BRzp    POLL_IN                     ; if KBSR[15] == 0, continue polling
            LDI     R0, KBDR                    ; R0 <- M[xFE02]

POLL_OUT    LDI     R1, DSR                     ; R1 <- M[xFE04]
            BRzp    POLL_OUT                    ; if DSR[15] == 0, continue polling
            STI     R0, DDR                     ; M[FE06] <- R0

            LD      R1, ZERO                    ; R1 <- -'0'
            ADD     R1, R0, R1                  ; R1 <- R0 - '0'
            BRn     NOT_DECIMAL                 ; if R0 < '0', then it's not a decimal
            LD      R2, NINE                    ; R2<- -'9'
            ADD     R2, R0, R2                  ; R2 <- R0 - '9'
            BRp     NOT_DECIMAL                 ; if R0 > '9', then it's not a decimal
            STI     R1, ADDR_N_                 ; M[x3FFF] <- R1 (R0 - '0')
            LEA     R0, DEC                     ; print " is a decimal digit."
            PUTS
            RTI

NOT_DECIMAL LEA     R0, NOT_DEC                 ; print " is not a decimal digit."
            PUTS
            RTI     

KBSR_       .FILL   xFE00
KBDR        .FILL   xFE02
DSR         .FILL   xFE04
DDR         .FILL   xFE06
NOT_DEC     .STRINGZ " is not a decimal digit.\n"
DEC         .STRINGZ " is a decimal digit.\n"
ZERO        .FILL   #-48                         ; -'0'
NINE        .FILL   #-57                         ; -'9'
ADDR_N_     .FILL   x3FFF

            ; *** End interrupt service routine code here ***
            .END
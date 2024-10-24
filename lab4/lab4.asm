                .ORIG x3000
                LD R6, TOP_OF_STACK     ; R6 <- top of stack        
                LD R2, ADDR_N           ; R2 <- x3100, the address to store results
                AND R1, R1, #0          ; R1 <- state, init to 0
                LDI R0, ADDR_N          ; R0 <- M[3100] = n
                JSR REMOVE              ; call REMOVE(R0: n) 
                HALT


REMOVE          BRz REMOVE_END          ; i = 0, do nothing
                ADD R3, R0, #-1         ; R3 <- R0 - 1
                BRp REMOVE_START         
                ADD R1, R1, #1          ; i = 1, remove the 1st ring (flip R1[1] from 0 to 1)
                ADD R2, R2, #1          ; increment result address
                STR R1, R2, #0          ; store result
                BR REMOVE_END           ; RET

REMOVE_START    ADD R6, R6, #-1
                STR R7, R6, #0          ; save R7

                ADD R0, R0, #-2         ; R0 <- i - 2
                JSR REMOVE              ; call REMOVE(R0: i - 2)

                ADD R4, R0, #2          ; R4 <- i
                AND R3, R3, #0          
                ADD R3, R3, #1          ; R3 <- 1
SET_REMOVE_MASK ADD R4, R4, #-1         ; R4 <- R4 - 1
                BRz REMOVE_i            ; now R3 = (1 << i)
                ADD R3, R3, R3          ; R3 <- R3 << 1
                BR SET_REMOVE_MASK
REMOVE_i        ADD R1, R1, R3          ; remove the i-th ring (flip R1[i] from 0 to 1)
                ADD R2, R2, #1          ; increment result address
                STR R1, R2, #0          ; store result

                ADD R0, R0, #0          ; R0 <- i - 2
                JSR PUT                 ; call PUT(R0: i - 2)

                ADD R0, R0, #1          ; R0 <- i - 1          
                JSR REMOVE              ; call REMOVE(R0: i - 1)

                ADD R0, R0, #1          ; R0 <- i
                LDR R7, R6, #0          ; restore R7
                ADD R6, R6, #1          
REMOVE_END      RET


PUT             BRz PUT_END             ; i = 0, do nothing
                ADD R3, R0, #-1         ; R3 <- R0 - 1
                BRp PUT_START
                ADD R1, R1, #-1         ; i = 1, put the 1st ring (flip R1[1] from 1 to 0)
                ADD R2, R2, #1          ; increment result address
                STR R1, R2, #0          ; store result
                BR PUT_END

PUT_START       ADD R6, R6, #-1
                STR R7, R6, #0          ; save R7

                ADD R0, R0, #-1         ; R0 <- i - 1
                JSR PUT                 ; call PUT(R0: i - 1)

                ADD R0, R0, #-1         ; R0 <- i - 2
                JSR REMOVE              ; call REMOVE(R0: i - 2)

                ADD R4, R0, #2          ; R4 <- i
                AND R3, R3, #0          
                ADD R3, R3, #1          ; R3 <- 1
SET_PUT_MASK    ADD R4, R4, #-1         ; R4 <- R4 - 1
                BRz PUT_i               ; now R3 = (1 << i)
                ADD R3, R3, R3          ; R3 <- R3 << 1
                BR SET_PUT_MASK
PUT_i           NOT R3, R3
                AND R1, R1, R3          ; put the i-th ring (flip R1[i] from 1 to 0)
                ADD R2, R2, #1          ; increment result address
                STR R1, R2, #0          ; store result

                ADD R0, R0, #0
                JSR PUT                 ; call PUT(R0: i - 2)           

                ADD R0, R0, #2          ; R0 <- i
                LDR R7, R6, #0          ; restore R7
                ADD R6, R6, #1
PUT_END         RET


                TOP_OF_STACK .FILL xFDFF
                ADDR_N       .FILL x3100
                .END

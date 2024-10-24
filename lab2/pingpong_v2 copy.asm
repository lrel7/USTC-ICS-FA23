.ORIG x3000

LDI R2, N       ; load N into R2

LD R7, MOD      ; load 4096 into R7
NOT R7, R7
ADD R7, R7, #1  ; R7 = -4096

AND R0, R0, #0
ADD R0, R0, #3  ; init R0 (v) to 3
AND R1, R1, #0
ADD R1, R1, #2  ; init R1 (d) to 2
AND R6, R6, #0
ADD R6, R6, #3  ; init R6 (last digit of v) to 3

LOOP ADD R2, R2, #-1      ; decrement R2
     BRz DONE             ; R2 == 0 -> done
     ADD R0, R0, R0       ; R0 *= 2
     AND R5, R5, #0       ; clear R5 (a flag indicates whether v subtracts 4096)
     ADD R4, R0, R7       ; R4 = R0 - R7
     BRn NEXT             ; if R0 < 4096, no need to subtract 4096
     ADD R0, R0, R7       ; R0 -= 4096
     ADD R5, R5, #1       ; R5 (flag) = 1
     NEXT ADD R0, R0, R1  ; R0 += d

     ADD R6, R6, R6             ; R6 *= 2
     ADD R4, R6, #-8            ; R4 = R6 - 8
     BRzp TWO                   ; if R6 * 2 >= 8, no need to borrow digit
     ADD R6, R6, #10            ; borrow digit
     TWO ADD R6, R6, R1         ; R6 += d
     ADD R5, R5, #0             ; set cc according to R5
     BRz MINUS10                ; if R5 == 0 (v hasn't subtract 4096), skip the next line
     ADD R6, R6, #-6            ; R6 -= 6 (4096)
     MINUS10 ADD R4, R6, #-10   ; R6 - 10
     BRn JUDGE                  ; if R6 < 10, no need to minus 10
     ADD R6, R6, #-10           ; R6 -= 10
     JUDGE ADD R4, R6, #-8      ; R4 = R6 - 8 
           BRnp MOD8            ; if R6 == 8, flip d and continue the loop, else jump to MOD8
           FLIP NOT R1, R1
                ADD R1, R1, #1  ; R1 = -R1
                BR LOOP

     MOD8 AND R4, R0, #7  ; v % 8
          BRz FLIP        ; if v % 8 == 0, flip d
          BR LOOP

DONE STI R0, RESULT  ; store result
TRAP x25             ; halt

N      .FILL x3102
RESULT .FILL x3103
MOD    .FILL #4096

.END

.ORIG x3000

LDI R3, N       ; load N into R3
NOT	R3,	R3      
ADD	R3,	R3,	#1  ; R3 = -N

LD R7, MOD      ; load 4095 into R7

AND R0, R0, #0
ADD R0, R0, #3  ; init R0 (v) to 3
AND R1, R1, #0
ADD R1, R1, #2  ; init R1 (d) to 2
AND R6, R6, #0
ADD R6, R6, #3  ; init R6 (last digit of v) to 3

AND R2, R2, #0  ; use R2 as counter

LOOP ADD R2, R2, #1  ; increment counter
     ADD R4, R2, R3  ; R2 - N
     BRz DONE        ; R2 == N -> done
     ADD R0, R0, R0  ; R0 *= 2
     AND R0, R0, R7  ; mod 4096
     ADD R0, R0, R1  ; R0 += d
     AND R0, R0, R7  ; mod 4096

     ADD R6, R6, R6         ; R6 *= 2
     BRp MINUS2             ; if R6 * 2 >= 2, no need to borrow digit
     ADD R6, R6, #10        ; borrow digit
     MINUS2 ADD R6, R6, R1  ; R6 += d
     ADD R4, R6, #-10       ; R6 - 10
     BRn JUDGE              ; if R6 < 10, no need to minus 10
     ADD R6, R6, #-10       ; R6 -= 10
     JUDGE ADD R4, R6, #-8  ; R4 = R6 - 8 
           BRnp MOD8         ; if R6 == 8, flip d and continue the loop, else jump to MOD8
           FLIP NOT R1, R1
                ADD R1, R1, #1  ; R1 = -R1
                BR LOOP

     MOD8 AND R4, R0, #7  ; v % 8
          BRz FLIP        ; if v % 8 == 0, flip d
          BR LOOP

DONE STI R0, RESULT
TRAP x25

N .FILL	x3102
RESULT .FILL x3103
MOD .FILL #4095

.END
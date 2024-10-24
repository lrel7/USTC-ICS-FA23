        .ORIG	x3000

        LD	R0,	S0_ADDR  ; address of the next character of s0
        LD	R1,	S1_ADDR  ; address of the next character of s1
LOOP    LDR	R3,	R0,	#0   ; R3 <- char of s0
        LDR	R4,	R1,	#0   ; R4 <- char of s1
        NOT	R4,	R4
        ADD	R4,	R4,	#1   ; R4 <- -R4
        ADD	R2,	R3,	R4   ; R2 <- char0 - char1
        BRnp DONE	     ; if unmatching, done
        ADD	R3,	R3,	#0   ; set cc according to R3
        BRz DONE         ; if char0 == char1 == NULL, done
        ADD	R0,	R0,	#1   ; increment address
        ADD R1, R1, #1   ; increment address
        BR	LOOP         ; continue loop

DONE    STI	R2,	RESULT   ; write result
        HALT
            
S0_ADDR .FILL	x3100
S1_ADDR .FILL	x3200
RESULT  .FILL	x3300
        .END
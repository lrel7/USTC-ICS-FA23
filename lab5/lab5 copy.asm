            .ORIG x3000
INIT        LEA	R1,	INIT_STR        
            JSR	PRINT               ; print init prompt

            LD	R1, W               ; R1 <- -'W'
INPUT_W     IN                      ; wait for the user to enter 'W'
            ADD	R0,	R0,	R1          ; R0 <- R0 - 'W'
            BRnp  INPUT_W           ; input != 'W'

            LEA R1, PROMPT_STR       ; password prompt
            JSR PRINT

            LD	R6,	Y               ; R6 <- -'Y'
            AND	R2,	R2,	#0          ; clear R2
            ADD R2, R2, #3          ; R2 <- 3 (total # of attempts)

; wait for the user to enter the password
INPUT       LEA R3, USER_ENTERED    ; R3: addr to store the next input char
            ADD R4, R3, #9          ; R4: end of the locations to store the user-enterdd password
            NOT R4, R4 
            ADD R4, R4, #1          ; 2's complement of negative of R4
LOOP_INPUT  IN                      ; input
            ADD	R5,	R0, R6          ; R5 <- R0 - 'Y'
            BRz CHECK	            ; input == 'Y', end
            ADD R5, R3, R4          ; R5 <- R3 - R4
            BRp	EXCEED              ; R3 exceeds the bound, the input is definitely wrong 
            STR	R0,	R3, #0          ; store user's input char
            ADD R3, R3, #1          ; increment R3
            BR LOOP_INPUT           ; continue loop

EXCEED      IN
            ADD R5, R0, R6          ; R5 <- R0 - 'Y'
            BRz INCORRECT           ; input == 'Y', directly branch to INCORRECT
            BR EXCEED

; check
CHECK       LEA R0, ANS             ; addr of the next char of ans
            LEA R1, USER_ENTERED    ; addr of the next char of user-entered
LOOP_CHECK  LDR	R3,	R0,	#0          ; R3 <- char of ans
            LDR R4, R1, #0          ; R4 <- char of user-entered
            NOT R4, R4
            ADD R4, R4, #1
            ADD R4, R3, R4          ; R4 <- R3 - R4
            BRnp INCORRECT          ; unmatching, incorrect
            ADD R3, R3, #0          ; set cc according to R3
            BRz  SUCCESS            ; both reaches '\0', success
            ADD R0, R0, #1          ; increment addr
            ADD R1, R1, #1          ; increment addr
            BR LOOP_CHECK

INCORRECT   ADD R2, R2, #-1         ; decrement # of attempts
            BRz FAIL                ; no attempt left, failed
            LEA	R1,	INCORRECT_STR_1
            JSR	PRINT               ; print the first half of the incorrect message
            LD	R0,	ZERO            ; R0 <- x30
            ADD R0, R0, R2          ; R0 <- # of attempts left
            OUT                     ; print the # of attempts left
            LEA R1, INCORRECT_STR_2
            JSR	PRINT               ; print the second half of the incorrect message
            BR  INPUT               ; continue attempt

SUCCESS     LEA R1, SUCCESS_STR
            JSR	PRINT               ; print success message
            HALT

FAIL        LEA R1, FAIL_STR
            JSR	PRINT               ; print fail message
            BR  INIT                ; go back to the init state


; R1: starting addr of the string to be printed
PRINT       ST	R0,	SAVE            ; save R0 because we need to use it
            LDR R0, R1, #0          ; R0 <- char to be printed
            BRz	PRINT_END           ; R0 = '\0', end
            OUT                     ; print
            ADD R1, R1, #1          ; increment R1
            BR PRINT                ; continue loop
PRINT_END   LD	R0,	SAVE            ; restore R0
            RET                     ; return

            
            INIT_STR .STRINGZ	"Welcome to the bank system! Type 'W' to withdraw some fund."
            PROMPT_STR .STRINGZ	"Please input your password:"
            SUCCESS_STR .STRINGZ	"Success!"
            INCORRECT_STR_1 .STRINGZ	"Incorrect password! "
            INCORRECT_STR_2 .STRINGZ	" attempt(s) remain."
            FAIL_STR .STRINGZ	"Fails.\n"
            W .FILL	#-87  ; inverse of the ascii code of 'W'
            Y .FILL #-89  ; inverse of the ascii code of 'Y'
            SAVE .BLKW	1
            ANS .STRINGZ	"PB22000197"  ; answer of the password
            USER_ENTERED .BLKW	10  ; store the user-entered password here
            NULL .FILL	#0
            ZERO .FILL	x30

           .END
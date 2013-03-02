	ORG 00H
	JMP MAIN

	ORG 03H
	JMP STARTorSTOP

	ORG 0BH
	JMP Timer0_interrupt

	ORG 13H
	JMP Clear

STARTorSTOP:
	JBC TR0,STOP ;if TR0=1(Timer0 is working), jump to STOP and make TR0=0(stop Timer0) 
START:
	SETB TR0	 ;if TR0=0(Timer0 is not working), make TR0=1(let timer0 begin to work)
STOP:
	RETI

Clear:
	JNB TR0,Clear_now  ;if TR0=0(Timer0 is not working), jump to Clear_now
	RETI			   ;if TR0=1(Timer0 is working), do nothing
Clear_now:
	MOV R6,#0		   ;clear R6
	MOV P2,#0		   ;clear P2
	RETI

Timer0_interrupt:
	CJNE R7,#0,reload_Timer0  ;if R7 is not equal 0, jump to reload. 2us
	;if R7=0, R6+1 and display R6
	;first adjust if R6=99
	CLR C  ;1us
	MOV A,R6  ;1us
	SUBB A,#99  ;1us
	JZ Clear_display        ;if R6=99,jump to Clear_display. 2us
	INC R6				      ;if R6 is not equal 99, R6+1 and display. 1us
	MOV A,R6    ;1us
	MOV B,#10   ;2us
	DIV AB      ;4us
	RL A        ;1us
	RL A        ;1us
	RL A        ;1us
	RL A        ;1us
	ADD A,B     ;1us
	MOV P2,A    ;1us
	;reload Timer0 and R7
	MOV TH0,#HIGH (65536-50000+29)  ;2us
	MOV TL0,#LOW (65536-50000+29)   ;2us
	MOV R7,#20                      ;2us
	RETI                            ;2us
	;total 29us
Clear_display:				  ;clear display
	MOV R6,#0  ;2us
	MOV P2,#0  ;2us
	;reload Timer0 and R7
	MOV TH0,#HIGH (65536-50000+19)  ;2us
	MOV TL0,#LOW (65536-50000+19)   ;2us
	MOV R7,#20  ;2us
	RETI  ;2us
	;total 19us
reload_Timer0:				   
	DEC R7  ;1us
	;reload Timer0
	MOV TH0,#HIGH (65536-50000+9)  ;2us
	MOV TL0,#LOW (65536-50000+9)  ;2us
	RETI  ;2us
	;total 9us


MAIN:
	MOV R6,#0
	MOV P2,#0
	;set INT0 and INT1
	SETB EX0
	SETB IT0
	SETB EX1
	SETB IT1
	;set Timer0 16 bit
	ANL TMOD,#11110001B
	ORL TMOD,#00000001B
	;set Timer0 50000us
	MOV TH0,#HIGH (65536-50000)
	MOV TL0,#LOW (65536-50000)
	;
	MOV R7,#20
	SETB ET0
	SETB EA
	JMP $
	END

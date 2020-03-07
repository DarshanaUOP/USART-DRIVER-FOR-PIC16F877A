;Author: DarshanaAriyarathna || darshana.uop@gmail.com || +94774901245
    processor	16f877a			;Initialize the processor
    #include	<p16f877a.inc>		;Include library


    org	    0x00;
TIMER1  EQU	0x20
TIMER2  EQU	0x21
DISP    EQU	0x22

K4	    equ	0x3C
K3	    EQU	0x23
K2	    EQU	0x24
K1	    EQU	0x25
K0	    EQU	0x26

HIGH_BIT_COPPY	EQU 0x27
LOW_BIT_COPPY	EQU 0x28
NEWS    EQU	0x29    
    
NORTH_H		EQU	0x2A
NORTH_L		EQU	0x2B
EAST_H		EQU	0x2C
EAST_L		EQU	0x2D
SOUTH_H		EQU	0x2E
SOUTH_L		EQU	0x2F
WEST_H		EQU	0x30
WEST_L		EQU	0x31
  
NORTH_H_ZERO	EQU	0x32
NORTH_L_ZERO	EQU	0x33
EAST_H_ZERO	EQU	0x34
EAST_L_ZERO	EQU	0x35
SOUTH_H_ZERO	EQU	0x36
SOUTH_L_ZERO	EQU	0x37
WEST_H_ZERO	EQU	0x38
WEST_L_ZERO	EQU	0x39

ADDITION_H	EQU	0x3A
ADDITION_L	EQU	0x3B
	;0x3C IS USED
ANGLE_H		EQU	0x3D
ANGLE_L		EQU	0x3E
				
ANGLE_REF_H	EQU	0x3F
ANGLE_REF_L	EQU	0x40
	
ANGLE_X_H	EQU	0x41
ANGLE_X_L	EQU	0x42
		
ANGLE_Y_H	EQU	0x43
ANGLE_Y_L	EQU	0x44		
COUNTR		EQU	0x45
		
TEMP_H		EQU	0x46
TEMP_L		EQU	0x47

COUNTR_H	EQU	0x48
COUNTR_L	EQU	0x49
		
    GOTO	Main
    ORG		0x04			    ;origin vector of interrupt
    GOTO	SET_ZERO

Main:
   CALL    INITIALIZE_IC
   CALL	   SET_VALUES_TO_ZERO
   CALL    INITIALIZE_ADC
   CALL    INITIALIZE_LCD
   CALL	   COMPARE_SETTINGS
   CALL	   RX_TX_CONFIG
TEMPLATE
   CALL	    displayClear
   CALL	    GET_VALUES

   CALL	    COMPARE
   CALL	    CALCULATIONS
               
   CALL	    MULTIPLY_X_100
   
   BSF	    PORTB,7
   ;CALL	    DEVIDER
   ;CALL    PRINT_ANGLE
   
   CALL	    WAIT  
   CALL	    WAIT  
   CALL	    WAIT  
   BCF	    PORTB,7
   GOTO	    TEMPLATE
   
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
DEVIDER
  
   RETURN

;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
MULTIPLY_X_100
   MOVLW    d'99'
   MOVWF    COUNTR   
   ;+++++++++++++++++++++++++
   MOVLW    B'00101110'
   MOVWF    ANGLE_X_L
   
   MOVLW    B'00000001'
   MOVWF    ANGLE_X_H
   
   ;+++++++++++++++++++++++++
   
   MOVF	    ANGLE_X_H,0
   MOVWF    TEMP_H
   MOVF	    ANGLE_X_L,0
   MOVWF    TEMP_L
   
START_MULTYPLY_L
   MOVF	    TEMP_L,0
   ADDWF    ANGLE_X_L,1
   BTFSC    STATUS,0
	    GOTO    ADD_ONE
	    GOTO    ADD_ZERO	    
ADD_ONE	
	    MOVLW   d'1'
	    GOTO    ADD_TO_H
ADD_ZERO
	    MOVLW   d'0'
	    GOTO    ADD_TO_H
ADD_TO_H
    ADDWF   ANGLE_X_H,1
    MOVLW   d'1'
    SUBWF   COUNTR,1
    BTFSC   STATUS,2
	GOTO    MULTIPLY_X_100_H	    ;MULTIPLY_X_100_H
	GOTO    START_MULTYPLY_L
	
MULTIPLY_X_100_H
    MOVLW    d'99'
    MOVWF    COUNTR
    
START_MULTYPLY_H
	MOVF	    TEMP_H,0
	ADDWF    ANGLE_X_H,1
	
	MOVLW   d'1'
	SUBWF   COUNTR,1
	BTFSC   STATUS,2
	    GOTO    END_MULTIPLY	    ;MULTIPLY_X_100_H
	    GOTO    START_MULTYPLY_H
END_MULTIPLY
    CALL    set_DDRAM_address_to_line2
    MOVLW   'Z'
    CALL    PRINT_CHAR
    MOVF    ANGLE_X_H,0
    MOVWF   HIGH_BIT_COPPY
    
    MOVF    ANGLE_X_L,0
    MOVWF   LOW_BIT_COPPY
    
    CALL    PRINT_ER
    CALL    PRINT_ANGLE
   RETURN
   
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
RX_TX_CONFIG
   CALL	    GO_BANK_1
	BCF	TXSTA,6		;Selects 8-bit transmission
	BSF	TXSTA,5		;Transmit enabled
	BCF	TXSTA,4		;Asynchronous mode
	BCF	TXSTA,2		;BRGH{assynchronance low speed mode}
	
	MOVLW	d'31'
	MOVWF	SPBRG		;
   CALL	    GO_BANK_0
	BSF	RCSTA,7		;enable serial port
	BSF	RCSTA,4		;Enables continuous receive
	BSF	RCSTA,3		;Enables address detection, enables interrupt and load of the receive buffer when RSR<8>is set			
	
	RETURN
SEND_DATA
	MOVLW	'A'
	MOVF	K2,0
	CALL	PUSH_DATA
	MOVF	K1,0
	CALL	PUSH_DATA
	MOVF	K1,0
	CALL	PUSH_DATA
	RETURN
;-------------------------------------------------------------
PUSH_DATA
	
	CALL	GO_BANK_1
CHECK_TSR	
	    BTFSS	TXSTA,1	;CHECK TSR REGISTER STATE
		GOTO	CHECK_TSR
		NOP
	CALL	GO_BANK_0
	
	MOVWF	TXREG
	CALL	WAIT
	
	RETURN
;-------------------------------------------------------------
RX_TX_INTERRUPT
	BSF	INTCON,7
	BSF	INTCON,6
	BSF	PIE1,5
	BCF	PIR1,5
	RETURN
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
COMPARE
   CALL	    COMPARISION 
   RETURN
;=====================================
   ;SUBROUTING FOR PRINT THE VALUE OF ANGLE.
PRINT_ANGLE
    CALL    set_DDRAM_address_to_line2

    MOVF    ANGLE_REF_H,0
    MOVWF   HIGH_BIT_COPPY
    
    MOVF    ANGLE_REF_L,0
    MOVWF   LOW_BIT_COPPY
    
    CALL    PRINT_ER
    MOVLW   b'11011111'		    ;DEGREES SYMBOL
    CALL    PRINT_CHAR
    RETURN
;======================================

COMPARISION
   CALL	    PRINT_DIRECTION
   CALL	    GO_BANK_1
   BTFSC    CMCON,7
	GOTO	WD
	GOTO	ED
WD
	CALL	    GO_BANK_1
	BTFSC    CMCON,6
	    GOTO	SW
	    GOTO	NW
	
ED
	CALL	    GO_BANK_1
	BTFSC    CMCON,6
	    GOTO	ES
	    GOTO	NE
	
NE				;N AND E ARE MAX
	CALL	GO_BANK_0
	MOVLW	'['
	CALL	PRINT_CHAR
	MOVLW	'S'
	CALL	PRINT_CHAR
	MOVLW	'W'
	CALL	PRINT_CHAR
	MOVLW	']'
	CALL	PRINT_CHAR
	
	CLRF	SOUTH_H
	CLRF	SOUTH_L
	CLRF	WEST_H
	CLRF	WEST_L
	
	MOVLW	d'180'
	MOVWF	ANGLE_REF_L
	MOVLW	d'0'
	MOVWF	ANGLE_REF_H
	
	MOVF	NORTH_L,0
	MOVWF	ANGLE_Y_L
	MOVF	NORTH_H,0
	MOVWF	ANGLE_Y_H
	
	MOVF	EAST_L,0
	MOVWF	ANGLE_X_L
	MOVF	EAST_H,0
	MOVWF	ANGLE_X_H
	
	GOTO	ENDZ_CMP
ES				;S AND E ARE MAX
	CALL	GO_BANK_0
	MOVLW	'['
	CALL	PRINT_CHAR
	MOVLW	'N'
	CALL	PRINT_CHAR
	MOVLW	'W'
	CALL	PRINT_CHAR
	MOVLW	']'
	CALL	PRINT_CHAR
	
	CLRF	NORTH_H
	CLRF	NORTH_L
	CLRF	WEST_H
	CLRF	WEST_L
	
	MOVLW	b'00001110'
	MOVWF	ANGLE_REF_L
	MOVLW	d'00000001'
	MOVWF	ANGLE_REF_H
	
	MOVF	EAST_L,0
	MOVWF	ANGLE_Y_L
	MOVF	EAST_H,0
	MOVWF	ANGLE_Y_H
	
	MOVF	SOUTH_L,0
	MOVWF	ANGLE_X_L
	MOVF	SOUTH_H,0
	MOVWF	ANGLE_X_H
	
	GOTO	ENDZ_CMP
NW				;N AND W ARE MAX
	CALL	GO_BANK_0
	MOVLW	'['
	CALL	PRINT_CHAR
	MOVLW	'E'
	CALL	PRINT_CHAR
	MOVLW	'S'
	CALL	PRINT_CHAR
	MOVLW	']'
	CALL	PRINT_CHAR
	
	CLRF	SOUTH_H
	CLRF	SOUTH_L
	CLRF	EAST_H
	CLRF	EAST_L
	
	MOVLW	d'90'
	MOVWF	ANGLE_REF_L
	MOVLW	d'0'
	MOVWF	ANGLE_REF_H
	
	MOVF	WEST_L,0
	MOVWF	ANGLE_Y_L
	MOVF	WEST_H,0
	MOVWF	ANGLE_Y_H
	
	MOVF	NORTH_L,0
	MOVWF	ANGLE_X_L
	MOVF	NORTH_H,0
	MOVWF	ANGLE_X_H
	
	GOTO	ENDZ_CMP
SW				;S AND W ARE MAX
	CALL	GO_BANK_0
	MOVLW	'['
	CALL	PRINT_CHAR
		
	MOVLW	'N'
	CALL	PRINT_CHAR
	MOVLW	'E'
	CALL	PRINT_CHAR
	MOVLW	']'
	CALL	PRINT_CHAR
	
	CLRF	NORTH_H
	CLRF	NORTH_L
	CLRF	EAST_H
	CLRF	EAST_L
	
	
	MOVLW	d'0'
	MOVWF	ANGLE_REF_L
	MOVLW	d'0'
	MOVWF	ANGLE_REF_H
	
	MOVF	SOUTH_L,0
	MOVWF	ANGLE_Y_L
	MOVF	SOUTH_H,0
	MOVWF	ANGLE_Y_H
	
	MOVF	WEST_L,0
	MOVWF	ANGLE_X_L
	MOVF	WEST_H,0
	MOVWF	ANGLE_X_H
	
	GOTO	ENDZ_CMP
ENDZ_CMP
   RETURN
;------------------------------------------

COMPARE_SETTINGS
   CALL	    GO_BANK_1
	BCF CMCON,5
	BCF CMCON,4
	
	BCF CMCON,2
	BSF CMCON,1
	BCF CMCON,0
   CALL	    GO_BANK_0
   
   RETURN
;------------------------------------------   
CALCULATIONS
    CALL    SUBSTRACT
    CALL    ADDITION_OF_FOUR    
    RETURN
;------------------------------------------
   
PRINT_ER
   ;TO USE PRINT_ER FUNCTION
    ;HIGH_BIT_COPPY AND LOW_BIT_COPPY REGISTERS SHOULD BE USE 
    
    GOTO    PROCESS_HIGH_VALUE
XP
    CALL    PRINT_K_VALUES
    CALL    K_VALUES_TO_ZERO
   ;CALL    set_DDRAM_address_to_line1

    RETURN
;------------------------------------------

ADDITION_ZERO
    CLRF    ADDITION_H
    CLRF    ADDITION_L

    RETURN
;------------------------------------------

ADDITION_OF_FOUR
    CALL    ADDITION_ZERO  
    BCF	    STATUS,0

    MOVF    NORTH_L,0
    ADDWF   ADDITION_L,1
    BTFSC   STATUS,0
	    GOTO    A1N
	    GOTO    A2N
A1N
	    MOVLW   d'1'
	    GOTO    T2N
A2N
	    MOVLW   d'0'
	    GOTO    T2N
T2N
    ADDWF   ADDITION_H,1
    MOVF    NORTH_H,0
    ADDWF   ADDITION_H,1
;-----------------------------------------------------
    
    MOVF    EAST_L,0
    ADDWF   ADDITION_L,1
    BTFSC   STATUS,0
	    GOTO    A1E
	    GOTO    A2E
A1E
	    MOVLW   d'1'
	    GOTO    T2E
A2E
	    MOVLW   d'0'
	    GOTO    T2E
T2E
    ADDWF   ADDITION_H,1
    MOVF    EAST_H,0
    ADDWF   ADDITION_H,1
;-----------------------------------------------------
    
    MOVF    SOUTH_L,0
    ADDWF   ADDITION_L,1
    BTFSC   STATUS,0
	    GOTO    A1S
	    GOTO    A2S
A1S
	    MOVLW   d'1'
	    GOTO    T2S
A2S
	    MOVLW   d'0'
	    GOTO    T2S
T2S
    ADDWF   ADDITION_H,1
    MOVF    SOUTH_H,0
    ADDWF   ADDITION_H,1

;-----------------------------------------------------

    MOVF    WEST_L,0
    ADDWF   ADDITION_L,1
    BTFSC   STATUS,0
	    GOTO    A1W
	    GOTO    A2W
A1W
	    MOVLW   d'1'
	    GOTO    T2W
A2W
	    MOVLW   d'0'
	    GOTO    T2W
T2W    
	    ADDWF   ADDITION_H,1
    MOVF    WEST_H,0
    ADDWF   ADDITION_H,1
    ;=====================================
    ;MOVF    ADDITION_H,0
    ;MOVWF   HIGH_BIT_COPPY
    
    ;MOVF    ADDITION_L,0
    ;MOVWF   LOW_BIT_COPPY
    
    ;CALL    PRINT_ER
   ;======================================
   
    RETURN
SUBSTRACT
    	;BCF	INTCON,7
	CALL	SUBSTRACT_N
	CALL	SUBSTRACT_E
	CALL	SUBSTRACT_S
	CALL	SUBSTRACT_W
    	;BSF	INTCON,7
	RETURN

SUBSTRACT_N

	MOVF	NORTH_L_ZERO,0
	SUBWF	NORTH_L,1
	
	BTFSC	STATUS,2
	    MOVLW   d'1'
	    MOVLW   d'0'
	SUBWF	NORTH_H,1
	MOVF	NORTH_H_ZERO,0
	SUBWF	NORTH_H,1
    RETURN
    
    ;------------------------------------------------------------------------------
SUBSTRACT_E

	MOVF	EAST_L_ZERO,0
	SUBWF	EAST_L,1
	
	BTFSC	STATUS,2
	    MOVLW   d'1'
	    MOVLW   d'0'
	SUBWF	EAST_H,1
	
	MOVF	EAST_H_ZERO,0
	SUBWF	EAST_H,1
	RETURN

    ;------------------------------------------------------------------------------
SUBSTRACT_S
	
	MOVF	SOUTH_L_ZERO,0
	SUBWF	SOUTH_L,1
	
	BTFSC	STATUS,2
	    MOVLW   d'1'
	    MOVLW   d'0'
	SUBWF	SOUTH_H,1
	
	MOVF	SOUTH_H_ZERO,0
	SUBWF	SOUTH_H,1
	RETURN
    
    ;------------------------------------------------------------------------------
SUBSTRACT_W
	
	MOVF	WEST_L_ZERO,0
	SUBWF	WEST_L,1
	
	BTFSC	STATUS,2
	    MOVLW   d'1'
	    MOVLW   d'0'
	SUBWF	WEST_H,1
	
	MOVF	WEST_H_ZERO,0
	SUBWF	WEST_H,1
        RETURN
    
    ;------------------------------------------------------------------------------
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
SET_VALUES_TO_ZERO
    MOVLW    b'00000000'
    MOVWF    NORTH_H_ZERO
    MOVLW    b'00000000'
    MOVWF    NORTH_L_ZERO
    
    MOVLW    b'00000000'
    MOVWF    EAST_H_ZERO
    MOVLW    b'00000000'
    MOVWF    EAST_L_ZERO
    
    MOVLW    b'00000000'
    MOVWF    SOUTH_H_ZERO
    MOVLW    b'00000000'
    MOVWF    SOUTH_L_ZERO
    
    MOVLW    b'00000000'
    MOVWF    WEST_H_ZERO
    MOVLW    b'00000000'
    MOVWF    WEST_L_ZERO
   RETURN

    
    ;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
SET_ZERO
    	BCF	    INTCON,7
	GOTO	    PRINT_SET_ZERO
RET_POINT
	BCF	    INTCON,1
	BSF	    INTCON,7
	RETFIE
    
PRINT_SET_ZERO
	CALL	set_DDRAM_address_to_line1
	MOVLW	'S'
	CALL	PRINT_CHAR
	MOVLW	'E'
	CALL	PRINT_CHAR
	MOVLW	'T'
	CALL	PRINT_CHAR
	MOVLW	' '
	CALL	PRINT_CHAR
	MOVLW	'Z'
	CALL	PRINT_CHAR
	MOVLW	'E'
	CALL	PRINT_CHAR
	MOVLW	'R'
	CALL	PRINT_CHAR
	MOVLW	'O'
	CALL	PRINT_CHAR
      	MOVLW	' '
	CALL	PRINT_CHAR
      	
	CALL	GET_ZERO
	CALL	WAIT
	CALL	displayClear
	GOTO	RET_POINT
    
GET_ZERO
	CALL	SET_ANALOG_CH0
	CALL	DELAY_50_MS
	CALL	START_CONVERSON
	
LOOP_N
	BTFSC	ADCON0,2
	    GOTO    LOOP_N
		MOVF	ADRESH,0
		MOVWF	NORTH_H_ZERO
	    CALL	GO_BANK_1
		MOVF	ADRESL,0
	    CALL	GO_BANK_0
		MOVWF	NORTH_L_ZERO
	MOVLW	'N'
	CALL	PRINT_CHAR
	;-----------------------------
	CALL	SET_ANALOG_CH1
	CALL	DELAY_50_MS
	CALL	START_CONVERSON
LOOP_E
	BTFSC	ADCON0,2
	    GOTO    LOOP_E
		MOVF	ADRESH,0
		MOVWF	EAST_H_ZERO
	    CALL	GO_BANK_1
		MOVF	ADRESL,0
	    CALL	GO_BANK_0
		MOVWF	EAST_L_ZERO
	MOVLW	'E'
	CALL	PRINT_CHAR
	;-----------------------------
	CALL	SET_ANALOG_CH3
	CALL	DELAY_50_MS
	CALL	START_CONVERSON
LOOP_S
	BTFSC	ADCON0,2
	    GOTO    LOOP_S
		MOVF	ADRESH,0
		MOVWF	SOUTH_H_ZERO
	    CALL	GO_BANK_1
		MOVF	ADRESL,0
	    CALL	GO_BANK_0
		MOVWF	SOUTH_L_ZERO
	MOVLW	'S'
	CALL	PRINT_CHAR
	;-----------------------------
	CALL	SET_ANALOG_CH2
	CALL	DELAY_50_MS
	CALL	START_CONVERSON
LOOP_W
	BTFSC	ADCON0,2
	    GOTO    LOOP_W
		MOVF	ADRESH,0
		MOVWF	WEST_H_ZERO
	    CALL	GO_BANK_1
		MOVF	ADRESL,0
	    CALL	GO_BANK_0
		MOVWF	WEST_L_ZERO
	MOVLW	'W'
	CALL	PRINT_CHAR
	RETURN
   ;-----------------------------
	
    
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    
GET_VALUES
   
	CALL	ADC_ON
	CALL	SET_ANALOG_CH0
	CALL	DELAY_50_MS
	CALL	START_CONVERSON
	
	GOTO    LOOP_NV
LOOP_NV
	BTFSC	ADCON0,2
	    GOTO    LOOP_NV
	    NOP
		MOVF	ADRESH,0
		MOVWF	NORTH_H
	
	    CALL	GO_BANK_1
		MOVF	ADRESL,0
	    CALL	GO_BANK_0
		MOVWF	NORTH_L
	
	CALL	SET_ANALOG_CH1
        CALL DELAY_50_MS
	CALL	START_CONVERSON
LOOP_EV
	BTFSC	ADCON0,2
	    GOTO    LOOP_EV
	    NOP
		MOVF	ADRESH,0
		MOVWF	EAST_H
	    CALL	GO_BANK_1
		MOVF	ADRESL,0
	    CALL	GO_BANK_0
		MOVWF	EAST_L
;-----------------------------
	CALL	SET_ANALOG_CH3
	CALL DELAY_50_MS
	CALL	START_CONVERSON
	
LOOP_SV
	BTFSC	ADCON0,2
	    GOTO    LOOP_SV
	    NOP
		MOVF	ADRESH,0
		MOVWF	SOUTH_H
	    CALL	GO_BANK_1
		MOVF	ADRESL,0
	    CALL	GO_BANK_0
		MOVWF	SOUTH_L
	CALL	SET_ANALOG_CH2
	CALL DELAY_50_MS
	CALL	START_CONVERSON
	
LOOP_WV
	BTFSC	ADCON0,2
	    GOTO    LOOP_WV
	    NOP
		MOVF	ADRESH,0
		MOVWF	WEST_H
	    CALL	GO_BANK_1
		MOVF	ADRESL,0
	    CALL	GO_BANK_0
		MOVWF	WEST_L
P11
	RETURN
    ;-----------------------------
    ;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    
    ;subroutings_for_INITIALIZE_ADC
    
INITIALIZE_ADC
    CALL    CONFIG_ADC_MODULE
    CALL    CONFIG_ADC_INTERUPT
    CALL    DELAY_50_MS		    ;WAIT THE REQURED ACQUISITION TIME
    CALL    START_CONVERSON
    RETURN
    ;______________________________________
CONFIG_ADC_MODULE
	CALL	INITIALIZE_ADC_SETTING
	CALL	ADC_ON
    RETURN
    ;______________________________________
INITIALIZE_ADC_SETTING
	CALL	GO_BANK_0
	    BSF	ADCON0,7    ;CLOCK
	    BCF	ADCON0,6    ;CLOCK
	CALL	GO_BANK_1
	    BSF	ADCON1,6    ;CLOCK
	    BSF	ADCON1,7    ;RESULT_FORMAT
			    ;ADFM: A/D Result Format Select bit
			    ;1 = Right justified. Six (6) Most Significant bits of ADRESH are read as ?0?.
			    ;0 = Left justified. Six (6) Least Significant bits of ADRESL are read as ?0?.
	    BCF	ADCON1,3    
	    BCF	ADCON1,2
	    BSF	ADCON1,1
	    BCF	ADCON1,0
	    
	CALL	GO_BANK_0
	RETURN
    
SET_ANALOG_CH0		   ;NORTH
	    BCF	 ADCON0,3
	    BCF	 ADCON0,4
	    BCF	 ADCON0,5  
    RETURN
    
SET_ANALOG_CH1		    ;EAST
	    BSF	 ADCON0,3
	    BCF	 ADCON0,4
	    BCF	 ADCON0,5 
    RETURN
    
SET_ANALOG_CH2		    ;WEST
	    BCF	 ADCON0,3
	    BSF	 ADCON0,4
	    BCF	 ADCON0,5 
    RETURN
    
SET_ANALOG_CH3		    ;SOUTH
	    BSF	 ADCON0,3
	    BSF	 ADCON0,4
	    BCF	 ADCON0,5 
    RETURN
    
    ;______________________________________
ADC_ON
    	CALL	GO_BANK_0
	BSF	ADCON0,0	
    RETURN
    
ADC_OFF
    	CALL	GO_BANK_0
	BCF	ADCON0,0
    RETURN
    ;______________________________________
CONFIG_ADC_INTERUPT
	BCF	PIR1,6	    ;ADIF(1=CONV CMPLTED,0=NOT COMPLETE)
	BSF	PIE1,6	    ;1 = Enables the A/D converter interrupt/0 = Disables the A/D converter interrupt
	BSF	INTCON,6    ;1 = Enables all unmasked peripheral interrupts/0 = Disables all peripheral interrupts
	BSF	INTCON,7    ;1 = Enables all unmasked interrupts/0 = Disables all interrupts
	NOP
    RETURN
    ;______________________________________
START_CONVERSON
	;CALL	GO_BANK_0
	BSF	ADCON0,2
	;CALL	WAIT
	;CALL	WAIT

    RETURN
    
END_CONVERSON
	BCF	ADCON0,2
    RETURN

    
    
    ;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
K_VALUES_TO_ZERO
	MOVLW	b'00000000'
	MOVWF	K4
	
	MOVLW	b'00000000'
	MOVWF	K3
	
	MOVLW	b'00000000'
	MOVWF	K2
	
	MOVLW	b'00000000'
	MOVWF	K1
	
	MOVLW	b'00000000'
	MOVWF	K0
    RETURN
    ;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

PROCESS_HIGH_VALUE
	;THIS VALUES ONLY FOR THIS PROG: TESTING
        GOTO	FIND_KH2
FIND_KH2
	MOVLW   d'100'
	SUBWF   HIGH_BIT_COPPY,0
	BTFSC   STATUS,0
	    GOTO	CHECK_POIT_2H	
    	    GOTO	FIND_KH1		
	    
FIND_KH1
	MOVLW   d'10'
	SUBWF   HIGH_BIT_COPPY,0
	BTFSC   STATUS,0
	    GOTO	CHECK_POIT_1H   
	    GOTO	FIND_KH0

FIND_KH0
	MOVLW   d'1'
	SUBWF   HIGH_BIT_COPPY,0
	BTFSC   STATUS,0
	    GOTO	CHECK_POIT_0H
	    GOTO	END_3H
	    
END_3H
    	    GOTO    PROCESS_LOWER_VALUE

	;WHEN EXITING FROM "GOTO END_3" IT IS NOT CALCULATE THAT ONE SO NEEDS TO ADD IT
	;CALL	K0_PLUS_ONE
    ;GOTO    UP
    ;______________________________    
CHECK_POIT_2H
	MOVWF	HIGH_BIT_COPPY
	CALL	K2_PLUS_SIX
	CALL	K3_PLUS_FIVE
	CALL	K4_PLUS_TWO
	
    GOTO    FIND_KH2
    ;______________________________ 
CHECK_POIT_1H
	MOVWF	HIGH_BIT_COPPY
	CALL	K1_PLUS_SIX
	CALL	K2_PLUS_FIVE
	CALL	K3_PLUS_TWO
	
    GOTO    FIND_KH1
    ;______________________________ 
CHECK_POIT_0H
	MOVWF	HIGH_BIT_COPPY
	CALL	K0_PLUS_SIX
	CALL	K1_PLUS_FIVE
	CALL	K2_PLUS_TWO
	
    GOTO    FIND_KH0
    
   
    ;______________________________
    ;PROCESS_LOWER_VALUE
    
PROCESS_LOWER_VALUE
    ;IN HERE SET ADRESL VALUE TO LOW_BIT_COPPY
        
	GOTO    FIND_K2
	
FIND_K2
	MOVLW   d'100'
	SUBWF   LOW_BIT_COPPY,0
	BTFSC   STATUS,0
	    GOTO	CHECK_POIT_2	
    	    GOTO	FIND_K1		
	    
FIND_K1
	MOVLW   d'10'
	SUBWF   LOW_BIT_COPPY,0
	BTFSC   STATUS,0
	    GOTO	CHECK_POIT_1    
	    GOTO	FIND_K0

FIND_K0
	MOVLW   d'1'
	SUBWF   LOW_BIT_COPPY,0
	BTFSC   STATUS,0
	    GOTO	CHECK_POIT_0
	    GOTO	END_3
	    
END_3
	
    GOTO    XP
    ;______________________________    
CHECK_POIT_2
	MOVWF	LOW_BIT_COPPY
	CALL	K2_PLUS_ONE
    GOTO    FIND_K2
    ;______________________________ 
CHECK_POIT_1
	MOVWF	LOW_BIT_COPPY
	CALL	K1_PLUS_ONE
    GOTO    FIND_K1
    ;______________________________ 
CHECK_POIT_0
	MOVWF	LOW_BIT_COPPY
	CALL	K0_PLUS_ONE
    GOTO    FIND_K0
    
    ;______________________________
K0_PLUS_ONE
	MOVLW	d'1'
	ADDWF	K0,1
	GOTO	K0_CHECK
K0_PLUS_TWO
	MOVLW	d'2'
	ADDWF	K0,1
	GOTO	K0_CHECK
K0_PLUS_FIVE
	MOVLW	d'5'
	ADDWF	K0,1
	GOTO	K0_CHECK
K0_PLUS_SIX
	MOVLW	d'6'
	ADDWF	K0,1
	GOTO	K0_CHECK
K0_CHECK
	MOVLW	d'10'
	SUBWF	K0,0
	BTFSC	STATUS,1
	   GOTO    K0_MIN_TEN
	   GOTO    END_2
	    
K0_MIN_TEN
		MOVLW   b'00001010'
		SUBWF   K0,1
		GOTO	K1_PLUS_ONE
		GOTO    END_2
    
K1_PLUS_ONE
        MOVLW	d'1'
	ADDWF	K1,1
	GOTO	K1_CHECK
K1_PLUS_TWO
        MOVLW	d'2'
	ADDWF	K1,1
	GOTO	K1_CHECK
K1_PLUS_FIVE
        MOVLW	d'5'
	ADDWF	K1,1
	GOTO	K1_CHECK
K1_PLUS_SIX
        MOVLW	d'6'
	ADDWF	K1,1
	GOTO	K1_CHECK
K1_CHECK
	MOVLW	d'10'
	SUBWF	K1,0
	BTFSC	STATUS,1
	   GOTO    K1_MIN_TEN
	   GOTO    END_2
	    
K1_MIN_TEN
		MOVLW   b'00001010'
		SUBWF   K1,1
		GOTO	K2_PLUS_ONE
		GOTO    END_2
	   
K2_PLUS_ONE
	MOVLW	d'1'
	ADDWF	K2,1
	GOTO	K2_CHECK
K2_PLUS_TWO
	MOVLW	d'2'
	ADDWF	K2,1
	GOTO	K2_CHECK
K2_PLUS_FIVE
	MOVLW	d'5'
	ADDWF	K2,1
	GOTO	K2_CHECK
K2_PLUS_SIX
	MOVLW	d'6'
	ADDWF	K2,1
	GOTO	K2_CHECK
K2_CHECK
	MOVLW	d'10'
	SUBWF	K2,0
	BTFSC	STATUS,1
	   GOTO    K2_MIN_TEN
	   GOTO    END_2
	    
K2_MIN_TEN
	MOVLW   b'00001010'
	SUBWF   K2,1
	GOTO	K3_PLUS_ONE
	GOTO    END_2

K3_PLUS_ONE
	MOVLW	d'1'
	ADDWF	K3,1
	GOTO	K3_CHECK
K3_PLUS_TWO
	MOVLW	d'2'
	ADDWF	K3,1
	GOTO	K3_CHECK
K3_PLUS_FIVE
	MOVLW	d'5'
	ADDWF	K3,1
	GOTO	K3_CHECK
K3_PLUS_SIX
	MOVLW	d'6'
	ADDWF	K3,1
	GOTO	K3_CHECK
K3_CHECK
	MOVLW	D'10'
	SUBWF	K3,0
	
	MOVF	STATUS,0
	;MOVWF	PORTB
	
	BTFSC	STATUS,1
	    GOTO    K3_MIN_TEN
	    GOTO    END_2
	    
K3_MIN_TEN
		MOVLW   b'00001010'
		SUBWF   K3,1
		GOTO	K4_PLUS_ONE
		GOTO    END_2
K4_PLUS_ONE
	MOVLW	d'1'
	ADDWF	K4,1
	GOTO	K4_CHECK
K4_PLUS_TWO
	MOVLW	d'2'
	ADDWF	K4,1
	GOTO	K4_CHECK
K4_PLUS_FIVE
	MOVLW	d'5'
	ADDWF	K4,1
	GOTO	K4_CHECK
K4_PLUS_SIX
	MOVLW	d'6'
	ADDWF	K4,1
	GOTO	K4_CHECK
K4_CHECK
	MOVLW	D'10'
	SUBWF	K4,0
	
	MOVF	STATUS,0
	;MOVWF	PORTB
	
	BTFSC	STATUS,1
	    GOTO    K4_MIN_TEN
	    GOTO    END_2
	    
K4_MIN_TEN
		MOVLW   b'00001010'
		SUBWF   K3,1
		GOTO    END_2

END_2
    RETURN
        
    ;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    
    ;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    ;subroutings_for_INITIALIZE_LCD
INITIALIZE_LCD
	CALL    instructionMode
	CALL    setFunctions
	CALL    setDisplayOnOff
	CALL    displayClear
	CALL    setEntryModule
	CALL	set_CGRAM_address
	CALL	set_DDRAM_address_to_line1
    RETURN
    ;______________________________________
    
instructionMode
	    MOVLW   b'000'
            MOVWF   PORTC
	    CALL    ENABLE_PULSE
    RETURN
    ;______________________________________
dataSendMode
	    ;MOVLW   b'11111111'
	    ;MOVWF   PORTD

            ;MOVLW   b'00001'
            ;MOVWF   PORTC
	    BSF	    PORTC,0
	    ;CALL    ENABLE_PULSE
    RETURN
    ;______________________________________
    
setFunctions
    	CALL    instructionMode
	MOVWF   PORTC
	MOVLW   b'00111000'
	;+----------+-----------+-----------+-----------+-----------+-----------+-----------+-----------+
	;| bit7	    | bit6	| bit5	    | bit4	| bit3	    | bit2	| bit1	    | bit0	|
	;+----------+-----------+-----------+-----------+-----------+-----------+-----------+-----------+
	;|	0   |	0   	|	1   |   1	|0=1 Line   |0=5x8 Dots |	x   |	x   	|
	;|	    |	    	|	    |	    	|1=2 Line   |1=5x11 Dots|	x   |	x   	|
	;+----------+-----------+-----------+-----------+-----------+-----------+-----------+-----------+  
	MOVWF   PORTD
	CALL    ENABLE_PULSE
    RETURN
    ;______________________________________
setDisplayOnOff
	CALL    instructionMode
	MOVLW   b'00001111'
	;+----------+-----------+-----------+-----------+-----------+-----------+-----------+-----------+
	;| bit7	    | bit6      | bit5	    | bit4	| bit3	    | bit2	| bit1	    | bit0      |
	;+----------+-----------+-----------+-----------+-----------+-----------+-----------+-----------+
	;|	0   |	0   	|	0   |	0   	|	1   |0=DispOff  |0=CurserOff|0=BlinkOff |
	;|	    |	    	|	    |	    	|	    |1=DispOn   |1=CurserOn |1=BlinkOn  |
	;+----------+-----------+-----------+-----------+-----------+-----------+-----------+-----------+
	MOVWF   PORTD
	CALL    ENABLE_PULSE
    RETURN
    ;______________________________________
displayClear
    	CALL    instructionMode
	MOVLW   b'00000001'
	;+----------+-----------+-----------+-----------+-----------+-----------+-----------+-----------+
	;| bit7	    | bit6	| bit5	    | bit4      | bit3	    | bit2      | bit1	    | bit0	|
	;+----------+-----------+-----------+-----------+-----------+-----------+-----------+-----------+
	;|	0   |	0	|	0   |	0	|	0   |   0	|	0   |   1	|
	;|	    |		|	    |		|	    |		|	    |		|
	;+----------+-----------+-----------+-----------+-----------+-----------+-----------+-----------+
	MOVWF   PORTD
	CALL    ENABLE_PULSE
	CALL	set_DDRAM_address_to_line1
    RETURN
    ;______________________________________
setEntryModule
       	CALL	instructionMode
	MOVLW   b'00000110'
	;+----------+-----------+-----------+-----------+-----------+-----------+-----------+---------------+
	;| bit7	    | bit6	| bit5	    | bit4      | bit3	    | bit2      | bit1	    | bit0	    |
	;+----------+-----------+-----------+-----------+-----------+-----------+-----------+---------------+
	;|	0   |   0	|	0   |   0	|	0   |   1	|0=Decrement|0=EntireShift  |
	;|	    |		|	    |		|	    |		|   Mode    |   off	    |
	;|	    |		|	    |		|	    |	        |1=Increment|1=EntireShif   |
	;|	    |		|	    |		|	    |		|   Mode    |   on	    |
	;+----------+-----------+-----------+-----------+-----------+-----------+-----------+---------------+
	MOVWF   PORTD
	CALL    ENABLE_PULSE
    RETURN
    
    ;______________________________________
set_CGRAM_address
    	CALL	instructionMode
	MOVLW   b'01000000'	
	;SET CGRAM ADDRESS
	;+----------+-----------+-----------+-----------+-----------+-----------+-----------+-----------+
	;| bit7	    | bit6	| bit5	    |bit4	| bit3	    | bit2	| bit1	    | bit0	|
	;+----------+-----------+-----------+-----------+-----------+-----------+-----------+-----------+
	;|	0   |	1	|	AC5 |	AC4	|	AC3 |	AC2	|	AC1 |	AC0	|
	;+----------+-----------+-----------+-----------+-----------+-----------+-----------+-----------+
	
	MOVWF   PORTD
	CALL    ENABLE_PULSE
    RETURN
    
    ;______________________________________
set_DDRAM_address_to_line1
    	CALL	instructionMode
	MOVLW   b'10000000'	;SET DDRAM ADDRESS
    
	;+----------+-----------+-----------+-----------+-----------+-----------+-----------+-----------+
	;| bit7	    | bit6	| bit5	    | bit4	| bit3	    | bit2	| bit1	    | bit0	|
	;+----------+-----------+-----------+-----------+-----------+-----------+-----------+-----------+
	;|	1   |	AC6	|	AC5 |	AC4	|	AC3 |	AC2	|	AC1 |	AC0	|
	;+----------+-----------+-----------+-----------+-----------+-----------+-----------+-----------+
	    ;DDRAM ADDRESS 1ST Line:00H to 27H
	    ;DDRAM ADDRESS 2ND Line:40H to 67H

	MOVWF   PORTD
	CALL    ENABLE_PULSE
	CALL	dataSendMode
    RETURN
   ;______________________________________
set_DDRAM_address_to_line2
    	CALL	instructionMode
	MOVLW   b'11000000'
	MOVWF   PORTD
	CALL    ENABLE_PULSE
	CALL	dataSendMode

    RETURN
    ;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    ;subroutings_for_INITIALIZE_IC
INITIALIZE_IC
	CALL	GO_BANK_1
	    MOVLW   b'10000000'
	    MOVWF   TRISC
	    MOVLW   b'00000000'
	    MOVWF   TRISD
    	    MOVLW   b'00000001'
	    MOVWF   TRISB
	    
	CALL	GO_BANK_0
	    BSF	    PORTB,0
	    MOVLW   b'000'
	    MOVWF   PORTC

	    MOVLW   b'00000000'
	    MOVWF   PORTD
	    MOVWF   PORTB
	    
	    
	    CALL    IC_INTERRUPT_CONFIG

    RETURN
IC_INTERRUPT_CONFIG
	CALL	GO_BANK_1	    ;SWITCH TO BANK 1
	   
	    bsf	    OPTION_REG,6    ;Interrupt on rising edge of RB0/INT pin
	    bsf	    INTCON,7	    ;Enable all unmasked interrupts
	    bsf	    INTCON,4	    ;Enables the RB0/INT external interrupt
	CALL	GO_BANK_0
    RETURN
    
GO_BANK_0
	BCF	    STATUS,5
        BCF	    STATUS,6
    RETURN
    
GO_BANK_1
	BSF	    STATUS,5
        BCF	    STATUS,6
    RETURN
    
GO_BANK_2
	BCF	    STATUS,5
        BSF	    STATUS,6
    RETURN
    
GO_BANK_3
	BSF	    STATUS,5
        BSF	    STATUS,6
    RETURN
    
ENABLE_PULSE
	
	BSF	    PORTC,2
	CALL    DELAY_50_MS
	BCF	    PORTC,2
	;CALL    DELAY_50_MS
    RETURN
    ;_______________________________________
DELAY_50_MS
	DECFSZ	TIMER1,1
	GOTO	DELAY_50_MS
	;DECFSZ	TIMER2,1
	;GOTO	DELAY_50_MS
	;MOVLW   b'11111111'
	;movwf   TIMER1
    RETURN
    
    ;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    ;subroutings_for_PRINT_IN_LCD
PRINT_DIRECTION
	CALL	displayClear
	MOVLW	'D'
	CALL    PRINT_CHAR
	MOVLW	'i'
	CALL    PRINT_CHAR
	MOVLW	'r'
	CALL    PRINT_CHAR
	MOVLW	'e'
	CALL    PRINT_CHAR
	MOVLW	'c'
	CALL    PRINT_CHAR
	MOVLW	't'
	CALL    PRINT_CHAR
	MOVLW	'i'
	CALL    PRINT_CHAR
	MOVLW	'o'
	CALL    PRINT_CHAR
	MOVLW	'n'
	CALL    PRINT_CHAR
	MOVLW	':'
	CALL    PRINT_CHAR	
    RETURN
    
PRINT_ANGLE_TEXT
	MOVLW	'A'
	CALL    PRINT_CHAR
	MOVLW	'n'
	CALL    PRINT_CHAR
	MOVLW	'g'
	CALL    PRINT_CHAR
	MOVLW	'l'
	CALL    PRINT_CHAR
	MOVLW	'e'
	CALL    PRINT_CHAR
	MOVLW	':'
	CALL    PRINT_CHAR
	
    RETURN
    
PRINT_K_VALUES
	;CALL	PRINT_ANGLE_TEXT
	;CALL	displayClear
	;CALL	set_DDRAM_address_to_line2
	;MOVLW	'+'
	;CALL    PRINT_CHAR
	
	MOVLW	'+'
	CALL    PRINT_CHAR
	
	MOVF	K4,0
	CALL	PUSH_DATA
	CALL	MAKE_LCD_NUMBER
	CALL    PRINT_CHAR
	
	MOVF	K3,0
	CALL	PUSH_DATA
	CALL	MAKE_LCD_NUMBER
	CALL    PRINT_CHAR
	
	MOVF	K2,0
	CALL	PUSH_DATA
	CALL	MAKE_LCD_NUMBER
	CALL    PRINT_CHAR
	
	MOVF	K1,0
		CALL	PUSH_DATA
	CALL	MAKE_LCD_NUMBER
	CALL    PRINT_CHAR
	
	MOVF	K0,0
	CALL	PUSH_DATA
	CALL	MAKE_LCD_NUMBER
	CALL    PRINT_CHAR
	
	MOVLW	','
	CALL	PUSH_DATA

	
	RETURN
;---------------------------   

	
GET_CHARACTER
	ADDWF	PCL,1
	RETLW	'A'
	RETLW	'B'
	RETLW	'C'
	RETLW	'D'
	RETLW	'E'
	RETLW	'F'
	RETLW	'G'
	RETLW	'H'
	
	RETURN
;---------------------------   
	
MAKE_LCD_NUMBER
	ADDLW	b'00110000'
    RETURN
    
PRINT_CHAR
	;CALL	LCD_CHECK_BUSY
	MOVWF  PORTD
	CALL    ENABLE_PULSE
    RETURN
;---------------------------   
LCD_CHECK_BUSY
    GOTO BUSY
BUSY
    BCF	    PORTC,0
    BSF	    PORTC,1
    ;CALL    ENABLE_PULSE
    BTFSC   PORTB,1
	    GOTO    BUSY
	    GOTO    NOT_BUSY
NOT_BUSY
    RETURN
;--------------------------- 
    
    
WAIT
	DECFSZ	TIMER1,1
	GOTO	WAIT
	DECFSZ	TIMER2,1
	GOTO	WAIT
    RETURN  
    
    END
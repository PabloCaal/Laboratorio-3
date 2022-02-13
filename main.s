
    ; Archivo:	    main
    ; Proyecto:	    Laboratorio_03 (Botones y TIMER0)
    ; Dispositivo:  PIC16F887
    ; Autor:	    Pablo Caal
    ; Compilador:   pic-as (v2.30), MPLABX V5.40
    ;
    ; Programa:	Contador de 4-bits empleando el timer 0
    ; Hardware:	Push-botons en el puerto B
    ;
    ; Creado: 07 feb, 2022
    ; Última modificación: 12 feb, 2022
    
    PROCESSOR 16F887
    #include <xc.inc>
    
    ; CONFIG1
	CONFIG  FOSC = INTRC_NOCLKOUT ; Oscillator Selection bits (INTOSCIO oscillator: I/O function on RA6/OSC2/CLKOUT pin, I/O function on RA7/OSC1/CLKIN)
	CONFIG  WDTE = OFF            ; Watchdog Timer Enable bit (WDT disabled and can be enabled by SWDTEN bit of the WDTCON register)
	CONFIG  PWRTE = ON            ; Power-up Timer Enable bit (PWRT enabled)
	CONFIG  MCLRE = OFF           ; RE3/MCLR pin function select bit (RE3/MCLR pin function is digital input, MCLR internally tied to VDD)
	CONFIG  CP = OFF              ; Code Protection bit (Program memory code protection is disabled)
	CONFIG  CPD = OFF             ; Data Code Protection bit (Data memory code protection is disabled)
	
	CONFIG  BOREN = OFF           ; Brown Out Reset Selection bits (BOR disabled)
	CONFIG  IESO = OFF            ; Internal External Switchover bit (Internal/External Switchover mode is disabled)
	CONFIG  FCMEN = OFF           ; Fail-Safe Clock Monitor Enabled bit (Fail-Safe Clock Monitor is disabled)
	CONFIG  LVP = ON              ; Low Voltage Programming Enable bit (RB3/PGM pin has PGM function, low voltage programming enabled)

    ; CONFIG2
	CONFIG  BOR4V = BOR40V        ; Brown-out Reset Selection bit (Brown-out Reset set to 4.0V)
	CONFIG  WRT = OFF             ; Flash Program Memory Self Write Enable bits (Write protection off)

    ; Variables globales
    PSECT udata_bank0		;common memory
	CONT:		DS 1	; Contador
	CONT2:		DS 1	; Contador 2
    
    ; Instrucciones del RESET
    PSECT resVect, class=CODE, abs, delta=2
    ORG 00h			; posición 0000h para el reset
    
    ;------------ VECTOR RESET --------------
	resetVec:
	    PAGESEL main	; Cambio de pagina
	    GOTO    main

    PSECT code, delta=2, abs
    ORG 100h    ; posición 100h para el codigo
	
    ;--------------------------- CONFIGURACIÓN ---------------------------------
    main:
	CALL	CONFIG_OSCC	; Configuración del osciloscopio
	CALL	CONFIG_TIMER0	; Configuracion del TIMER0
	CALL	CONFIG_PORTS	; Comfiguración de los puertos
	BANKSEL PORTB
	CLRF	CONT		; Reseteo de la variable global CONT
	CLRF	CONT2		; Reseteo de la variable global CONT2
	
	MOVF    CONT, W		; Valor de contador a W para buscarlo en la tabla
	CALL    TABLA		; Buscamos caracter de CONT en la tabla ASCII
	MOVWF   PORTC		; Guardamos caracter de CONT en PORTC
	
    loop:
	BTFSC	PORTA, 0	; Comprobar si el botón 1 está presionado
	CALL	antirrebote1
	BTFSC	PORTA, 1	; Comprobar si el botón 2 está presionado
	CALL	antirrebote2	
	CALL	inc_B
	CALL	COMPARACION	; Verificamos si ambos contadores son iguales
	GOTO	loop		; Volvemos a comenzar con el loop
	
    ;----------------------------- SUBRUTINAS ----------------------------------      
    CONFIG_OSCC:
	BANKSEL OSCCON		; Direccionamos al banco 1
	BSF	OSCCON, 0	; Configurar SCS -> 1, Usamos reloj interno
	BCF	OSCCON, 4   
	BCF	OSCCON, 5
	BSF	OSCCON, 6	; Configurar la frecuencia en 1MHz <100>
	return
	
    CONFIG_TIMER0:
	BANKSEL OPTION_REG	; Redireccionamos de banco
	BCF	T0CS		; Configuramos al timer0 como temporizador
	BCF	PSA		; Configurar el Prescaler para el timer0 (No para el Wathcdog timer)
	BSF	PS2
	BSF	PS1
	BSF	PS0		; PS<2:0> -> 111 (Prescaler 1:256)
	CALL	RESET_TIMER	; Reiniciamos la bandera interrupción
	return
	
    CONFIG_PORTS:
	BANKSEL ANSEL
	CLRF	ANSEL		; Definir todas las entradas como digitales
	CLRF	ANSELH
	BANKSEL TRISB		; Configurar como salidas los 4 bits lsb del PORTB
	BCF	TRISB, 0
	BCF	TRISB, 1
	BCF	TRISB, 2
	BCF	TRISB, 3
	BSF	TRISA, 0	; Configurar como entradas los 2 bits lsb del PORTA
	BSF	TRISA, 1
	BCF	TRISC, 0	; Configurar como salidas los 7 bits lsb del PORTC
	BCF	TRISC, 1
	BCF	TRISC, 2
	BCF	TRISC, 3
	BCF	TRISC, 4
	BCF	TRISC, 5
	BCF	TRISC, 6
	BCF	TRISD, 0	; Configurar como salidas los 4 bits lsb del PORTB
	BCF	TRISD, 1
	BCF	TRISD, 2
	BCF	TRISD, 3
	BCF	TRISE, 0
	BANKSEL PORTB		; Reiniciamos el PORTB
	CLRF	PORTB
	CLRF	PORTC
	CLRF	PORTD
	BCF	PORTE, 0	; Reiniciamos el bit 0 del PORTD
	BSF	PORTC, 0
	return   
    
    antirrebote1:
	BTFSC	PORTA, 0	; Comprobar si el botón ya no está presionado
	GOTO	$-1
	INCF    CONT		; Incremento de contador
	MOVF    CONT, W		; Valor de contador a W para buscarlo en la tabla
	CALL    TABLA		; Buscamos caracter de CONT en la tabla ASCII
	MOVWF   PORTC		; Guardamos caracter de CONT en PORTC
	return	

    antirrebote2:
	BTFSC	PORTA, 1	; Comprobar si el botón ya no está presionado
	GOTO	$-1
	DECF    CONT		; Decremento de contador
	MOVF    CONT, W		; Valor de contador a W para buscarlo en la tabla
	CALL    TABLA		; Buscamos caracter de CONT en la tabla ASCII
	MOVWF   PORTC		; Guardamos caracter de CONT en PORTC
	return
    
    RESET_TIMER:
	BANKSEL TMR0		; Redireccionamos de banco
	MOVLW   158
	MOVWF   TMR0		; Cálculo de retardo (100ms)
	BCF	T0IF		; Limpiamos bandera de interrupción
	return
	
    inc_B:
	BTFSS	T0IF		; Comprobar si la bandera T0IF está encendida
	GOTO	$-1
	CALL	RESET_TIMER	; Reiniciamos la bandera de interrupción
	INCF	PORTB
	INCF	CONT2		; Incrementamos el valor del CONT2
	BTFSS	CONT2, 3	; Verificamos si el bit 3 está en "1"
	return
	BTFSS	CONT2, 1	; Verificamos si el bit 1 está en "1"
	return
	INCF	PORTD		
	CLRF	CONT2		; Esta instrucción se ejecuta solo cuando CONT2 = 1010B = 10d
	return
    
    COMPARACION:
	MOVF    CONT, W		; Se mueve el valor del PORTC a W
	SUBWF   PORTD, W	; Se resta W a PORTC
	BTFSC   ZERO		; Verificación de la bandera ZERO
	CALL    LED		; Se llama la subrutina led cero que compara ambos resultados
	return
	
    LED:
	CLRF    CONT2		; Se limpia la variable de la repeticiónde 10 -> 100 ms
	CLRF    PORTD		; Se limpia el contador de segundos
	INCF    PORTE		; Incrementar en 1 el PORTE
	return
		
    ORG 200h
    TABLA:
	CLRF    PCLATH		; Limpiamos registro PCLATH
	BSF	PCLATH, 1	; Posicionamos el PC en dirección 02xxh
	ANDLW   0x0F		; no saltar más del tamaño de la tabla
	ADDWF   PCL		; Apuntamos el PC a caracter en ASCII de CONT
	RETLW   00000001B	; ASCII char 0
	RETLW   01001111B	; ASCII char 1
	RETLW   00010010B	; ASCII char 2
	RETLW   00000110B	; ASCII char 3
	RETLW   01001100B	; ASCII char 4
	RETLW   00100100B	; ASCII char 5
	RETLW   00100000B	; ASCII char 6
	RETLW   00001111B	; ASCII char 7
	RETLW   00000000B	; ASCII char 8
	RETLW   00000100B	; ASCII char 9
	RETLW   00001000B	; ASCII char 10 (A)
	RETLW   01100000B	; ASCII char 11 (B)
	RETLW   00110001B	; ASCII char 12 (C)
	RETLW   01000010B	; ASCII char 13 (D)
	RETLW   00110000B	; ASCII char 14 (E)
	RETLW   00111000B	; ASCII char 15 (F)
    END
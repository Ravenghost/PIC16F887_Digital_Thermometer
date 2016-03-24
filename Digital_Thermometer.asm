;***** -55 +150 C Diapazono skaitmeninis termometras ****
;************* su skystuju kristalu ekranu **************
;**************** ir analoginiu jutikliu ****************
;***************** E.Pupeikis KIKf-12 *******************
;********************************************************
; Mikrovaldiklis PIC16F887
; Kvarcinio rezonatoriaus daznis 4 MHz
;********************************************************
    list p=16F887
    #include <p16F887.inc>
    __CONFIG _CONFIG1, _XT_OSC & _WDT_OFF & _PWRTE_ON & _MCLRE_ON & _CP_OFF & _CPD_OFF & _BOR_OFF & _IESO_OFF & _FCMEN_ON & _LVP_OFF 
    __CONFIG _CONFIG2, _BOR40V & _WRT_OFF
;********************* Kintamieji ***********************
    Temp1H EQU 20h
    Temp1L EQU 21h
    Temp2H EQU 22h
    Temp2L EQU 23h
    Kint0 EQU 24h
    Kint1 EQU 25h
    Kint2 EQU 26h
    Kint3 EQU 27h
    Kint4 EQU 28h
    Kint5 EQU 29h
    Kint6 EQU 2Ah
	Kint7 EQU 2Bh
	skilt2 EQU 2Ch
	skilt3 EQU 2Dh
;********************* Pastoviosios *********************
    E EQU 0
    RS EQU 1
;********************************************************
    ORG 0x000
    clrf PORTA
    clrf PORTC
    clrf PORTD
    banksel TRISA
    movlw b'00000011' ;Nustatomi PORTA0 ir PORTA1 iejimui
    movwf TRISA
    movlw b'00000000'
    movwf TRISC
	movlw b'00000000'
    movwf TRISD
	banksel PORTD
;************** LCD darbo iniciacija ********************
    call Velin200ms
    movlw b'00110000'
    call Komanda
    call Velin5ms
    movlw b'00110000'
    call Komanda
    call Velin5ms
    movlw b'00110000'
    call Komanda
    call Velin5ms
    movlw b'00111000'
    call Komanda
    call Velin5ms
    movlw b'00001000'
    call Komanda
    call Velin5ms
    movlw b'00000001'
    call Komanda
    call Velin5ms
    movlw b'00000100'
    call Komanda
    call Velin5ms
    movlw b'00001100'
    call Komanda
    call Velin5ms
;************ Pradine reiksme LCD ekrane ****************
    movlw b'00000001'
    call Komanda
    call Velin5ms
    movlw b'10000000'
    call Komanda
    call Velin100mks
    movlw 'T'
    call Duomenys
    call Velin100mks
	movlw 'e'
    call Duomenys
    call Velin100mks
	movlw 'm'
    call Duomenys
    call Velin100mks
	movlw 'p'
    call Duomenys
    call Velin100mks
	movlw 'e'
    call Duomenys
    call Velin100mks
	movlw 'r'
    call Duomenys
    call Velin100mks
	movlw 'a'
    call Duomenys
    call Velin100mks
	movlw 't'
    call Duomenys
    call Velin100mks
	movlw 'u'
    call Duomenys
    call Velin100mks
	movlw 'r'
    call Duomenys
    call Velin100mks
	movlw 'a'
    call Duomenys
    call Velin100mks
	movlw ':'
    call Duomenys
    call Velin100mks
	movlw '0'
    call Duomenys
    call Velin100mks
	movlw '0'
    call Duomenys
    call Velin100mks
	movlw '0'
    call Duomenys
    call Velin100mks
	movlw 'C'
    call Duomenys
    call Velin100mks
;******* A/S konvertavimas ir pagrindine programa *******
Start	clrf Temp1H	
	clrf  Temp1L			
	clrf  Temp2H			
	clrf  Temp2L			
	clrf skilt2			
	clrf skilt3
	banksel ADCON1
    movlw b'10000000' ;Nustatomas desininis A/S konvertavimo formatas
    movwf ADCON1
	banksel ANSEL
    movlw b'00000001' ;Nustatomas PORTA0 kaip analoginis iejimas
    movwf ANSEL
	banksel ADCON0
    movlw b'1000001' ;Nustatoma A/S konvertavimo daznis(Fosc/32)
    movwf ADCON0 ;ir pasirenkame AN0 kanala siam A/S konvertavimui
    call Velin1
    bsf ADCON0, GO ;Pradedam pirma A/S konvertavima
    btfsc ADCON0, GO ;Laukiam kol pasibaigs A/S konvertavimas
    goto $-1
    movf ADRESH,w ;Rezultata perkeliam i tam tikrus registrus
    movwf Temp1H
    banksel ADRESL
    movf ADRESL,w
	banksel Temp1L
    movwf Temp1L
    banksel ADCON1
    movlw b'10000000'
    movwf ADCON1
	banksel ANSEL
	movlw b'00000010' ;Nustatomas PORTA1 kaip analoginis iejimas
    movwf ANSEL
	banksel ADCON0
    movlw b'1000101' ;Pasirenkame AN1 kanala siam A/S konvertavimui
    movwf ADCON0
    call Velin1
    bsf ADCON0, GO ;Pradedam antra A/S konvertavima
    btfsc ADCON0, GO
    goto $-1
    movf ADRESH,w
    movwf Temp2H
    banksel ADRESL
    movf ADRESL,w
	banksel Temp2L
    movwf Temp2L
;************* Gautu rezultatu apdorojimas **************
	bcf STATUS,C
	btfsc Temp1H,0 ;jei Temp1H0 = 1 tai su carry bitu dalinam is 2, kitaip be jo
	bsf STATUS,C
	rrf Temp1L
	bcf STATUS,C
	rrf Temp2L
	movf Temp2L,w
	subwf Temp1L ;Temp1L-Temp2L
	btfss STATUS,C ;Jei rezultatas neigiamas einame i programos vieta Minus
	goto Minus
;************** Rezultatu isvedimas i LCD **************
	call Simtai ;Kvieciame paprograme apdoroti simtu skilti
	call Desimtys ;Kvieciame paprograme apdoroti desimciu skilti
	movlw b'10001110'
	call Komanda
	call Velin100mks
	movf Temp1L,w ;Isvedame vienetu skilti
	call lentele
	call Duomenys
	call Velin100mks
	movlw b'10001101'
	call Komanda
	call Velin100mks
	movf skilt2,w ;Isvedame desimciu skilti
	call lentele
	call Duomenys
	call Velin100mks
	movlw b'10001100'
	call Komanda
	call Velin100mks
	movf skilt3,w ;Isvedame simtu skilti
	call lentele
	call Duomenys
	call Velin100mks
	call Velin2
	goto Start
;*********** Neigiamo rezultato apdorojimas *************
Minus	call Minusret ;Kvieciame paprograme apdoroti neigiama A/S rezultata
	call Desimtys
	movlw b'10001110'
	call Komanda
	call Velin100mks
	movf Temp1L,w
	call lentele
	call Duomenys
	call Velin100mks
	movlw b'10001101'
	call Komanda
	call Velin100mks
	movf skilt2,w
	call lentele
	call Duomenys
	call Velin100mks
	movlw b'10001100'
	call Komanda
	call Velin100mks
	movlw '-'
	call Duomenys
	call Velin100mks
	call Velin2
	goto Start
;********************** lentele *************************
lentele
	addwf PCL,f
retlw '0'
retlw '1'
retlw '2'
retlw '3'
retlw '4'
retlw '5'
retlw '6'
retlw '7'
retlw '8'
retlw '9'
;**** Paprogrames aritmetiniui rezultatu apdorojimui ****
;******************* Simtu apdorojimas ****************
Simtai
	movlw d'100'
	subwf Temp1L,f ;Is Temp1L atemame 100
	btfsc STATUS,C ;ir tikriname jei rezultatas teigiamas
	incf skilt3,f ;jei rezultatas teigiamas padidinam skilt3 vienetu, taip panaikindami is
	btfss STATUS,C ;rezultato simta(pvz.:Temp1L=123-100=23) ir turime skilt3 kintamaji isvedimui i LCD
	call Simtret ;jei neigiamas(pvz.: Temp1L=23-100=-77) tai reikia kintamaji grazinti i pradine verte
return
;****************** Simtu grazinimas ********************
Simtret
	comf Temp1L,w ;Invertuojame gauta minusini rezultata (pvz.: inversija(d-77;b1011 0011)=b0100 1100)
	sublw  d'100'
	movwf Temp1L ;ir invertuota rezultata atemame is simto(pvz.: b0110 0100-b0100 1100=b0001 1000;d24)
	decf Temp1L,f ;atemus is rezultato vieneta gausime pradine kintamojo reiksme (pvz.: b0001 1000-b0001=b0001 0111;d23)
return
;***************** Desimciu apdorojimas *****************
Desimtys
    movlw d'10' ;Desimciu apdorojimas veikia taip pat kaip ir simciu, tik reikia padaryti cikla,
    movwf Kint7 ;nes desimciu gali buti 0-90
ciklas5	movlw d'10' ;ciklas daromas 10 kartu, o ne 9 tam, kad gauti neigiama rezultata
	subwf Temp1L,f
	btfsc STATUS,C
	incf skilt2,f
	btfss STATUS,C
	call Desret
	decfsz Kint7,f
	btfsc STATUS,C ;Tikriname ar rezultatas tapo neigiamas pries kartojant cikla 
	goto ciklas5
return
;***************** Desimciu grazinimas *****************
Desret
	comf Temp1L,w
	sublw  d'10'
	movwf Temp1L
	decf Temp1L,f
	bcf STATUS,C ;Isvalome Carry bita, kad galetumem iseiti is ciklo atstacius rezultata
return
;**************** Minuso grazinimas *********************
Minusret
	comf Temp1L,f
	incf Temp1L,f
return
;**************** Komandos paprograme *******************
Komanda
    bcf PORTD,RS
    movwf PORTC
    nop
    nop
    bsf PORTD,E
    nop
    nop
    nop
    bcf PORTD,E
    nop
    nop
return
;**** Duomenu(rodomo zenklo kodo) ikelimo paprograme ****
Duomenys
    bsf PORTD,RS
    movwf PORTC
    nop
    nop
    bsf PORTD,E
    nop
    nop
    nop
    bcf PORTD,E
    nop
    nop
return
;*************** Velinimo ciklu paprogrames *************
;***************** 100 mks velinimas ********************
Velin100mks
    movlw d'33'
    movwf Kint0
ciklas0	decfsz Kint0,f
    goto ciklas0
return
;****************** 5 ms velinimas **********************
Velin5ms
    movlw d'7'
    movwf Kint2
ciklas1	decfsz Kint1,f
    goto ciklas1
    decfsz Kint2,f
    goto ciklas1
return
;***************** 200 ms velinimas *********************
Velin200ms
ciklas2	decfsz Kint1,f
    goto ciklas2
    decfsz Kint3,f
    goto ciklas2
return
;***************** 0,8-200 ms velinimas *****************
Velin1
    movlw d'19'
    movwf Kint4
ciklas3	decfsz Kint1,f
    goto ciklas3
    decfsz Kint4,f
    goto ciklas3
return
;******************* 0,2-50 s velinimas *****************
Velin2
    movlw d'5'
    movwf Kint6
ciklas4	decfsz Kint1,f
    goto ciklas4
    decfsz Kint5,f
    goto ciklas4
    decfsz Kint6,f
    goto ciklas4
return
;********************************************************
END
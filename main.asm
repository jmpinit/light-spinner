.include "tn85def.inc"

.equ    ADC0    = 0x0
.equ    ADC1    = 0x1

; pin definitions

.equ	PIN_LED1	= PB3
.equ	PIN_LED2	= PB4
.equ	PIN_LED3	= PB1
.equ	PIN_LED4	= PB0
.equ	PIN_LIGHT	= PB2

.def    rPositionL      = r25
.def    rPositionH      = r26

.cseg
.org 0
	rjmp	reset

reset:

init_stack:
    ldi         R16, low(RAMEND)
    out         SPL, r16
    ldi         R16, high(RAMEND)
    out         SPH, r16

init_pins:
    sbi		DDRB, PIN_LED1
    sbi		DDRB, PIN_LED2
    sbi		DDRB, PIN_LED3
    sbi		DDRB, PIN_LED4

init_adc:
    ldi         r16, ADC1 | (1<<ADLAR)
    out         ADMUX, r16
    ldi         r16, (1<<ADEN) | (1<<ADPS1) | (1<<ADPS0)
    out         ADCSRA, r16
	
forever:
    ldi         r16, 1
    rcall       short_delay

    rcall       adc_read

    add         rPositionL, r16
    brcc        set_leds
    inc         rPositionH
set_leds: 
    in          r16, PORTB
    andi        r16, ~((1<<PIN_LED1) | (1<<PIN_LED2) | (1<<PIN_LED3) | (1<<PIN_LED4));
    out         PORTB, r16

    cpi         rPositionH, 64
    brlo        led_1
    cpi         rPositionH, 128
    brlo        led_2
    cpi         rPositionH, 196
    brlo        led_3

led_4:
    sbi         PORTB, PIN_LED4
    rjmp        forever
led_3:
    sbi         PORTB, PIN_LED3
    rjmp        forever
led_2:
    sbi         PORTB, PIN_LED2
    rjmp        forever
led_1:
    sbi         PORTB, PIN_LED1
    rjmp	forever

; Read from ADC
; return ADC value in r16
; destroys r16
adc_read:
    sbi         ADCSRA, ADSC
adc_read_loop:
    sbis        ADCSRA, ADIF
    rjmp        adc_read_loop
    in          r16, ADCH
    ret

; Delay for short time
; param r16 is time
; destroys r0, r16
short_delay:
    clr         r0
short_delay0:
    dec         r0
    brne        short_delay0
    dec         r16
    brne        short_delay0
    ret


/* Clock */
.equ CM_PER_GPIO1_CLKCTRL, 0x44e000AC

/* Watch Dog Timer */
.equ WDT_BASE, 0x44E35000

/* GPIO */
.equ GPIO1_OE, 0x4804C134
.equ GPIO1_SETDATAOUT, 0x4804C194
.equ GPIO1_CLEARDATAOUT, 0x4804C190

/* UART */
.equ UART0_BASE, 0x44E09000

/* CPSR */
.equ CPSR_I, 0x80
.equ CPSR_F, 0x40
.equ CPSR_IRQ, 0x12
.equ CPSR_USR, 0x10
.equ CPSR_FIQ, 0x11
.equ CPSR_SVC, 0x13
.equ CPSR_ABT, 0x17
.equ CPSR_UND, 0x18
.equ CPSR_SYS, 0x1F

_start:
    /* init */
    mrs r0, cpsr
    bic r0, r0, #0x1F @ clear mode bits
    orr r0, r0, #0x13 @ set SVC mode
    orr r0, r0, #0xC0 @ disable FIQ and IRQ
    msr cpsr, r0

    bl .cod_hexa
    bl .gpio_setup
    bl .disable_wdt
    //ldr r0, .hello
    //bl .print_string
    
    mov r3, #0x1 
    mov r5, #1
    mov r4, #0

.main_loop:
    /* logical 1 turns on the led, TRM 25.3.4.2.2.2 */
    
    ldr r0, =GPIO1_CLEARDATAOUT      
    ldr r1, =(0xF<<21)		     
    str r1, [r0]		    

    ldr r0, =GPIO1_SETDATAOUT	   
    and r1, r3, LSL #21           
    str r1, [r0]                

    //str r1, [r0] (Debug)
    
    /*contagem*/
    adr r0, .contagem
    bl .print_int
    add r5, r5, #1
    /**********/
    
    bl .delay
    
    add r3, r3, #0x1
    cmp r3, #16      	 
    beq .fim	     	
    and  r3, r3, #0xF       
    b .main_loop         


.delay:
    ldr r1, =0xfffffff
.wait:
    sub r1, r1, #0x1
    cmp r1, #0
    bne .wait
    bx lr

/********************************************************
  Registers (see TRM 20.4.4.1):
    WDT_BASE -> 0x44E35000
    WDT_WSPR -> 0x44E35048
    WDT_WWPS -> 0x44E35034
********************************************************/
.gpio_setup:
    /* set clock for GPIO1, TRM 8.1.12.1.31 */
    ldr r0, =CM_PER_GPIO1_CLKCTRL
    ldr r1, =0x40002
    str r1, [r0]

    /* set pin 21 for output, led USR0, TRM 25.3.4.3 */
    ldr r0, =GPIO1_OE
    ldr r1, [r0]
    bic r1, r1, #(0x1E00000)
    str r1, [r0]
    bx lr

/********************************************************
  WDT disable sequence (see TRM 20.4.3.8):
    1- Write XXXX AAAAh in WDT_WSPR.
    2- Poll for posted write to complete using WDT_WWPS.W_PEND_WSPR. (bit 4)
    3- Write XXXX 5555h in WDT_WSPR.
    4- Poll for posted write to complete using WDT_WWPS.W_PEND_WSPR. (bit 4)
    
  Registers (see TRM 20.4.4.1):
    WDT_BASE -> 0x44E35000
    WDT_WSPR -> 0x44E35048
    WDT_WWPS -> 0x44E35034
********************************************************/
.disable_wdt: 
    /* TRM 20.4.3.8 */
    stmfd sp!,{r0-r1,lr}
    ldr r0, =WDT_BASE
    
    ldr r1, =0xAAAA
    str r1, [r0, #0x48]
    bl .poll_wdt_write

    ldr r1, =0x5555
    str r1, [r0, #0x48]
    bl .poll_wdt_write

    ldmfd sp!,{r0-r1,pc}

.poll_wdt_write:
    ldr r1, [r0, #0x34]
    and r1, r1, #(1<<4)
    cmp r1, #0
    bne .poll_wdt_write
    bx lr
/********************************************************/

/********************************************************
UART0 PUTC (default configuration)
********************************************************/
.uart_putc:
	stmfd sp!, {r1-r2, lr} //push
	ldr r1, =UART0_BASE
	
.wait_tx_fifo_empty:
	ldr r2, [r1, #0x14] 
	and r2, r2, #(1<<5)
	cmp r2, #0
	beq .wait_tx_fifo_empty 
	
	strb r0, [r1]
	ldmfd sp!, {r1-r2, pc}
/********************************************************
imprime uma string até o '\0'
r0 -> endereço da string
********************************************************/
.print_string:
	stmfd sp!, {r0-r2, lr}
	mov r1, r0
.print:
	ldrb r0, [r1], #1
	and r0, r0, #0xff
	cmp r0, #0
	beq .end_print 
	bl .uart_putc
	b .print
	
.end_print:
	ldmfd sp!, {r0-r2, pc}
/******************************************************
contagem
********************************************************/
.print_int:
	stmfd sp!, {r0-r2, lr}
	mov r2, r0
	mov r1, r0
	
	cmp r5, #10
	bne .print_i
	add r4, r4, #1
	mov r5, #0
	
.print_i:
	ldrb r0, [r1], r4
	ldrb r0, [r1], r4
	//and r0, r0, #0xff
	bl .uart_putc
	
	mov r1, r2
	ldrb r0, [r1], r5
	ldrb r0, [r1], r5
	and r0, r0, #0xff
	bl .uart_putc
	
	mov r1, r2
	ldrb r0, [r1], #16
	ldrb r0, [r1], #16
	and r0, r0, #0xff
	bl .uart_putc
	
	mov r1, r2
	ldrb r0, [r1], #17
	ldrb r0, [r1], #17
	and r0, r0, #0xff
	bl .uart_putc
	
.end_print_int:
	ldmfd sp!, {r0-r2, pc}
_end:
/*******************************************************/

/*******************************************************
print_hexa
*******************************************************/
.cod_hexa:
	stmfd sp!, {r0-r4, lr}
	adr r1, _start
	adr r2, _end
	mov r3, #28
	
.loop1:
	ldr r4, [r1]
	mov r4, r4, LSR r3
	and r4, r4, #0xf
	cmp r4, #0xa
	bge .num_char
	add r4, r4, #0x30
	
.loop2:
	mov r0, r4
	bl .uart_putc
	sub r3, r3, #4
	cmp r3, #0
	bge .loop1
	mov r3, #28
	adr r0, .prox_linha
	bl .print_string
	add r1, r1, #0x4
	cmp r1, r2
	bne .loop1
	ldmfd sp!, {r0-r4, pc}
	
.num_char:
	add r4, r4, #0x57
	b .loop2

/******************************************************/

.fim:
b .
.contagem: .asciz "0123456789ABCDEF\n\r"
.hello: .asciz "Hello World!\n\r"
.prox_linha: .asciz "\n\r"






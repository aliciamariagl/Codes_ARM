/* Global Symbols */
.global .uart_putc
.global .uart_getc
.global .uart0_setup
.global .uart0
.global .num
.type .uart_getc, %function
.type .uart_putc, %function


/* Registradores */
.equ UART0_BASE, 0x44E09000
.equ UART0_IER, 0x44E09004

/* Text Section */
.section .text,"ax"
         .code 32
         .align 4
         

/********************************************************
UART0 SETUP 
********************************************************/
.uart0_setup:
	stmfd sp!,{r0-r1,lr}
	
	/* Enable UART0 */
    	ldr r0, =UART0_IER
    	ldr r1, =#(1<<0) 
    	strb r1, [r0]
    	ldr r1, =#(1<<1) 
    	strb r1, [r0]
    	
    	 /* UART0 Interrupt configured as IRQ Priority 0 */
    	//UART0 Interrupt number 72
    	ldr r0, =INTC_ILR
   	ldr r1, =#0    
    	strb r1, [r0, #72]
	
	/* Interrupt mask */
    	ldr r0, =INTC_BASE
    	ldr r1, =#(1<<8)    
    	str r1, [r0, #0xc8] //(72 --> Bit 8 do 3º registrador (MIR CLEAR2))  ;  MIRCLEAR2_BASE = C8
	
	ldmfd sp!,{r0-r1,pc}

/********************************************************/
         
/********************************************************
UART0 PUTC (Default configuration)  
********************************************************/
.global _putc
.type _putc, %function

_putc:
.uart_putc:
    stmfd sp!,{r1-r2,lr}
    ldr     r1, =UART0_BASE

.wait_tx_fifo_empty:
    ldr r2, [r1, #0x14] 
    and r2, r2, #(1<<5)
    cmp r2, #0
    beq .wait_tx_fifo_empty

    strb    r0, [r1]                
    ldmfd sp!,{r1-r2,pc}

/********************************************************
UART0 GETC (Default configuration)  
********************************************************/
.uart_getc:
    stmfd sp!,{r1-r2,lr}
    ldr     r1, =UART0_BASE

.wait_rx_fifo:
    ldr r2, [r1, #0x14] 
    and r2, r2, #(1<<0)
    cmp r2, #0
    beq .wait_rx_fifo

    ldrb    r0, [r1]                 
    ldmfd sp!,{r1-r2,pc}
/********************************************************/

aviso:         .asciz "erro\n\r\0"
tabela1:       .asciz "0123456789-\n\r"
tabela2:       .asciz "0123456789\n\r"

prox_linha:    .asciz "\n\r"


/* Data Section */
.section .data
.align 4

/* BSS Section */
.section .bss
.align 4

.equ BUFFER_SIZE, 16


_buffer_num: .fill BUFFER_SIZE
_cont: .fill 4


_cont_vetor: .fill 4
_vetor: .fill BUFFER_SIZE


_flag: .fill 4



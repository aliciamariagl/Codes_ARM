/* Global Symbols */
.global .uart_putc
.global .uart_getc
.global .uart0_setup
.global .uart0
.global .time_end
.global _cont

.type .uart_getc, %function
.type .uart_putc, %function


/* Registradores */
.equ UART0_BASE, 0x44E09000
.equ UART0_IER, 0x44E09004

.equ ENDERECO, 0x80000710

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
.time_end:
    stmfd sp!,{r1-r2,lr}
    
     bl .uart_getc
     cmp r0, #'\r'
     bleq .enter
     bl .uart_putc
     
     ldr r3, =_cont
     ldrb r2, [r3]
     ldr r4, =_buffer
     strb r0, [r4, r2]
     add r2, r2, #1
     strb r2, [r3]
                    
    ldmfd sp!,{r1-r2,pc}

.enter:
    ldr r0, =prox_linha
    bl .print_string
    
.convertendo:
    ldr r3, =_cont
     ldrb r2, [r3]
     ldr r4, =_buffer
     bl .ascii_to_hex
     
.contabilizando:

 /*    ldr r4, =DMTIMER_TCRR
     mov r0, #0x0
     str r0, [r4]*/
     
     ldr r0, =DMTIMER_IRQENABLE_SET
     mov r1, #0x2
     str r1, [r0]
     
  //   bl .Timer_enable

     mov r14, r15
     mov r15, r3
     add r1, r1, #0
     
  //   bl .Timer_disable
     
 /*    ldr r4, =DMTIMER_IRQENABLE_CLR
     mov r1, #0x2
     str r1, [r4]*/
     
  /*   ldr r4, =DMTIMER_TCRR
     ldr r0, [r4]
     bl .hex_to_ascii
     
     ldr r0, =prox_linha
     bl .print_string*/
     
     bl _start

/********************************************************/

prox_linha:    .asciz "\n\r"


/* Data Section */
.section .data
.align 4

/* BSS Section */
.section .bss
.align 4

.equ BUFFER_SIZE, 16


_buffer: .fill BUFFER_SIZE
_cont: .fill 4


_flag: .fill 4



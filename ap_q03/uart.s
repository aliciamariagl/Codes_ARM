/* Global Symbols */
.global .uart_putc
.global .uart_getc
.global .uart0_setup
.global .uart0
.global .uart
.global _cont1
.global _cont2
.global _flag

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
/********************************************************
UART
********************************************************/
.uart:
     stmfd sp!,{r1-r5,lr}
     
     bl .uart_getc
     cmp r0, #'\r'
     bleq .enter
     bl .uart_putc
     ldr r3, =_flag
     ldrb r2, [r3]
     cmp r2, #1
     bleq .save_num2
     
.save_num1:
     ldr r3, =_cont1
     ldrb r2, [r3]
     ldr r4, =_buffer1
     strb r0, [r4, r2]
     add r2, r2, #1
     strb r2, [r3]
     
     ldmfd sp!,{r1-r5,pc}
     
.save_num2:
     ldr r3, =_cont2
     ldrb r2, [r3]
     ldr r4, =_buffer2
     strb r0, [r4, r2]
     add r2, r2, #1
     strb r2, [r3]

     ldmfd sp!,{r1-r5,pc}
     
.enter:
     ldr r0, =prox_linha
     bl .print_string
     
     ldr r3, =_flag
     ldrb r2, [r3]
     add r2, r2, #1
     strb r2, [r3]
     
     cmp r2, #1
     bleq .prefixo
     
     cmp r2, #2
     bleq .sum_num
     
     ldmfd sp!,{r1-r5,pc}
     
.prefixo:
    ldr r0, =hex_prefix
    mov r1, #2
    bl .print_nstring
    ldmfd sp!,{r1-r5,pc}

/********************************************************/
.sum_num:
     ldr r3, =_cont1
     ldrb r2, [r3]
     ldr r4, =_buffer1
     bl .ascii_to_hex
     
     mov r6, r3
     
     ldr r3, =_cont2
     ldrb r2, [r3]
     ldr r4, =_buffer2
     bl .ascii_to_hex
     
     ldr r0, =hex_prefix
     mov r1, #2
     bl .print_nstring
     add r0, r3, r6
     bl .hex_to_ascii
     
     ldr r0, =prox_linha
     bl .print_string
     
     bl .mascara_cpsr
     
     bl _start
     
     ldmfd sp!,{r1-r5,pc}
/********************************************************/
.mascara_cpsr:
     stmfd sp!,{r1-r5,lr}
     mov r2, #0
     
     mrs r0, cpsr    
     and r1, r0, #0x20             // T    10 0000
     mov r1, r1, lsr #5
     
     add r2, r2, r1
     mov r2, r2, lsl #1
         
     and r1, r0, #0x40             // F   100 0000
     mov r1, r1, lsr #6
     
     add r2, r2, r1
     mov r2, r2, lsl #1
     
     and r1, r0, #0x80             // I      1000 0000
     mov r1, r1, lsr #7
     
     add r2, r2, r1
     mov r2, r2, lsl #1
     
     and r1, r0, #0x1000000      // J     1 0000 0000 0000 0000 0000 0000
     mov r1, r1, lsr #24
     
     add r2, r2, r1
     mov r2, r2, lsl #1
     
     and r1, r0, #0x8000000       // Q     1000 0000 0000 0000 0000 0000 0000
     mov r1, r1, lsr #27
     
     add r2, r2, r1
     mov r2, r2, lsl #1
     
     and r1, r0, #0x10000000      // V    1 0000 0000 0000 0000 0000 0000 0000
     mov r1, r1, lsr #28
     
     add r2, r2, r1
     mov r2, r2, lsl #1
     
     and r1, r0, #0x20000000      // C    10 0000 0000 0000 0000 0000 0000 0000
     mov r1, r1, lsr #29
     
     add r2, r2, r1
     mov r2, r2, lsl #1
     
     and r1, r0, #0x40000000      // Z    100 0000 0000 0000 0000 0000 0000 0000
     mov r1, r1, lsr #30
     
     add r2, r2, r1
     mov r2, r2, lsl #1
     
     and r1, r0, #0x80000000      // N    1000 0000 0000 0000 0000 0000 0000 0000
     mov r1, r1, lsr #31
     
     add r2, r2, r1
     
.print_cpsr:
     mov r4, #9
     mov r3, #0

.loop_print:
     mov r1, r2
     and r1, r1, #0x01
     mov r2, r2, lsr #1
     cmp r1, #0
     bleq .tab0
     cmp r1, #1
     bleq .tab1
     add r3, r3, #1
     cmp r3, r4
     bne .loop_print
     
     ldr r0, =modo
     bl .print_string
     
     ldmfd sp!,{r1-r5,pc}
 
/********************************************************/
.tab0:
     stmfd sp!,{r1-r5,lr}
     
     ldr r1, =tabela0
     ldrb r0, [r1, r3]
     bl .uart_putc

     ldmfd sp!,{r1-r5,pc}
     
.tab1:
     stmfd sp!,{r1-r5,lr}
     
     ldr r1, =tabela1
     ldrb r0, [r1, r3]
     bl .uart_putc

     ldmfd sp!,{r1-r5,pc}

/********************************************************/

modo:               .asciz "_MODO\n\r\0"
tabela0:            .asciz "nzcvqjift"
tabela1:            .asciz "NZCVQJIFT"
prox_linha:         .asciz "\n\r"


/* Data Section */
.section .data
.align 4

/* BSS Section */
.section .bss
.align 4

.equ BUFFER_SIZE, 16


_buffer1: .fill BUFFER_SIZE
_cont1: .fill 4


_buffer2: .fill BUFFER_SIZE
_cont2: .fill 4


_flag: .fill 4



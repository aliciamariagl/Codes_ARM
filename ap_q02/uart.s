/* Global Symbols */
.global .uart_putc
.global .uart_getc
.global .uart0_setup
.global .uart0
.global .numbers
.global _cont_a
.global _cont_b
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

.troca:
    mov r1, r0
    mov r0, r4
    mov r4, r1
    
    bl .volta

/********************************************************
A e B
********************************************************/
.numbers:
    stmfd sp!,{r1-r5,lr}
    
    bl .uart_getc
    cmp r0, #'\r'
    bleq .enter
    mov r1, r0
    bl .uart_putc
    cmp r1, #','
    bleq .prox_num
    
    ldr r1, =tabela                  //erro
    mov r3, #0
    
.loop_num:
    ldrb r2, [r1, r3]         
    cmp r0, r2
    bleq .save
    add r3, r3, #1
    cmp r3, #10
    bne .loop_num
    
   ldmfd sp!,{r1-r5,pc}

/*********************************/
// SALVAR

.save:
    ldr r1, =_cont
    ldrb r2, [r1]
    cmp r2, #1
    bleq .save_b
    
.save_a:
    ldr r3, =_cont_a
    ldrb r2, [r3]              
    ldr r1, =_buffer_a
    strb r0, [r1, r2]         
    add r2, r2, #1
    strb r2, [r3] 
    ldmfd sp!,{r1-r5,pc}

.save_b:
    ldr r3, =_cont_b
    ldrb r2, [r3]              
    ldr r1, =_buffer_b
    strb r0, [r1, r2]         
    add r2, r2, #1
    strb r2, [r3] 
    ldmfd sp!,{r1-r5,pc}
/*********************************/

.prox_num:
    ldr r1, =_cont
    mov r2, #1
    strb r2, [r1]
    
    ldmfd sp!,{r1-r5,pc}

.enter:
    ldr r0, =prox_linha
    bl .print_string
    
    //pegar o numero que esta no buffer a e limpar o buffer
    ldr r4, =_buffer_a
    ldr r3, =_cont_a
    ldrb r2, [r3]
    cmp r2, #0
    bleq .final_enter
    mov r5, #0
    mov r1, #0
    
.loop_a:
    ldrb r0, [r4, r5]
    sub r0, r0, #48
    mov r1, r1, LSL #4
    add r1, r1, r0
    add r5, r5, #1
    cmp r5, r2
    bne .loop_a
    
    bl .hex_to_int
    ldr r3, =_guardar_a
    strb r0, [r3]
  /*  add r0, r0, #48
    bl .uart_putc*/        // TESTE
    
    ldr r3, =_cont_a
    mov r1, #0
    strb r1, [r3]
    
    //pegar o numero que esta no buffer b e limpar o buffer
    ldr r4, =_buffer_b
    ldr r3, =_cont_b
    ldrb r2, [r3]
    cmp r2, #0
    bleq .final_enter
    mov r5, #0
    mov r1, #0
    
.loop_b:
    ldrb r0, [r4, r5]
    sub r0, r0, #48
    mov r1, r1, LSL #4
    add r1, r1, r0
    add r5, r5, #1
    cmp r5, r2
    bne .loop_b
    
    bl .hex_to_int
    ldr r3, =_guardar_b
    strb r0, [r3]
    
    ldr r3, =_cont_b
    mov r1, #0
    strb r1, [r3]
    
    ldr r3, =_cont
    mov r1, #0
    strb r1, [r3]
    
    ldr r3, =_guardar_a
    ldrb r4, [r3]
    ldr r3, =_guardar_b
    ldrb r0, [r3]
     
    cmp r4, r0
    bgt .troca
.volta: 
    bl .regs
  /*  add r0, r0, #48
    bl .uart_putc*/         // TESTE
    
.final_enter:
    ldr r3, =_cont_a
    mov r1, #0
    strb r1, [r3]
    
    ldr r3, =_cont_b
    mov r1, #0
    strb r1, [r3]
    
    ldr r3, =_cont
    mov r1, #0
    strb r1, [r3]
    
    ldmfd sp!,{r1-r5,pc}
    
/********************************************/
    
.regs:
    stmfd sp!,{r1-r5,lr}
    sub r1, r0, r4
    cmp r1, #0
    beq .erro
    add r1, r1, #1
    mov r2, #0
    
.loop_regs:
    cmp r4, #0
    bleq .F0
    
    cmp r4, #1
    bleq .F1
    
    cmp r4, #2
    bleq .F2
    
    cmp r4, #3
    bleq .F3
    
    cmp r4, #4
    bleq .F4
    
    cmp r4, #5
    bleq .F5
    
    cmp r4, #6
    bleq .F6
    
    cmp r4, #7
    bleq .F7
    
    cmp r4, #8
    bleq .F8
    
    cmp r4, #9
    bleq .F9
    
    cmp r4, #10
    bleq .F10
    
    cmp r4, #11
    bleq .F11
    
    cmp r4, #12
    bleq .F12
    
    cmp r4, #13
    bleq .F13
    
    cmp r4, #14
    bleq .F14
    
    cmp r4, #15
    bleq .F15
    
    ldr r0, =prox_linha
    bl .print_string
    
    add r4, r4, #1
    add r2, r2, #1
    cmp r2, r1
    bne .loop_regs

    ldmfd sp!,{r1-r5,pc}
    
.erro:
    ldr r0, =aviso
    bl .print_string
    ldmfd sp!,{r1-r5,pc}
    
/*********************************************************/

aviso:         .asciz "Erro: numeros iguais\n\r\0"
tabela:        .asciz "0123456789\n\r"
prox_linha:    .asciz "\n\r"


/* Data Section */
.section .data
.align 4

/* BSS Section */
.section .bss
.align 4

.equ BUFFER_SIZE, 16


_buffer_a: .fill BUFFER_SIZE
_cont_a: .fill 4


_buffer_b: .fill BUFFER_SIZE
_cont_b: .fill 4

_guardar_a: .fill 4
_guardar_b: .fill 4
_cont: .fill 4



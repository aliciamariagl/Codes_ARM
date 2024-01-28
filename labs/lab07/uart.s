/* Global Symbols */
.global .uart_putc
.global .uart_getc
.global .uart0_setup
.global .uart0
.global .num
.global _cont_vetor
.global _cont
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
    	
    	ldr r3, =_cont
    	mov r1, #0
    	strb r1, [r3]
    	ldr r3, =_cont_vetor
    	mov r1, #0
    	strb r1, [r3]
    	ldr r3, =_flag
    	mov r1, #0
    	strb r1, [r3]
    	mov r9, #0
	
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

/********************************************************
NUM
********************************************************/

.num:
    stmfd sp!,{r0-r4,lr}
    
/*    bl .Timer_disable
    ldr r4, =DMTIMER_IRQENABLE_CLR
    mov r1, #0x2
    str r1, [r4]*/
    
    bl .uart_getc
    cmp r0, #'\r'
    bleq .igual
    bl .uart_putc
    
    ldr r1, =tabela1                   //erro
    mov r3, #0
    
    //comparar para ver se é numero ou letra
.loop_num:
    ldrb r2, [r1, r3]         
    cmp r0, r2
    bleq .save2
    add r3, r3, #1
    cmp r3, #10
    bne .loop_num
    
    //se for negativo
    ldr r1, =tabela1                   //erro
    ldrb r2, [r1, r3]
    cmp r0, r2
    bleq .negativo
    
    ldr r3, =_cont
    mov r1, #0
    str r1, [r3]
    //quando for outro caractere
    ldr r0, =prox_linha
    bl .print_string
    
    ldr r2, =_cont_vetor
    ldrb r1, [r2]
    cmp r1, #0
    bleq .erro
    
    //r0 -> vetor
    //r1 -> tamanho do vetor
    //r2 -> numeros negativos (flag)
    ldr r0, =_vetor
    ldr r2, =_cont_vetor
    ldrb r1, [r2]  
    ldr r3, =_flag
    ldrb r2, [r3] 
   // mov r2, r9           
    bl main
    
    ldr r0, =prox_linha                 //erro
    bl .print_string
    
/*    ldr r2, =_cont_vetor
    mov r1, #0
    strb r1, [r2]   
    ldr r2, =_cont
    mov r1, #0
    strb r1, [r2]  
    ldr r2, =_flag
    mov r1, #0
    strb r1, [r2] */
 //   mov r9, #0    
    b _start             //    
    
    ldmfd sp!,{r0-r4,pc}


.igual:
    ldr r0, =prox_linha
    bl .print_string
    
    //printar os numeros digitados
/*    ldr r4, =_buffer_num
    ldr r3, =_cont
    ldrb r2, [r3]
    cmp r2, #0
    bleq .final_loop
    mov r5, #0
    
.loop:
    ldrb r0, [r4, r5]
    bl .uart_putc
    add r5, r5, #1
    cmp r5, r2
    bne .loop    //ble
    
    ldr r3, =_cont
    mov r1, #0
    str r1, [r3]
    
    adr r0, prox_linha
    bl .print_string*/
    
    //tentativa 1
/*    ldr r3, =_cont_vetor
    ldrb r4, [r3]
    ldr r5, =_buffer_num
    ldrh r6, [r5, #0]
    ldr r5, =_vetor
    strh r6, [r5, r4]
    add r4, r4, #1
    strb r4, [r3]*/
    
    ldr r4, =_buffer_num
    ldr r3, =_cont
    ldrb r2, [r3]              
    cmp r2, #0
    bleq .final_loop
    mov r5, #0
    mov r1, #0
    
.loop:
    ldrb r0, [r4, r5]           
    mov r1, r1, LSL #4
    add r1, r1, r0
    add r5, r5, #1
    cmp r5, r2
    bne .loop    //ble
    bl .hex_to_int
    
    //guardar no vetor
    ldr r3, =_cont_vetor
    ldrb r2, [r3]               
    ldr r1, =_vetor
    strb r0, [r1, r2]           
    add r2, r2, #1
    strb r2, [r3]               
  //  bl main
    
    ldr r3, =_cont
    mov r1, #0
    strb r1, [r3]   

.final_loop:
 //   bl .delay_timer
 //   b .main             //
    ldmfd sp!,{r0-r4,pc}
    
.save2:

    sub r0, r0, #48    
    ldr r3, =_cont
    ldrb r2, [r3]              
    ldr r1, =_buffer_num
    strb r0, [r1, r2]         
    add r2, r2, #1
    strb r2, [r3] 
 //   bl .delay_timer
  //  b .main             //

    ldmfd sp!,{r0-r4,pc}
    
.negativo:             // r9 = 0000 0000 0000 0000
    ldr r6, =_flag
    ldrb r5, [r6]
    
    mov r3, #1
    ldr r1, =_cont_vetor
    ldrb r2, [r1]
    mov r3, r3, LSL r2
    orr r5, r5, r3
    
    strb r5, [r6]
 //   bl .delay_timer
 //   b .main           //
    ldmfd sp!,{r0-r4,pc}
    
.erro:
    ldr r0, =aviso
    bl .print_string
    bl .restart
    b _start             //
    ldmfd sp!,{r0-r4,pc}
    
/*********************************************************/

aviso:         .asciz "Primeiro dado nao e um numero: reiniciando programa (leds ativados, espere cinco segundos para digitar novamente)\n\r\0"
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



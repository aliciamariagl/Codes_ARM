/* Global Symbols */
.global .uart_putc
.global .uart_getc
.global .uart0_setup
.global .uart0
.global .num
.global _buffer_count1
.global _buffer_count2
.global _flag
.global .ler_end

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

/********************************************************
LER
********************************************************/
.ler_end:
     stmfd sp!,{r1-r5,lr}
     
     bl .uart_getc
     cmp r0, #'\r'
     bleq .enter
     bl .uart_putc
     ldr r3, =_flag
     ldrb r2, [r3]
     cmp r2, #1
     bleq .ler_end2
     
     //guardar enderço 1 no buffer
     ldr r3, =_buffer_count1
     ldrb r2, [r3]
     ldr r4, =_buffer1
     strb r0, [r4, r2]
     add r2, r2, #1
     strb r2, [r3]
     

     ldmfd sp!,{r1-r5,pc}
/*********************************************************/

.enter:
     ldr r0, =prox_linha
     bl .print_string
     
     ldr r3, =_flag
     ldrb r2, [r3]
     add r2, r2, #1
     strb r2, [r3]
     
//Se dermos o enter depois de ler o end final
     cmp r2, #2
     bleq .printa_enderecos   
     
//Se dermos o  enter depois de ler o end inicial
     ldr r0, =end_final
     bl .print_string
     
     ldmfd sp!,{r1-r5,pc}
/*********************************************************/

.ler_end2:
     //guardar enderço 2 no buffer
     ldr r3, =_buffer_count2
     ldrb r2, [r3]
     ldr r4, =_buffer2
     strb r0, [r4, r2]
     add r2, r2, #1
     strb r2, [r3]

     ldmfd sp!,{r1-r5,pc}

/*********************************************************/
.printa_enderecos:
     stmfd sp!,{r1-r5,lr}
     
     // transformando para hexa e colocando no buffer1
     ldr r3, =_buffer_count1
     ldrb r2, [r3]
     ldr r4, =_buffer1
     bl .ascii_to_hex
     
     ldr r6, =_buffer_count1
     ldrb r2, [r6]
     mov r2, #4
     strb r2, [r6]       
     ldr r4, =_buffer1
     bl .save_buffer
     
     /* TESTE
    ldr r4, =_buffer1
    ldr r3, =_buffer_count1
    ldrb r2, [r3]
    mov r5, #0
    
.loop1:
    ldrb r0, [r4, r5]
    bl .uart_putc
    add r5, r5, #1
    cmp r5, r2
    bne .loop1    //ble
    
    adr r0, prox_linha
    bl .print_string
    */
     
     // transformando para hexa e colocando no buffer2
     ldr r3, =_buffer_count2
     ldrb r2, [r3]
     ldr r4, =_buffer2
     bl .ascii_to_hex
     
     ldr r6, =_buffer_count2
     ldrb r2, [r6]
     mov r2, #4
     strb r2, [r6]
     ldr r4, =_buffer2
     bl .save_buffer
     
     //comparando os buffers
     ldr r0, =_buffer1
     ldr r1, [r0]
     ldr r0, =_buffer2
     ldr r2, [r0]
     cmp r2, r1
     bgt .comparar
     bl .inverter
    
.fim:
     bl _start
     ldmfd sp!,{r1-r5,pc}

/*************************************************/
.comparar:
     ldr r3, =_buffer1
     ldr r0, [r3]
     ldr r4, =_buffer2
     ldr r2, [r4]
     mov r1, #0
     
.loop_comparar:
     add r0, r0, #0x4
     add r1, r1, #1
     cmp r0, r2
     bne .loop_comparar
     
     add r1, r1, #1
     ldr r3, =_buffer1
     ldr r0, [r3]
     
     bl .memory_dump
     
     bl .fim
     
.inverter:
     ldr r3, =_buffer1
     ldr r0, [r3]
     ldr r4, =_buffer2
     ldr r2, [r4]
     mov r1, #0
     
.loop_inverter:
     add r2, r2, #0x4
     add r1, r1, #1
     cmp r0, r2
     bne .loop_inverter
     
     add r1, r1, #1
     ldr r3, =_buffer1
     ldr r0, [r3]
     
     bl .memory_dump_contrario
     
     bl .fim
     
     nop
     nop
     nop
     nop
      nop
       nop
        nop
         nop
          nop
     
/*************************************************/

prox_linha:    .asciz "\n\r"


/* Data Section */
.section .data
.align 4

/* BSS Section */
.section .bss
.align 4

.equ BUFFER_SIZE, 16


_buffer1: .fill BUFFER_SIZE
_buffer_count1: .fill 4


_buffer2: .fill BUFFER_SIZE
_buffer_count2: .fill 4


_flag: .fill 4



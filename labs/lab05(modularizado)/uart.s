/* Global Symbols */
.global .uart_putc
.global .uart_getc
.global .uart0_setup
.global .uart0
.global _buffer_count
.global _num_count
.global .limpar_buffer
.type .uart_getc, %function
.type .uart_putc, %function


/* Registradores */
.equ UART0_BASE, 0x44E09000
.equ UART0_IER, 0x44E09004

/* Text Section */
.section .text,"ax"
         .code 32
         .align 4
         
        mov r2, #0
	ldr r3, =_buffer_count
	strb r2, [r3]

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
UART0   
********************************************************/
.uart0:
    stmfd sp!,{r1-r2,lr}
    bl .uart_getc
    cmp r0, #'\r'
    bleq .uart0_comandos
    bl .uart_putc
    bl .save
    
    ldmfd sp!,{r1-r2,pc}
    
.uart0_comandos:
    ldr r0, =prox_linha
    bl .print_string
    
    ldr r0, =comando1
    ldr r1, =_buffer
    ldr r3, =_buffer_count
    ldrb r4, [r3]
    mov r2, #5
    cmp r4, r2
    bleq .memcmp
    cmp r0, #0
    bleq .print_comando1
    
    ldr r0, =comando2
    ldr r1, =_buffer
    ldr r3, =_buffer_count
    ldrb r4, [r3]
    mov r2, #6
    cmp r4, r2
    bleq .memcmp
    cmp r0, #0
    bleq .print_comando2
    
    ldr r0, =comando3
    ldr r1, =_buffer
    ldr r3, =_buffer_count
    ldrb r4, [r3]
    mov r2, #7
    cmp r4, r2
    bleq .memcmp
    cmp r0, #0
    bleq .print_comando3
    
    ldr r0, =comando4
    ldr r1, =_buffer
    ldr r3, =_buffer_count
    ldrb r4, [r3]
    mov r2, #6
    cmp r4, r2
    bleq .memcmp
    cmp r0, #0
    bleq .print_comando4
    
    ldr r0, =comando5
    ldr r1, =_buffer
    ldr r3, =_buffer_count
    ldrb r4, [r3]
    mov r2, #4
    cmp r4, r2
    bleq .memcmp
    cmp r0, #0
    bleq .print_comando5
    
    ldr r0, =comando6
    ldr r1, =_buffer
    ldr r3, =_buffer_count
    ldrb r4, [r3]
    mov r2, #4
    cmp r4, r2
    bleq .memcmp
    cmp r0, #0
    bleq .print_comando6
    
    ldr r0, =comando7
    ldr r1, =_buffer
    ldr r3, =_buffer_count
    ldrb r4, [r3]
    mov r2, #9
    cmp r4, r2
    bleq .memcmp
    cmp r0, #0
    bleq .print_comando7
    
    
/************************************************/
    ldr r0, =comando9
    ldr r1, =_buffer
    ldr r3, =_buffer_count
    ldrb r4, [r3]
    mov r2, #5
    cmp r4, r2
    bleq .memcmp
    cmp r0, #0
    bleq .print_comando9
    
    ldr r0, =comando10
    ldr r1, =_buffer
    ldr r3, =_buffer_count
    ldrb r4, [r3]
    mov r2, #5
    cmp r4, r2
    bleq .memcmp
    cmp r0, #0
    bleq .print_comando10
    /************************************************/
    
.limpar_buffer:

    ldr r3, =_buffer_count
    mov r1, #0
    strb r1, [r3]
    
    ldr r3, =_num_count
    mov r1, #0
    strb r1, [r3]

 /*   ldr r0, =_buffer
    ldr r3, =_buffer_count
    ldrb r1, [r3]
    bl .memory_clear
    ldr r3, =_buffer_count
    mov r1, #0
    strb r1, [r3]
    
    ldr r0, =_num
    ldr r3, =_num_count
    ldrb r1, [r3]
    bl .memory_clear
    ldr r3, =_num_count
    mov r1, #0
    strb r1, [r3]*/
    
    ldmfd sp!,{r1-r2,pc}
/********************************************************/

.save:
    stmfd sp!,{r0-r4,lr}
    
    cmp r0, #':'
    bleq .fim_save
    cmp r0, #'0'
    bleq .num_save
    cmp r0, #'1'
    bleq .num_save
    cmp r0, #'2'
    bleq .num_save
    cmp r0, #'3'
    bleq .num_save
    cmp r0, #'4'
    bleq .num_save
    cmp r0, #'5'
    bleq .num_save
    cmp r0, #'6'
    bleq .num_save
    cmp r0, #'7'
    bleq .num_save
    cmp r0, #'8'
    bleq .num_save
    cmp r0, #'9'
    bleq .num_save
    //hexadecimais
    ldr r3, =_num_count
    ldrb r2, [r3]
    cmp r2, #0
    bne .num_save
    
    ldr r3, =_buffer_count
    ldrb r2, [r3]
    ldr r1, =_buffer
    strb r0, [r1, r2]
    add r2, r2, #1
    strb r2, [r3]

.fim_save:
    ldmfd sp!,{r0-r4,pc}
    
.num_save:
    ldr r3, =_num_count
    ldrb r2, [r3]
    ldr r1, =_num
    strb r0, [r1, r2]
    add r2, r2, #1
    strb r2, [r3]
    ldmfd sp!,{r0-r4,pc}
	
/*********************************************************/

.print_comando1:
    stmfd sp!,{r0-r4,lr}
    adr r0, hello
    bl .print_string
    ldmfd sp!,{r0-r4,pc}
    
.print_comando2:
    stmfd sp!,{r0-r4,lr}
    bl .led_ON
    ldmfd sp!,{r0-r4,pc}
    
.print_comando3:
    stmfd sp!,{r0-r4,lr}
    bl .led_OFF
    ldmfd sp!,{r0-r4,pc}
    
.print_comando4:
    stmfd sp!,{r0-r4,lr}
    ldr r1, =_num_count
    ldrb r2, [r1]
    ldr r3, =_num
    mov r1, #0
    mov r5, #0
.loop_comando4:
    ldrb r4, [r3, r1]
    sub r4, r4, #48
    mov r5, r5, LSL #4
    add r5, r5, r4
    add r1, r1, #1
    cmp r1, r2
    bne .loop_comando4
    mov r0, r5
    bl .hex_to_int
    bl .blink_led
    ldmfd sp!,{r0-r4,pc}
    
.print_comando5:
    stmfd sp!,{r0-r4,lr}
    ldr r1, =_num_count
    ldrb r2, [r1]
    ldr r3, =_num
    mov r1, #0
    mov r5, #0
.loop_comando5:
    ldrb r4, [r3, r1]
    sub r4, r4, #48
    mov r5, r5, LSL #4
    add r5, r5, r4
    add r1, r1, #1
    cmp r1, r2
    bne .loop_comando5
    mov r0, r5
    bl .hex_to_int
    mov r3, r0
    bl .num_led
    ldmfd sp!,{r0-r4,pc}
    
.print_comando6:
    stmfd sp!,{r0-r4,lr}
    bl .rtc_isr
    ldmfd sp!,{r0-r4,pc}
    
.print_comando7:
    stmfd sp!,{r0-r4,lr}
    ldr r1, =_num_count
    ldrb r2, [r1]
    ldr r3, =_num
    mov r1, #0
    mov r5, #0
.loop_comando7:
    ldrb r4, [r3, r1]
    sub r4, r4, #48
    mov r5, r5, LSL #4
    add r5, r5, r4
    add r1, r1, #1
    cmp r1, r2
    bne .loop_comando7
    bl .uart_to_rtc
    ldmfd sp!,{r0-r4,pc}
    
/**********************************************/
.print_comando9:
     ldr r3, =_num_count
     ldrb r2, [r3]
     ldr r4, =_num
     bl .ascii_to_hex

     mov r14, r15
     mov r15, r3
     add r1, r1, #0
    
    bl .limpar_buffer
 //   bl _start

.print_comando10:
    bl .reset
    
/*********************************************************/

hello:         .asciz "Hello world!!!\n\r"

prox_linha:    .asciz "\n\r"
comando1:      .asciz "hello\n\r"
comando2:      .asciz "led on\n\r"
comando3:      .asciz "led off\n\r"
comando4:      .asciz "blink \n\r"
comando5:      .asciz "led \n\r"
comando6:      .asciz "time\n\r"
comando7:      .asciz "set time \n\r"
comando8:      .asciz "cache\n\r"
comando9:      .asciz "goto \n\r"
comando10:     .asciz "reset\n\r"


/* Data Section */
.section .data
.align 4

/* BSS Section */
.section .bss
.align 4

.equ BUFFER_SIZE, 16
_num: .fill BUFFER_SIZE
_num_count: .fill 4
_buffer: .fill BUFFER_SIZE
_buffer_count: .fill 4












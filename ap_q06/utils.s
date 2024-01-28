/* Global Symbols */
.global div
.global .memory_clear
.global .memory_dump
.global .delay
.global .delay_1s
.global .dec_digit_to_ascii
.global .print_string
.global .print_nstring
.global .hex_to_ascii
.global .int_to_ascii
.global .hex_digit_to_ascii
.global .memcmp
.global .hex_to_int
.global .maior_delay
.global .ascii_to_hex
.global .save_buffer

.type div, %function
.type .memory_clear, %function
.type .memory_dump, %function
.type .dec_digit_to_ascii, %function
.type .print_nstring, %function
.type .hex_digit_to_ascii, %function


/* Text Section */
.section .text,"ax"
         .code 32
         .align 4
         
/********************************************************
Division
//Input  --> Num: R0, Den: R1 
//Output --> Quot: R0, Rem: R2
********************************************************/
div:
    mov r2, r0
    mov r3, r1
    mov r0, #0
div_loop:
    cmp r2,r3
    blt fim_div 
    sub r2, r2, r3
    add r0, r0, #1
    b div_loop
fim_div:
    bx lr  
/********************************************************/

/********************************************************
Limpa memória
R0-> Endereço
R1-> Tamanho
/********************************************************/
.memory_clear:
    stmfd sp!,{r0-r2,lr}
    add     r1, r1, r0
    mov     r2, #0
0:
    cmp     r0, r1
    strlt   r2, [r0], #4
    blt     0b
    ldmfd sp!,{r0-r2,pc}
/********************************************************/

/********************************************************
Memory Dump
------------
Imprime o conteúdo da memória.
R0 -> Endereço inicial
R1 -> Quantidade de endereços 
********************************************************/
.memory_dump:
    stmfd sp!,{r0-r3,lr}
    mov r2, r0
    mov r3, r1

dump_loop:  
    // Imprime o endereço
    ldr r0, =hex_prefix
    mov r1, #2
    bl .print_nstring
    mov r0, r2
    bl .hex_to_ascii 

    // Imprime o separador '  :  '
    ldr r0, =dump_separator
    mov r1, #5
    bl .print_nstring

    // Imprime o conteúdo
    ldr r0, =hex_prefix
    mov r1, #2
    bl .print_nstring
    ldr r0, [r2], #4
    bl .hex_to_ascii
    
    //Salta linha
    ldr r0,=CRLF
    mov r1, #2
    bl .print_nstring

    //Verifica se já terminou
    subs r3, r3, #4
    bne dump_loop

    ldmfd sp!,{r0-r3,pc}


/********************************************************
DELAY
********************************************************/
.delay:
    ldr r1, =0xffffff
.wait:
    sub r1, r1, #0x1
    cmp r1, #0
    bne .wait
    bx lr
    
.maior_delay:
    stmfd sp!,{r0-r2,lr}
    ldr r1, =0xfffffff
    bl .wait
    ldmfd sp!,{r0-r2,pc}
    
/********************************************************/
.delay_1s:
    stmfd sp!,{r0-r2,lr}
    ldr  r0,=RTC_BASE
    ldrb r1, [r0, #0] //seconds
.wait_second:
    ldrb r2, [r0, #0] //seconds
    cmp r2, r1
    beq .wait_second
    ldmfd sp!,{r0-r2,pc}



/********************************************************/
.dec_digit_to_ascii:
	add r0,r0,#0x30
	bx lr


.hex_digit_to_ascii:
       stmfd sp!,{r0-r2,lr} 
       ldr r1, =ascii
       ldrb r0, [r1, r0]
       
       ldmfd sp!, {r0-r2, pc}
/********************************************************/
/********************************************************
Converte int (de de 0 a 99) to ascii
********************************************************/
.global _int_to_ascii
.type _int_to_ascii, %function

_int_to_ascii:
.int_to_ascii:
    stmfd sp!,{r0-r2,lr}
    mov r1, #10
    bl div
    add r0, r0, #0x30
    bl .uart_putc
    add r0, r2, #0x30
    bl .uart_putc
    ldmfd sp!, {r0-r2, pc}
/********************************************************/
/********************************************************
Converte HEX para ASCCI
********************************************************/
.hex_to_ascii:
    stmfd sp!,{r0-r3,lr}
    mov r1, r0

    mov r0, #0
    mov r3, #28
    ldr r2, =ascii

ascii_loop:
    mov r0, r1, LSR r3
    and r0, r0, #0x0f 
    ldrb r0, [r2, r0]
    bl .uart_putc
    subs r3, r3, #4
    bne ascii_loop
    mov r0, r1
    and r0, r0, #0x0f 
    ldrb r0, [r2, r0]
    bl .uart_putc

    ldmfd sp!,{r0-r3,pc}

/********************************************************/
// Calcula o checksum de uma região
//RO - Ponteiro para mem1
//R1 - quantidade de bytes
//Retorno
// R0: Soma dos bytes (32 bits)
/********************************************************/
check_sum:
    stmfd sp!,{r1-r3,lr}
    
    mov r2, r0
    mov r0, #0

 0: cmp r1,#0
    beq 1f
    ldrb r3, [r2], #1
    add r0,r0,r3
    sub r1,r1,#1
    b 0b
1:    
    ldmfd sp!,{r1-r3,pc}
/********************************************************/

/********************************************************/
// Compara o checksum de duas regiões de memória
//RO - Ponteiro para mem1
//R1 - ponteiro para mem2
//R2 - quantidade de bytes
//Retorno
//R0 = 0 -> checksums iguais
//R0 != 0 -> checksums diferentes
/********************************************************/
.memcmp_chksum:
	stmfd sp!,{r1-r4,lr}

	mov r4, r1
	
	mov r1, r2
	bl check_sum
	
	mov r3, r0 //checksum da mem1
	
	mov r0, r4
	bl check_sum //checksum da mem2
	
	sub r0, r3,r0
    
   	ldmfd sp!,{r1-r4,pc}
/********************************************************/

/********************************************************/
// Compara o conteúdo de duas regiões de memória
//RO - Ponteiro para mem1
//R1 - ponteiro para mem2
//R2 - quantidade de bytes
//Retorno
//R0 = 0 -> conteudos iguais
//R0 != 0 -> conteudos diferentes
/********************************************************/
.memcmp:
    stmfd sp!,{r1-r6,lr}

    mov r3, r0
    mov r4, r1 
    mov r0, #0
0: 
    ldrb r5, [r3, r0]
    ldrb r6, [r4, r0]
    cmp r5, r6
    bne 1f
    add r0, r0, #1
    cmp r2, r0
    beq 2f
    b 0b
1: 
    mov r0, #1
    ldmfd sp!,{r1-r6,pc}
2:
    mov r0, #0
    ldmfd sp!,{r1-r6,pc}
/********************************************************/

/********************************************************
Imprime uma string até o '\0'
// R0 -> Endereço da string
/********************************************************/
.print_string:
    stmfd sp!,{r0-r2,lr}
    mov r1, r0
.print:
    ldrb r0,[r1],#1
    and r0, r0, #0xff
    cmp r0, #0
    beq .end_print
    bl .uart_putc
    b .print
    
.end_print:
    ldmfd sp!,{r0-r2,pc}
/********************************************************/



/********************************************************
Imprime n caracteres de uma string
// R0 -> Endereço da string R1-> Número de caracteres
/********************************************************/
.print_nstring:
    stmfd sp!,{r0-r2,lr}
    mov r2, r0
.print_n:
    ldrb r0,[r2],#1
    bl .uart_putc
    subs r1, r1, #1
    beq .end_print
    b .print_n
    
.end_print_n:
    ldmfd sp!,{r0-r2,pc}
    
/********************************************************/

.hex_to_int:
    stmfd sp!,{r1-r5,lr}
    //r1 = numero
    mov r2, #1
    mov r3, #10
    mov r5, #0
    mov r8, #0
    
.loop_hex_to_int:
    mov r4, r1
    and r4, r4, #0xf
    mul r6, r4, r2
    mov r4, r6
    mul r7, r2, r3
    mov r2, r7
    add r5, r5, r4
    mov r1, r1, LSR #4
    add r8, r8, #1
    cmp r8, #7
    bne .loop_hex_to_int
    
    mov r0, r5
    
    ldmfd sp!,{r1-r5,pc}
    
/********************************************************/
// recebe o endereço do buffer em r4 e o contador do buffer em r2
// resultado volta em r3

.ascii_to_hex:
     stmfd sp!,{r6-r8,lr}
     mov r5, #0
     mov r3, #0

.loop_buffer:
     ldrb r0, [r4, r5]    
     cmp r0, #':'
     blt .numero
     sub r0, r0, #0x57
.volta:
     mov r3, r3, LSL #4 
     add r3, r3, r0 
     add r5, r5, #1
     cmp r2, r5     
     bne .loop_buffer
     ldmfd sp!,{r6-r8,pc}
    
.numero:
	sub r0,r0, #0x30
	bl .volta

/*************************************************/
// recebe o contador em r2 e o endereço do buffer em r4

.save_buffer:
     stmfd sp!,{r4-r6,lr}
     mov r5, #0

.loop_save_buffer:
     strb r3, [r4, r5]
     mov r3, r3, LSR #8
     add r5, r5, #1
     cmp r2, r5
     bne .loop_save_buffer
     
     ldmfd sp!,{r4-r6,pc}
/*************************************************/  
    
    
    
    
    
    
    
    
    



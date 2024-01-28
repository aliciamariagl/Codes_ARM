/* Global Symbols */
.global .disable_wdt
.global .F0
.global .F1
.global .F2
.global .F3
.global .F4
.global .F5
.global .F6
.global .F7
.global .F8
.global .F9
.global .F10
.global .F11
.global .F12
.global .F13
.global .F14
.global .F15

.type .disable_wdt, %function


/* Registradores */
.equ WDT_BASE, 0x44E35000


/* Text Section */
.section .text,"ax"
         .code 32
         .align 4
         
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
    
    ldr r1, =0xAAAA     //1010 1010 1010 1010
    str r1, [r0, #0x48]
    bl .poll_wdt_write

    ldr r1, =0x5555     //0101 0101 0101 0101
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

.able_wdt:
    /* TRM 20.4.3.8 */
    stmfd sp!,{r0-r1,lr}
    
    ldr r0, =WDT_BASE
    mov r1, #0
    str r1, [r0, #0x34]

    ldmfd sp!,{r0-r1,pc}





/**********************QUESTAO 2*************************/

.F0:
    stmfd sp!,{r0-r5,lr}
    
    ldr r0, =reg_0
    bl .print_string
    bl .hex_to_ascii
    
    ldmfd sp!,{r0-r5,pc}
    
.F1:
    stmfd sp!,{r0-r5,lr}
    
    ldr r0, =reg_1
    bl .print_string
    mov r0, r1
    bl .hex_to_ascii
    
    ldmfd sp!,{r0-r5,pc}
    
.F2:
    stmfd sp!,{r0-r5,lr}
    
    ldr r0, =reg_2
    bl .print_string
    mov r0, r2
    bl .hex_to_ascii
    
    ldmfd sp!,{r0-r5,pc}
    
.F3:
    stmfd sp!,{r0-r5,lr}
    
    ldr r0, =reg_3
    bl .print_string
    mov r0, r3
    bl .hex_to_ascii
    
    ldmfd sp!,{r0-r5,pc}
    
    
.F4:
    stmfd sp!,{r0-r5,lr}
    
    ldr r0, =reg_4
    bl .print_string
    mov r0, r4
    bl .hex_to_ascii
    
    ldmfd sp!,{r0-r5,pc}
    
.F5:
    stmfd sp!,{r0-r5,lr}
    
    ldr r0, =reg_5
    bl .print_string
    mov r0, r5
    bl .hex_to_ascii
    
    ldmfd sp!,{r0-r5,pc}
    
    
.F6:
    stmfd sp!,{r0-r5,lr}
    
    ldr r0, =reg_6
    bl .print_string
    mov r0, r6
    bl .hex_to_ascii
    
    ldmfd sp!,{r0-r5,pc}
    
.F7:
    stmfd sp!,{r0-r5,lr}
    
    ldr r0, =reg_7
    bl .print_string
    mov r0, r7
    bl .hex_to_ascii
    
    ldmfd sp!,{r0-r5,pc}
    
.F8:
    stmfd sp!,{r0-r5,lr}
    
    ldr r0, =reg_8
    bl .print_string
    mov r0, r8
    bl .hex_to_ascii
    
    ldmfd sp!,{r0-r5,pc}
    
.F9:
    stmfd sp!,{r0-r5,lr}
    
    ldr r0, =reg_9
    bl .print_string
    mov r0, r9
    bl .hex_to_ascii
    
    ldmfd sp!,{r0-r5,pc}
    
.F10:
    stmfd sp!,{r0-r5,lr}
    
    ldr r0, =reg_10
    bl .print_string
    mov r0, r10
    bl .hex_to_ascii
    
    ldmfd sp!,{r0-r5,pc}
.F11:
    stmfd sp!,{r0-r5,lr}
    
    ldr r0, =reg_11
    bl .print_string
    mov r0, r11
    bl .hex_to_ascii
    
    ldmfd sp!,{r0-r5,pc}
    
.F12:
    stmfd sp!,{r0-r5,lr}
    
    ldr r0, =reg_12
    bl .print_string
    mov r0, r12
    bl .hex_to_ascii
    
    ldmfd sp!,{r0-r5,pc}

.F13:
    stmfd sp!,{r0-r5,lr}
    
    ldr r0, =reg_13
    bl .print_string
    mov r0, r13
    bl .hex_to_ascii
    
    ldmfd sp!,{r0-r5,pc}
    
.F14:
    stmfd sp!,{r0-r5,lr}
    
    ldr r0, =reg_14
    bl .print_string
    mov r0, r14
    bl .hex_to_ascii
    
    ldmfd sp!,{r0-r5,pc}
    
.F15:
    stmfd sp!,{r0-r5,lr}
    
    ldr r0, =reg_15
    bl .print_string
    mov r0, r15
    bl .hex_to_ascii
    
    ldmfd sp!,{r0-r5,pc}

/********************************************/


reg_0:        .asciz "R0 : 0x\0"
reg_1:        .asciz "R1 : 0x\0"
reg_2:        .asciz "R2 : 0x\0"
reg_3:        .asciz "R3 : 0x\0"
reg_4:        .asciz "R4 : 0x\0"
reg_5:        .asciz "R5 : 0x\0"
reg_6:        .asciz "R6 : 0x\0"
reg_7:        .asciz "R7 : 0x\0"
reg_8:        .asciz "R8 : 0x\0"
reg_9:        .asciz "R9 : 0x\0"
reg_10:       .asciz "R10 : 0x\0"
reg_11:       .asciz "R11 : 0x\0"
reg_12:       .asciz "R12 : 0x\0"
reg_13:       .asciz "R13 : 0x\0"
reg_14:       .asciz "R14 : 0x\0"
reg_15:       .asciz "R15 : 0x\0"










/* Global Symbols */
.global INTC_BASE
.global INTC_ILR
.global _vector_table
.global CRLF
.global dump_separator
.global hex_prefix
.global ascii
.global .Timer_disable
.global _start
.global .main
.global DMTIMER_IRQENABLE_CLR
.global .delay_timer

/* Registers */
.equ INTC_BASE, 0x48200000
.equ INTC_ILR,  0x48200100

/*TIMER*/
.equ CM_PER_TIMER7_CLKCTRL,    0x44E0007C
.equ INTC_MIR_CLEAR2,          0x482000C8
.equ DMTIMER_TCLR,             0x4804A038
.equ DMTIMER_IRQSTATUS,        0x4804A028
.equ DMTIMER_IRQENABLE_SET,    0x4804A02C
.equ DMTIMER_IRQENABLE_CLR,    0x4804A030
.equ TIMER_1MS_COUNT,          0x5DC0
.equ TIMER_OVERFLOW,           0xFFFFFFFF
.equ DMTIMER_TCRR,             0x4804A03C


/* General Definitions */


/* CPSR */
.equ CPSR_I,   0x80
.equ CPSR_F,   0x40
.equ CPSR_IRQ, 0x12
.equ CPSR_USR, 0x10
.equ CPSR_FIQ, 0x11
.equ CPSR_SVC, 0x13
.equ CPSR_ABT, 0x17
.equ CPSR_UND, 0x1B
.equ CPSR_SYS, 0x1F


//.equ VECTOR_BASE, 0x4030CE20
.equ VECTOR_BASE, 0x4030CE00 // Vector Base on BBB
//.equ VECTOR_BASE, 0x4030FC00


/*******************************
Stack
/*******************************/
.set StackModeSize,  0x100

.equ StackUSR, (_stack_end - 0*StackModeSize)
.equ StackFIQ, (_stack_end - 1*StackModeSize)
.equ StackIRQ, (_stack_end - 2*StackModeSize)
.equ StackSVC, (_stack_end - 3*StackModeSize)
.equ StackABT, (_stack_end - 4*StackModeSize)
.equ StackUND, (_stack_end - 5*StackModeSize)
.equ StackSYS, (_stack_end - 6*StackModeSize)

.section .text,"ax"
         .code 32
         .align 4

/********************************************************/
/* Vector table */
/********************************************************/
_vector_table:
    ldr   pc, _reset     /* reset - _start           */
    ldr   pc, _undf      /* undefined - _undf        */
    ldr   pc, _swi       /* SWI - _swi               */
    ldr   pc, _pabt      /* program abort - _pabt    */
    ldr   pc, _dabt      /* data abort - _dabt       */
    nop                  /* reserved                 */
    ldr   pc, _irq       /* IRQ - read the VIC       */
    ldr   pc, _fiq       /* FIQ - _fiq               */

_reset: .word _start
_undf:  .word 0x4030CE24 /* undefined               */
_swi:   .word 0x4030CE28 /* SWI                     */
_pabt:  .word 0x4030CE2C /* program abort           */
_dabt:  .word 0x4030CE30 /* data abort              */
         nop
_irq:   .word 0x4030CE38  /* IRQ                     */
_fiq:   .word 0x4030CE3C  /* FIQ                     */

/********************************************************/
/* Startup Code */
/********************************************************/
_start:
    
    ldr r2, =_cont_vetor
    mov r1, #0
    strb r1, [r2]   
    ldr r2, =_cont
    mov r1, #0
    strb r1, [r2]  
    ldr r2, =_flag
    mov r1, #0
    strb r1, [r2] 
	
    ldr r0, =digite
    bl .print_string

    /* Configure CP15 */
    bl .cp15_configure
         
    /* init */
    mrs r0, cpsr
    bic r0, r0, #0x1F            // clear mode bits
    orr r0, r0, #CPSR_SVC        // set SVC mode
    orr r0, r0, #(CPSR_F | CPSR_I)        // disable FIQ and IRQ
    msr cpsr, r0


   /* Stack setup */
   mov r0, #(CPSR_I | CPSR_F) | CPSR_SVC
   msr cpsr_c, r0
   ldr sp,=StackSVC
  
   mov r0, #(CPSR_I | CPSR_F) | CPSR_IRQ
   msr cpsr_c, r0
   ldr sp,=StackIRQ

   mov r0, #(CPSR_I | CPSR_F) | CPSR_FIQ
   msr cpsr_c, r0
   ldr sp,=StackFIQ

   mov r0, #(CPSR_I | CPSR_F) | CPSR_UND
   msr cpsr_c, r0
   ldr sp,=StackUND

   mov r0, #(CPSR_I | CPSR_F) | CPSR_ABT
   msr cpsr_c, r0
   ldr sp,=StackABT

   mov r0, #(CPSR_I | CPSR_F) | CPSR_SYS
   msr cpsr_c, r0
   ldr sp,=StackSYS

//   mov r0, #(CPSR_I | CPSR_F) | CPSR_USR
   mov r0, # CPSR_USR
   msr cpsr_c, r0
   ldr sp,=StackUSR

         
    /* Exceptions Setup */
    ldr r0, =_irq
    ldr r1, =.irq_handler
    str r1, [r0]
    
    ldr r0, =_swi
    ldr r1, =.swi_handler
    str r1, [r0]
      
    /* Hardware setup */
    bl .gpio_setup
    bl .disable_wdt
    bl .timer_setup
    bl .rtc_setup
    bl .uart0_setup
    
/*    ldr r1, =digite
    mov r2, #0
.loop_digite:
    ldrb r0, [r1, r2]
    bl .uart_putc
    add r2, r2, #1
    cmp r2, #19
    bne .loop_digite*/
    
    /* Enable global irq */
    mrs r0, cpsr
    and r0, r0, #~(CPSR_I)
    msr cpsr, r0
    bl .main
    
/********************************************************/
/* Main Code */
/********************************************************/
.global _main
.type _main, %function

_main:
.main:

    
    bl .delay_timer
    
.loop_main:
    b .loop_main

/********************************************************/

.timer_setup:
   stmfd sp!,{r0-r1,lr}
    
/*   ldr r0, =_flag
   mov r1, #0
   strb r1, [r0]*/
   
   ldr r0, =CM_PER_TIMER7_CLKCTRL
   ldr r1, [r0]
   orr r1, r1, #0x2  
   str r1, [r0]
   
   ldr r0, =INTC_MIR_CLEAR2
   ldr r1, [r0]
   orr r1, r1, #0x80000000
   str r1, [r0]
   
   ldmfd sp!,{r0-r1,pc}
   

.Timer_enable:
	stmfd sp!, {r0-r1, lr}
	
	ldr r4, =DMTIMER_TCLR
	ldr r3, [r4]
	orr r3, r3, #0x1
	str r3, [r4]
	
	ldmfd sp!,{r0-r1,pc}
	

.Timer_disable:
	stmfd sp!, {r0-r1, lr}
	
	ldr r4, =DMTIMER_TCLR
	ldr r3, [r4]
	and r3, r3, #0xfffffffe
	str r3, [r4]
	
	ldmfd sp!,{r0-r1,pc}
	
.timer:                              
	stmfd sp!, {r0-r1, lr}
	
	bl .Timer_disable
	
	ldr r4, =DMTIMER_IRQENABLE_CLR
	mov r1, #0x2
	str r1, [r4]
	
	bl .reset
.loop_reset:
	b .loop_reset
	
	/*ldr r0, =_flag
	mov r1, #1
	strb r1, [r0]*/
	
	ldmfd sp!,{r0-r1,pc}


/********************************************************
IRQ Handler
********************************************************/
.irq_handler:
        stmfd sp!, {r0-r3, r11, lr}
        mrs r11, spsr
        
 	/* Interrupt Source */
	ldr r0,=INTC_BASE
	ldr r1, [r0, #0x40]
	
	/* if rtc interrupt */
	and r1,r1, #0x7f
	
	cmp r1, #75  /* TRM 6.3 Table 6-1*/
	//bleq .rtc_isr
	
	cmp r1, #72
	bleq .num
	//bleq .uart0
	
	cmp r1, #95
	bleq .timer

        /* new IRQ */
        ldr r0, =INTC_BASE 
        ldr r1, =0x1
        str r1, [r0, #0x48]

        /*Data Sync Barrier */
	dsb
        msr spsr, r11
        ldmfd sp!, {r0-r3, r11, pc}^

/********************************************************
DELAY
********************************************************/
.delay_timer:
	stmfd sp!, {r0-r1, lr}
	
        mov r1, #0x5DC0    //1 milissegundo
        mov r0, #10000
        mul r2, r1, r0
        mov r1, #0xffffffff
        sub r0, r1, r2
        
        ldr r4, =DMTIMER_TCRR
        ldr r1, [r4]
        mov r1, r0
        str r1, [r4]
	
	ldr r0, =DMTIMER_IRQENABLE_SET
	ldr r1, [r0]
	mov r1, #0x2
	str r1, [r0]
	
	bl .Timer_enable
	
	stmfd sp!, {r0-r1, lr}

/********************************************************/

/********************************************************/
.fiq_handler:
   b .      
/********************************************************/
.undefined_handler:
   b .     
/********************************************************/
.swi_handler:
   
    stmfd           sp!,{r0-r12,lr} 
    ldr             r0,[lr,#-4]      
                                                             
    bic             r1,r0,#0xff000000   //SWI Number  
    
    ldr r0, =swi_msg
    bl .print_string
    
    mov r0, r1
    bl .hex_to_ascii
    
    ldr r0,=CRLF
    bl .print_string
    
    
    ldmfd           sp!, {r0-r12,pc}^     
   
   
/********************************************************/
.prefetch_abort_handler:
   b .      
/********************************************************/
.data_abort_handler:
   b .      
/********************************************************/

digite:                  .asciz "Digite os numeros: (Somente numeros de -255 a 255)\n\r"

/* Read-Only Data Section */
.section .rodata
.align 4

hello:                   .asciz "Hello world!!!\n\r\0"
irq_mode_msg:            .asciz "IRQ Mode!\n\r"
fiq_mode_msg:            .asciz "FIQ Mode!\n\r"
prefetch_abort_msg:      .asciz "Prefetch Abort!\n\r"
data_abort_msg:          .asciz "Data Abort!\n\r"
undefined_exception_msg: .asciz "Undefined Exception!\n\r"
swi_msg:                 .asciz "Software Interrupt Number: \n\r"
ascii:                   .asciz "0123456789ABCDEF"
dash:                    .asciz "-------------------------\n\r"
hex_prefix:              .asciz "0x"
CRLF:                    .asciz "\n\r"
dump_separator:          .asciz "  :  "


/* Data Section */
.section .data
.align 4

/* BSS Section */
.section .bss
.align 4

.equ BUFFER_SIZE, 16
_buffer: .fill BUFFER_SIZE
_buffer_count: .fill 4

























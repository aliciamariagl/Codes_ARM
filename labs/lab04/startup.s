/* Clock */
.equ CM_PER_GPIO1_CLKCTRL, 0x44e000AC
.equ CM_RTC_RTC_CLKCTRL, 0x44E00800
.equ CM_RTC_CLKSTCTRL,  0x44E00804

/* Watch Dog Timer */
.equ WDT_BASE, 0x44E35000

/* GPIO */
.equ GPIO1_OE, 0x4804C134
.equ GPIO1_SETDATAOUT, 0x4804C194
.equ GPIO1_CLEARDATAOUT, 0x4804C190

/* RTC */
.equ RTC_BASE, 0x44E3E000

/* UART */
.equ UART0_BASE, 0x44E09000
.equ UART0_IER, 0x44E09004

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

/* INT */
.equ INTC_BASE, 0x48200000
.equ INTC_ILR,  0x48200100

//.equ VECTOR_BASE, 0x4030CE20
.equ VECTOR_BASE, 0x4030CE00
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

/* Vector table */
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


/* Startup Code */
_start:

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

         
    /* Exceptions */
    ldr r0, _swi
    ldr r1, =.swi_handler
    str r1, [r0]
    

    ldr r0, =_irq
    ldr r1, =.irq_handler
    str r1, [r0]
    


    
    /* Hardware setup */
    bl .gpio_setup
    bl .disable_wdt
    bl .rtc_setup
    bl .uart0_setup
  
    

    /* Enable global irq */
    mrs r0, cpsr
    and r0, r0, #~(CPSR_I)
    msr cpsr, r0
    
       /* Print Hello World */ 
    ldr r0, =hello
    bl .print_string
    bl .print_time 
    
    and r5, r5, #0

/* Main Loop */
.main_loop:
    
       
    /* logical 1 turns on the led, TRM 25.3.4.2.2.2 */
    ldr r0, =GPIO1_CLEARDATAOUT
    ldr r1, =(1<<21)
    str r1, [r0]
    bl .delay_1s

    ldr r0, =GPIO1_SETDATAOUT
    ldr r1, =(1<<21)
    str r1, [r0]
    bl .delay_1s

    b .main_loop    



/********************************************************
CP15 CONFIGURE
********************************************************/
.cp15_configure:
    stmfd sp!,{r0-r2,lr}

    // 2016: Brian Fraser's Fix for UBoot Messing with Interrupts
    // Disable the MMU, instruction and data caches.
    // Without this, the ISRs seem not to work with the latest UBoot code (2016)
    //SUB r0, r0, r0
    //MCR p15, 0, r0, c1, c0, 0

    /* Set V=0 in CP15 SCTRL register - for VBAR to point to vector */
    mrc    p15, 0, r0, c1, c0, 0    // Read CP15 SCTRL Register
    bic    r0, #(1 << 13)           // V = 0
    mcr    p15, 0, r0, c1, c0, 0    // Write CP15 SCTRL Register

    /* Set vector address in CP15 VBAR register */
    ldr     r0, =_vector_table
    mcr     p15, 0, r0, c12, c0, 0  //Set VBAR */


    ldmfd sp!,{r0-r2,pc}

/********************************************************
GPIO SETUP
********************************************************/
.gpio_setup:
    /* set clock for GPIO1, TRM 8.1.12.1.31 */
    ldr r0, =CM_PER_GPIO1_CLKCTRL
    ldr r1, =0x40002
    str r1, [r0]

    /* set pin 21 for output, led USR0, TRM 25.3.4.3 */
    ldr r0, =GPIO1_OE
    ldr r1, [r0]
    bic r1, r1, #(0xf<<21)
    str r1, [r0]
    bx lr
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
DELAY
********************************************************/
.delay:
    ldr r1, =0xfffffff
.wait:
    sub r1, r1, #0x1
    cmp r1, #0
    bne .wait
    bx lr
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

/********************************************************
Converte int (de de 0 a 99) to ascii
********************************************************/
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
RTC SETUP 
********************************************************/
.rtc_setup:

    /* Save context */	
    stmfd sp!,{r0-r1,lr}

    /*  Clock enable for RTC TRM 8.1.12.6.1 */
    ldr r0, =CM_RTC_CLKSTCTRL
    ldr r1, =0x2
    str r1, [r0]
    ldr r0, =CM_RTC_RTC_CLKCTRL
    str r1, [r0]

    /* Disable write protection TRM 20.3.5.23 e 20.3.5.24 */
    ldr r0, =RTC_BASE
    ldr r1, =0x83E70B13
    str r1, [r0, #0x6c]
    ldr r1, =0x95A4F1E0
    str r1, [r0, #0x70]
    
    /* Select external clock*/
    ldr r1, =0x48
    str r1, [r0, #0x54]



    /* Interrupt setup */
    ldr r1, =0x04     /* interrupt every second */
    //ldr r1, =0x05     /* interrupt every minute */
    //ldr r1, =0x06     /* interrupt every hour */
    str r1, [r0, #0x48]

    /* Enable RTC */
    ldr r0, =RTC_BASE
    ldr r1, =(1<<0)
    str r1, [r0, #0x40]  

    /*rtc irq setup */
.wait_rtc_update:
    ldr r1, [r0, #0x44]
    and r1, r1, #1
    cmp r1, #0
    bne .wait_rtc_update

   
    /* RTC Interrupt configured as IRQ Priority 0 */
    //RTC Interrupt number 75
    ldr r0, =INTC_ILR
    ldr r1, =#0    
    strb r1, [r0, #75] 


    /* Interrupt mask */
    ldr r0, =INTC_BASE
    ldr r1, =#(1<<11)    
    str r1, [r0, #0xc8] //(75 --> Bit 11 do 3º registrador (MIR CLEAR2))

    
    /* Load context */	
    ldmfd sp!,{r0-r1,pc}

/********************************************************/
/********************************************************
UART0 SETUP 
********************************************************/
.uart0_setup:
	stmfd sp!,{r0-r1,lr}
	
	/* Enable UART0 */
    	ldr r0, =UART0_IER
    	ldr r1, =#(1<<0) 
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
    
    ldr r1, =0xAAAA
    str r1, [r0, #0x48]
    bl .poll_wdt_write

    ldr r1, =0x5555
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
.ascii_digit_to_dec:
	sub r0,r0,#0x30
	bx lr

.dec_digit_to_ascii:
	add r0,r0,#0x30
	bx lr

.hex_digit_to_ascii:
       stmfd sp!,{r0-r2,lr} 
       ldr r1, =ascii
       ldrb r0, [r1, r0]
       
       ldmfd sp!, {r0-r2, pc}
/********************************************************
Imprime hora do RTC
(see TRM 20.3.5.1 - 20.3.5.3)
********************************************************/
.rtc_to_ascii:
    stmfd sp!,{r0-r2,lr} 
    mov r2, r0
    
    and r0, r2, #0x70
    
    mov r0, r0, LSR #4
    bl .dec_digit_to_ascii
    bl .uart_putc

    and r0, r2, #0x0f
    add r0,r0,#0x30 
    bl .uart_putc

    ldmfd sp!, {r0-r2, pc}

.print_time:
    stmfd sp!,{r0-r2,lr}
    ldr r1,=RTC_BASE     
    ldr r0, [r1, #8] //hours
    bl .rtc_to_ascii

    ldr r0,=':'
    bl .uart_putc

    ldr r0, [r1, #4] //minutes
    bl .rtc_to_ascii

    ldr r0,=':'
    bl .uart_putc

    ldr r0, [r1, #0] //seconds
    bl .rtc_to_ascii

    ldr r0,='\r'
    bl .uart_putc
    ldmfd sp!, {r0-r2, pc}
/********************************************************/

/********************************************************
RTC ISR
********************************************************/
.rtc_isr:
    stmfd sp!, {r0-r2, lr}

    /*print time*/
    bl .print_time

    ldmfd sp!, {r0-r2, pc}
    
/********************************************************
Imprime hora do RTC
(see TRM 20.3.5.1 - 20.3.5.3)
********************************************************/
.uart_to_rtc:
    
    ldr r1,=RTC_BASE                 // 23:34:12    r5: 0000 0010 0011 0011 0100 0001 0010
    and r5, r5, #0x00ffffff
    strb r5, [r1]
    
    mov r5, r5, lsr #8
    strb r5, [r1, #4]

    mov r5, r5, lsr #8
    strb r5, [r1, #8]
    
    bl .fim
  
/********************************************************/
    
/********************************************************
UART0
********************************************************/
.uart0:
    stmfd sp!, {r0-r2, lr}

    bl .uart_getc
    cmp r0, #'\r'
    bleq .uart_to_rtc
    
    bl .ascii_digit_to_dec
    and r0, r0, #0xf
    lsl r5, r5, #4
    add r5, r5, r0

.fim:
    ldmfd sp!, {r0-r2, pc}
    
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
	bleq .rtc_isr
	
	cmp r1, #72
	bleq .uart0
	//bleq .inicio

        /* new IRQ */
        ldr r0, =INTC_BASE
        ldr r1, =0x1
        str r1, [r0, #0x48]

        /*Data Sync Barrier */
	dsb
        msr spsr, r11
        ldmfd sp!, {r0-r3, r11, pc}^


/********************************************************/
 .inicio:
    stmfd sp!, {r0-r2, lr}

    ldr r0, =GPIO1_SETDATAOUT
    ldr r1, =(1<<24)
    str r1, [r0]
    bl .delay_1s

    ldr r0, =GPIO1_CLEARDATAOUT
    ldr r1, =(1<<24)
    str r1, [r0]
   
    ldmfd sp!, {r0-r2, pc}

/********************************************************/
.fiq_handler:
   b .      // infinite loop
/********************************************************/
.undefined_handler:
   b .     
/********************************************************/
.swi_handler:
   b .
/********************************************************/
.prefetch_abort_handler:
   b .      
/********************************************************/
.data_abort_handler:
   b .      
/********************************************************/




.section .rodata


hello:                   .asciz "Hello world!!!\n\r"
irq_mode_msg:            .asciz "IRQ Mode!\n\r"
fiq_mode_msg:            .asciz "FIQ Mode!\n\r"
prefetch_abort_msg:      .asciz "Prefetch Abort!\n\r"
data_abort_msg:          .asciz "Data Abort!\n\r"
undefined_exception_msg: .asciz "Undefined Exception!\n\r"
swi_msg:                 .asciz "Software Interrupt!\n\r"
ascii:                   .asciz "0123456789ABCDEF"
dash:                    .asciz "-------------------------\n\r"
hex_prefix:              .asciz "0x"
CRLF:                    .asciz "\n\r"
dump_separator:          .asciz "  :  "



.section .data
.align 4

.section .bss
.align 4

_buffer: .fill 0x10

























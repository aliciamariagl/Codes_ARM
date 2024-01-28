#include <iostream>
#include <fstream>
#include <string>
#include <sstream>
#include <cstring>
#include <bits/stdc++.h>
#include <cstdlib>
#include <math.h>
#include <vector>

using namespace std;
int decodificar_registradores(int r, char n, int v);

int poff;

int primeira_linha(int* code, int op, int pos){
    ofstream file_out;
    int aux;
    file_out.open("docout.txt", ios::app);
    switch(pos){
        case 0:
            switch (op){
                case 0:
                    file_out << "   lsl ";
                break;
                case 1:
                    file_out << "   lsr ";
                break;
                default:
                break;
            }
            aux = ((code[1] & 0x7)*pow(2, 2)) + ((code[2] & 0xc)/pow(2, 2));
        break;
        case 1:
            file_out << "   asr ";
            aux = ((code[1] & 0x7)*pow(2, 2)) + ((code[2] & 0xc)/pow(2, 2));
        break;
        case 2:
            switch (op){
                case 0:
                    file_out << "   str ";
                break;
                case 1:
                    file_out << "   ldr ";
                break;
                default:
                break;
            }
            aux = (((code[1] & 0x7)*pow(2, 2)) + ((code[2] & 0xc)/pow(2, 2)))*4;
        break;
        case 3:
            switch (op){
                case 0:
                    file_out << "   strb ";
                break;
                case 1:
                    file_out << "   ldrb ";
                break;
                default:
                break;
            }
            aux = ((code[1] & 0x7)*pow(2, 2)) + ((code[2] & 0xc)/pow(2, 2));
        break;
        case 4:
            switch (op){
                case 0:
                    file_out << "   strh ";
                break;
                case 1:
                    file_out << "   ldrh ";
                break;
                default:
                break;
            }
            aux = (((code[1] & 0x7)*pow(2, 2)) + ((code[2] & 0xc)/pow(2, 2)))*2;
        break;
        default:
        break;
    }
    file_out.close();

    decodificar_registradores(code[3] & 0x7, 'L', 1);
    if(pos == 2 || pos == 3 || pos == 4){
        file_out.open("docout.txt", ios::app);
        file_out << "[";
        file_out.close();
    }
    decodificar_registradores(((code[2] & 0x3)*pow(2, 1)) + ((code[3] & 0x8)/pow(2, 3)), 'L', 1);
    file_out.open("docout.txt", ios::app);
    file_out << "#" << aux;
    if(pos == 2 || pos == 3 || pos == 4){
        file_out << "]";
    }
    file_out << endl;
    file_out.close();
    return 0;
}

int terceira_linha(int* code, int op, int pos){
    ofstream file_out;
    file_out.open("docout.txt", ios::app);
    if(pos == 0 || pos == 1){
        if(op == 0){
            file_out << "   add ";
        }else{
            file_out << "   sub ";
        }
    }else if(pos == 2){
        switch (op){
            case 0:
                file_out << "   str ";
            break;
            case 1:
                file_out << "   strh ";
            break;
            case 2:
                file_out << "   strb ";
            break;
            case 3:
                file_out << "   ldrsb ";
            break;
            default:
            break;
        }
    }else{
        switch (op){
            case 0:
                file_out << "   ldr ";
            break;
            case 1:
                file_out << "   ldrh ";
            break;
            case 2:
                file_out << "   ldrb ";
            break;
            case 3:
                file_out << "   ldrsh ";
            break;
            default:
            break;
        }
    }
    file_out.close();
    decodificar_registradores(code[3] & 0x7, 'L', 1);
    decodificar_registradores(((code[2] & 0x3)*pow(2, 1)) + ((code[3] & 0x8)/pow(2, 3)), 'L', 1);
    if(pos == 1){
        file_out.open("docout.txt", ios::app);
        file_out << "#" << ((code[1] & 0x1)*pow(2, 2)) + ((code[2] & 0xc)/pow(2, 2)) << endl;
        file_out.close();
    }else{
        decodificar_registradores(((code[1] & 0x1)*pow(2, 2)) + ((code[2] & 0xc)/pow(2, 2)), 'L', 0);
    }
    return 0;
}

int quinta_linha(int* code, int op, int pos){
    ofstream file_out;
    int aux;
    file_out.open("docout.txt", ios::app);
    switch (pos){
        case 0:
            switch (op){
                case 0:
                    file_out << "   mov ";
                break;
                case 1:
                    file_out << "   cmp ";
                break;
                default:
                break;
            }
            aux = (code[2]*pow(2, 4)) + code[3];
        break;
        case 1:
            switch (op){
                case 0:
                    file_out << "   add ";
                break;
                case 1:
                    file_out << "   sub ";
                break;
                default:
                break;
            }
            aux = (code[2]*pow(2, 4)) + code[3];
        break;
        case 2:
            file_out << "   ldr ";
            aux = ((code[2]*pow(2, 4)) + code[3])*4;
        break;
        case 3:
            switch (op){
                case 0:
                    file_out << "   str ";
                break;
                case 1:
                    file_out << "   ldr ";
                break;
                default:
                break;
            }
            aux = ((code[2]*pow(2, 4)) + code[3])*4;
        break;
        case 4:
            file_out << "   add ";
            aux = ((code[2]*pow(2, 4)) + code[3])*4;
        break;
        case 5:
            switch (op){
                case 0:
                    file_out << "   push ";
                break;
                case 1:
                    file_out << "   pop ";
                break;
                default:
                break;
            }
        break;
        case 6:
            file_out << "   bkpt ";
            aux = (code[2]*pow(2, 4)) + code[3];
        break;
        case 7:
            switch (op){
                case 0:
                    file_out << "   stmia ";
                break;
                case 1:
                    file_out << "   ldmia ";
                break;
                default:
                break;
            }
        break;
        case 8:
            file_out << "   swi ";
            aux = (code[2]*pow(2, 4)) + code[3];
        break;
        default:
        break;
    }
    file_out.close();
    if(pos == 0 || pos == 1 || pos == 2 || pos == 3 || pos == 4 || pos == 7){
        decodificar_registradores(code[1] & 0x7, 'L', 1);
    }
    file_out.open("docout.txt", ios::app);
    if(pos == 7){
        file_out << "!, ";
    }
    if(pos == 2 || pos == 3){
        file_out << "[";
    }
    if(pos == 7 || pos == 5){
        file_out << "{";
    }
    if((pos == 2) || (pos == 4 && op == 0)){
        file_out << "pc, ";
    }
    if((pos == 3) || (pos == 4 && op == 1)){
        file_out << "sp, ";
    }
    if(pos == 7 || pos == 5){
        file_out.close();
        int r = (code[2]*pow(2, 4)) + code[3];
        switch (r){
            case 1:
                decodificar_registradores(0, 'L', 2);
            break;
            case 2:
                decodificar_registradores(1, 'L', 2);
            break;
            case 4:
                decodificar_registradores(2, 'L', 2);
            break;
            case 8:
                decodificar_registradores(3, 'L', 2);
            break;
            case 16:
                decodificar_registradores(4, 'L', 2);
            break;
            case 32:
                decodificar_registradores(5, 'L', 2);
            break;
            case 64:
                decodificar_registradores(6, 'L', 2);
            break;
            case 128:
                decodificar_registradores(7, 'L', 2);
            break;
            default:
            break;
        }
        file_out.open("docout.txt", ios::app);
    }else{
        file_out << "#" << aux;
    }
    if(pos == 2 || pos == 3){
        file_out << "]";
    }
    if(pos == 7 || pos == 5){
        file_out << "}";
    }
    file_out << endl;
    file_out.close();
    return 0;
}

int setima_linha(int* code, int op, int pos){
    ofstream file_out;
    file_out.open("docout.txt", ios::app);
    if(pos == 5 || pos == 6 || pos == 7){
        if(op == 0){
            file_out << "   add ";
        }else{
            file_out << "   mov ";
        }
    }else if(pos == 8 || pos == 9 || pos == 10){
        file_out << "   cmp ";
    }else{
        switch (pos){
            case 0:
                switch (op){
                    case 0:
                        file_out << "   and ";
                    break;
                    case 1:
                        file_out << "   eor ";
                    break;
                    case 2:
                        file_out << "   lsl ";
                    break;
                    case 3:
                        file_out << "   lsr ";
                    break;
                    default:
                    break;
                }
            break;
            case 1:
                switch (op){
                    case 0:
                        file_out << "   asr ";
                    break;
                    case 1:
                        file_out << "   adc ";
                    break;
                    case 2:
                        file_out << "   sbc ";
                    break;
                    case 3:
                        file_out << "   ror ";
                    break;
                    default:
                    break;
                }
            break;
            case 2:
                switch (op){
                    case 0:
                        file_out << "   tst ";
                    break;
                    case 1:
                        file_out << "   neg ";
                    break;
                    case 2:
                        file_out << "   cmp ";
                    break;
                    case 3:
                        file_out << "   cmn ";
                    break;
                    default:
                    break;
                }
            break;
            case 3:
                switch (op){
                    case 0:
                        file_out << "   orr ";
                    break;
                    case 1:
                        file_out << "   mul ";
                    break;
                    case 2:
                        file_out << "   bic ";
                    break;
                    case 3:
                        file_out << "   mvn ";
                    break;
                    default:
                    break;
                }
            break;
            case 4:
                file_out << "   cpy ";
            break;
            case 11:
                switch (op){
                case 0:
                    file_out << "   sxth ";
                break;
                case 1:
                    file_out << "   sxtb ";
                break;
                case 2:
                    file_out << "   uxth ";
                break;
                case 3:
                    file_out << "   uxtb ";
                break;
                default:
                break;
            }
            break;
            case 12:
                switch (op){
                case 0:
                    file_out << "   rev ";
                break;
                case 1:
                    file_out << "   rev16 ";
                break;
                case 3:
                    file_out << "   revsh ";
                break;
                default:
                break;
            }
            break;
            default:
            break;
        }
    }
    file_out.close();
    if(pos == 5 || pos == 7 || pos == 8 || pos == 10){
        decodificar_registradores(code[3] & 0x7, 'H', 1);
    }else{
        decodificar_registradores(code[3] & 0x7, 'L', 1);
    }
    if(pos == 6 || pos == 7 || pos == 9 || pos == 10){
        decodificar_registradores(((code[2] & 0x3)*pow(2, 1)) + ((code[3] & 0x8)/pow(2, 3)), 'H', 0);
    }else{
        decodificar_registradores(((code[2] & 0x3)*pow(2, 1)) + ((code[3] & 0x8)/pow(2, 3)), 'L', 0);
    }
    return 0;
}

int decimaoitava_linha(int* code, int op){
    ofstream file_out;
    file_out.open("docout.txt", ios::app);
    switch (op){
        case 0:
            file_out << "   bx ";
        break;
        case 1:
            file_out << "   blx ";
        break;
        default:
        break;
    }
    file_out.close();
    decodificar_registradores(((code[2] & 0x7)*pow(2, 1))+((code[3] & 0x8)/pow(2, 3)), 'R', 0);
    return 0;
}

int vigesimasetima_linha(int* code, int op){
    ofstream file_out;
    file_out.open("docout.txt", ios::app);
    switch (op){
        case 0:
            file_out << "   add sp, ";
        break;
        case 1:
            file_out << "   sub sp, ";
        break;
        default:
        break;
    }
    file_out << "#" << (((code[2] & 0x7)*pow(2, 4)) + code[3])*4 << "]" << endl;
    file_out.close();
    return 0;
}

int trigesimaprimeira_linha(int* code, int op){
    ofstream file_out;
    file_out.open("docout.txt", ios::app);
    switch (op){
        case 0:
            file_out << "   setend le ";
        break;
        case 1:
            file_out << "   setend be ";
        break;
        default:
        break;
    }
    file_out.close();
    return 0;
}

int trigesimasegunda_linha(int* code, int op){
    ofstream file_out;
    file_out.open("docout.txt", ios::app);
    switch (op){
        case 0:
            file_out << "   cpsie ";
        break;
        case 1:
            file_out << "   cpsid ";
        break;
        default:
        break;
    }
    file_out.close();
    return 0;
}

int trigesimaquinta_linha(int* code, int op, int line){
    int offset = (code[2]*(pow(2, 4))) + code[3];
    if(code[1] & 0x4){
        offset = (2048 - offset)*(-1);
    }
    ofstream file_out;
    file_out.open("docout.txt", ios::app);
    switch (op){
        case 0:
            file_out << "   beq ";
        break;
        case 1:
            file_out << "   bne ";
        break;
        case 2:
            file_out << "   bcs ";
        break;
        case 3:
            file_out << "   bcc ";
        break;
        case 4:
            file_out << "   bmi ";
        break;
        case 5:
            file_out << "   bpl ";
        break;
        case 6:
            file_out << "   bvs ";
        break;
        case 7:
            file_out << "   bvc ";
        break;
        case 8:
            file_out << "   bhi ";
        break;
        case 9:
            file_out << "   bls ";
        break;
        case 10:
            file_out << "   bge ";
        break;
        case 11:
            file_out << "   blt ";
        break;
        case 12:
            file_out << "   bgt ";
        break;
        case 13:
            file_out << "   ble ";
        break;
        default:
        break;
    }
    file_out << line+4+(offset*2) << endl;
    file_out.close();
    return 0;
}

int trigesimaoitava_linha(int* code, int line){
    ofstream file_out;
    int offset = ((code[1] & 0x7)*(pow(2, 8))) + (code[2]*(pow(2, 4))) + code[3];
    if(code[1] & 0x4){
        offset = (2048 - offset)*(-1);
    }
    if(code[0] == 14){
        file_out.open("docout.txt", ios::app);
        file_out << "   b ";
        file_out << line+4+(offset*2) << endl;
        file_out.close();
    }else{
        poff = offset;
    }
    return 0;
}

int trigesimanona_linha(int* code, int line){
    ofstream file_out;
    int offset = ((code[0] & 0x7)*(pow(2, 7))) + (code[2]*(pow(2, 3))) + ((code[3] & 0x14)/(pow(2, 1)));
    int calc = (line+4+(poff*(pow(2, 12)))+(offset*4));
    int result = calc/(pow(2, 2));
    result = result*(pow(2, 2));
    file_out.open("docout.txt", ios::app);
    file_out << "   blx ";
    file_out << result << endl;
    file_out.close();
    return 0;
}

int quadrigesimaprimeira_linha(int* code, int line){
    ofstream file_out;
    int offset = ((code[1] & 0x7)*(pow(2, 8))) + (code[2]*(pow(2, 4))) + code[3];
    file_out.open("docout.txt", ios::app);
    file_out << "   bl ";
    file_out << line+4+(poff*(pow(2, 12)))+(offset*2) << endl;
    file_out.close();
    return 0;
}

int decodificar_registradores(int r, char n, int v){
    ofstream file_out;
    file_out.open("docout.txt", ios::app);
    int i;
 
    if(n == 'R'){
        switch (r){
            case 0:
                file_out << "r0";
            break;
            case 1:
                file_out << "r1";
            break;
            case 2:
                file_out << "r2";
            break;
            case 3:
                file_out << "r3";
            break;
            case 4:
                file_out << "r4";
            break;
            case 5:
                file_out << "r5";
            break;
            case 6:
                file_out << "r6";
            break;
            case 7:
                file_out << "r7";
            break;
            case 8:
                file_out << "r8";
            break;
            case 9:
                file_out << "r9";
            break;
            case 10:
                file_out << "r10";
            break;
            case 11:
                file_out << "r11";
            break;
            case 12:
                file_out << "r12";
            break;
            case 13:
                file_out << "r13";
            break;
            case 14:
                file_out << "r14";
            break;
            case 15:
                file_out << "r15";
            break;
            default:
            break;
        }

        file_out.close();
        return 0;
        
    }else if(n == 'L'){
        i = 0;
    }else if(n == 'H'){
        i = 8;
    }

    switch (r){
        case 0:
            file_out << "r" << i;
        break;
        case 1:
            file_out << "r" << i+1;
        break;
        case 2:
            file_out << "r" << i+2;
        break;
        case 3:
            file_out << "r" << i+3;
        break;
        case 4:
            file_out << "r" << i+4;
        break;
        case 5:
            file_out << "r" << i+5;
        break;
        case 6:
            file_out << "r" << i+6;
        break;
        case 7:
            file_out << "r" << i+7;
        break;
        default:
        break;
    }

    if(v == 1){
        file_out << ", ";
    }else if(v == 2){
        file_out.close();
        return 0;
    }else{
        file_out << endl;
    }

    file_out.close();
    return 0;
}

int decodificar_comandos(int line, int* code){

    switch (code[0]){                            //para entender essa parte é necessário entender a tabela
        case 0:
            switch (code[1] & 0x8){
                case 0:
                    primeira_linha(code, 0, 0);
                    //printf LSL
                    //cont code
                break;
                case 8:
                    primeira_linha(code, 1, 0);
                    //printf LSR
                    //cont code
                break;
                default:
                break;
            }
        break;
        case 1:
            switch (code[1] & 0x8){
                case 0:
                    primeira_linha(code, 0, 1);
                    //printf ASR
                    //cont code
                break;
                case 8:
                    switch (code[1] & 0x4){ 
                        case 0:
                            switch (code[1] & 0x2){
                                case 0:
                                    terceira_linha(code, 0, 0);
                                break;
                                case 2:
                                    terceira_linha(code, 1, 0);
                                    //printf SUB
                                    //cont code
                                break;
                                default:
                                break;
                            }
                        break;
                        case 4:
                            switch (code[1] & 0x2){
                                case 0:
                                    terceira_linha(code, 0, 1);
                                    //printf ADD
                                    //cont code
                                break;
                                case 2:
                                    terceira_linha(code, 1, 1);
                                    //printf SUB
                                    //cont code
                                break;
                                default:
                                break;
                            }
                        break;
                        default:
                        break;
                    }
                break;
                default:
                break;
            }
        break;
        case 2:
            switch (code[1] & 0x8){
                case 0:
                    quinta_linha(code, 0, 0);
                    //printf MOV
                break;
                case 8:
                    quinta_linha(code, 1, 0);
                    //printf CMP
                    //cont code
                break;
                default:
                break;
            }
        break;
        case 3:
            switch (code[1] & 0x8){
                case 0:
                    quinta_linha(code, 0, 1);
                    //printf ADD
                    //cont code
                break;
                case 8:
                    quinta_linha(code, 1, 1);
                    //printf SUB
                    //cont code
                break;
                default:
                break;
            }
        break;
        case 4:
            switch (code[1] & 0x8){
                case 0:
                    switch (code[1] & 0x4){
                        case 0:
                            switch (code[1] & 0x2){
                                case 0:
                                    switch (code[1] & 0x1){
                                        case 0:
                                            switch (code[2] & 0xc){ 
                                                case 0:
                                                    setima_linha(code, 0, 0);
                                                    //printf AND
                                                    //cont code
                                                break;
                                                case 4:
                                                    setima_linha(code, 1, 0);
                                                    //printf EOR
                                                    //cont code
                                                break;
                                                case 8:
                                                    setima_linha(code, 2, 0);
                                                    //printf LSL
                                                    //cont code
                                                break;
                                                case 12:
                                                    setima_linha(code, 3, 0);
                                                    //printf LSR
                                                    //cont code
                                                break;
                                                default:
                                                break;
                                            }
                                        break;
                                        case 1:
                                            switch (code[2] & 0xc){ 
                                                case 0:
                                                    setima_linha(code, 0, 1);
                                                    //printf ASR
                                                    //cont code
                                                break;
                                                case 4:
                                                    setima_linha(code, 1, 1);
                                                    //printf ADC
                                                    //cont code
                                                break;
                                                case 8:
                                                    setima_linha(code, 2, 1);
                                                    //printf SBC
                                                    //cont code
                                                break;
                                                case 12:
                                                    setima_linha(code, 3, 1);
                                                    //printf ROR
                                                    //cont code
                                                break;
                                                default:
                                                break;
                                            }
                                        break;
                                        default:
                                        break;
                                    }
                                break;
                                case 2:
                                    switch (code[1] & 0x1){
                                        case 0:
                                            switch (code[2] & 0xc){
                                                case 0:
                                                    setima_linha(code, 0, 2);
                                                    //printf TST
                                                    //cont code
                                                break;
                                                case 4:
                                                    setima_linha(code, 1, 2);
                                                    //printf NEG
                                                    //cont code
                                                break;
                                                case 8:
                                                    setima_linha(code, 2, 2);
                                                    //printf CMP
                                                    //cont code
                                                break;
                                                case 12:
                                                    setima_linha(code, 3, 2);
                                                    //printf CMN
                                                    //cont code
                                                break;
                                                default:
                                                break;
                                            }
                                        break;
                                        case 1:
                                            switch (code[2] & 0xc){
                                                case 0:
                                                    setima_linha(code, 0, 3);
                                                    //printf ORR
                                                    //cont code
                                                break;
                                                case 4:
                                                    setima_linha(code, 1, 3);
                                                    //printf MUL
                                                    //cont code
                                                break;
                                                case 8:
                                                    setima_linha(code, 2, 3);
                                                    //printf BIC
                                                    //cont code
                                                break;
                                                case 12:
                                                    setima_linha(code, 3, 3);
                                                    //printf MVN
                                                    //cont code
                                                break;
                                                default:
                                                break;
                                            }
                                        break;
                                        default:
                                        break;
                                    }
                                break;
                                default:
                                break;
                            }
                        break;
                        case 4:
                            switch (code[1] & 0x2){
                                case 0:
                                    switch (code[1] & 0x1){
                                        case 0:
                                            switch (code[2] & 0x8){
                                                case 0:
                                                    setima_linha(code, 0, 5);
                                                    //printf ADD Ld, Hm
                                                    //cont code
                                                break;
                                                case 8:
                                                    switch (code[2] & 0x4){
                                                        case 0:
                                                            setima_linha(code, 0, 6);
                                                            //printf ADD Hd, Lm
                                                            //cont code
                                                        break;
                                                        case 4:
                                                            setima_linha(code, 0, 7);
                                                            //printf ADD Hd, Hm
                                                            //cont code
                                                        break;
                                                        default:
                                                        break;
                                                    }
                                                break;
                                                default:
                                                break;
                                            }
                                        break;
                                        case 1:
                                            switch (code[2] & 0x8){
                                                case 0:
                                                    setima_linha(code, 0, 8);
                                                    //printf CMP
                                                    //cont code
                                                break;
                                                case 8:
                                                    switch (code[2] & 0x4){
                                                        case 0:
                                                            setima_linha(code, 0, 9);
                                                            //printf CMP
                                                            //cont code
                                                        break;
                                                        case 4:
                                                            setima_linha(code, 0, 10);
                                                            //printf CMP
                                                            //cont code
                                                        break;
                                                        default:
                                                        break;
                                                    }
                                                break;
                                                default:
                                                break;
                                            }
                                        break;
                                        default:
                                        break;
                                    }
                                break;
                                case 2:
                                    switch (code[1] & 0x1){
                                        case 0:
                                            switch (code[2] & 0x8){
                                                case 0:
                                                    switch (code[2] & 0x4){
                                                        case 0:
                                                            setima_linha(code, 0, 4);
                                                            //printf CPY Ld, Lm
                                                            //cont code
                                                        break;
                                                        case 4:
                                                            setima_linha(code, 1, 5);
                                                            //printf MOV Ld, Hm
                                                        break;
                                                        default:
                                                        break;
                                                    }
                                                break;
                                                case 8:
                                                    switch (code[2] & 0x4){
                                                        case 0:
                                                            setima_linha(code, 1, 6);
                                                            //printf MOV Hd, Lm
                                                        break;
                                                        case 4:
                                                            setima_linha(code, 1, 7);
                                                            //printf MOV Hd, Hm
                                                        break;
                                                        default:
                                                        break;
                                                    }
                                                break;
                                                default:
                                                break;
                                            }
                                        break;
                                        case 1:
                                            switch (code[2] & 0x8){
                                                case 0:
                                                    decimaoitava_linha(code, 0);
                                                    //printf BX
                                                    //cont code
                                                break;
                                                case 8:
                                                    decimaoitava_linha(code, 1);
                                                    //printf BLX
                                                    //cont code
                                                break;
                                                default:
                                                break;
                                            }
                                        break;
                                        default:
                                        break;
                                    }
                                break;
                                default:
                                break;
                            }
                        break;
                        default:
                        break;
                    }
                break;
                case 8:
                    quinta_linha(code, 0, 2);
                    //printf LDR Ld, [pc, #immed*4]
                    //cont code
                break;
                default:
                break;
            }
        break;
        case 5:
            switch (code[1] & 0x8){
                case 0:
                    switch (code[1] & 0x6){ 
                        case 0:
                            terceira_linha(code, 0, 2);
                            //printf STR pre
                            //cont code
                        break;
                        case 2:
                            terceira_linha(code, 1, 2);
                            //printf STRH pre
                            //cont code
                        break;
                        case 4:
                            terceira_linha(code, 2, 2);
                            //printf STRB pre
                            //cont code
                        break;
                        case 6:
                            terceira_linha(code, 3, 2);
                            //printf LDRSB pre
                            //cont code
                        break;
                        default:
                        break;
                    }
                break;
                case 8:
                    switch (code[1] & 0x6){ 
                        case 0:
                            terceira_linha(code, 0, 3);
                            //printf LDR pre
                            //cont code
                        break;
                        case 2:
                            terceira_linha(code, 1, 3);
                            //printf LDRH pre
                            //cont code
                        break;
                        case 4:
                            terceira_linha(code, 2, 3);
                            //printf LDRB pre
                            //cont code
                        break;
                        case 6:
                            terceira_linha(code, 3, 3);
                            //printf LDRSH pre
                            //cont code
                        break;
                        default:
                        break;
                    }
                break;
                default:
                break;
            }
        break;
        case 6:
            switch (code[1] & 0x8){
                case 0:
                    primeira_linha(code, 0, 2);
                    //printf STR Ld, [Ln, #immed*4]
                    //cont code
                break;
                case 8:
                    primeira_linha(code, 1, 2);
                    //printf LDR Ld, [Ln, #immed*4]
                    //cont code
                default:
                break;
            }
        break;
        case 7:
            switch (code[1] & 0x8){
                case 0:
                    primeira_linha(code, 0, 3);
                    //printf STRB Ld, [Ln, #immed]
                    //cont code
                break;
                case 8:
                    primeira_linha(code, 1, 3);
                    //printf LDRB Ld, [Ln, #immed]
                    //cont code
                default:
                break;
            }
        break;
        case 8:
            switch (code[1] & 0x8){
                case 0:
                    primeira_linha(code, 0, 4);
                    //printf STRH Ld, [Ln, #immed*2]
                    //cont code
                break;
                case 8:
                    primeira_linha(code, 1, 4);
                    //printf LDRH Ld, [Ln, #immed*2]
                    //cont code
                default:
                break;
            }
        break;
        case 9:
            switch (code[1] & 0x8){
                case 0:
                    quinta_linha(code, 0, 3);
                    //printf STR Ld, [sp, #immed*4]
                    //cont code
                break;
                case 8:
                    quinta_linha(code, 1, 3);
                    //printf LDR Ld, [sp, #immed*4]
                    //cont code
                default:
                break;
            }
        break;
        case 10:
            switch (code[1] & 0x8){
                case 0:
                    quinta_linha(code, 0, 4);
                    // comando_add(code, 6);
                    //printf ADD Ld, pc, #immed*4 |
                    //cont code
                break;
                case 8:
                    quinta_linha(code, 1, 4);
                    // comando_add(code, 7);
                    //printf ADD Ld, sp, #immed*4
                    //cont code
                default:
                break;
            }
        break;
        case 11:
            switch (code[1] & 0x8){
                case 0:
                    switch (code[1] & 0x4){
                        case 0:
                            switch (code[1] & 0x2){
                                case 0:
                                    switch (code[2] & 0x8){
                                        case 0:
                                            vigesimasetima_linha(code, 0);
                                            // comando_add(code, 8);
                                            //printf ADD sp, #immed*4
                                            //cont code
                                        break;
                                        case 8:
                                            vigesimasetima_linha(code, 1);
                                            // comando_sub(code, 3);
                                            //printf SUB sp, #immed*4
                                            //cont code
                                        break;
                                        default:
                                        break;
                                    }
                                break;
                                case 2:
                                    switch (code[2] & 0xc){ 
                                        case 0:
                                            setima_linha(code, 0, 11);
                                            //printf SXTH
                                            //cont code
                                        break;
                                        case 4:
                                            setima_linha(code, 1, 11);
                                            //printf SXTB
                                            //cont code
                                        break;
                                        case 8:
                                            setima_linha(code, 2, 11);
                                            //printf UXTH
                                            //cont code
                                        break;
                                        case 12:
                                            setima_linha(code, 3, 11);
                                            //printf UXTB
                                            //cont code
                                        break;
                                        default:
                                        break;
                                    }
                                break;
                                default:
                                break;
                            }
                        break;
                        case 4:
                            switch (code[1] & 0x2){
                                case 0:
                                    quinta_linha(code, 0, 5);
                                    //printf PUSH
                                    //cont code
                                break;
                                case 2:
                                    switch (code[2] & 0x2){
                                        case 0:
                                            switch (code[3] & 0x8){
                                                case 0:
                                                    trigesimaprimeira_linha(code, 0);
                                                    //printf SETEND LE
                                                    //cont code
                                                break;
                                                case 8:
                                                    trigesimaprimeira_linha(code, 1);
                                                    //printf SETEND BE
                                                    //cont code
                                                break;
                                                default:
                                                break;
                                            }
                                        break;
                                        case 2:
                                            switch (code[2] & 0x1){
                                                case 0:
                                                    trigesimasegunda_linha(code, 0);
                                                    //printf CPSIE
                                                    //cont code
                                                break;
                                                case 1:
                                                    trigesimasegunda_linha(code, 1);
                                                    //printf CPSID
                                                    //cont code
                                                break;
                                                default:
                                                break;
                                            }
                                        break;
                                        default:
                                        break;
                                    }
                                break;
                                default:
                                break;
                            }
                        break;
                        default:
                        break;
                    }
                break;
                case 8:
                    switch (code[1] & 0x4){
                        case 0:
                            switch (code[2] & 0xc){
                                case 0:
                                    setima_linha(code, 0, 12);
                                    //printf REV
                                    //cont code
                                break;
                                case 4:
                                    setima_linha(code, 1, 12);
                                    //printf REV16
                                    //cont code
                                break;
                                case 12:
                                    setima_linha(code, 3, 12);
                                    //printf REVSH
                                    //cont code
                                break;
                                default:
                                break;
                            }
                        break;
                        case 4:
                            switch (code[1] & 0x2){
                                case 0:
                                    quinta_linha(code, 1, 5);
                                    //printf POP
                                    //cont code
                                break;
                                case 2:
                                    quinta_linha(code, 0, 6);
                                    //printf BKPT immed8
                                    //cont code
                                break;
                                default:
                                break;
                            }
                        break;
                        default:
                        break;
                    }
                break;
                default:
                break;
            }
        break;
        case 12:
            switch (code[1] & 0x8){
                case 0:
                    quinta_linha(code, 0, 7);
                    //printf STMIA Ln!, {register-list}
                    //cont code
                break;
                    quinta_linha(code, 1, 7);
                case 8:
                    //printf LDMIA Ln!, {register-list}
                    //cont code
                break;
                default:
                break;
            }
        break;
        case 13:
            switch (code[1] & 0xf){
                case 15:
                    quinta_linha(code, 0, 8);
                    //printf SWI immed8
                    //cont code
                break;
                case 14:
                    //Undefined and expected to remain so
                break;
                default:
                    trigesimaquinta_linha(code, code[1] & 0xf, line);
                    //printf B<cond> instruction_address+4+offset*2
                    //condicionais
                    //cont code
                break;
            }
        break;
        case 14:
            switch (code[1] & 0x8){
                case 0:
                    trigesimaoitava_linha(code, line);
                    //printf B instruction_address+4+offset*2
                    //cont code
                break;
                case 8:
                    trigesimanona_linha(code, line);
                    //printf BLX ((instruction+4+(poff<<12)+offset*4) &~ 3)
                    //cont code
                break;
                default:
                break;
            }
        break;
        case 15:
            switch (code[1] & 0x8){
                case 0:
                    trigesimaoitava_linha(code, line);
                    //This is the branch prefix instruction. It must befollowed by a relative BL or BLX instruction.
                    //cont code
                break;
                case 8:
                    quadrigesimaprimeira_linha(code, line);
                    //printf BL instruction+4+ (poff<<12)+offset*2
                    //cont code
                break;
                default:
                break;
            }
        break;
        default:
        break;
    }

    return 0;
}

int translate(char caractere){
    switch (caractere){
        case '0':
            return 0;
        break;
        case '1':
            return 1;
        break;
        case '2':
            return 2;
        break;
        case '3':
            return 3;
        break;
        case '4':
            return 4;
        break;
        case '5':
            return 5;
        break;
        case '6':
            return 6;
        break;
        case '7':
            return 7;
        break;
        case '8':
            return 8;
        break;
        case '9':
            return 9;
        break;
        case 'a':
            return 10;
        break;
        case 'b':
            return 11;
        break;
        case 'c':
            return 12;
        break;
        case 'd':
            return 13;
        break;
        case 'e':
            return 14;
        break;
        case 'f':
            return 15;
        break;
        default:
        break;
    }

    return 0;
}

int organize(char* vet, int n){
    int n_address;
    for(int i=0; i<n; i++){
        if(vet[i] == ':'){
            n_address = i;
        }
    }

    char address[n_address], first[4], second[4];
    int j = 0, k = 0, m = 0;
    for(int i=0; i<n; i++){
        if(vet[i] != ' ' && vet[i] != ':'){
            if(i < n_address){
                address[m] = vet[i];
                m++;
            }else if(i < n_address+6){
                second[j] = vet[i];
                j++;
            }else if(i < n_address+10){
                first[k] = vet[i];
                k++;
            }                             //nessas primeiras linhas da função eu to separando cada parte do vetor pra mexer so com o que eu quero
        }                                 //ex: vetor no inicio -> 8: bc04df0a                   vetor do endereço -> 8
    }                                     //    vetor da primeira linha de codigo -> d f 0 a     vetor da segunda linha de codigo -> b c 0 4

    int* a = new int [n_address];
    int* f = new int [4];
    int* s = new int [4];
    for(int i=0; i<n_address; i++){
        a[i] = translate(address[i]);     //o translate é pra transformar de hexa pra decimal
    }
    int linha = a[0];
    for(int i=1; i<n_address; i++){
        linha = linha*(pow(2, 4));
        linha += a[i];
    }
    for(int i=0; i<4; i++){
        f[i] = translate(first[i]);
        s[i] = translate(second[i]);     //nessas linhas eu to tranformando o vetor do endereço num numero e os vetores de linha de codigo que
    }                                    //estavam em hexa para decimal, ficando:
                                         //linha = 8     vetor da primeira linha de codigo = 13 15 0 10     vetor da segunda linha de codigo = 11 12 0 4
    if(f[0]==0 && f[1]==0 && f[2]==0 && f[3]==0 ){
        return 0;
    }                                    //se caso o codigo for 0000 finaliza o programa
    decodificar_comandos(linha, f);      //decodificar os comandos enviando como parametro a linha (endereço) e o vetor da primeira linha de codigo
    if(s[0]==0 && s[1]==0 && s[2]==0 && s[3]==0 ){
        return 0;
    }                                    //se caso o codigo for 0000 finaliza o programa
    decodificar_comandos(linha+2, s);    //decodificar os comandos enviando como parametro a linha (endereço) e o vetor da segunda linha de codigo

    return 0;
}

int main(){

    ofstream file_out;                //ofstream vem de out, ou seja eu estou criando um ponteiro para um arquivo que eu quero escrever
    file_out.open("docout.txt");      //se o arquivo nao existir o programa criará um arquivo com esse nome e irá abir-lo, se existir ele so abre o arquivo
    file_out << ".thumb" << endl;     //essa será a primeira linha que estará escrita no arquivo
    file_out.close();                 //aqui o arquivo esta sendo fechado (sempre fechar o arquivo depois de acabar o que foi feito nele, senão da erro)

    ifstream file_in;                 //ifstream vem de in, ou seja eu estou criando um ponteiro para um arquivo que eu quero ler
    string line_in;                   //estou declarando uma string chamada line_in
    
    file_in.open("docin.txt");        //irei abrir o arquivo que terá esse nome, senão existir ele criará, mas não terá nada la dentro, então tem que
                                      //colocar o codigo nesse arquivo
    while(getline(file_in, line_in)){ //aqui eu to carregando o que tem na primeira linha do arquivo que esta sendo apontado pelo file_in e colocando no line_in e assim por diante
        int tam = line_in.length();   //aqui eu vou pegar quantos caracteres tem a minha string e armazenar em tam
        char *code = new char [tam];  //crio um ponteiro q aponta para um vetor de char de tamanho tam
        strcpy(code, line_in.c_str());//aqui eu to tornando minha string num vetor de char

        organize(code, tam);          //agora vou organizar o codigo para separar os endereços das linhas e os codigos
    }

    file_in.close();

    return 0;
}
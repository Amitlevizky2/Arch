macros:
    %macro startFunction 0
        push    ebp
        mov     ebp, esp
    %endmacro

    %macro endFunction 0
        mov     esp, ebp
        pop     ebp
        ret
    %endmacro

    %macro printwinn 1
        pushad
        push dword [%1]
        push printwin
        call printf
        add esp,8
        popad
        %endmacro
    
    %macro endFunctionParameter 0
        mov     eax, dword[ebp-4]
        mov     esp, ebp
        pop     ebp
        ret
    %endmacro
%macro generate_num 2
        push %1
        push %2
        call random_number
        add esp,8
%endmacro




%macro zero_q 1
    mov dword [%1],0
    mov dword [%1+4],0
%endmacro


%macro print_float 0
    fld qword [res]
    sub esp,8
    fstp qword [esp]
    push format_string_2f
    call printf
    add esp,12
    %endmacro




section .text                           ; functions from c libary
  align 16

     global drone:function
     extern ass3
     extern res
     extern CURR
     extern beta
     extern d
     extern T
     extern N
     extern xt
     extern yt
     extern targetCo
     extern dronesArray
     extern random_number
     extern target
     extern CORS
     extern res
     extern resume
     extern CURR
     extern endCo
     extern schedulerCo
     extern scheduler
     extern printer
     extern printf 
     extern fprintf
     extern sscanf
     extern malloc
     extern free

 
    
     drone:
        
        finit
                                xor esi, esi
                                mov esi, [CORS]
                                mov esi, [esi]
                                mov esi, [esi +8]
        xor eax,eax
        mov eax,dword [CURR]
        ;mov eax,dword [eax]
        mov eax, [eax + 8]
        shl eax,2
        xor ebx,ebx
        mov ebx, [dronesArray]
        
        add ebx,eax
        fld qword [ebx]
        fstp qword [x1]
        fld qword [ebx+8]
        fstp qword [y1]
        fld qword [ebx+16]
        fstp qword [alpha]
       


 
     calc_gagree:
        
        generate_num deg1,deg
        fld qword [res]
        fld qword [alpha]               ; drone old degree
        fadd
        fstp qword [alpha]
        fld qword [alpha]
        fild dword [deg]    
        fcomip
        jl nofixdegree 
        fild qword [alpha]
        fsub dword [deg]
        ;zero_q alpha
        fstp qword [alpha]
        nofixdegree:
        fld qword [alpha]
        fild dword [halffeg]
        fdiv 
        fldpi
        fmul
        fstp qword [alpha]
        

     calc_dist: 
            
        zero_q res
        zero_q x2           
        zero_q y2
        generate_num dis1,dis
        fld qword [alpha]       ;load angle into st0
        fld qword [rad]
        fmul
        fcos                        ;st0 = cos(ang)
        fmul qword [res]            ;st0 = cos(ang) * distance
        fstp qword [x2]             ; distance*cos(deg)
        fld qword [x1]
        fld qword [x2]
        fadd 
        fild dword [dis]
        fcomip                      ;if new distance>100
        jae checklowx
        fild dword [dis]
        fsub
        checklowx:
        fild dword [zerodata]
        fcomip
        jb calcYsin
        fild dword [dis]
        fadd
        fstp qword [x1]             ;new x place
        calcYsin:

        fld qword [alpha]       ;load angle into st0
        fld qword [rad]
        fmul
        fsin                        ;st0 = cos(ang)
        fmul qword [res]            ;st0 = cos(ang) * distance
        fstp qword [y2]             ; distance*cos(deg)
        fld qword [y1]
        fadd qword [y2]
        fild dword [dis]
        fcomip                      ;if new distance>100
        jae checklowy
        fild dword [dis]
        fsub
        checklowy:
        fild dword [zerodata]
        fcomip
        jb myDestroy
        fild dword [dis]
        fadd
        fstp qword [y1]             ;new x place
        


        myDestroy:
            push ebp
            mov ebp,esp
            fld qword [xt]
            fld qword [x1]
            fsub 
            fstp qword [xmd]
            fld qword [yt]
            fld qword [y1]
            fsub 
            fstp qword [ymd]
            call calc_distance
            call calc_deg

            fild dword [d]
            fld qword [dis_tar_dro]
            fcomip              ; check if distance to target < d
            jae resumeSchedular
            fld qword [beta]
            fld qword [gamma]
            fcomip
            jae resumeSchedular     ; TODO make resume scheduler
            call distroyTarget
            jmp drone

            


            calc_distance:
                startFunction
                fld qword [ymd]
                fld qword [ymd]
                fmul    
                fstp qword [ymd]
                fld qword [xmd]
                fld qword [xmd]
                fmul
                fstp qword [xmd]
                fld qword [ymd]
                fld qword [xmd]
                fadd
                fsqrt
                fstp qword [dis_tar_dro]
                pop ebp
                ret


            calc_deg:
                startFunction
                ffree
                fld qword [ymd]
                fld  qword [xmd]
                fpatan
                fstp qword [gamma]
                fld qword [gamma]
                fld qword [pi]
                fmul
                fstp qword [gamma]
                fld qword [gamma]
                fld qword [alpha]
                fsub 
                fabs
                fstp qword [gamma]
                fldpi
                fld qword [gamma]
                fcomip
                ja add2pi
                ffree
                pop ebp
                ret
                add2pi:
                fldpi
                fadd
                fldpi
                fadd
                fld qword [gamma]
                endFunction
                

            
        distroyTarget:
            startFunction
            ffree
            xor eax,eax
            mov eax,dword [CURR]
            ;mov eax,dword [eax]
            add eax,8
            shl eax,2
            xor ebx,ebx
            mov ebx,dword [dronesArray]
            add ebx,eax
            add dword [ebx+24],1
            mov esi,[T]
            cmp esi, dword [ebx+24]
            je printwinner

            mov eax,[CORS]
            mov ecx,dword [targetCo]
            add eax,ecx
            mov ebx,[eax]
            ffree
            call resume
            endFunction
            





            printwinner:
                printwinn eax
                ffree   
                call endCo






                resumeSchedular:
                    xor ebx,ebx
                    xor eax,eax
                    xor esi,esi
                    mov eax,[CORS]
                    mov esi,dword [schedulerCo]
                    add eax,esi
                    mov ebx,[eax]
                    ffree
                    call resume
                    jmp drone





        

section .data
    deg : dd 360
    dis :dd 100
    deg1 : dd 60
    dis1 :dd 50
    halffeg :dd 180
    rad : dq 0.0174532925199433
    pi: dq 57.2957795130823209
    degree: dd 0
    zerodata: dd 0
    olddegree: dd 0
    dronearr : dd 0
    distance: dd 0
    olddistance: dd 0
    x2: dd 0            ;delta x cordinate     
    y2: dd 0            ;first y cordinate
    x1: dq 0
    y1: dq 0
    xmd: dq 0 
    ymd: dq 0
    dis_tar_dro: dq 0
    numofhit: dq 0
    alpha: dq 0
    gamma: dd 0
    maxint : DD 0xffff
    format_string_2f: db "%.2f",10,0 ; float 2 numbers after dot
    format_string : db "%d",10,0 
    printwin: db "Drone id %d: I am a winner",10,0


section .bss
 


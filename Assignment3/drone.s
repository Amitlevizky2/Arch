macros:
    %macro startFunction 0
        push    ebp
        mov     ebp, esp
    %endmacro

    %macro endFunction 0
        popa
        mov     esp, ebp
        pop     ebp
        ret
    %endmacro

    %macro printwinn 1
        pushad
        push [%1]
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

%macro in_renage 2
    fld qword [%1]
    fild dword [%2]
    fcomip
    jg %%bigger
    fld qword [%1]
    ftst
    jl %%lower
   jmp  %%endmacro_in
    %%bigger:
        fsub dword [%2]
        fstp qword [%1]
        jmp %%endmacro_in
    %%lower:
        fadd dword [%2]
        fstp qword [%1]
    %%endmacro_in:      
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
     extern xt
     extern yt
     extern dronesArray
     extern random_number
     extern target
     extern scheduler
     extern printer
     extern printf 
     extern fprintf
     extern sscanf
     extern malloc
     extern free

 
    
     drone:
        finit
        xor eax,eax
        mov eax,dword [CURR]
        ;mov eax,dword [eax]
        add eax,8
        shl eax,2
        xor ebx,ebx
        mov ebx,dword [dronesArray]
        add ebx,eax
        fild qword [ebx]
        fstp qword [x1]
        fild qword [ebx+8]
        fstp qword [y1]
        fild qword [ebx+16]
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
        zero_q olddegree
        fstp qword [alpha]
        nofixdegree:


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
        fadd qword [x2]
        zero_q x1
        fstp qword [x1]             ;new x place
        in_renage x1,dis
        fld qword [alpha]       ;load angle into st0
        fld qword [rad]
        fmul
        fsin                        ;st0 = cos(ang)
        fmul qword [res]            ;st0 = cos(ang) * distance
        fstp qword [y2]             ;distance*cos(deg)
        fld qword [y1]
        fadd qword [y2]
        zero_q y1
        fstp qword [y1]             ;new y place
        in_renage y1,dis
        zero_q res 


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
            fae resumeSchedular
            fld qword [beta]
            fld qword [gamma]
            fcomip
            jae resumeSchedular     ; TODO make resume scheduler

            call distroyTarget

            







            calc_distance:
                startFunction
                fld qword [ymd]
                fld qword [ymd]
                fmul    
                fld qword [xmd]
                fld qword [xmd]
                fmul
                fadd
                fsqrt
                fstp qword [dis_tar_dro]
                pop ebp
                ret


            calc_deg:
                startFunction
                fld qword [ymd]
                fld  qword [xmd]
                fpatan
                fstp qword [gamma]
                fld qword [alpha]
                fsub qword [gamma]

                fld qword [qamma]
                fld qword [pi]
                fmul
                fstp qword [gamma]
                pop ebp
                ret
                

            
        distroyTarget:
            startFunction
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
            jmp resumetarger    ;TODO make resume target




            printwinner:
                xor ecx,ecx
                mov ecx,dword [eax]
                printwinn eax
                ffree




          












        

section .data
    deg equ 360
    dis equ 100
    deg1 equ 60
    dis1 equ 50
    halffeg :dd 180
    rad : oword 0.0174532925199433
    pi: oword 57.2957795130823209
    degree: dd 0
    olddegree: dd 0
    dronearr : dd 0
    distance: dd 0
    olddistance: dd 0
    x2: dd 0            ;delta x cordinate     
    y2: dd 0            ;first y cordinate
    x1: qword 0
    x2: qword 0
    xmd: qword 0 
    ymd: qword 0
    dis_tar_dro: tword 0
    numofhit: qword 0
    alpha: qword 0
    gamma: dd 0
    maxint : DD 0xffff
    format_string_2f: db "%.2f",10,0 ; float 2 numbers after dot
    format_string : db "%d",10,0 
    printwin: db "Drone id %d: I am a winner",10,0


section .bss
 


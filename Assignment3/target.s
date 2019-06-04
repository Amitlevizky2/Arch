
%macro generate_num 2
        push %1
        push %2
        call random_number
        add esp,8
%endmacro




section .text                           ; functions from c libary
  align 16
	 global target:function
	 global random_number
     global N
     global T
     global K
     global seed
     global beta
     global d
     global AlcCoRoutins
     global preInitCoLoop
     global startCo
     global CORS
     global xt
     global yt
     global dronesArray
     global schedulerCo
     global targetCo
     global printerCo
     global resume
     extern drone
     extern target
     extern scheduler
     extern printer
     extern printf 
     extern fprintf
     extern sscanf
     extern malloc
     extern free


     target:
     finit
   	 xor edx,edx
   	 generate_num edx,distance
   	 fld qword [res]
   	 fstp qword [xt]
   	 mov qword [res],0
   	 generate_num edx,distance
   	 fld qword [res]
   	 fstp qword [yt]
   	 xor ebx,ebx
   	 xor eax,eax
   	 xor esi,esi
   	 mov eax,[CORS]
   	 mov esi,dword [schedulerCo]
   	 add eax,esi
   	 mov ebx,eax
   	 call resume
     




   	 section .data
	xt :qword 0
	yt :qword 0
	distance equ 100



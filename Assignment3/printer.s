%macro print_target_details 2
    push %1
    push %2
    call printf
    add esp, 8
%endmacro

%macro print_drone_details 6
    push %1
    push %2
    push %3
    push %4
    push %5
    push %6
    call printf
    add esp, 20
%endmacro


section .data
  targetCordinatesStr: db "%.2f,%.2f",10,0 ; float 2 numbers after dot
  droneDetailsStr: db "%d,%.2f,%.2f,%.2f,%d", 10, 0   ; format string int

section .text                           ; functions from c libary
  align 16
	 global printer:function
    extern drone
    extern target
    extern scheduler
    extern printer
    extern printf 
    extern fprintf
    extern sscanf
    extern malloc
    extern xt
    extern yt
    extern free
    extern printerCo
    extern schedulerCo
    extern CORS
    extern arrayDrones
    extern N
    
    printer:
    xor esi, esi
    xor edi, edi
    xor ecx, ecx
    print_target_details targetCordinatesStr [xt], [yt]
    mov eax, dword [arrayDrones]
    mov ecx, dword [N]

    printDronesLoop:
      mov edi, dword [eax]
      print_drone_details droneDetailsStr, dword esi, qword [edi], qword [edi + 8], qword [edi + 16], dword [edi + 20]
      inc esi
      add eax, dword, 4
    loop printDronesLoop, ecx

    mov eax, [CORS]
    add eax, dword [schedulerCo]
    call resume




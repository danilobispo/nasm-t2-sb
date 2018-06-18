section .data                           ;Data segment
   userMsg db 'Informe seu nome de usuário: ' ;Ask the user to enter a number
   lenUserMsg equ $-userMsg             ;The length of the message
   dispMsg db 'Hóla,'
   lenDispMsg equ $-dispMsg
   dispMsg2 db ' ,bem vindo ao programa de CALC IA-32'               
   lenDispMsg2 equ $-dispMsg2

section .bss           ;Uninitialized data
   num resb 5
	
section .text          ;Code Segment
   global _start
	
_start:                ; Mostra mensagem para usuário informar o nome
   mov eax, 4
   mov ebx, 1
   mov ecx, userMsg
   mov edx, lenUserMsg
   int 80h

   ;Read and store the user input
   mov eax, 3
   mov ebx, 2
   mov ecx, num  
   mov edx, 100          ;100 bytes é o tamanho máximo do nome(100 caracteres)
   int 80h

trata_string:
   dec eax
   cmp byte[ecx+eax], 0xa ; Verifica se o último caractere é newline
   je remove_char
	
mostra_mensagem:
   ;Mostra a mensagem 'Hóla, '
   mov eax, 4
   mov ebx, 1
   mov ecx, dispMsg
   mov edx, lenDispMsg
   int 80h  

   ;Por fim, exibe o nome inserido pelo usuário
   mov eax, 4
   mov ebx, 1
   mov ecx, num
   mov edx, 100
   int 80h

   ;Output the message 'The entered number is: '
   mov eax, 4
   mov ebx, 1
   mov ecx, dispMsg2
   mov edx, lenDispMsg2
   int 80h  
    
   ; Exit code
   mov eax, 1
   mov ebx, 0
   int 80h

remove_char:
   mov byte[ecx+eax], 0
   jmp mostra_mensagem

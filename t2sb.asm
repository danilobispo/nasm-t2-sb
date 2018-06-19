section .data                           ;Data segment
   informeNomeUsuario db 'Informe seu nome de usuário: '
   lenInformeNomeUsuario equ $-informeNomeUsuario
   holaMsg db 'Hóla, '
   lenHolaMsg equ $-holaMsg
   bemVindoMsg db ',bem vindo ao programa de CALC IA-32', 10, 'ESCOLHA UMA OPÇÃO:', 10
   lenBemVindoMsg equ $-bemVindoMsg
   operacoesOptions db '-1: SOMA',10,'-2: SUBTRAÇÃO', 10, '-3: MULTIPLICAÇÃO', 10 ,'-4: DIVISÃO',10, '-5: MOD', 10, '-6: SAIR', 10
   lenOperacoesOptions equ $-operacoesOptions              

section .bss           ;Uninitialized data
   nomeUsuario resb 100
   num resb 2
	
section .text          ;Code Segment
   global _start
	
_start:                ; Mostra mensagem para usuário informar o nome
   mov eax, 4
   mov ebx, 1
   mov ecx, informeNomeUsuario
   mov edx, lenInformeNomeUsuario
   int 80h

   ;Lê e guarda o input do usuário
   mov eax, 3
   mov ebx, 0
   mov ecx, nomeUsuario  
   mov edx, 100          ;100 bytes é o tamanho máximo do nome(100 caracteres)
   int 80h

trataNomeDeUsuario:
   dec eax
   cmp byte[ecx+eax], 0xa ; Verifica se o último caractere é newline(10 em ASCII)
   je remove_char
	
mostra_mensagem:
   ;Mostra a mensagem 'Hóla, '
   mov eax, 4
   mov ebx, 1
   mov ecx, holaMsg
   mov edx, lenHolaMsg
   int 80h  

   ;Por fim, exibe o nome inserido pelo usuário
   mov eax, 4
   mov ebx, 1
   mov ecx, nomeUsuario
   mov edx, 100
   int 80h

   ;Mostra a mensagem de 'Bem vindo'
   mov eax, 4
   mov ebx, 1
   mov ecx, bemVindoMsg
   mov edx, lenBemVindoMsg
   int 80h  

mod:
   ;Mostra as opções da calculadora
   mov eax, 4
   mov ebx, 1
   mov ecx, operacoesOptions
   mov edx, lenOperacoesOptions
   int 80h  

   ;Lê e guarda o input do usuário
   mov eax, 3
   mov ebx, 0
   mov ecx, num  
   mov edx, 2          ;5 bytes, um para o sinal
   int 80h

trata_numero:
   mov ah, [num]
   sub ah, '0' ; Converte de ASCII para decimal

   ;Compara se o número fornecido é 6, se sim, realiza o pulo para a saída
   cmp ah, 6 ; SAIR
   je sair
   cmp ah, 5 ; MOD
   je mod

sair:
   ; Exit code
   mov eax, 1
   mov ebx, 0
   int 80h

remove_char:
   mov byte[ecx+eax], 0
   jmp mostra_mensagem

remove_newline:
   mov byte[ecx+eax], 0
   jmp trata_numero

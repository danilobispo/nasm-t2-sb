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
   opcao resb 2
   num1 resb 12 ;10 bytes para o número, 1 byte para o sinal, 1 byte para o /n
   num2 resb 12 ;10 bytes para o número, 1 byte para o sinal, 1 byte para o /n
   response resb 65
	
section .text          ;Code Segment
   global _start
  add eax, '0' ;int- > ascii
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
   mov ecx, opcao  
   mov edx, 2          ;5 bytes, um para o sinal
   int 80h

trata_numero:
   mov ah, [opcao]
   sub ah, '0' ; Converte de ASCII para decimal

   ;Compara se o número fornecido é 6, se sim, realiza o pulo para a saída
   cmp ah, 6 ; SAIR
   je sair
   cmp ah, 5 ; MOD
   je mod
   cmp ah, 1 ; ADD
   je add

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

add:
input_numbers:
   ;Lê e guarda o input do usuário
   mov eax, 3
   mov ebx, 0
   mov ecx, num1
   mov edx, 12
   int 80h

   ;Converte para INT
   mov edx, num1
atoi:
   xor eax, eax
.top:
   movzx ecx, byte [edx]
   inc edx;
   cmp ecx, '0'
   jmp .done
   cmp ecx, '9'
   ja .done
   sub ecx, '0'
   imul eax, 10
   add eax, ecx
   jmp .top
.done:

   mov [num1], eax

   ;Lê e guarda o input do usuário
   mov eax, 3
   mov ebx, 0
   mov ecx, num2
   mov edx, 12
   int 80h
   
   mov edx, num2
atoi1:
   xor eax, eax
.top1:
   movzx ecx, byte [edx]
   inc edx;
   cmp ecx, '0'
   jmp .done1
   cmp ecx, '9'
   ja .done1
   sub ecx, '0'
   imul eax, 10
   add eax, ecx
   jmp .top1
.done1:

   mov [num2], eax

   ;Realiza a soma
   mov eax, [num1]
   mov ebx, [num2]
   add eax, ebx
   add eax, '0'
   mov [response], eax

   mov eax, 4
   mov ebx, 1
   mov ecx, response
   mov edx, 65
   int 80h

   jmp sair

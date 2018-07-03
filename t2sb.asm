section .data                           ;Data segment
	informeNomeUsuario db 'Informe seu nome de usuário: '
	lenInformeNomeUsuario equ $-informeNomeUsuario
	holaMsg db 'Hóla, '
	lenHolaMsg equ $-holaMsg
	bemVindoMsg db ',bem vindo ao programa de CALC IA-32', 10, 'ESCOLHA UMA OPÇÃO:', 10
	lenBemVindoMsg equ $-bemVindoMsg
	operacoesOptions db '-1: SOMA',10,'-2: SUBTRAÇÃO', 10, '-3: MULTIPLICAÇÃO', 10 ,'-4: DIVISÃO',10, '-5: MOD', 10, '-6: SAIR', 10
	lenOperacoesOptions equ $-operacoesOptions           
	informeNumero1 db 'Informe o primeiro número da operação: ', 10
	lenInformeNumero1 equ $-informeNumero1
	informeNumero2 db 'Informe o segundo número da operação: ', 10
	lenInformeNumero2 equ $-informeNumero2
	
	num1 dd 40
	num2 dd 50

section .bss           ;Uninitialized data
	nomeUsuario resb 100
	opcao resb 2
	;num1 resb 12 ;10 bytes para o número, 1 byte para o sinal, 1 byte para o /n
	;num2 resb 12 ;10 bytes para o número, 1 byte para o sinal, 1 byte para o /n
	response resb 65
	num1_string resb 30
	num2_string resb 30
	response_string resb 30
	num1_int resd 1
	num2_int resd 1
	num1_int_tamanho resd 1 ; Os dois tamanhos são iguais, então vamos reaproveitar pra segunda
	new_int resb 30
	response_size resd 2

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

calculadora_options:
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
	
	jmp inputNumbers

trata_numero:
	mov ah, [opcao]
	sub ah, '0' ; Converte de ASCII para decimal

menu_option:
	;Compara se o número fornecido é 6, se sim, realiza o pulo para a saída
	cmp ah, 6 ; SAIR
	je sair
	cmp ah, 5 ; MOD
	je mod
	cmp ah, 4 ; DIV
	je divisao
	cmp ah, 3 ; MUL
	je multiplicacao
	cmp ah, 2 ; SUB
	je subtracao
	cmp ah, 1 ; ADD
	je add
	
add:
	mov eax, dword[num1_int]
	mov ebx, dword[num2_int]
	add eax, ebx
	jmp prepara_resultado_final
	
mod:
	mov eax, dword[num1_int]
	mov ebx, dword[num2_int]
	idiv ebx
	mov eax, edx
	jmp prepara_resultado_final
divisao:
	mov eax, dword[num1_int]
	mov ebx, dword[num2_int]
	idiv ebx
	jmp prepara_resultado_final
multiplicacao:
	mov eax, dword[num1_int]
	mov ebx, dword[num2_int]
	imul ebx
	jmp prepara_resultado_final
subtracao:
	mov eax, dword[num1_int]
	mov ebx, dword[num2_int]
	sub eax, ebx
	jmp prepara_resultado_final
	

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

inputNumbers:

	mov eax, 4
	mov ebx, 1
	mov ecx, informeNumero1
	mov edx, lenInformeNumero1
	int 80h
	;Lê e guarda o input do usuário
	mov eax, 3
	mov ebx, 0
	mov ecx, num1_string
	mov edx, 12
	int 80h

	;Converte para INT

	;now save size of string input
	dec eax; tira o '/n'
	mov dword [num1_int_tamanho], eax  ; Guarda o tamanho da string

	mov edi, 10 ; Guarda em edi o valor de 10, que multiplicaremos elevado a posição do número
	mov ecx, [num1_int_tamanho] ; Guarda o tamanho do número em ecx
	mov esi, num1_string ; Guarda o valor de leitura da string em esi
	xor eax, eax ; Zera eax
	xor ebx, ebx ; Zera ebx

	mov bl, [esi] ; Pega um char da string
	cmp bl, '-' ; Verifica se char == '-'
	jne checagem_de_sinal_num1 ; Se não for, checamos se é '+'
	inc eax ; eax = 1
	inc esi
	dec ecx
	jmp parse_sinal_num1
checagem_de_sinal_num1: 
	cmp bl, '+'; Se não for também, assumimos que é positivo
	jne parse_sinal_num1
	inc esi
	dec ecx
parse_sinal_num1: 
	push eax ; Guardamos o eax com o valor do endereço 
	xor eax, eax ; Removemos o valor 1, para evitar problemas na escrita
lop_num1_int: 
	mov bl, [esi] ; Movemos o char seguinte, subtraímos 0x30 ('0')
	sub bl, '0'
	mul edi; eax = eax * 10 ; Multiplicamos a posição por 10
	mov bh, 0 ; Limpamos a parte superior de bh, para evitar problemas na soma
	add eax, ebx ; Somamos ao resultado total
	inc esi ; Avançamos em uma posição no indice em chars
	loop lop_num1_int ; Faremos isso até o esi ser 0
	
	pop ebx
	cmp ebx, 1
	jne fim_parse_num1
	neg eax

	fim_parse_num1:
	mov dword [num1_int], eax
	
	mov eax, 4
	mov ebx, 1
	mov ecx, informeNumero2
	mov edx, lenInformeNumero2
	int 80h
	
   ;Lê e guarda o input do usuário
	mov eax, 3
	mov ebx, 0
	mov ecx, num2_string
	mov edx, 12
	int 80h
	
	;now save size of string input
	dec eax; tira o '/n'
	mov dword [num1_int_tamanho], eax  ; Guarda o tamanho da string

	mov edi, 10 ; Guarda em edi o valor de 10, que multiplicaremos elevado a posição do número
	mov ecx, [num1_int_tamanho] ; Guarda o tamanho do número em ecx
	mov esi, num2_string ; Guarda o valor de leitura da string em esi
	xor eax, eax ; Zera eax
	xor ebx, ebx ; Zera ebx

	mov bl, [esi] ; Pega um char da string
	cmp bl, '-' ; Verifica se char == '-'
	jne checagem_de_sinal_num2 ; Se não for, checamos se é '+'
	inc eax ; eax = 1
	inc esi
	dec ecx
	jmp parse_sinal_num2
checagem_de_sinal_num2: 
	cmp bl, '+'; Se não for também, assumimos que é positivo
	jne parse_sinal_num2
	inc esi
	dec ecx
parse_sinal_num2: 
	push eax ; Guardamos o eax com o valor do endereço 
	xor eax, eax ; Removemos o valor 1, para evitar problemas na escrita
lop_num2_int: 
	mov bl, [esi] ; Movemos o char seguinte, subtraímos 0x30 ('0')
	sub bl, '0'
	mul edi; eax = eax * 10 ; Multiplicamos a posição por 10
	mov bh, 0 ; Limpamos a parte superior de bh, para evitar problemas na soma
	add eax, ebx ; Somamos ao resultado total
	inc esi ; Avançamos em uma posição no indice em chars
	loop lop_num2_int ; Faremos isso até o esi ser 0
	
	pop ebx
	cmp ebx, 1
	jne fim_parse_num2
	neg eax

	fim_parse_num2:
	mov dword [num2_int], eax
	jmp trata_numero
	
	
	jmp trata_numero

prepara_resultado_final:
	;pop ebx;
	;cmp ebx, 1; ebx agora é comparado com 1
	;jne converte_int_para_string; Se ebx não for igual a 1, salto para
	;neg eax
converte_int_para_string:
  mov esi, new_int; Agora colocamos esi para apontar para o endereço do nosso novo inteiro 
  mov ebx, 10 ; ebx novamente recebe 10, pois iremos fazer a desconversão
  xor ecx, ecx ; Zeramos ecx
  cmp eax, 0 ; Comparamos eax com 0
  jge pula_negacao; se eax >=0, não precisamos fazer a negação
  neg eax; caso contrário, negamos o valor eax
  push dword 1; lançamos o valor 1 na pilha pra lembrar que o número é negativo
  jmp inicia_conversao ; Iniciamos a conversão
pula_negacao: 
push dword 0; Caso seja positivo, lembramos que o número é positivo
inicia_conversao:
  xor edx, edx ; Zeramos edx
  div ebx 
  add dl, '0'; somamos '0'
  push edx; edx entra na pilha
  inc ecx; aumentamos uma posição
  cmp eax, 0
  jne inicia_conversao ; Enquanto eax não for 0, refazemos o loop
  mov eax, ecx
  inc eax
  inc esi
  ; Escreve o valor no endereço de esi
lp2: 
  pop edx
  mov [esi], dl
  inc esi; 
  loop lp2
  pop edx
  cmp edx, 1
  jne positivo
  pop ecx;
  mov esi, new_int
  mov [esi], byte '-'
  jmp finish
positivo: mov esi, new_int
  mov [esi], byte '+'
finish:
mov [response_size], eax

;print out new int

mov edx, dword [response_size]
mov ecx, new_int
mov ebx, 1
mov eax, 4
int 80h

jmp sair
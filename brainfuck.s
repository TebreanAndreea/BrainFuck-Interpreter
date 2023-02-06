.global brainfuck
.bss
vector: .skip 30000, 0 							#making an array of 0's

.text

format_str: .asciz "We should be executing the following code:\n%s\n"
format_chr: .asciz "%c"

# Your brainfuck subroutine will receive one argument:
# a zero termianted string containing the code to execute.
brainfuck:
	#prologue
	pushq %rbp
	movq %rsp, %rbp

	#saving the values of the calee saved registers
	pushq %r12
	pushq %r13
	pushq %r14
	pushq %r15

	#nulling the registers
	movq $0, %r12
	movq $0, %r13
	movq $0, %r14
	movq $0, %r15

	movq %rdi, %r12								#moving the brainfuck string in R12

	movq $vector, %r15 							#setting R15 as our pointer in the array
	movq $0, %r14 								#nulling R14


	#printing the brainfuck string we have in the file
	movq $format_str, %rdi 						#first argument: format string
	movq %rdi, %rsi 							#second argument: the code in the file
	movq $0, %rax 								#0 in RAX
	call printf 								#call printf



	loopp:
		cmpb $0, (%r12)							#testing if we reached the end of the file
		je end 									#if yes, jump to end

		cmpb $62, (%r12)    					#see if the character is '>'
		je incrementpointer 					#if yes jump to incrementpointer

		cmpb $60, (%r12) 						#see if the character is '<'
		je decrementpointer 					#if yes jump to decrementpointer

		cmpb $43, (%r12) 						#see if the character is '+'
		je plus 								#if yes jump to plus

		cmpb $45, (%r12) 						#see if the character is '-'
		je minus 								#if yes jump to minus

		cmpb $46, (%r12) 						#see if the character is '.'
		je dot 									#if yes jump to dot

		cmpb $44, (%r12) 						#see if the character is ','
		je comma								#if yes jump to comma

		cmpb $93, (%r12) 						#see if the character is ']'
		je goback 								#if yes jump to goback

		cmpb $91, (%r12) 						#see if the character is '['
		je vrf 									#if yes jump to vrf

		incq %r12 								#increment R12 if no conditions are fulfilled
		jmp loopp								#jump to loopp

	end:
		#getting back the values for the calee saved registers
		popq %r15
		popq %r14
		popq %r13
		popq %r12

		#epilogue
		movq %rbp, %rsp
		popq %rbp
		ret

incrementpointer:
	incq %r15 									#increment the pointer of the array
	incq %r12 									#go to the next character in the file
	jmp loopp									#jump to loopp

decrementpointer:
	decq %r15									#decrement the pointer of the array
	incq %r12									#go to the next character in the file
	jmp loopp 									#jump to loopp

plus:
	incq (%r15) 								#increment the cell R15 is pointing to
	incq %r12									#go to the next character in the file
	jmp loopp									#jump to loopp

minus:
	decq (%r15)									#decrement the cell R15 is pointing to
	incq %r12									#go to the next character in the file
	jmp loopp									#jump to loopp

dot:
	movq $format_chr, %rdi 						#first argument: format string
	movq $0, %rsi 								#nulling RSI
	movb (%r15), %sil 							#second argument: the value from the cell R15 is pointig to
	movq $0, %rax								#0 in RAX
dotdot:
	call printf									#call printf
	incq %r12									#go to the next character in the file
	jmp loopp									#jump to loopp
comma:
	movq $format_chr, %rdi 						#first argument: format string
	movq $0, %rsi 								#nulling RSI
	leaq (%r15), %sil 							#second argument:
	movq $0, %rax								#0 in RAX
	call scanf									#call scanf
	incq %r12 									#go to the next character in the file
	jmp loopp									#jump loopp

goback:
	cmpb $0, (%r15)								#see if the value in the cell is 0
	je ezero 									#if yes jump to ezero

	movq $0, %r8								#nulling R8

	loop2:
		cmpb $93, (%r12) 						#check if the character is ']'
		jne continu1 							#if not jump to continu1

		incq %r8 								#increment R8

		continu1:
			cmpb $91, (%r12)					#check if the character is '['
			jne continu 						#if not jump to continu

			decq %r8							#decrement R8

		continu:
			decq %r12 							#decrement R12

			cmpq $0, %r8						#check is R8 is 0 (we reached the correct "[")
			jne final 							#if not jump to final

			incq %r12 							#go to the next character in the file
			incq %r12							#go to the next character in the file
			jmp loopp							#jump to loopp

		final:
			//incq %r12
			jmp loop2							#jump to loop2

	ezero:
		incq %r12 								#go to the next character in the file
		jmp loopp 								#jump loopp

vrf:
	cmpb $0, (%r15)								#see if the value in the cell is 0
	jne ezero									#if not jumpt to ezero

	movq $0, %r8 								#nulling r8

	loop3:
		cmpb $93, (%r12) 						#check if the character is ']'
		jne continu12							#if not jump to continu12

		incq %r8 								#increment R8

		continu12:
			cmpb $91, (%r12) 					#check if the character is '['
			jne continu0 						#if not jump to continu0

			decq %r8 							#decrement R8

		continu0:
			incq %r12 							#go to the next character in the file

			cmpq $0, %r8 						#check if r8 is 0 (we reached the corect "]")
			je loopp 							#if yes jump to loopp

		jmp loop3 								#jump to loop 3

.586
.model flat, stdcall
option casemap :none
.STACK 4096
	extrn ExitProcess@4: proc
	GetStdHandle proto :dword
	ReadConsoleA  proto :dword, :dword, :dword, :dword, :dword
	WriteConsoleA proto :dword, :dword, :dword, :dword, :dword
	MessageBoxA proto:dword, :dword, :dword, :dword
	STD_INPUT_HANDLE equ -10
	STD_OUTPUT_HANDLE equ -11

.DATA
    bufferSize = 80
    inputHandle DWORD ? 
    buffer db bufferSize dup(?) 
    bytes_read  DWORD  ? 
    celsius db "Enter 'C' to convert temperature to Centigrade or enter 'F' to convert to Fahrenheit: ",0
    prompts db "The temperature is: "
    sum_string db "The temperature converted to Fahrenheit is: ",0
    inDec db "The temperature converted to Centigrade is: ",0
    outputHandle DWORD ? 
    bytes_written dd ?
    actNumber dw 0
    number dw 0
    asciiBuf db 4 dup (" "),13,10,0

.CODE
	main:
		invoke GetStdHandle, STD_OUTPUT_HANDLE
		mov outputHandle, eax 
		mov eax,LENGTHOF celsius
		invoke WriteConsoleA, outputHandle, addr celsius, eax, addr bytes_written,3
		invoke GetStdHandle, STD_INPUT_HANDLE 
		mov inputHandle, eax 
		invoke ReadConsoleA, inputHandle, addr buffer, bufferSize, addr bytes_read,5 
		sub bytes_read, 2
		mov ebx,0 
		mov al, byte ptr buffer+[ebx]
		add[number],ax

    cont:
		cmp number, 43H
		je Centigrade
		cmp number, 46H
		je Fahrenheit
		call ExitProcess@4

	Centigrade:
		call to_Centigrade
		call ExitProcess@4

		to_Centigrade PROC
		invoke GetStdHandle, STD_OUTPUT_HANDLE
		mov outputHandle, eax 
		mov eax,LENGTHOF prompts
		invoke WriteConsoleA, outputHandle, addr prompts, eax, addr bytes_written,3
		invoke GetStdHandle, STD_INPUT_HANDLE 
		mov inputHandle, eax 
		invoke ReadConsoleA, inputHandle, addr buffer, bufferSize, addr bytes_read,5 
		sub bytes_read, 2 ;-2 to remove cr,lf
		mov ebx,0 
		mov al, byte ptr buffer+[ebx]
		sub al,30h
		add[actNumber],ax

		getNext:
		inc bx
		cmp ebx,bytes_read
		jz calculateC
		mov ax,10
		mul[actNumber]
		mov actNumber,ax
		mov al, byte ptr buffer+[ebx]
		sub al,30h
		add actNumber,ax
		jmp getNext

    calculateC:	
		mov cx, 0
		mov cx, actNumber
		mov eax, ecx
		sub eax, 32
		mov cx, 5   
		mul cx
		mov cx, 9
		div cx
		mov ebx, eax
		mov cl,10
		mov ebx,3

    print:
		idiv cl
		add ah,30h
		mov byte ptr asciiBuf+[ebx],ah
		dec ebx
		mov ah,0
		cmp al,0
		ja print
		mov eax,4
		invoke GetStdHandle, STD_OUTPUT_HANDLE
		mov outputHandle, eax 
		mov eax,LENGTHOF inDec;length of sum_string
		invoke WriteConsoleA, outputHandle, addr inDec, eax, addr bytes_written,0
		invoke GetStdHandle, STD_OUTPUT_HANDLE
		mov outputHandle, eax 
		mov eax,LENGTHOF asciiBuf
		invoke WriteConsoleA, outputHandle, addr asciiBuf, eax, addr bytes_written,0

		push 0
		call ExitProcess@4
		to_Centigrade ENDP

    Fahrenheit:
		Call to_Fahrenheit
		call ExitProcess@4
		to_Fahrenheit Proc
		invoke GetStdHandle, STD_OUTPUT_HANDLE
		mov outputHandle, eax 
		mov eax,LENGTHOF prompts
		invoke WriteConsoleA, outputHandle, addr prompts, eax, addr bytes_written,3
		invoke GetStdHandle, STD_INPUT_HANDLE 
		mov inputHandle, eax 
		invoke ReadConsoleA, inputHandle, addr buffer, bufferSize, addr bytes_read,5 
		sub bytes_read, 2
		mov ebx,0 
		mov al, byte ptr buffer+[ebx]
		sub al,30h
		add[actNumber],ax

    getNext:
		inc bx
		cmp ebx,bytes_read
		jz calculateF
		mov ax,10
		Imul[actNumber]
		mov actNumber,ax
		mov al, byte ptr buffer+[ebx]
		sub al,30h
		add actNumber,ax
		jmp getNext

	calculateF:
		mov cx, actNumber
		mov eax, ecx
		IMUL cx, 9
		mov ax, cx
		mov bx, 5
		idiv bx
		add eax, 32
		mov ebx, eax
		mov cl, 10
		mov ebx, 3

    print:
		idiv cl
		add ah, 30h
		mov byte ptr asciiBuf+[ebx], ah
		dec ebx
		mov ah, 0
		cmp al, 0
		ja print
		mov eax, 4
		invoke GetStdHandle, STD_OUTPUT_HANDLE
		mov outputHandle, eax 
		mov eax,LENGTHOF sum_string;length of sum_string
		invoke WriteConsoleA, outputHandle, addr sum_string, eax, addr bytes_written,0
		invoke GetStdHandle, STD_OUTPUT_HANDLE
		mov outputHandle, eax 
		mov eax,LENGTHOF asciiBuf
		invoke WriteConsoleA, outputHandle, addr asciiBuf, eax, addr bytes_written,0

		push 0
		call ExitProcess@4
		to_Fahrenheit ENDP

	end main
end

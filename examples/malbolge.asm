
; This program is absolute madness.
; Written by the Assembly Menace in dedication for JavaScript programmers.

; Copyright (C) by Krzysztof Szewczyk. All rights reserved.
; Licensed under the terms of MIT license.

; This Malbolge interpreter in Brainfuck is subject of optimizations made by hand.
; I'll submit small patches regarding code size with time flowing.
; It doesn't seem to work right now.

; Version stamp: 190721:1840

stk 10

org 20
db 4
db 3
db 3
db 1
db 0
db 0
db 1
db 0
db 0
db 4
db 3
db 5
db 1
db 0
db 2
db 1
db 0
db 2
db 5
db 5
db 4
db 2
db 2
db 1
db 2
db 2
db 1
db 4
db 3
db 3
db 1
db 0
db 0
db 7
db 6
db 6
db 4
db 3
db 5
db 1
db 0
db 2
db 7
db 6
db 8
db 5
db 5
db 4
db 2
db 2
db 1
db 8
db 8
db 7
db 7
db 6
db 6
db 7
db 6
db 6
db 4
db 3
db 3
db 7
db 6
db 8
db 7
db 6
db 8
db 4
db 3
db 5
db 8
db 8
db 7
db 8
db 8
db 7
db 5
db 5
db 4

org 101
txt "+b(29e*j1VMEKLyC})8&m#~W>qxdRp0wkrUo[D7,XTcA"
db ."
txt "lI.v%{gJh4G\-=O@5`_3i<?Z';FNQuY]szf$!BS/|t:Pn6^Ha"

org 195
txt "5z]&gqtyfr$(we4{WP)H-Zn,[%\3dL+Q;>U!pJS72FhOA1CB6v^=I_0/8|jsb9m<.TVac`uY*MK'X~xDl}REokN:#?G"
db ."
txt "i@"

;org 289

; Fill 0-4 memory with powers of 9.
; [0] = 1
mov r1, 1
sto r2, r1
; [1] = 9
mov r1, 9
inc r2
sto r2, r1
; [2] = 81
mul r1, 9
inc r2
sto r2, r1
; [3] = 729
inc r2
mul r1, 9
sto r2, r1
; [4] = 6561
inc r2
mul r1, 9
sto r2, r1
; [14] = 289
mov r1, 17
mov r2, r1
mul r1, r2
sub r2, 3
sto r2, r1
; [16] = 289
inc r2
inc r2
sto r2, r1
; [15] = 59048
mov r3, 8
mov r2, 11
mov r1, 8
mov r4, r1
mul r1, r4
sub r1, 3
mul r1, r2
mul r1, r2
mul r1, r3
; r1 = 59048 now
mov r2, 15
sto r2, r1

; We can use m[11], m[12] and m[13] to store our things.
; m[16] = i

lbl 21
	in r1
	mov r4, r1
	mov r3, r1
	mov r2, 11
	sto r2, r1
	eq r1, 0
	jnz r1, 22
	psh r3
	mov r4, r3
	mov r2, r3
	eq r4, 32
	lt r2, 13
	or r4, r2
	pop r1
	jnz r4, 21
	rcl r4, 16
	rcl r3, 15
	inc r3
	eq r3, r4
	jnz r3, 23
	sto r4, r1
	inc r4
	mov r3, 16
	sto r3, r4
	jmp 21
lbl 22
	; Done reading, now fill up rest of memory
	; and launch the interpreter.
	rcl r1, 16
	mov r3, r1
	rcl r2, 15
	inc r2
	lt r1, r2
	jz r1, 23
	
	rcl r1, 16 ; Get I value
	dec r1
	mov r3, r1
	dec r1
	mov r2, r1
	mov r1, r3
	psh 24
	jmp 1
lbl 24
	; mem[i] = r1
	rcl r2, 16
	sto r2, r1
	; i = i + 1;
	mov r2, 16
	rcl r1, r2
	inc r1
	sto r2, r1
	jmp 22
lbl 23

; End of loader code

mov r1, 11
sto r1, 0
inc r1
sto r1, 0
inc r1
sto r1, 0

; Execution loop.
; No input, no output, no register preservation :).
lbl 4
	; m[11] = a, m[12] = c, m[13] = d
	; if(mem[c] < 33 || mem[c] > 126) continue;
	rcl r1, 12
	rcl r2, 14
	add r1, r2
	psh r1
	rcl r3, r1
	mov r4, r3
	psh r4
	; r3 = mbm[m[12]]
	lt r3, 33
	gt r4, 126
	or r3, r4
	jnz r3, 5
	
	; xlat1[( mem[c] - 33 + c ) % 94]
	pop r4
	pop r3
	sub r4, 33
	add r4, r3
	mod r4, 94
	add r4, 101
	rcl r1, r4
	
	; Now compare instructions against r1.
	mov r2, r1
	eq r2, .v
	jnz r2, 6
	
	mov r2, r1
	eq r2, ./
	jnz r2, 7
	
	mov r2, r1
	eq r2, .<
	jnz r2, 10
	
	mov r2, r1
	eq r2, .p
	jnz r2, 11
	
	mov r2, r1
	eq r2, .*
	jnz r2, 13
	
	mov r2, r1
	eq r2, .i
	jnz r2, 14
	
	mov r2, r1
	eq r2, .i
	jnz r2, 15
lbl 16
	; Coding code will go here.
	; mem[c] = xlat2[mem[c] - 33];
	rcl r1, 12
	rcl r2, 14
	add r1, r2
	rcl r3, r1
	
	; r3 = mem[c]
	; r1, stack = c
	add r3, 162
	rcl r3, r4
	sto r1, r3
	
	; if ( c == 59048 ) c = 0; else c++;
	rcl r4, 15
	eq r1, r4
	jnz r1, 17
	jmp 18
lbl 17
	clr r1
	dec r1
lbl 18
	inc r1
	mov r2, 12
	sto r2, r1
	
	; if ( d == 59048 ) d = 0; else d++;
	rcl r1, 13
	rcl r4, 15
	eq r1, r4
	jnz r1, 19
	jmp 20
lbl 19
	clr r1
	dec r1
lbl 20
	inc r1
	mov r2, 13
	sto r2, r1
	
	jmp 4
lbl 5
	; Original interpreter was designed to loop forever here.
	jmp 5

lbl 6
	; Exit.
	end

lbl 7
	; Getchar
	in r1
	mov r2, r1
	eq r2, 0
	jnz r2, 8
	jmp 9
lbl 8
	rcl r1, 15
lbl 9
	mov r2, 11
	sto r2, r1
	jmp 16

lbl 10
	; Putchar
	rcl r1, 11
	out r1
	jmp 16

lbl 11
	; CrazyOP.
	; a = mem[d] = op( a, mem[d] );
	rcl r1, 13
	rcl r2, 14
	add r1, r2
	rcl r3, r1
	rcl r1, 11
	mov r2, r3
	clr r3
	clr r4
	psh 12
	jmp 1
lbl 12
	mov r2, 11
	sto r2, r1
	rcl r4, 13
	rcl r2, 14
	add r4, r2
	sto r4, r1
	jmp 16

lbl 13
	; a = mem[d] = mem[d] / 3 + mem[d] % 3 * 19683;
	rcl r1, 13
	rcl r2, 14
	add r1, r2
	rcl r3, r1
	; r3 = mem[d]
	psh r3
	div r3, 3
	pop r2
	mod r2, 3
	rcl r4, 4
	mul r4, 3
	mul r2, r4
	add r3, r2
	; r3 is now value to assign to mem[d] and a
	rcl r1, 13
	rcl r2, 14
	add r1, r2
	sto r1, r3
	mov r1, 11
	sto r1, r3
	jmp 16

lbl 14
	; c = mem[d]
	rcl r1, 13
	rcl r2, 14
	add r1, r2
	rcl r3, r1
	mov r1, 12
	sto r1, r3
	jmp 16

lbl 15
	; d = mem[d]
	rcl r1, 13
	rcl r2, 14
	add r1, r2
	rcl r3, r1
	mov r1, 13
	sto r1, r3
	jmp 16

; Crazy OP
; Input:  r1 = x, r2 = y
; Output: r1 = value
; Registers preserved.
lbl 1
	psh r3
	psh r4
	clr r3
	clr r4
	sto r3, r4
	inc r3
	sto r3, r4
	inc r3
	sto r3, r4
	inc r3
	sto r3, r4
	inc r3
	sto r3, r4
	clr r3
	
	; Important:
	; p9: mem[0-2]
	; o: o[x][y] = mem[5 + 9 * x + y]
	
	clr r3
lbl 2
	mov r4, r3
	ge r4, 5
	jnz r4, 3
	psh r2
	
	; This will execute 5 times.
	; r3: j
	
	; [10 + 9 * (y / [r3] % 9) + (x / [r3] % 9)] * [r3];
	rcl r4, r3
	; r4 = [r3]
	psh r3
	psh r4
	mov r3, r2
	div r3, r4
	mod r3, 9
	mul r3, 9
	add r3, 20
	mov r4, r3
	; r4 = value of first part of expression.
	; it used to be [r3].
	mov r2, r1
	pop r3 ; r3 = [r3]
	div r2, r3
	mod r2, 9
	add r4, r2
	rcl r2, r4
	mul r2, r3
	; r2 is the result.
	pop r3
	add r3, 5
	sto r3, r2
	sub r3, 5
	pop r2
	inc r3
	jmp 2
lbl 3
	psh r2
	mov r2, 5
	rcl r4, r2
	inc r2
	rcl r3, r2
	add r3, r4
	inc r2
	rcl r4, r2
	inc r2
	add r3, r4
	rcl r4, r2
	inc r2
	add r3, r4
	rcl r4, r2
	add r3, r4
	mov r1, r3
	pop r2
	pop r4
	pop r3
	ret

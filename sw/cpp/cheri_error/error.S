.include "assembly-helpers.s"

.section .text, "ax", @progbits
.zero 0x80
.globl start
.p2align 2
.type start,@function
start:
	// ca0 (first argument) contains the read-write root
	cspecialr ca0, mtdc

	// install trap handler
	la_abs t0, trap
	auipcc cra, 0
	csetaddr cra, cra, t0
	cspecialw mtcc, cra

	// cause a trap
	ecall
	j endloop

.section .trap, "ax", @progbits
.p2align 2
trap:
	li t0, 0x10 //0x10 for simulation 0x01000000 for FPGA
delayloop:
	addi t0, t0, -1
	bnez t0, delayloop
	csrw mtval, 0

traploop:
	j traploop

endloop:
	j endloop

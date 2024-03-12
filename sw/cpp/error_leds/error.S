.include "assembly-helpers.s"

.section .text, "ax", @progbits
	.zero 0x80
	.globl start
	.p2align 2
	.type start,@function
start:
	// The memory root for storing and loading.
	cspecialr ca0, mtdc
	// The execution root.
	auipcc ca1, 0
	// The sealing root.
	cspecialr ca2, mscratchc

	// Install trap handler.
	la_abs t0, trap
	csetaddr ct0, ca1, t0
	cspecialw mtcc, ct0

	// Keeps track of which violation to cause next.
	li s0, 8

nextviolation:
	addi s0, s0, 1
	addi t0, s0, -9
	bnez t0, checkvalues
	li s0, 0
checkvalues:
	li t0, 0
	beq s0, t0, bounds
	addi t0, t0, 1
	beq s0, t0, tag
	addi t0, t0, 1
	beq s0, t0, seal
	addi t0, t0, 1
	//beq s0, t0, permitexecute
	addi t0, t0, 1
	beq s0, t0, permitload
	addi t0, t0, 1
	beq s0, t0, permitstore
	addi t0, t0, 1
	//beq s0, t0, permitstorecap
	addi t0, t0, 1
	//beq s0, t0, permitstoreloccap
	addi t0, t0, 1
	//beq s0, t0, permitaccsysreg
	j nextviolation

bounds:
	// Cause an out of bounds violation
	csetboundsimm ct0, ca0, 4
	clw t0, 5(ct0) // 5 is beyond the bound of 4
	j fail

tag:
	// Cause a tag violation
	ccleartag ct0, ca0
	clw t0, 0(ct0)
	j fail

seal:
	// Seal a capability
	li t0, 9 // Used as otype
	csetaddr ct1, ca2, t0
	cseal ct0, ca0, ct1
	clw t0, 0(ct0) // Try loading from a sealed capability
	j fail

permitexecute:
	// Jumping to the memory root causes execute permission violation.
	cjalr ca0
	j fail

permitload:
	// Loading from the seal root causes load permission violation.
	clw t0, 0(ca2)
	j fail

permitstore:
	// Storing to execute root causes store permission violation.
	csw t0, 0(ca1)
	j fail

permitstorecap:
	// Create data capability with store data permission set.
	li t0, 4
	candperm ct0, ca0, t0
	// Cause store capability permission violation.
	csc cnull, 0(ct0)
	j fail

permitstoreloccap:
	j fail

permitaccsysreg:
	j fail

.section .text, "ax", @progbits
	.globl compartment_key
	.p2align 3
compartment_key:
	.long 0
	.long 0

.section .trap, "ax", @progbits
.p2align 2
trap:
	li t0, 0x01000000 //0x10 for simulation 0x01000000 for FPGA
delayloop:
	addi t0, t0, -1
	bnez t0, delayloop
	csrw mtval, 0
	csrw mcause, 0
	j nextviolation

fail:
	j fail

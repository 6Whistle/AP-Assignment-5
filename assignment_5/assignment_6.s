	AREA ARMex, CODE, READONLY
		ENTRY
	
	LDR r0, =ReadAddress1
	
	LDR r1, [r0], #4
	LDR r2, [r0], #4
	
	MOV r3, r1, LSR #31			;sign only
	MOV r4, r2, LSR #31
	
	MOV r5, r1, LSL #1			;no sign bit
	MOV r6, r2, LSL #1
	
	CMP r5, #0						;verify r1 is 0
	MOVEQ r10, r2
	BEQ STORE						;if r1 is 0, store r2
	
	CMP r6, #0						;verify r2 is 0
	MOVEQ r10, r1				
	BEQ STORE						;if r2 is 0, store r1
	
	MOV r5, r5, LSR #24			;exponent only
	MOV r6, r6, LSR #24
	
	CMP r5, #255					;verify r1's exponent is FF
	MOVEQ r10, r1
	MOVEQ pc, #0
	
	CMP r6, #255					;;verify r2's exponent is FF
	MOVEQ r10, r2
	MOVEQ pc, #0
	
	MOV r7, r1, LSL #9			;mantissa only
	MOV r8, r2, LSL #9
	MOV r7, r7, LSR #9
	MOV r8, r8, LSR #9
	
	LDR r12, [r0], #4				;1.mantissa
	ADD r7, r12
	ADD r8, r12
	
	
	CMP r5, r6						;exponent difference
	SUBGE r9, r5, r6
	SUBLT r9, r6, r5
	
	MOVGE r11, r5					;bigger's exponent
	MOVLT r11, r6
	
	MOVGE r8, r8, LSR r9		;low exponent's mantissa / 2^r9
	MOVLT r7, r7, LSR r9
	
	CMP r3, r4						;add or sub
	BNE	SUBNUM
	B		ADDNUM
	
	
SUBNUM		;When sign bits aren't same
	CMP r7, r8
	SUBGE r10, r7, r8				;bigger - smaller
	SUBLT r10, r8, r7
	

	MOVLT r3, r4					;bigger mantissa's sign
	
	CMP r10, #0						;if result is 0
	MOVEQ r10, r3, LSL #31
	BEQ STORE
	
LOOP
	CMP r10, r12					;while mantissia is 24 bit
	MOVLT r10, r10, LSL #1	;mantissia *= 2
	SUBLT r11, #1					;exponent--
	BLT LOOP
	
	BIC r10, r10, r12				;erease 24th bit
	ADD r10, r3, LSL #31		;add sign
	ADD r10, r11, LSL #23		;add exponent
	B STORE
	
	
ADDNUM		;When sign bits aren't same
	ADD r10, r7, r8			;add mantissa
	
	MOV r2, r12, LSL #1
	CMP r10, r2							;if result mantissa is 25-bits
	MOVGE r10, r10, LSR #1		;result /2
	ADDGE r11, #1						;exponent ++
	
	BIC r10, r10, r12					;erease 24th bit
	ADD r10, r3, LSL #31			;add sign
	ADD r10, r11, LSL #23			;add exponent
	B STORE
	
	

	
STORE
	LDR r11, StoreAddress
	STR r10, [r11]
	
	MOV pc, #0
	
	
StoreAddress & &40000000
ReadAddress1	DCD 0x14ed2845, 0x16df3245, 0x00800000

		END
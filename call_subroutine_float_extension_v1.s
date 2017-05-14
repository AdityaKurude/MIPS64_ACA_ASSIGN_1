      .data 
N_COEFFS:  .word 3
coeff: .double 5.0,2.0,-3.0
N_SAMPLES: .word 3
sample: .double 1,2,3,4,5,6,7,8,9,10
result: .double 0,0,0,0,0,0,0,0,0,0
C_ZERO: .double 0.0
        .text


start:	ld r1,N_COEFFS(r0)  # r1 = N_COEFFS
	ld r4,N_SAMPLES(r0)  # r4 = N_SAMPLES
	slt r3,r1,r4    # N_COEFFS < N_SAMPLES?
        bnez r3,smooth       # yes - go to smooth
	beq r1,r4,smooth # branch N_COEFFS = N_SAMPLES        
	halt

smooth:    
	L.D F3,C_ZERO(r0)  # F3=norm=0.0;
	daddu r2,r0,r0   ; r2 = 0
        ld r1,N_COEFFS(r2)  # r1 = N_COEFFS
        L.D F31,coeff(r2)  # F31=coeff[0]
        L.D F0,C_ZERO(r0)  # F0=0

	c.lt.d F31,F0	#coeff[0]<0	c.lt.d freg,freg - set FP flag if less than
	bc1t neg_coeff_zero 	#- branch to address if FP flag is true
	ADD.D F3,F3,F31	#norm+=coeff[0];
	jal coeff_one         ; call coeff_one

neg_coeff_zero: 
	SUB.D F3,F3,F31	#norm-=coeff[0];
	jal coeff_one         ; call coeff_one

coeff_one:
	daddi r2,r0,8   ; r2 = 8
        L.D F30,coeff(r2)  # F30=coeff[1]
	c.lt.d F30,F0	#coeff[1]<0	c.lt.d freg,freg - set FP flag if less than
	bc1t neg_coeff_one 	#- branch to address if FP flag is true
	ADD.D F3,F3,F30	#norm+=coeff[1];
	jal coeff_two         ; call coeff_two

neg_coeff_one: 
	SUB.D F3,F3,F30	#norm-=coeff[1];
	jal coeff_two         ; call coeff_two

coeff_two:
	daddi r2,r0,16   ; r2 = 16
        L.D F29,coeff(r2)  # F29=coeff[2]
	c.lt.d F29,F0	#coeff[2]<0	c.lt.d freg,freg - set FP flag if less than
	bc1t neg_coeff_two 	#- branch to address if FP flag is true
	ADD.D F3,F3,F29	#norm+=coeff[2];
	jal go_result         ; call go_result

neg_coeff_two: 
	SUB.D F3,F3,F29	#norm-=coeff[2];
	jal go_result         ; call go_result

go_result:

	daddu r31,r0,r0   ;i = r31 = 0
for:    slt r2,r31,r4    # i < N_SAMPLES?
        beqz r2,out       # yes - exit
	#Inside logic of For loop
	#r4 : N_SAMPLES
	# F31 : coeff[0]
	# F30 : coeff[1]
	# F29 : coeff[2]

	# Implementation for if part of the condition
	#if (i==0 || i==N_SAMPLES-1){	
	
	beq r31,r0,in_if_cond # branch i == 0
	daddi r30,r0,1   # r30 = 1
	dsubu r6,r4,r30   #N_SAMPLES-1	
	beq r31,r6,in_if_cond # branch i==N_SAMPLES-1
		
	halt	# add else condition here

in_if_cond: halt # add if condition here


	#Increment For loop Counter
        daddi r31,r31,8    # i++
        j for




out:    halt
   

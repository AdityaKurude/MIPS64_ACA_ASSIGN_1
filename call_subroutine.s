      .data 
N_COEFFS:  .word 3
coeff: .double 1.0,25.0,3.0
N_SAMPLES: .word 10
sample: .double 1,2,3,4,5,6,7,8,9,10
result: .double 0,0,0,0,0,0,0,0,0,0

        .text


start:	ld $t1,N_COEFFS(r0)  # $t1 = N_COEFFS
	ld $t0,N_SAMPLES(r0)  # $t0 = N_SAMPLES
	slt $t2,$t1,$t0    # N_COEFFS < N_SAMPLES?
        bnez $t2,smooth       # yes - go to smooth
        halt

smooth:    
	daddu $t0,r0,r0   ; $t0 = 0
        ld $t1,N_COEFFS($t0)  # $t1 = N_COEFFS
        dsll $t1,$t1,3     # $t1 = N_COEFFS*8
for:    slt $t2,$t0,$t1    # i < N_COEFFS?
        beqz $t2,out       # yes - exit
        ld r5,coeff($t0)  # r5=a[i]
        daddi $t0,$t0,8    # i++
        j for
out:    halt
   

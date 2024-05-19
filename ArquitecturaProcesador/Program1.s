.data 
num0: .word 1 # posic 0
num1: .word 2 # posic 4
num2: .word 4 # posic 8 
num3: .word 8 # posic 12 
num4: .word 16 # posic 16 
num5: .word 32 # posic 20
num6: .word 0 # posic 24
num7: .word 0 # posic 28
num8: .word 0 # posic 32
num9: .word 0 # posic 36
num10: .word 0 # posic 40
num11: .word 0 # posic 44
.text 
main:
  lw $t1, 0($zero) 
  lw $t2, 4($zero) 
  lw $t3, 8($zero) 
  lw $t4, 12($zero)
  lw $t5, 16($zero)
  lw $t6, 20($zero)
  sw $t1, 24($zero)
  sw $t2, 28($zero)
  sw $t3, 32($zero)
  sw $t4, 36($zero)
  sw $t5, 40($zero)
  sw $t6, 44($zero)
  lw $t1, 24($zero) 
  lw $t2, 28($zero) 
  lw $t3, 32($zero) 
  lw $t4, 36($zero) 
  lw $t5, 40($zero) 
  lw $t6, 44($zero) 
  add $t7, $t1, $t2
  add $s0, $t3, $t4
  sub $s1, $t5, $t1
  sub $s2, $t6, $t2
  and $s3, $t1, $t2
  and $s4, $t7, $t2
  slt $s7, $t1, $t2
  slt $t8, $s0, $t2
  or $s5, $t1, $t2 
  or $s6, $s0, $t2 
  beq $t1, $s7, salto1 #salto efectivo
  add $s0, $s0, $t1
  add $s1, $s1, $t1
  add $t1, $t1, $t1
salto1: beq $t1, $zero, salto2 #salto no efectivo
  add $s2, $s2, $t1
  add $s3, $s3, $t1
  add $t1, $t1, $t1
salto2: lui $t1, 1
  lui $t2, 2

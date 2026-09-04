    .text
    .globl _start
_start:
    addi    a2, x0, 4                 # AVL request = 4
    vsetvli  a0, a2, e32, m1, ta, ma  # a0 = vl = min(4, VLMAX)
    vsetivli a1, 3,  e32, m1, ta, ma  # a1 = vl = min(3, VLMAX), AVL is uimm 3
    addi    t0, x0, 8                 # AVL request = 8
    addi    t1, x0, 0xD0              # vtype value (e32,m1,ta,ma)
    vsetvl  a3, t0, t1                # a3 = vl = min(8, VLMAX), vtype from t1
end:
    j       end                      # self-loop so PC settles (no jump back to 0)

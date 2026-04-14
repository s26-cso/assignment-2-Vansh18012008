.text 

.global make_node           #so firstly we are making a function to make new node of our binary search tree 
make_node:
    addi sp,sp,-16           #sp stands for stack pointer we made 2 spaces in the stack one for return address and one for the val of new node 
    sd ra,8(sp)             #storing ra in the sp (using sd for 64-bit)
    sd a0,0(sp)             #storing a0 in sp

    li a0,24                #size I want my node to be of i.e 8 bytes each for val,left and right
    call malloc             #allocate memory (standard 64-bit way)

    ld t0,0(sp)             #using ld for 64-bit

    sd t0,0(a0)             #node->val = val
    sd x0,8(a0)             #left = NULL (offset 8)
    sd x0,16(a0)            #right = NULL (offset 16)

    ld ra,8(sp)             #got the r from the stack
    addi sp,sp,16            #restored the stack 
    ret                     #return 

.global insert
insert:
    addi sp,sp,-32          #a0 is root and a1 is the val (aligned to 16 bytes)
    sd ra,24(sp)
    sd a0,16(sp)
    sd a1,8(sp)

    beq a0,x0,insert_create #if root ==NULL then ...
    ld t0,0(a0)             #t0 is storing the val of root

    beq a1,t0,insert_done   #if equal then do nothing
    blt a1,t0,left          #if val is less than root go to left else go to right
    j right

left:
    ld t1,8(a0)             #root left is taken
    mv a0,t1                #moving it into a temporary register
    ld a1,8(sp)             #a1 is the val
    jal ra,insert           #calling insert function for root->left
    ld t2,16(sp)            #restoring the orignal root
    sd a0,8(t2)             #root->left = val
    mv a0,t2                
    j insert_done

right:
    ld t1,16(a0)            #root right is taken
    mv a0,t1                #moving it into a temporary register
    ld a1,8(sp)             #a1 is the val
    jal ra,insert           #calling insert function for root->right
    ld t2,16(sp)            #restoring the orignal root
    sd a0,16(t2)            #root->right = val
    mv a0,t2                
    j insert_done

insert_create:
    ld a0,8(sp)             #this is the base case i.e if root is equal to null
    jal ra,make_node

insert_done:
    ld ra,24(sp)
    addi sp,sp,32
    ret

.global get
get:
    beq a0,x0,get_null      #if root is null

    ld t0,0(a0)             #storing root in a temporary register 
    
    beq t0,a1,get_found     #check match
    blt a1,t0,get_left      #if less than root go to left else go to right
    bgt a1,t0,get_right
    
get_found:
    ret                     #if equal that means found so retun

get_left:
    ld a0,8(a0)             #go left of the root and call the ge function
    j get                   #using jump for tail recursion to keep stack clean

get_right:
    ld a0,16(a0)
    j get                   #using jump for tail recursion
    
get_null:
    li a0,0                 #if root is null just return 
    ret


.global getAtMost
getAtMost:
    beq a1,x0,return_minus  #if root == null return -1

    ld t0,0(a1)             #root's val stored in temporary register

    beq t0,a0,return_equal  #if root's val == val then return 

    blt a0,t0,go_left       #go to left if val is less than root->val 

    mv t1,t0                #noow fromm here we will check if the right subtree has a better value than root itself
    ld t2,16(a1)            #t2 = root->right
    mv a1,t2                #a1 = root->right

    addi sp,sp,-32           #stack is used to stored the return address and the candidate
    sd ra,24(sp)
    sd t1,16(sp)
    sd a0,8(sp)             # save target val

    jal ra,getAtMost        #recursive call

    ld t1,16(sp)             #restore candidate and the stack
    ld ra,24(sp)
    addi sp,sp,32

    li t3,-1                #checking if we got a better val from right subtree 
    beq a0,t3,return_candidate

    ret

go_left:
    ld t2,8(a1)        # move to left child
    mv a1,t2
    j getAtMost        # Tail call optimization

return_candidate:
    mv a0,t1
    ret

return_equal:
    mv a0,t0
    ret

return_minus:
    li a0,-1
    ret

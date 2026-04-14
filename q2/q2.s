.section .rodata
    space: .string " "
    newline: .string "\n"
    fmt_int: .string "%d"

.section .text
.globl main

main:
    addi sp, sp, -64 
    sd ra, 56(sp)               #return address
    sd s1, 48(sp)               #s1 storing argument count
    sd s2, 40(sp)               #s2 storing pointer to an array of strings
    
    mv s1, a0                   
    mv s2, a1
    
    li t0, 1                    
    ble s1, t0, exit_early      #if no of students is less than or equal to 1 then quit

    addi s1, s1, -1             #decrementing 1 to get the count
    
    slli t0, s1, 3              #Multiply n by 8 (each integer/pointer is 8 bytes)
    sub sp, sp, t0              #moving sp to make room for arr
    mv s4, sp                   #s4 is the base address of arr
    sub sp, sp, t0              #making room for result array
    mv s5, sp                   #s5 is base address of result
    sub sp, sp, t0              #making space for our stack
    mv s6, sp                   #s6 is the base address of stack
    
    li s3, 0                    #setting loop counter to 0
parse_loop:
    beq s3, s1, process_init    #if i==n then done
    slli t0, s3, 3              #offset
    add t1, s2, t0              #address of the string pointer pointer to an array of strings
    ld a0, 8(t1)                
    call atoi                   #calling C library function sting to int
    
    slli t0, s3, 3              #offset
    add t1, s4, t0
    sd a0, 0(t1)
    
    addi s3, s3, 1              #increment i
    j parse_loop

process_init:
    li s7, 0                    #initialize the stack
    addi s3, s1, -1             #starting i from n-1 

outer_loop:
    blt s3, zero, print_results #if i<0 all studets ae processed
    
    slli t0, s3, 3              #get offset
    add t1, s4, t0
    ld t2, 0(t1)                #load the IQ

while_stack:
    beq s7, zero, stack_empty   #if stck is empty directly go the logic
    
    addi t0, s7, -1             #look at the top index i.e stack_top -1 
    slli t0, t0, 3
    add t0, s6, t0
    ld t3, 0(t0)                # t3 = the index stored at the top of the stack
    
    slli t1, t3, 3
    add t1, s4, t1
    ld t4, 0(t1)                # t4 = the IQ of the student at that index
    
    bgt t4, t2, stack_not_empty # If IQ on stack > current IQ, we found the next greatest element
    addi s7, s7, -1             # Otherwise, pop the stack
    j while_stack               # Check next element in stack

stack_empty:
    li t5, -1                   # No greater element found, use -1
    j store_result

stack_not_empty:
    addi t0, s7, -1             # The index of the next greatest element  is the current top of stack
    slli t0, t0, 3
    add t0, s6, t0
    ld t5, 0(t0)                # t5 = index of the next greater student

store_result:
    slli t0, s3, 3
    add t1, s5, t0
    sd t5, 0(t1)                # result[i] = t5
    
    slli t0, s7, 3
    add t0, s6, t0
    sd s3, 0(t0)                # Push current index onto stack
    addi s7, s7, 1              #increment the stack
    
    addi s3, s3, -1             # Move to the student on the left (i--)
    j outer_loop

print_results:
    li s3, 0                    #set loop counter for printing

print_loop:
    beq s3, s1, end_program     # If i == n, finished printing
    
    slli t0, s3, 3  
    add t1, s5, t0
    ld a1, 0(t1)                # Load result[i] into a1
    
    la a0, fmt_int              #load %d format string
    call printf                 
    
    addi t0, s1, -1             #check if it is the last number 
    beq s3, t0, skip_space      # if last don't print a space 
    la a0, space                #load ""string
    call printf
skip_space:
    addi s3, s3, 1              #i++
    j print_loop

end_program:
    la a0, newline              #laod "\n"
    call printf

exit_early:
    ld ra, 56(sp)
    ld s1, 48(sp)
    ld s2, 40(sp)
    addi sp, sp, 64
    li a0, 0
    ret

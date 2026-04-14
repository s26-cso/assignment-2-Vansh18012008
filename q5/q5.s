.data
filename: .asciz "input.txt"
mode: .asciz "r"              #open the file in read mode 
yes: .asciz "Yes\n"           #output if the file is palindroome
no: .asciz "No\n"

.text
.globl main

main:
    addi sp,sp,-32
    sd ra,24(sp)                #for return address
    sd s0,16(sp)                #file pointer
    sd s1,8(sp)                 #right pointer
    sd s2,0(sp)                 #left pointer
    
    la a0,filename     #we will open the file i.e fopen #a0 is the pointer to filename
    la a1,mode         #a1 is the pointerr to mode string 
    call fopen          #we will call fopen(filename,mode)
    mv s0,a0          #s0 = FILE*(file pointer)

    mv a0,s0           #we will use fseek to go till the end of the file #a0 is file pointer
    li a1,0            #offset = 0
    li a2,2            #seek_end = 2
    call fseek          #move the pointer to the end of the file

    
    mv a0,s0          #we will get the lenght with the help of ftell
    call ftell          #returns the current position i.e file size
    mv s1,a0          # length

    addi s1,s1,-1    # right pointer
    li s2,0           # left pointer

loop:
    bge s2,s1,palindrome      #if left>=right then end the process

    mv a0,s0              #from here we will read left char
    mv a1,s2              #the left index would be the offset
    li a2,0               #seek_set = 0 i.e to mark the start
    call fseek             #move file pointer to left

    mv a0,s0             
    call fgetc             #reads one char 
    mv t0,a0              #t0 is the left character

   
    mv a0,s0               #from here we will read right char
    mv a1,s1
    li a2,0
    call fseek

    mv a0,s0
    call fgetc
    mv t1,a0               #t1 is the right character

    bne t0,t1,not_palindrome      # we will compare the right and left char if not same then sent to not_palindrome function

    addi s2,s2,1                  #left++
    addi s1,s1,-1                 #right--
    j loop                          #repeat

palindrome:
    la a0,yes
    call printf
    j exit

not_palindrome:
    la a0,no
    call printf

exit:
    mv a0,s0          # pass file pointer
    call fclose        # close file

    li a0,0           # return value = 0
    ld ra,24(sp)
    ld s0,16(sp)
    ld s1,8(sp)
    ld s2,0(sp)
    addi sp,sp,32
    ret

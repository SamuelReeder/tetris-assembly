################ CSC258H1F Winter 2024 Assembly Final Project ##################
# This file contains our implementation of Tetris.
#
# Student 1: Samuel Reeder, 1008840257
# Student 2: Name, Student Number (if applicable)
######################## Bitmap Display Configuration ########################
# - Unit width in pixels:       4
# - Unit height in pixels:      4
# - Display width in pixels:    64
# - Display height in pixels:   64
# - Base Address for Display:   0x10008000 ($gp)
##############################################################################

    .data
##############################################################################
# Immutable Data
##############################################################################
# The address of the bitmap display. Don't forget to connect it!
ADDR_DSPL:
    .word 0x10008000
# The address of the keyboard. Don't forget to connect it!
ADDR_KBRD:
    .word 0xffff0000
Straight_Tetromino:
    .word 0, 0  # Center square
    .word 0, 1  # Left square
    .word 0, 2  # Middle square (base point)
    .word 0, 3  # Right square
    .word 4, 0 # height and start index of first column
    .word 0, 0 # height and start index of second column
Line:
    .word 0, 0
    .word 1, 0
    .word 2, 0
    .word 3, 0
    .word 4, 0
    .word 5, 0
    .word 6, 0
    .word 7, 0
    .word 8, 0
    .word 9, 0
    .word 10, 0
    .word 11, 0
TetrominoSize:
    .byte 4     # Number of squares in the tetromino


##############################################################################
# Mutable Data
##############################################################################

##############################################################################
# Code
##############################################################################
	.text
	.globl main

main:
    li $t5, 0x0000ff
    lw $t0, ADDR_DSPL       # $t0 = base address for display
    addi $t0, $t0, 2048
    li $t2, 0
    li $t3, 0 # for keeping track of colour column-wise
    li $t8 0 # for keeping track of colour row-wise
    li $t6, 4              # $t6 = 4 for dividing $t3 by 4   
    li $t8, 64
setup_loop:
    beq $t2, 3064, fill    # 4096 - 1024 - 8 (margin)
    div $t2, $t8
    mfhi $t9
    
    beq $t9, 56 increment_alt # if remainder is 56, add right and left margin
    beq $t9, 0, increment # if remainer is 0, add left margin

    j condition

# grid creation
increment:
    addi $t2, $t2, 8
    addi $t0, $t0, 32
    j condition
increment_alt:
    addi $t2, $t2, 16
    addi $t0, $t0, 64
    j condition
condition:
    # Determine color based on $t3's current value (0-7)
    div $t3, $t6           # Divide $t3 by 8 using $t6, check the remainder
    mfhi $t4               # Move the division remainder to $t4
    beqz $t4, check_color  # If remainder is 0, check the current color
    j set_color
set_color:
    sw $t5, 0($t0)         # Store color value at the current address
    addi $t0, $t0, 4       # Increment address pointer by 4 bytes for the next pixel
    addi $t2, $t2, 1       # Increment the overall pixel counter
    addi $t3, $t3, 1       # Increment pattern counter (0-7, then repeat)
    j setup_loop            # Jump back to paint the next pixel
check_color:
    # If $t3 is a multiple of 8, change the color
    div $t3, $t6
    mfhi $t7
    beqz $t7, toggle_color
    j set_color
toggle_color:
    addi $s2, $t2, -8   # account for margin
    andi $t1, $s2, 0xFF     # Zero out all but the lowest 8 bits of $t2
    beqz $t1, other   
    beq $t5, 0x212121, set_light # If the current color is dark, change to light
    li $t5, 0x212121          # Otherwise, change to dark
    j set_color
other:
    beq $t5, 0x424242, set_light # If the current color is light, change to light
    li $t5, 0x212121           # Otherwise, change to dark
    j set_color
set_light:
    li $t5, 0x424242           
    j set_color

new_tetromino:
    j fill

# drawing tetrominos
fill:
    li $t5, 0x0000ff         # $t5 = color
    li $a0, 2    # x coordinate of the tetromino's base point on the grid 
    li $a1, 2    # y coordinate of the tetromino's base point on the grid
    la $a2, Straight_Tetromino  # Address of the T Tetromino data
    j draw_tetromino
    # j move_tetromino
draw_tetromino:
    li $t5, 0x0000ff         # $t5 = color
    la $a2, Straight_Tetromino  # Address of the T Tetromino data
    li $a3, 8   # Load the size of the tetromino (2 x number of squares)
draw_square_loop:
    lw $t2, 0($a2)         # Load x offset of the current square
    lw $t3, 0($a2)         # Load y offset of the current square
    
    srl $t8, $t2, 16      # Shift right logical to get the high half in the low half
    add $a0, $a0, $t8     # Add it to $a0
    andi $t9, $t3, 0xFFFF # Mask the high half to get only the low half
    add $a1, $a1, $t9     # Add it to $a1
    jal fill_square        # Draw the square

    sub $a0, $a0, $t8      
    sub $a1, $a1, $t9
    addi $a2, $a2, 4
    addi $a3, $a3, -1      # Decrement the counter
    bnez $a3, draw_square_loop  # If there are more squares, continue the loop
move_tetromino:
    la $a2, Straight_Tetromino  # Address of the T Tetromino data
    lw $t0, ADDR_KBRD               # $t0 = base address for keyboard
    lw $t8, 0($t0)                  # Load first word from keyboard
    beq $t8, 1, keyboard     # If first word 1, key is pressed
    b move_tetromino

draw_tetromino_and_new:
    li $t5, 0x0000ff         # $t5 = color
    la $a2, Straight_Tetromino  # Address of the T Tetromino data
    li $a3, 8   # Load the size of the tetromino (2 x number of squares)
draw_square_loop_and_new:
    lw $t2, 0($a2)         # Load x offset of the current square
    lw $t3, 0($a2)         # Load y offset of the current square
    
    srl $t8, $t2, 16      # Shift right logical to get the high half in the low half
    add $a0, $a0, $t8     # Add it to $a0
    andi $t9, $t3, 0xFFFF # Mask the high half to get only the low half
    add $a1, $a1, $t9     # Add it to $a1
    jal fill_square        # Draw the square

    sub $a0, $a0, $t8      
    sub $a1, $a1, $t9
    addi $a2, $a2, 4
    addi $a3, $a3, -1      # Decrement the counter
    bnez $a3, draw_square_loop_and_new  # If there are more squares, continue the loop
    j check_for_lines_init
    
delete_tetromino:
    la $a2, Straight_Tetromino  # Address of the T Tetromino data
    li $a3,8   # Load the size of the tetromino (2 x number of squares)
delete_square_loop:
    lw $t2, 0($a2)         # Load x offset of the current square
    lw $t3, 0($a2)         # Load y offset of the current square
    
    srl $t8, $t2, 16      # Shift right logical to get the high half in the low half
    add $a0, $a0, $t8     # Add it to $a0
    andi $t9, $t3, 0xFFFF # Mask the high half to get only the low half
    add $a1, $a1, $t9     # Add it to $a1
    jal delete_square

    sub $a0, $a0, $t8      
    sub $a1, $a1, $t9
    addi $a2, $a2, 4
    addi $a3, $a3, -1      # Decrement the counter
    bnez $a3, delete_square_loop  # If there are more squares, continue the loop
    j keyboard_input
start:
    # j fill_square
    # Load the color to a temporary register
    li $t5, 0x0000ff         # $t5 = color
    lw $t0, ADDR_KBRD               # $t0 = base address for keyboard
    lw $t8, 0($t0)                  # Load first word from keyboard
    beq $t8, 1, keyboard_input      # If first word 1, key is pressed
    b start

check_collision_w:
    addi $a1, $a1, -4
    sll $t0, $a0, 2       # $t0 = x * 4 (since each cell is 4 pixels wide)
    sll $t1, $a1, 2       # $t1 = y * 4 (since each cell is 4 pixels high)
    lw $t2, ADDR_DSPL
    li $t3, 64            # $t3 = width of the display in pixels
    mul $t4, $t1, $t3     # $t4 = y * width of display (row offset)
    add $t4, $t4, $t0     # $t4 = row offset + x (final pixel offset)\
    mul $t4, $t4, 4       # multiply by 4
    add $t2, $t2, $t4     # $t2 = starting address for the square
    lw $s0, 0($t2)             # Load the color at current address
    addi $a1, $a1, 4
    beq $s0, 0x0000ff, move_tetromino # If color does not match, go to next 
    j init_move
check_collision_a:
    addi $a0, $a0, -1
    sll $t0, $a0, 2       # $t0 = x * 4 (since each cell is 4 pixels wide)
    sll $t1, $a1, 2       # $t1 = y * 4 (since each cell is 4 pixels high)
    lw $t2, ADDR_DSPL
    li $t3, 64            # $t3 = width of the display in pixels
    mul $t4, $t1, $t3     # $t4 = y * width of display (row offset)
    add $t4, $t4, $t0     # $t4 = row offset + x (final pixel offset)\
    mul $t4, $t4, 4       # multiply by 4
    add $t2, $t2, $t4     # $t2 = starting address for the square
    lw $s0, 0($t2)             # Load the color at current address
    addi $a0, $a0, 1
    beq $s0, 0x0000ff, move_tetromino # If color does not match, go to next 

    j init_move
check_collision_s:
    addi $a1, $a1, 4
    sll $t0, $a0, 2       # $t0 = x * 4 (since each cell is 4 pixels wide)
    sll $t1, $a1, 2       # $t1 = y * 4 (since each cell is 4 pixels high)
    lw $t2, ADDR_DSPL
    li $t3, 64            # $t3 = width of the display in pixels
    mul $t4, $t1, $t3     # $t4 = y * width of display (row offset)
    add $t4, $t4, $t0     # $t4 = row offset + x (final pixel offset)\
    mul $t4, $t4, 4       # multiply by 4
    add $t2, $t2, $t4     # $t2 = starting address for the square
    lw $s0, 0($t2)             # Load the color at current address
    addi $a1, $a1, -4
    beq $s0, 0x0000ff, move_tetromino # If color does not match, go to next 

    j init_move
check_collision_d:
    addi $a0, $a0, 1
    sll $t0, $a0, 2       # $t0 = x * 4 (since each cell is 4 pixels wide)
    sll $t1, $a1, 2       # $t1 = y * 4 (since each cell is 4 pixels high)
    lw $t2, ADDR_DSPL
    li $t3, 64            # $t3 = width of the display in pixels
    mul $t4, $t1, $t3     # $t4 = y * width of display (row offset)
    add $t4, $t4, $t0     # $t4 = row offset + x (final pixel offset)\
    mul $t4, $t4, 4       # multiply by 4
    add $t2, $t2, $t4     # $t2 = starting address for the square
    lw $s0, 0($t2)             # Load the color at current address
    addi $a0, $a0, -1
    li $v0, 1
    syscall
    beq $s0, 0x0000ff, move_tetromino # If color does not match, go to next 
    j init_move
    

keyboard:
    # li $v0, 1
    # syscall
    lw $t0, ADDR_KBRD               # $t0 = base address for keyboard
    lw $t8, 4($t0)
    beq $t8, 0x71, exit
    beq $t8, 0x77, check_collision_w
    beq $t8, 0x61, check_collision_a
    beq $t8, 0x73, check_collision_s
    beq $t8, 0x64, check_collision_d
    beq $t8, 0x65, init_move
    j init_move

init_move:
    li $a3, 0
    addi $sp, $sp, -4  # Decrement stack pointer to make room for the value
    sw $a3, 0($sp)     # Store the value from $t0 into the stack
    j delete_tetromino
keyboard_input:
    lw $a3, 0($sp)     # Load the value from the stack into $t0
    addi $sp, $sp, 4   # Increment stack pointer to remove the value from the stack
    
    lw $t0, ADDR_KBRD               # $t0 = base address for keyboard
    lw $a3, 4($t0)
    beq $a3, 0x77, key_w_pressed
    beq $a3, 0x61, key_a_pressed
    beq $a3, 0x73, key_s_pressed
    beq $a3, 0x64, key_d_pressed
    beq $a3, 0x78, key_x_pressed
    beq $a3, 0x65, return_pressed
    beq $a3, 0x71, key_q_pressed
    b move_tetromino
key_x_pressed:
    j move_tetromino
key_w_pressed:
    addi $a1, $a1, -1
    bne $a1, 1, draw_tetromino
    li $a1, 2
    j draw_tetromino
key_a_pressed:
    addi $a0, $a0, -1
    bne $a0, 1, draw_tetromino
    li $a0, 2
    j draw_tetromino
key_s_pressed:
    addi $a1, $a1, 1
    bne $a1, 11, draw_tetromino
    li $a1, 10
    j draw_tetromino
key_d_pressed:
    addi $a0, $a0, 1
    bne $a0, 14, draw_tetromino
    li $a0, 13
    j draw_tetromino
return_pressed:
    j find_row
key_q_pressed:
    j exit

    
find_row:
    la $a2, Straight_Tetromino
    lw $t9, 32($a2)
    add $a1, $a1, $t9
    # we start looking at t1
    j check_square
next_row:
    beq $a1, 14, found_row
    addi $a1, $a1, 1
    j check_square                # Repeat for the next row
check_square:
    sll $t0, $a0, 2       # $t0 = x * 4 (since each cell is 4 pixels wide)
    sll $t1, $a1, 2       # $t1 = y * 4 (since each cell is 4 pixels high)
    lw $t2, ADDR_DSPL
    li $t3, 64            # $t3 = width of the display in pixels
    mul $t4, $t1, $t3     # $t4 = y * width of display (row offset)
    add $t4, $t4, $t0     # $t4 = row offset + x (final pixel offset)\
    mul $t4, $t4, 4       # multiply by 4
    add $t2, $t2, $t4     # $t2 = starting address for the square
    lw $s0, 0($t2)             # Load the color at current address
    bne $s0, 0x0000ff, next_row # If color does not match, go to next row
found_row:
    sub $a1, $a1, $t9
    # need to first remove rows
    j draw_tetromino_and_new

check_for_lines_init:
    li $a1, 2
    addi $sp, $sp, -4  # Decrement stack pointer to make room for the value
    sw $a1, 0($sp)   
check_for_lines:
    lw $a1, 0($sp)     # Load the value from the stack into $t0
    addi $sp, $sp, 4   # Increment stack pointer to remove the value from the stack
    beq $a1, 15, fill
    addi $a1, $a1, 1
    addi $sp, $sp, -4  # Decrement stack pointer to make room for the value
    sw $a1, 0($sp)  
    addi $a1, $a1, -1
    lw $t2, ADDR_DSPL
    li $t3, 64            # $t3 = width of the display in pixels
new_row:
    beq $a1, 15, fill
    li $a0, 2
    lw $t2, ADDR_DSPL
    li $t3, 64            # $t3 = width of the display in pixels
    addi $a1, $a1, 1
    li $t9, 0
    sll $t0, $a0, 2       # $t0 = x * 4 (since each cell is 4 pixels wide)
    sll $t1, $a1, 2       # $t1 = y * 4 (since each cell is 4 pixels high).
    mult $t4, $t1, $t3     # $t4 = y * width of display (row offset)
    add $t4, $t4, $t0     # $t4 = row offset + x (final pixel offset)
    mult $t4, $t4, 4       # multiply by 4
    add $t2, $t2, $t4     # $t2 = starting address for the square
check:
    lw $s0, 0($t2)             # Load the color at current address 
    bne $s0, 0x0000ff, new_row # If color does not match, go to next row
    beq $t9, 11, remove_row
    addi $t9, $t9, 1
    addi $t2, $t2, 16
    j check
remove_row:
    li $a0, 1
    la $a2, Line  # Address of the T Tetromino data
remove_row_loop: 
    addi $a0, $a0, 1     # Add it to $a0 
    jal delete_square
    bne $a0, 13 remove_row_loop  # If there are more squares, continue the loop
shift_down:
    beq $a1, 2, check_for_lines
    li $a0, 2
    addi $a1, $a1, -1
check_square_new:
    beq $a0, 14, shift_down
    sll $t0, $a0, 2       # $t0 = x * 4 (since each cell is 4 pixels wide)
    sll $t1, $a1, 2       # $t1 = y * 4 (since each cell is 4 pixels high)
    lw $t2, ADDR_DSPL
    li $t3, 64            # $t3 = width of the display in pixels
    mul $t4, $t1, $t3     # $t4 = y * width of display (row offset)
    add $t4, $t4, $t0     # $t4 = row offset + x (final pixel offset)\
    mul $t4, $t4, 4       # multiply by 4
    add $t2, $t2, $t4     # $t2 = starting address for the square
    lw $s0, 0($t2)             # Load the color at current address
    addi $a0, $a0, 1
    bne $s0, 0x0000ff, check_square_new
delete_and_new:
    addi $a0, $a0, -1
    jal delete_square
    addi $a1, $a1, 1
    li $t5, 0x0000ff         # $t5 = color
    jal fill_square
    addi $a0, $a0, 1
    addi $a1, $a1, -1
    j check_square_new

    
# drawing individual squares
fill_square:
    li $s0, 4
    # Convert grid coordinates to pixel coordinates
    sll $t0, $a0, 2       # $t0 = x * 4 (since each cell is 4 pixels wide)
    sll $t1, $a1, 2       # $t1 = y * 4 (since each cell is 4 pixels high)

    # Calculate starting memory address for the square
    lw $t2, ADDR_DSPL     # $t2 = base address for the display
    # need to add 64 times y plus x for initial location
    li $t3, 64            # $t3 = width of the display in pixels
    mul $t4, $t1, $t3     # $t4 = y * width of display (row offset)
    add $t4, $t4, $t0     # $t4 = row offset + x (final pixel offset)\
    mul $t4, $t4, 4       # multiply by 4
    add $t2, $t2, $t4     # $t2 = starting address for the square
    li $t6, 4             # $t6 = counter for rows
draw_square_row:
    li $t7, 4             # $t7 = counter for columns
draw_square_column:
    sw $t5, 0($t2)        # Set the pixel color
    addi $t2, $t2, 4      # Move to the next pixel in the row
    addi $t7, $t7, -1     # Decrement the column counter
    bnez $t7, draw_square_column # Continue drawing columns if $t7 != 0

    # Move to the next row
    addi $t2, $t2, 240     # Skip the remaining pixels to get to the start of the next row (64 * 4 - 16 = 240)
    addi $t6, $t6, -1     # Decrement the row counter
    bnez $t6, draw_square_row   # Continue drawing rows if $t6 != 0
    jr $ra  # Return to the caller

# deleting squares
delete_square:
    li $s0, 2
    div $a0, $s0
    mfhi $s1
    div $a1, $s0
    mfhi $s2
    beq $s1, $s2, colour_dark
    bnez $s1, colour_light
    bnez $s2, colour_light
    jr $ra
colour_dark:
    li $t5, 0x212121
    j fill_square
colour_light:
    li $t5, 0x424242
    j fill_square
    
exit:
    li $v0, 10              # terminate the program gracefully
    syscall

game_loop:
	# 1a. Check if key has been pressed
    # 1b. Check which key has been pressed
    # 2a. Check for collisions
	# 2b. Update locations (paddle, ball)
	# 3. Draw the screen
	# 4. Sleep

    #5. Go back to 1
    b game_loop

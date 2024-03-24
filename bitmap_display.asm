##############################################################################
# Example: Displaying Pixels
#
# This file demonstrates how to draw pixels with different colours to the
# bitmap display.
##############################################################################

######################## Bitmap Display Configuration ########################
# - Unit width in pixels: 8
# - Unit height in pixels: 8
# - Display width in pixels: 256
# - Display height in pixels: 256
# - Base Address for Display: 0x10008000 ($gp)
##############################################################################
    .data
ADDR_DSPL:
    .word 0x10008000
ADDR_KBRD:
    .word 0xffff0000
TETROMINOES:
    .space 288
I_Tetromino:
    .byte 0b0000, 0b1111, 0b0000, 0b0000  # Vertical representation
    # .byte 0b0010, 0b0010, 0b0010, 0b0010  # Horizontal representation (alternative)
# T_Tetromino:
    # .byte 1, 0  # Center square
    # .byte 0, 1  # Left square
    # .byte 1, 1  # Middle square (base point)
    # .byte 2, 1  # Right square
    # .byte 1, 2  # Bottom square
# T_Tetromino:
    # .word 0, 0   # Center square (relative to itself as a base)
    # .word -1, 1  # Left square
    # .word 0, 1   # Middle square (base point)
    # .word 1, 1   # Right square
    # .word 0, 2   # Bottom square
T_Tetromino:
    .word 1, 0  # Center square
    .word 0, 1  # Left square
    .word 1, 1  # Middle square (base point)
    .word 2, 1  # Right square
    .word 1, 2  # Bottom square
Straight_Tetromino:
    .word 0, 0  # Center square
    .word 0, 1  # Left square
    .word 0, 2  # Middle square (base point)
    .word 0, 3  # Right square
TetrominoOffsets:
    .word 0, 0   # Base square
    .word 4, 0   # Right square
    .word 0, 4   # Bottom square
    .word -4, 0  # Left square
TetrominoSize:
    .byte 4     # Number of squares in the tetromino

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

# drawing tetrominos
fill:
    li $t5, 0x0000ff         # $t5 = color
    li $a0, 5    # x coordinate of the tetromino's base point on the grid
    li $a1, 6    # y coordinate of the tetromino's base point on the grid
    la $a2, Straight_Tetromino  # Address of the T Tetromino data
    j draw_tetromino
    # j move_tetromino
draw_tetromino:
    li $t5, 0x0000ff         # $t5 = color
    la $a2, Straight_Tetromino  # Address of the T Tetromino data
    li $a3, 8   # Load the size of the tetromino (2 x number of squares)
    # j draw_square_loop
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
    
    # jr $ra   # Return to the caller
    j move_tetromino
    
move_tetromino:
    # for each member of tetromino
    # increment it by value from input
    # delete square at existing values
    # initial points of tetromino stored in a0 and a1
    # basically call draw tetromino with new a0 and a1
    la $a2, Straight_Tetromino  # Address of the T Tetromino data
    lw $t0, ADDR_KBRD               # $t0 = base address for keyboard
    lw $t8, 0($t0)                  # Load first word from keyboard
    beq $t8, 1, keyboard     # If first word 1, key is pressed
    b move_tetromino
    
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
    jal delete_square        # Draw the square

    sub $a0, $a0, $t8      
    sub $a1, $a1, $t9
    addi $a2, $a2, 4
    addi $a3, $a3, -1      # Decrement the counter
    bnez $a3, delete_square_loop  # If there are more squares, continue the loop
    j keyboard_input

hi:
    li $v0, 1       # Load the syscall for printing an integer (1)
    syscall   
start:
    # j fill_square
    # Load the color to a temporary register
    li $t5, 0x0000ff         # $t5 = color
    lw $t0, ADDR_KBRD               # $t0 = base address for keyboard
    lw $t8, 0($t0)                  # Load first word from keyboard
    beq $t8, 1, keyboard_input      # If first word 1, key is pressed
    b start

keyboard:
    beq $a3, 0x71, exit
        
    addi $sp, $sp, -4  # Decrement stack pointer to make room for the value
    sw $a3, 0($sp)     # Store the value from $t0 into the stack
    j delete_tetromino
# handle input
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
    b move_tetromino
key_x_pressed:
    jal delete_tetromino
    j move_tetromino
key_w_pressed:
    addi $a1, $a1, -1
    bne $a1, 1, draw_tetromino
    li $a1, 2
    j draw_tetromino
key_a_pressed:
    # jal delete_tetromino
    addi $a0, $a0, -1
    bne $a0, 1, draw_tetromino
    li $a0, 2
    j draw_tetromino
key_s_pressed:
    # jal delete_tetromino
    addi $a1, $a1, 1
    bne $a1, 14, draw_tetromino
    li $a1, 13
    j draw_tetromino
key_d_pressed:
    # jal delete_tetromino
    addi $a0, $a0, 1
    bne $a0, 14, draw_tetromino
    li $a0, 13
    j draw_tetromino

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

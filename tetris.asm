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
# tetromino has max of 4 blocks
# firt eight words are xy for each block
# next 8 are height and start of each col
# last 2 are references to their rotations
Straight_Tetromino:
    .word 0, 0
    .word 0, 1
    .word 0, 2
    .word 0, 3
    .word 4, 0 # height and start index of first column
    .word 0, 0 # height and start index of second column
    .word 0, 0 # height and start index of third column
    .word 0, 0 # height and start index of fourth column
    .word Straight_Tetromino_Horizontal, Straight_Tetromino_Horizontal
Straight_Tetromino_Horizontal:
    .word 0, 0
    .word 1, 0
    .word 2, 0
    .word 3, 0
    .word 1, 0 # height and start index of first column
    .word 1, 0 # height and start index of second column
    .word 1, 0 # height and start index of third column
    .word 1, 0 # height and start index of fourth column
    .word Straight_Tetromino, Straight_Tetromino
Square_Tetromino:
    .word 0, 0
    .word 1, 0
    .word 0, 1
    .word 1, 1
    .word 2, 0  # Height and start index of first column
    .word 2, 0  # Height and start index of second column
    .word 0, 0  # Height and start index of third column (unused)
    .word 0, 0  # Height and start index of fourth column (unused)
    .word Square_Tetromino, Square_Tetromino  # Reference to itself (rotation does not change shape)
# Default (Spawn) Orientation
T_Tetromino:
    .word 1, 0  # Bottom of T
    .word 0, 1  # Left of T
    .word 1, 1  # Center of T
    .word 2, 1  # Right of T
    .word 1, 1  # Column heights and start indices for the first column
    .word 2, 0  # Column heights and start indices for the second column
    .word 1, 1  # Column heights and start indices for the third column
    .word 0, 0  # Unused column
    .word T_Tetromino_Left, T_Tetromino_Right

# Left Rotation
T_Tetromino_Left:
    .word 0, 1
    .word 1, 0
    .word 1, 1
    .word 1, 2
    .word 1, 1  # Column heights and start indices for the first column
    .word 3, 0  # Column heights and start indices for the second column, taller part of T
    .word 0, 0  # Unused columns
    .word 0, 0
    .word T_Tetromino_Upside_Down, T_Tetromino

# Right Rotation
T_Tetromino_Right:
    .word 0, 0
    .word 0, 1
    .word 0, 2
    .word 1, 1
    .word 3, 0  # This column is the tall part of T
    .word 1, 1  # Column heights and start indices
    .word 0, 0  # Unused columns
    .word 0, 0
    .word T_Tetromino, T_Tetromino_Upside_Down

# Upside-Down Rotation
T_Tetromino_Upside_Down:
    .word 0, 0
    .word 1, 0
    .word 2, 0
    .word 1, 1
    .word 1, 0  # Column heights and start indices for the first column
    .word 2, 0  # Column heights and start indices for the second column
    .word 1, 0  # Column heights and start indices for the third column
    .word 0, 0  # Unused column
    .word T_Tetromino_Right, T_Tetromino_Left

# Default (Spawn) Orientation
S_Tetromino:
    .word 1, 0  # Bottom left of S
    .word 2, 0  # Bottom right of S
    .word 0, 1  # Top left of S
    .word 1, 1  # Top right of S
    .word 1, 1  # Column heights and start indices for the first column
    .word 2, 0  # Column heights and start indices for the second column
    .word 1, 0  # Unused columns
    .word 0, 0
    .word S_Tetromino_Vertical, S_Tetromino_Vertical  # Rotated references

# Rotated (Vertical) Orientation
S_Tetromino_Vertical:
    .word 0, 0
    .word 0, 1
    .word 1, 1
    .word 1, 2
    .word 2, 0  # Column heights and start indices for the first column, taller part of S
    .word 2, 1  # Column heights and start indices for the second column, taller part of S
    .word 0, 0  # Unused columns
    .word 0, 0
    .word S_Tetromino, S_Tetromino  # Back to default orientation

# Default (Spawn) Orientation
Z_Tetromino:
    .word 0, 0  # Bottom left of Z
    .word 1, 0  # Bottom middle of Z
    .word 1, 1  # Top middle of Z
    .word 2, 1  # Top right of Z
    .word 1, 0  # Column heights and start index for the first column
    .word 2, 0  # Column heights and start index for the second column
    .word 1, 1  # Unused columns
    .word 0, 0
    .word Z_Tetromino_Vertical, Z_Tetromino_Vertical  # Rotated references

# Rotated (Vertical) Orientation
Z_Tetromino_Vertical:
    .word 1, 0
    .word 1, 1
    .word 0, 1
    .word 0, 2
    .word 2, 1  # Column heights and start index for the first column, taller part of Z
    .word 2, 0  # Column heights and start index for the second column, taller part of Z
    .word 0, 0  # Unused columns
    .word 0, 0
    .word Z_Tetromino, Z_Tetromino  # Back to default orientation

# Default (Spawn) Orientation
J_Tetromino:
    .word 1, 0  # Bottom of J
    .word 1, 1  # Middle of J
    .word 1, 2  # Top of J
    .word 0, 2  # Left of J
    .word 1, 2  # Column heights and start index for the first column
    .word 3, 0  # Column heights and start index for the second column
    .word 0, 0  # Unused columns
    .word 0, 0
    .word J_Tetromino_Left, J_Tetromino_Right

# Left Rotation
J_Tetromino_Left:
    .word 0, 0
    .word 1, 0
    .word 2, 0
    .word 2, 1
    .word 1, 0  # Column heights and start index for the first column
    .word 1, 0  # Column heights and start index for the second column
    .word 2, 0  # Column heights and start index for the third column
    .word 0, 0
    .word J_Tetromino_Upside_Down, J_Tetromino

# Right Rotation
J_Tetromino_Right:
    .word 0, 0
    .word 0, 1
    .word 1, 1
    .word 2, 1
    .word 2, 0  # Column heights and start index for the first column
    .word 1, 1  # Column heights and start index for the second column
    .word 0, 0  # Unused columns
    .word 0, 0
    .word J_Tetromino, J_Tetromino_Upside_Down

# Upside-Down (180°) Rotation
J_Tetromino_Upside_Down:
    .word 0, 0
    .word 1, 0
    .word 0, 1
    .word 0, 2
    .word 3, 0  # Column heights and start index for the first column
    .word 1, 0  # Column heights and start index for the second column
    .word 0, 0  # Unused columns
    .word 0, 0
    .word J_Tetromino_Right, J_Tetromino_Left

# Default (Spawn) Orientation
L_Tetromino:
    .word 0, 0  
    .word 0, 1
    .word 0, 2
    .word 1, 2
    .word 3, 0
    .word 1, 1
    .word 0, 0
    .word 0, 0
    .word L_Tetromino_Left, L_Tetromino_Right

# Left Rotation
L_Tetromino_Left:
    .word 0, 1
    .word 1, 1
    .word 2, 1
    .word 2, 0
    .word 1, 1
    .word 1, 1
    .word 2, 0
    .word 0, 0
    .word L_Tetromino_Upside_Down, L_Tetromino

# Right Rotation
L_Tetromino_Right:
    .word 0, 0
    .word 0, 1
    .word 1, 0
    .word 2, 0
    .word 2, 0
    .word 1, 0
    .word 1, 0
    .word 0, 0
    .word L_Tetromino, L_Tetromino_Upside_Down

# Upside-Down (180°) Rotation
L_Tetromino_Upside_Down:
    .word 0, 0
    .word 1, 0
    .word 1, 1
    .word 1, 2
    .word 1, 0
    .word 3, 0
    .word 0, 0
    .word 0, 0
    .word L_Tetromino_Right, L_Tetromino_Left
Colors:
    .word 0x00FFFF
    .word 0xFFFF00
    .word 0x800080
    .word 0x00FF00
    .word 0xFF0000
    .word 0x0000FF
    .word 0xFFA500
Light_Colors:
    .word 0x42e9f5
    .word 0xc9f720
    .word 0x993399
    .word 0x33FF33
    .word 0xFF3333
    .word 0x3333FF
    .word 0xFFB733
Tetrominos:
    .word Straight_Tetromino
    .word Square_Tetromino
    .word T_Tetromino
    .word S_Tetromino
    .word Z_Tetromino
    .word J_Tetromino
    .word L_Tetromino
    
patterns: 
    .word zero_pattern
    .word one_pattern
    .word two_pattern
    .word three_pattern
    .word four_pattern
    .word five_pattern
    .word six_pattern
    .word seven_pattern
    .word eight_pattern
    .word nine_pattern
score:
    .word 0
##############################################################################
# Mutable Data
##############################################################################
Current_Tetromino:
    .word Straight_Tetromino    # This contains the address of L_Tetromino
    .word -1
Gravity_Speed:
    .word 5000000

zero_pattern: .byte 1, 1, 1
              .byte 1, 0, 1
              .byte 1, 0, 1
              .byte 1, 0, 1
              .byte 1, 1, 1
  
one_pattern: .byte 0, 1, 0
              .byte 1, 1, 0
              .byte 0, 1, 0
              .byte 0, 1, 0
              .byte 1, 1, 1

two_pattern: .byte 1, 1, 1
              .byte 0, 0, 1
              .byte 1, 1, 1
              .byte 1, 0, 0
              .byte 1, 1, 1

three_pattern: .byte 1, 1, 1
              .byte 0, 0, 1
              .byte 1, 1, 1
              .byte 0, 0, 1
              .byte 1, 1, 1

four_pattern: .byte 1, 0, 1
              .byte 1, 0, 1
              .byte 1, 1, 1
              .byte 0, 0, 1
              .byte 0, 0, 1

five_pattern: .byte 1, 1, 1
              .byte 1, 0, 0
              .byte 1, 1, 1
              .byte 0, 0, 1
              .byte 1, 1, 1
              
six_pattern: .byte 1, 1, 1
              .byte 1, 0, 0
              .byte 1, 1, 1
              .byte 1, 0, 1
              .byte 1, 1, 1

seven_pattern: .byte 1, 1, 1
              .byte 0, 0, 1
              .byte 0, 0, 1
              .byte 0, 0, 1
              .byte 0, 0, 1

eight_pattern: .byte 1, 1, 1
              .byte 1, 0, 1
              .byte 1, 1, 1
              .byte 1, 0, 1
              .byte 1, 1, 1

nine_pattern: .byte 1, 1, 1
              .byte 1, 0, 1
              .byte 1, 1, 1
              .byte 0, 0, 1
              .byte 1, 1, 1
              

##############################################################################
# Code
##############################################################################
	.text
	.globl main
    
main:
    lw $t0, ADDR_DSPL       # $t0 = base address for display
    addi $t0, $t0, 2048
    li $t2, 0
    li $t3, 0 # for keeping track of colour column-wise
    li $t8 0 # for keeping track of colour row-wise
    li $t6, 4              # $t6 = 4 for dividing $t3 by 4   
    li $t8, 64
    li $t5, 0
    li $t1, 0
setup_loop:
    beq $t2, 3064, fill    # 4096 - 1024 - 8 (margin)
    div $t2, $t8
    mfhi $t9
    
    beq $t9, 56 increment_alt # if remainder is 56, add right and left margin
    beq $t9, 0, increment # if remainer is 0, add left margin

    j condition
    
reset_score:
    lw $a0, score
    li $t1, 10
    div $a0, $t1   
    mflo $s0
    mfhi $s1 
    
    move $a0, $s0
    li $t7, 0x000000  
    li $t8, 0
    jal draw_number   
    
    move $a0, $s1
    addi $t8, $t8, 4
    jal draw_number 

    j finished_reset 
    
draw_double_digit:
    lw $a0, score
    li $t1, 10
    div $a0, $t1
    mflo $s0   
    mfhi $s1 
    
    move $a0, $s0
    li $t7, 0xffffff 
    li $t8, 0
    jal draw_number      
    
    move $a0, $s1
    addi $t8, $t8, 4
    jal draw_number 

    j finished_score      
    
draw_number:
    lw $a1, ADDR_DSPL
    mul $t8, $t8, 4
    add $a1, $a1, $t8
    # li $a0, 0
    sll $t0, $a0, 2   
    la $t1, patterns   
    add $t1, $t1, $t0  
    lw $t2, 0($t1)

    li $t3, 5 
    li $t4, 3

draw_rows:
    li $t5, 0

draw_cols:
    lb $t6, 0($t2)     
    beqz $t6, skip_pixel
    sw $t7, 0($a1)       

skip_pixel:
    addi $t2, $t2, 1   
    addi $a1, $a1, 4 
    addi $t5, $t5, 1 
    blt $t5, $t4, draw_cols 

    addi $a1, $a1, -12
    addi $a1, $a1, 256
    subi $t3, $t3, 1   
    bgtz $t3, draw_rows

    jr $ra            
    
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
    div $t3, $t6        
    mfhi $t4             
    beqz $t4, check_color 
    j set_color
set_color:
    sw $t5, 0($t0)       
    addi $t0, $t0, 4       
    addi $t2, $t2, 1      
    addi $t3, $t3, 1     
    j setup_loop         
check_color:
    div $t3, $t6
    mfhi $t7
    beqz $t7, toggle_color
    j set_color
toggle_color:
    addi $s2, $t2, -8   # account for margin
    andi $t1, $s2, 0xFF  
    beqz $t1, other   
    beq $t5, 0x212121, set_light 
    li $t5, 0x212121      
    j set_color
other:
    beq $t5, 0x424242, set_light 
    li $t5, 0x212121          
    j set_color
set_light:
    li $t5, 0x424242           
    j set_color

# drawing tetrominos
fill:
    j reset_score
finished_reset:
    la $t0, score
    lw $t0, 0($t0)
    addi $t0, $t0, 1
    la $t2, score
    sw $t0, 0($t2)
    j draw_double_digit
finished_score:
    li $a0, 80
	li $a1,100#time
	li $a2,37
	li $a3,100#volume
	li $v0,33#syscall
	syscall
    la $t5, Current_Tetromino
    lw $t6, 4($t5)
    beq $t6, 6, reset_color
    addi $t6, $t6, 1
    sw $t6, 4($t5)
    jal get_light_color
    li $a0, 2  
    li $a1, 2  
    jal get_tetromino
    la $a2, Current_Tetromino 
    lw $a2, 0($a2)
draw_tetromino:
    j check_placement
finish_check:
    jal get_light_color
    la $a2, Current_Tetromino 
    lw $a2, 0($a2)
    li $a3, 4   
draw_square_loop:
    lw $t8, 0($a2)      
    lw $t9, 4($a2)       
    add $a0, $a0, $t8     
    add $a1, $a1, $t9    
    jal fill_square  

    sub $a0, $a0, $t8      
    sub $a1, $a1, $t9
    addi $a2, $a2, 8
    addi $a3, $a3, -1   
    bnez $a3, draw_square_loop  
draw_five_next:
    jal reset_next
    li $t6, 0
draw_next:
    la $a2, Current_Tetromino
    lw $a2, 4($a2)
    add $a2, $a2, $t6
    jal get_next
    mul $a2, $a2, 4
    la $t0, Tetrominos
    add $t0, $t0, $a2
    lw $a2, 0($t0)
    li $t1, 0
    li $t5, 0xffffff
draw_next_loop:
    lw $t2, ADDR_DSPL
    li $t3, 1402
    mul $t3, $t3, 4
    add $t2, $t2, $t3
    lw $t8, 0($a2)
    lw $t9, 4($a2)
    mul $t8, $t8, 4
    add $t2, $t2, $t8
    mul $t9, $t9, 256
    add $t2, $t2, $t9
    mul $t7, $t6, 1280
    add $t2, $t2, $t7
    sw $t5, 0($t2)
    addi $t1, $t1, 1
    addi $a2, $a2, 8
    bne $t1, 4, draw_next_loop
    addi $t6, $t6, 1
    bne $t6, 5, draw_next
    
move_tetromino:
    la $a2, Current_Tetromino
    lw $a2, 0($a2)
    lw $t0, ADDR_KBRD   
    lw $t8, 0($t0)       
    beq $t8, 1, keyboard
    addi $t1, $t1, 1
    la $t2, Gravity_Speed
    lw $t2, 0($t2)
    beq $t1, $t2, check_collision_gravity
    
    j move_tetromino
gravity:
    j delete_tetromino_other
gravity_draw:
    la $t2, Gravity_Speed
    lw $t0, 0($t2)     
    li $t1, 99     
    
    mult $t0, $t1     
    mflo $t3          
    
    li $t4, 100      
    div $t3, $t4     
    mflo $t5   
    sw $t5, 0($t2)
    addi $a1, $a1, 1
    li $t1, 0
    j draw_tetromino

check_collision_gravity:
    li $t7, 0
    la $a2, Current_Tetromino 
    lw $a2, 0($a2)
loop_gravity:
    lw $s0, 0($a2)
    lw $s1, 4($a2)
    addi $s1, $s1, 1
    add $a0, $a0, $s0
    add $a1, $a1, $s1
    sll $t0, $a0, 2      
    sll $t1, $a1, 2      
    lw $t2, ADDR_DSPL
    mul $t4, $t1, 64    
    add $t4, $t4, $t0   
    mul $t4, $t4, 4      
    add $t2, $t2, $t4    
    lw $t3, 0($t2)         
    sub $a0, $a0, $s0
    sub $a1, $a1, $s1
    beq $t3, 0x00FFFF, return_pressed 
    beq $t3, 0xFFFF00, return_pressed 
    beq $t3, 0x800080, return_pressed 
    beq $t3, 0x00FF00, return_pressed 
    beq $t3, 0xFF0000, return_pressed 
    beq $t3, 0x0000FF, return_pressed 
    beq $t3, 0xFFA500, return_pressed 
    beq $t3, 0x000000, return_pressed 
    beq $t7, 4, gravity
    addi $a2, $a2, 8
    addi $t7, $t7, 1
    j loop_gravity
    
delete_tetromino_other:
    la $a2, Current_Tetromino 
    lw $a2, 0($a2)
    li $a3,4   
delete_square_loop_other:
    lw $t8, 0($a2)         
    lw $t9, 4($a2)         
    add $a0, $a0, $t8    
    add $a1, $a1, $t9     
    jal delete_square        

    sub $a0, $a0, $t8      
    sub $a1, $a1, $t9
    addi $a2, $a2, 8
    addi $a3, $a3, -1      
    bnez $a3, delete_square_loop_other  
    j gravity_draw

draw_tetromino_and_new:
    jal get_color
    la $a2, Current_Tetromino  
    lw $a2, 0($a2)
    li $a3, 4   
draw_square_loop_and_new:
    lw $t8, 0($a2)        
    lw $t9, 4($a2)         
    add $a0, $a0, $t8  
    add $a1, $a1, $t9   
    jal fill_square     

    sub $a0, $a0, $t8      
    sub $a1, $a1, $t9
    addi $a2, $a2, 8
    addi $a3, $a3, -1    
    bnez $a3, draw_square_loop_and_new  
    j check_for_lines_init

check_placement:
    li $t7, 0
    la $a2, Current_Tetromino 
    lw $a2, 0($a2)
loop_placement:
    lw $s0, 0($a2)
    lw $s1, 4($a2)
    add $a0, $a0, $s0
    add $a1, $a1, $s1
    sll $t0, $a0, 2      
    sll $t1, $a1, 2      
    lw $t2, ADDR_DSPL
    mul $t4, $t1, 64
    add $t4, $t4, $t0 
    mul $t4, $t4, 4
    add $t2, $t2, $t4
    lw $t3, 0($t2)         
    sub $a0, $a0, $s0
    sub $a1, $a1, $s1
    beq $t3, 0x00FFFF, gameover
    beq $t3, 0xFFFF00, gameover 
    beq $t3, 0x800080, gameover
    beq $t3, 0x00FF00, gameover
    beq $t3, 0xFF0000, gameover
    beq $t3, 0x0000FF, gameover
    beq $t3, 0xFFA500, gameover
    beq $t3, 0x000000, gameover 
    beq $t7, 4, finish_check # change
    addi $a2, $a2, 8
    addi $t7, $t7, 1
    j loop_placement
    
gameover:
    li $a0, 68
	li $a1,500
	li $a2,37
	li $a3,100
	li $v0,33
	syscall
	
	li $t5, 0xFF0000
	lw $t6, ADDR_DSPL
	addi $t6, $t6, 7800
	sw $t5, 0($t6)
	sw $t5, 4($t6)
	sw $t5, 8($t6)
	sw $t5, 12($t6)
	addi $t6, $t6, 256
	sw $t5, 0($t6)
	sw $t5, 4($t6)
	sw $t5, 8($t6)
	sw $t5, 12($t6)
	addi $t6, $t6, 256
	sw $t5, 0($t6)
	sw $t5, 4($t6)
	sw $t5, 8($t6)
	sw $t5, 12($t6)
	addi $t6, $t6, 256
	sw $t5, 0($t6)
	sw $t5, 4($t6)
	sw $t5, 8($t6)
	sw $t5, 12($t6)
    
gameover_loop:
    lw $t0, ADDR_KBRD   
    lw $t8, 0($t0)       
    beq $t8, 1, gameover_keyboard
    j gameover_loop
    
gameover_keyboard:
    lw $t8, 4($t0)
    beq $t8, 0x72, main
    
delete_tetromino:
    la $a2, Current_Tetromino  
    lw $a2, 0($a2)
    li $a3,4   
delete_square_loop:
    lw $t8, 0($a2)        
    lw $t9, 4($a2)         
    add $a0, $a0, $t8    
    add $a1, $a1, $t9  
    jal delete_square    

    sub $a0, $a0, $t8      
    sub $a1, $a1, $t9
    addi $a2, $a2, 8
    addi $a3, $a3, -1   
    bnez $a3, delete_square_loop 
    j keyboard_input

check_collision_w:
    la $a2, Current_Tetromino  
    lw $a2, 0($a2)
    lw $a2, 64($a2)
    li $t7, 0
loop_w:
    lw $t0, 0($a2)
    lw $t1, 4($a2)
    add $a0, $a0, $t0
    add $a1, $a1, $t1
    sll $t8, $a0, 2    
    sll $t9, $a1, 2    
    lw $t2, ADDR_DSPL
    mul $t4, $t9, 64   
    add $t4, $t4, $t8    
    mul $t4, $t4, 4      
    add $t2, $t2, $t4  
    lw $s0, 0($t2)         
    
    sub $a0, $a0, $t0
    sub $a1, $a1, $t1
    
    addi $t7, $t7, 1
    addi $a2, $a2, 8
    beq $s0, 0x00FFFF, move_tetromino
    beq $s0, 0xFFFF00, move_tetromino
    beq $s0, 0x800080, move_tetromino
    beq $s0, 0x00FF00, move_tetromino
    beq $s0, 0xFF0000, move_tetromino 
    beq $s0, 0x0000FF, move_tetromino
    beq $s0, 0xFFA500, move_tetromino  
    beq $s0, 0x000000, move_tetromino
    beq $t7, 4, init_move
    
    j loop_w
    
    
check_collision_a:
    li $t7, 0
    la $a2, Current_Tetromino  
    lw $a2, 0($a2)
loop_a:
    lw $s0, 0($a2)
    lw $s1, 4($a2)
    addi $s0, $s0, -1
    add $a0, $a0, $s0
    add $a1, $a1, $s1
    sll $t0, $a0, 2      
    sll $t1, $a1, 2     
    lw $t2, ADDR_DSPL
    mul $t4, $t1, 64 
    add $t4, $t4, $t0    
    mul $t4, $t4, 4      
    add $t2, $t2, $t4    
    lw $t3, 0($t2)         
    sub $a0, $a0, $s0
    sub $a1, $a1, $s1
    beq $t3, 0x00FFFF, move_tetromino
    beq $t3, 0xFFFF00, move_tetromino  
    beq $t3, 0x800080, move_tetromino 
    beq $t3, 0x00FF00, move_tetromino 
    beq $t3, 0xFF0000, move_tetromino 
    beq $t3, 0x0000FF, move_tetromino 
    beq $t3, 0xFFA500, move_tetromino 
    beq $t3, 0x000000, move_tetromino 
    beq $t7, 4, init_move
    addi $a2, $a2, 8
    addi $t7, $t7, 1
    j loop_a
check_collision_s:
    la $a2, Current_Tetromino
    lw $a2, 0($a2)
    lw $a2, 68($a2)
    li $t7, 0
loop_s:
    lw $t0, 0($a2)
    lw $t1, 4($a2)
    add $a0, $a0, $t0
    add $a1, $a1, $t1
    sll $t8, $a0, 2    
    sll $t9, $a1, 2    
    lw $t2, ADDR_DSPL
    mul $t4, $t9, 64   
    add $t4, $t4, $t8     
    mul $t4, $t4, 4      
    add $t2, $t2, $t4     
    lw $s0, 0($t2)         
    sub $a0, $a0, $t0
    sub $a1, $a1, $t1
    addi $t7, $t7, 1
    addi $a2, $a2, 8
    beq $s0, 0x00FFFF, move_tetromino
    beq $s0, 0xFFFF00, move_tetromino
    beq $s0, 0x800080, move_tetromino
    beq $s0, 0x00FF00, move_tetromino
    beq $s0, 0xFF0000, move_tetromino 
    beq $s0, 0x0000FF, move_tetromino
    beq $s0, 0xFFA500, move_tetromino  
    beq $s0, 0x000000, move_tetromino
    beq $t7, 4, init_move
    j loop_s

check_collision_d:
    li $v0, 1
    syscall
    li $t7, 0
    la $a2, Current_Tetromino
    lw $a2, 0($a2)
loop_d:
    lw $s0, 0($a2)
    lw $s1, 4($a2)
    addi $s0, $s0, 1
    add $a0, $a0, $s0
    add $a1, $a1, $s1
    sll $t0, $a0, 2      
    sll $t1, $a1, 2      
    lw $t2, ADDR_DSPL
    mul $t4, $t1, 64   
    add $t4, $t4, $t0     
    mul $t4, $t4, 4  
    add $t2, $t2, $t4   
    lw $t3, 0($t2)       
    sub $a0, $a0, $s0
    sub $a1, $a1, $s1
    beq $t3, 0x00FFFF, move_tetromino  
    beq $t3, 0xFFFF00, move_tetromino 
    beq $t3, 0x800080, move_tetromino 
    beq $t3, 0x00FF00, move_tetromino 
    beq $t3, 0xFF0000, move_tetromino
    beq $t3, 0x0000FF, move_tetromino
    beq $t3, 0xFFA500, move_tetromino 
    beq $t3, 0x000000, move_tetromino 
    beq $t7, 4, init_move
    addi $a2, $a2, 8
    addi $t7, $t7, 1
    j loop_d

keyboard:
    lw $t0, ADDR_KBRD    
    lw $t8, 4($t0)
    beq $t8, 0x71, exit
    beq $t8, 0x77, check_collision_w
    beq $t8, 0x61, check_collision_a
    beq $t8, 0x73, check_collision_s
    beq $t8, 0x64, check_collision_d
    beq $t8, 0x78, pause # change to p
    j init_move

init_move:
    la $a2, Current_Tetromino
    lw $a2, 0($a2)
    li $a3, 0
    j delete_tetromino
keyboard_input:
    lw $t0, ADDR_KBRD       
    lw $a3, 4($t0)
    beq $a3, 0x77, key_w_pressed
    beq $a3, 0x61, key_a_pressed
    beq $a3, 0x73, key_s_pressed
    beq $a3, 0x64, key_d_pressed
    beq $a3, 0x65, return_pressed
    beq $a3, 0x71, key_q_pressed
    b move_tetromino
pause:
    li $t8, 0
    li $t5, 0xffffff         # $t5 = color
    lw $t2, ADDR_DSPL
    jal make_pause
    j pause_loop
make_pause:
    addi $t2, $t2, 256
    sw $t5, 120($t2)
    sw $t5, 124($t2)
    sw $t5, 132($t2)
    sw $t5, 136($t2)
    addi $t8, $t8, 1
    bne $t8, 6, make_pause
    jr $ra
pause_loop:
    lw $t0, ADDR_KBRD    
    lw $t8, 0($t0)      
    beq $t8, 1, check_pause
    j pause_loop
check_pause:
    lw $t8, 4($t0)   
    beq $t8, 0x78, unpause
    j pause
unpause:
    li $t8, 0
    li $t5, 0x0000000
    lw $t2, ADDR_DSPL
    jal make_pause
    j move_tetromino
    
key_w_pressed:
    lw $a2, 32($a2)
    la $s0, Current_Tetromino
    sw $a2, 0($s0)
    j draw_tetromino
key_a_pressed:
    addi $a0, $a0, -1
    bne $a0, 1, draw_tetromino
    li $a0, 2
    j draw_tetromino
key_s_pressed:
    lw $a2, 36($a2)
    la $s0, Current_Tetromino
    sw $a2, 0($s0)
    j draw_tetromino
key_d_pressed:
    # li $v0, 1
    # syscall
    addi $a0, $a0, 1
    bne $a0, 15, draw_tetromino
    li $a0, 14
    j draw_tetromino
return_pressed:
    j find_row_init
key_q_pressed:
    j exit


find_row_init:
    la $a2, Current_Tetromino
    lw $a2, 0($a2)
    addi $a2, $a2, 32
    li $t6, 0 # count
    li $t8, 14
    li $t3, 0
find_row:
    beq $t6, 4, finish
    lw $t9, 0($a2)
    lw $t7, 4($a2)
    beq $t9, 0, finish
    add $t9, $t9, $t7
    add $a1, $a1, $t9
    sub $a1, $a1, $t3
    add $a0, $a0, $t6
    li $t3, 0
    j check_square
next_row:
    beq $a1, 14, found_row
    addi $t3, $t3, 1
    addi $a1, $a1, 1
check_square:
    sll $t0, $a0, 2
    sll $t1, $a1, 2
    lw $t2, ADDR_DSPL
    mul $t4, $t1, 64
    add $t4, $t4, $t0 
    mul $t4, $t4, 4
    add $t2, $t2, $t4
    lw $s0, 0($t2)     
    beq $s0, 0x00FFFF, found_row 
    beq $s0, 0xFFFF00, found_row 
    beq $s0, 0x800080, found_row 
    beq $s0, 0x00FF00, found_row 
    beq $s0, 0xFF0000, found_row 
    beq $s0, 0x0000FF, found_row
    beq $s0, 0xFFA500, found_row 
    j next_row
found_row:
    sub $a0, $a0, $t6
    sub $a1, $a1, $t9
    addi $t6, $t6, 1
    addi $a2, $a2, 8
    slt $s0, $a1, $t8
    bnez $s0, set_new
    j find_row
set_new:
    move $t8, $a1
    j find_row
finish:
    move $a1, $t8
    j draw_tetromino_and_new
    
check_for_lines_init:
    li $a1, 2
    addi $sp, $sp, -4
    sw $a1, 0($sp)   
check_for_lines:
    lw $a1, 0($sp)
    addi $sp, $sp, 4
    beq $a1, 15, fill
    addi $a1, $a1, 1
    addi $sp, $sp, -4
    sw $a1, 0($sp)  
    addi $a1, $a1, -1
    lw $t2, ADDR_DSPL
    li $t3, 64       
new_row:
    beq $a1, 15, fill
    li $a0, 2
    lw $t2, ADDR_DSPL
    li $t3, 64    
    addi $a1, $a1, 1
    li $t9, 0
    sll $t0, $a0, 2 
    sll $t1, $a1, 2 
    mult $t4, $t1, $t3
    add $t4, $t4, $t0
    mult $t4, $t4, 4   
    add $t2, $t2, $t4 
check:
    lw $s0, 0($t2)        
    beq $s0, 0x00FFFF, check_new 
    beq $s0, 0xFFFF00, check_new  
    beq $s0, 0x800080, check_new
    beq $s0, 0x00FF00, check_new 
    beq $s0, 0xFF0000, check_new
    beq $s0, 0x0000FF, check_new
    beq $s0, 0xFFA500, check_new
    j new_row
check_new:
    beq $t9, 11, remove_row
    addi $t9, $t9, 1
    addi $t2, $t2, 16
    j check
remove_row:
    li $a0, 1
remove_row_loop: 
    addi $a0, $a0, 1
    jal delete_square
    bne $a0, 13 remove_row_loop  
shift_down:
    beq $a1, 2, check_for_lines
    li $a0, 2
    addi $a1, $a1, -1
check_square_new:
    beq $a0, 14, shift_down
    sll $t0, $a0, 2       
    sll $t1, $a1, 2   
    lw $t2, ADDR_DSPL
    mul $t4, $t1, 64
    add $t4, $t4, $t0
    mul $t4, $t4, 4   
    add $t2, $t2, $t4
    lw $t2, 0($t2)  
    addi $a0, $a0, 1
    beq $t2, 0x00FFFF, delete_and_new 
    beq $t2, 0xFFFF00, delete_and_new 
    beq $t2, 0x800080, delete_and_new 
    beq $t2, 0x00FF00, delete_and_new 
    beq $t2, 0xFF0000, delete_and_new
    beq $t2, 0x0000FF, delete_and_new 
    beq $t2, 0xFFA500, delete_and_new 
    j check_square_new
delete_and_new:
    addi $a0, $a0, -1
    move $t9, $t2
    jal delete_square
    addi $a1, $a1, 1

    move $t5, $t9
    jal fill_square
    addi $a0, $a0, 1
    addi $a1, $a1, -1
    j check_square_new

# drawing individual squares
fill_square:
    li $s0, 4
    sll $t0, $a0, 2      
    sll $t1, $a1, 2     
    lw $t2, ADDR_DSPL   
    li $t3, 64         
    mul $t4, $t1, $t3     
    add $t4, $t4, $t0    
    mul $t4, $t4, 4      
    add $t2, $t2, $t4   
    li $t6, 4            
draw_square_row:
    li $t7, 4          
draw_square_column:
    sw $t5, 0($t2)    
    addi $t2, $t2, 4     
    addi $t7, $t7, -1   
    bnez $t7, draw_square_column 
    addi $t2, $t2, 240     # (64 * 4 - 16 = 240)
    addi $t6, $t6, -1    
    bnez $t6, draw_square_row 
    jr $ra 

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

get_color:
    la $t5, Current_Tetromino
    lw $t5, 4($t5)
    mul $t5, $t5, 4
    la $s1, Colors
    add $s1, $s1, $t5
    lw $t5, 0($s1)
    jr $ra
get_tetromino:
    la $t4, Current_Tetromino
    lw $t3, 4($t4)
    mul $t3, $t3, 4
    la $s1, Tetrominos
    add $s1, $s1, $t3
    lw $t3, 0($s1)
    sw $t3, 0($t4)
    jr $ra
get_light_color:
    la $t5, Current_Tetromino
    lw $t5, 4($t5)
    mul $t5, $t5, 4
    la $s1, Light_Colors
    add $s1, $s1, $t5
    lw $t5, 0($s1)
    jr $ra
reset_color:
    la $t5, Current_Tetromino
    lw $t6, 4($t5)
    li $t6, -1
    sw $t6, 4($t5)
    j fill
    # cl
get_next:
    beq $a2, 7, restart_queue
    beq $a2, 8, restart_queue
    beq $a2, 9, restart_queue
    beq $a2, 10, restart_queue
    beq $a2, 11, restart_queue
    beq $a2, 12, restart_queue
    addi $a2, $a2, 1
    jr $ra
restart_queue:
    addi $a2, $a2, -7
    # li $a2, 0
    jr $ra
reset_next:
    lw $t0, ADDR_DSPL
    li $t1, 56
    mul $t1, $t1, 4
    add $t0, $t0, $t1
    li $t5, 0x000000
    li $t2, 0
reset_next_loop:
    sw $t5, 0($t0)
    sw $t5, 4($t0)
    sw $t5, 8($t0)
    sw $t5, 12($t0)
    sw $t5, 16($t0)
    sw $t5, 20($t0)
    sw $t5, 24($t0)
    sw $t5, 28($t0)
    addi $t2, $t2, 1
    addi $t0, $t0, 256
    bne $t2, 64  reset_next_loop
    jr $ra
    
exit:
    li $v0, 10              # terminate the program gracefully
    syscall

# ============================================================
# RISC-V Traffic Light Control Simulation
# RARS Bitmap Display
#
# Traffic sequence:
# 1. North-South Green  | East-West Red
# 2. North-South Yellow | East-West Red
# 3. North-South Red    | East-West Green
# 4. North-South Red    | East-West Yellow
#
# Bitmap Display base address: 0x10040000
# Logical display size required: at least 64 x 152 units
# ============================================================

.data

red_color:     .word 0x00FF0000      # Red
yellow_color:  .word 0x00FFFF00      # Yellow
green_color:   .word 0x0000FF00      # Green
off_color:     .word 0x00000000      # Black / off

display_base:  .word 0x10040000


.text
.globl main


# ============================================================
# Main program
# ============================================================

main:
    # Software delay durations
    li s0, 5000000        # Green-light duration
    li s1, 1500000        # Yellow-light duration


traffic_loop:

    # State 1:
    # North-South Green, East-West Red
    jal draw_ns_green
    jal draw_ew_red
    jal delay_green

    # State 2:
    # North-South Yellow, East-West Red
    jal draw_ns_yellow
    jal draw_ew_red
    jal delay_yellow

    # State 3:
    # North-South Red, East-West Green
    jal draw_ns_red
    jal draw_ew_green
    jal delay_green

    # State 4:
    # North-South Red, East-West Yellow
    jal draw_ns_red
    jal draw_ew_yellow
    jal delay_yellow

    # Repeat forever
    j traffic_loop


# ============================================================
# North-South traffic light
#
# X position: 16
# Red Y:     8
# Yellow Y: 32
# Green Y:  56
# ============================================================

draw_ns_green:
    addi sp, sp, -16
    sw ra, 12(sp)

    li a0, 16

    li a1, 8
    jal draw_light_off

    li a1, 32
    jal draw_light_off

    li a1, 56
    la a2, green_color
    jal draw_light

    lw ra, 12(sp)
    addi sp, sp, 16
    ret


draw_ns_yellow:
    addi sp, sp, -16
    sw ra, 12(sp)

    li a0, 16

    li a1, 8
    jal draw_light_off

    li a1, 56
    jal draw_light_off

    li a1, 32
    la a2, yellow_color
    jal draw_light

    lw ra, 12(sp)
    addi sp, sp, 16
    ret


draw_ns_red:
    addi sp, sp, -16
    sw ra, 12(sp)

    li a0, 16

    li a1, 32
    jal draw_light_off

    li a1, 56
    jal draw_light_off

    li a1, 8
    la a2, red_color
    jal draw_light

    lw ra, 12(sp)
    addi sp, sp, 16
    ret


# ============================================================
# East-West traffic light
#
# X position: 40
# Red Y:     88
# Yellow Y: 112
# Green Y:  136
# ============================================================

draw_ew_red:
    addi sp, sp, -16
    sw ra, 12(sp)

    li a0, 40

    li a1, 112
    jal draw_light_off

    li a1, 136
    jal draw_light_off

    li a1, 88
    la a2, red_color
    jal draw_light

    lw ra, 12(sp)
    addi sp, sp, 16
    ret


draw_ew_yellow:
    addi sp, sp, -16
    sw ra, 12(sp)

    li a0, 40

    li a1, 88
    jal draw_light_off

    li a1, 136
    jal draw_light_off

    li a1, 112
    la a2, yellow_color
    jal draw_light

    lw ra, 12(sp)
    addi sp, sp, 16
    ret


draw_ew_green:
    addi sp, sp, -16
    sw ra, 12(sp)

    li a0, 40

    li a1, 88
    jal draw_light_off

    li a1, 112
    jal draw_light_off

    li a1, 136
    la a2, green_color
    jal draw_light

    lw ra, 12(sp)
    addi sp, sp, 16
    ret


# ============================================================
# Draw a 16 x 16 light
#
# Inputs:
# a0 = X coordinate
# a1 = Y coordinate
# a2 = Address of color value
# ============================================================

draw_light:
    lw t0, 0(a2)          # Load color value
    li t1, 16             # Light width and height
    li t2, 0              # Row counter
    lw t3, display_base   # Bitmap Display base address


draw_loop_row:
    li t4, 0              # Column counter


draw_loop_column:
    add t5, a1, t2        # Current Y = starting Y + row
    slli t5, t5, 6        # Y * 64 logical units per row

    add t5, t5, a0        # Add starting X
    add t5, t5, t4        # Add current column

    slli t5, t5, 2        # Multiply by 4 bytes per pixel
    add t5, t3, t5        # Calculate final memory address

    sw t0, 0(t5)          # Draw pixel

    addi t4, t4, 1
    blt t4, t1, draw_loop_column

    addi t2, t2, 1
    blt t2, t1, draw_loop_row

    ret


# Draw a black 16 x 16 block to turn a light off
draw_light_off:
    la a2, off_color
    j draw_light


# ============================================================
# Software delay functions
# ============================================================

delay_green:
    mv t0, s0
    j delay_loop


delay_yellow:
    mv t0, s1


delay_loop:
    addi t0, t0, -1
    bnez t0, delay_loop
    ret
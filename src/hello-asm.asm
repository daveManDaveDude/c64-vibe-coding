BasicUpstart2(start)

.label VIC_BANK_SELECT = $dd00
.label SCREEN_RAM = $0400
.label SPRITE_POINTERS = SCREEN_RAM + $03f8
.label COLOR_RAM = $d800
.label BORDER_COLOR = $d020
.label BACKGROUND_COLOR = $d021
.label RASTER = $d012
.label VIC_CTRL1 = $d011
.label VIC_CTRL2 = $d016
.label MEMORY_SETUP = $d018
.label SPRITE_ENABLE = $d015
.label SPRITE_X_MSB = $d010
.label SPRITE_PRIORITY = $d01b
.label SPRITE_MULTICOLOR = $d01c
.label SPRITE_X_EXPAND = $d01d
.label SPRITE_Y_EXPAND = $d017
.label JOYSTICK_PORT_2 = $dc00
.label SPRITE0_X = $d000
.label SPRITE0_Y = $d001
.label SPRITE1_X = $d002
.label SPRITE1_Y = $d003
.label SPRITE2_X = $d004
.label SPRITE2_Y = $d005
.label SPRITE3_X = $d006
.label SPRITE3_Y = $d007
.label SPRITE4_X = $d008
.label SPRITE4_Y = $d009
.label SPRITE5_X = $d00a
.label SPRITE5_Y = $d00b
.label SPRITE6_X = $d00c
.label SPRITE6_Y = $d00d
.label SPRITE7_X = $d00e
.label SPRITE7_Y = $d00f
.label SPRITE_MULTICOLOR_0 = $d025
.label SPRITE_MULTICOLOR_1 = $d026
.label SPRITE0_COLOR = $d027
.label SPRITE1_COLOR = $d028
.label SPRITE2_COLOR = $d029
.label SPRITE3_COLOR = $d02a
.label SPRITE4_COLOR = $d02b
.label SPRITE5_COLOR = $d02c
.label SPRITE6_COLOR = $d02d
.label SPRITE7_COLOR = $d02e

.label HUD_TEXT_COLOR = $01
.label PLAYFIELD_TEXT_COLOR = $0e
.label FORMATION_MULTI0_COLOR = $06
.label FORMATION_MULTI1_COLOR = $02
.label FLAGSHIP_COLOR = $07
.label ESCORT_COLOR = $04
.label GRUNT_COLOR = $03
.label HIT_FLASH_COLOR = $01
.label BORDER_BASE_COLOR = $06
.label FORMATION_START_X_LO = $58
.label FORMATION_START_X_HI = $00
.label FORMATION_TOP_Y = 68
.label FORMATION_MID_Y = 92
.label FORMATION_BOTTOM_Y = 116
.label FORMATION_MIN_X_LO = $18
.label FORMATION_MIN_X_HI = $00
.label FORMATION_MAX_X_LO = $1c
.label FORMATION_MAX_X_HI = $01
.label FORMATION_SLOT0_OFFSET = 0
.label FORMATION_SLOT1_OFFSET = 36
.label FORMATION_SLOT2_OFFSET = 0
.label FORMATION_SLOT3_OFFSET = 36
.label FORMATION_SLOT4_OFFSET = 0
.label FORMATION_SLOT5_OFFSET = 36
.label FLAGSHIP_SPRITE0_PTR = $80
.label FLAGSHIP_SPRITE1_PTR = $81
.label FLAGSHIP_SPRITE2_PTR = $82
.label ESCORT_SPRITE0_PTR = $83
.label ESCORT_SPRITE1_PTR = $84
.label ESCORT_SPRITE2_PTR = $85
.label GRUNT_SPRITE0_PTR = $86
.label GRUNT_SPRITE1_PTR = $87
.label GRUNT_SPRITE2_PTR = $88
.label FORMATION_SLOT0_MASK = %00000001
.label FORMATION_SLOT1_MASK = %00001000
.label FORMATION_SLOT2_MASK = %00010000
.label FORMATION_SLOT3_MASK = %00100000
.label FORMATION_SLOT4_MASK = %01000000
.label FORMATION_SLOT5_MASK = %10000000
.label FORMATION_SPRITE_MASK = %11111001
.label FORMATION_MSB_CLEAR_MASK = %00000110
.label PLAYER_COLOR = $0f
.label PLAYER_START_X_LO = $a8
.label PLAYER_START_X_HI = $00
.label PLAYER_Y = 220
.label PLAYER_MIN_X_LO = $18
.label PLAYER_MIN_X_HI = $00
.label PLAYER_MAX_X_LO = $40
.label PLAYER_MAX_X_HI = $01
.label PLAYER_SPRITE_PTR = $89
.label SHOT_COLOR = $01
.label SHOT_SPRITE_PTR = $8a
.label SHOT_START_Y = PLAYER_Y - 12
.label SHOT_SPEED = 10
.label SHOT_MIN_Y = 16
.label SHOT_HIT_LEFT_OFFSET = 8
.label SHOT_HIT_RIGHT_OFFSET = 15
.label SHOT_HIT_BOTTOM_OFFSET = 7
.label FIRE_MASK = %00010000
.label SCORE_FLAGSHIP_LO = $80
.label SCORE_FLAGSHIP_MID = $00
.label SCORE_FLAGSHIP_HI = $00
.label SCORE_ESCORT_LO = $50
.label SCORE_ESCORT_MID = $00
.label SCORE_ESCORT_HI = $00
.label SCORE_GRUNT_LO = $30
.label SCORE_GRUNT_MID = $00
.label SCORE_GRUNT_HI = $00
.label FORMATION_ANIMATION_SHIFT = 5

* = $1000 "Main Program"

start:
  sei
  cld
  jsr init_vic
  jsr clear_screen
  jsr draw_hud
  jsr init_score
  jsr init_formation
  jsr init_player
  jsr init_shot

main_loop:
  jsr wait_frame
  jsr update_effects
  jsr update_player
  jsr update_shot
  jsr update_formation
  jmp main_loop

init_vic:
  lda VIC_BANK_SELECT
  and #%11111100
  ora #%00000011
  sta VIC_BANK_SELECT

  lda #$1b
  sta VIC_CTRL1
  lda #$08
  sta VIC_CTRL2
  lda #$14
  sta MEMORY_SETUP

  lda #$00
  sta BACKGROUND_COLOR
  lda #BORDER_BASE_COLOR
  sta BORDER_COLOR
  rts

clear_screen:
  ldx #$00
clear_loop:
  lda #$20
  sta SCREEN_RAM + $000, x
  sta SCREEN_RAM + $100, x
  sta SCREEN_RAM + $200, x
  sta SCREEN_RAM + $300, x

  lda #PLAYFIELD_TEXT_COLOR
  sta COLOR_RAM + $000, x
  sta COLOR_RAM + $100, x
  sta COLOR_RAM + $200, x
  sta COLOR_RAM + $300, x

  inx
  bne clear_loop
  rts

draw_hud:
  ldx #$00
hud_loop:
  lda hud_row0, x
  beq hud_done
  sta SCREEN_RAM, x
  lda #HUD_TEXT_COLOR
  sta COLOR_RAM, x
  inx
  bne hud_loop
hud_done:
  rts

init_score:
  lda #$00
  sta score_total_lo
  sta score_total_mid
  sta score_total_hi
  sta score_award_lo
  sta score_award_mid
  sta score_award_hi
  rts

init_formation:
  lda #FORMATION_START_X_LO
  sta formation_x_lo
  lda #FORMATION_START_X_HI
  sta formation_x_hi

  lda #FORMATION_TOP_Y
  sta SPRITE0_Y
  sta SPRITE3_Y
  lda #FORMATION_MID_Y
  sta SPRITE4_Y
  sta SPRITE5_Y
  lda #FORMATION_BOTTOM_Y
  sta SPRITE6_Y
  sta SPRITE7_Y

  lda #$01
  sta formation_dir
  sta formation_slot0_alive
  sta formation_slot1_alive
  sta formation_slot2_alive
  sta formation_slot3_alive
  sta formation_slot4_alive
  sta formation_slot5_alive

  lda #$00
  sta formation_frame
  sta SPRITE_X_MSB
  sta SPRITE_PRIORITY
  sta SPRITE_X_EXPAND
  sta SPRITE_Y_EXPAND

  lda #FORMATION_SPRITE_MASK
  sta SPRITE_MULTICOLOR

  lda #FORMATION_MULTI0_COLOR
  sta SPRITE_MULTICOLOR_0
  lda #FORMATION_MULTI1_COLOR
  sta SPRITE_MULTICOLOR_1

  lda #FLAGSHIP_COLOR
  sta SPRITE0_COLOR
  sta SPRITE3_COLOR
  lda #ESCORT_COLOR
  sta SPRITE4_COLOR
  sta SPRITE5_COLOR
  lda #GRUNT_COLOR
  sta SPRITE6_COLOR
  sta SPRITE7_COLOR

  jsr update_formation_animation
  jsr store_formation_x

  lda #FORMATION_SPRITE_MASK
  sta SPRITE_ENABLE
  rts

init_player:
  lda #PLAYER_SPRITE_PTR
  sta SPRITE_POINTERS + 1

  lda #PLAYER_START_X_LO
  sta player_x_lo
  lda #PLAYER_START_X_HI
  sta player_x_hi
  jsr store_player_x

  lda #PLAYER_Y
  sta SPRITE1_Y

  lda #PLAYER_COLOR
  sta SPRITE1_COLOR

  lda SPRITE_ENABLE
  ora #%00000010
  sta SPRITE_ENABLE
  rts

init_shot:
  lda #SHOT_SPRITE_PTR
  sta SPRITE_POINTERS + 2

  lda #SHOT_COLOR
  sta SPRITE2_COLOR

  lda #$00
  sta shot_x_lo
  sta shot_x_hi
  sta shot_y
  sta shot_active
  sta effective_fire
  sta fire_locked
  sta hit_flash_timer
  sta target_x_lo
  sta target_x_hi
  sta target_right_lo
  sta target_right_hi
  sta shot_left_lo
  sta shot_left_hi
  sta shot_right_lo
  sta shot_right_hi

  lda SPRITE_ENABLE
  and #%11111011
  sta SPRITE_ENABLE

  lda SPRITE_X_MSB
  and #%11111011
  sta SPRITE_X_MSB
  rts

wait_frame:
  lda #$ff
wait_for_line_255:
  cmp RASTER
  bne wait_for_line_255
wait_for_next_frame:
  cmp RASTER
  beq wait_for_next_frame
  rts

update_effects:
  lda hit_flash_timer
  beq effects_done

  dec hit_flash_timer
  lda #HIT_FLASH_COLOR
  sta BORDER_COLOR

  lda hit_flash_timer
  bne effects_done

  lda #BORDER_BASE_COLOR
  sta BORDER_COLOR
effects_done:
  rts

update_formation:
  inc formation_frame
  jsr update_formation_animation
  lda formation_frame
  and #$01
  bne formation_done

  lda formation_dir
  bpl formation_move_right

formation_move_left:
  lda formation_x_lo
  bne formation_dec_low
  dec formation_x_hi
formation_dec_low:
  dec formation_x_lo

  lda formation_x_hi
  cmp #FORMATION_MIN_X_HI
  bcc formation_clamp_min
  bne formation_store_x
  lda formation_x_lo
  cmp #FORMATION_MIN_X_LO
  bcs formation_store_x

formation_clamp_min:
  lda #FORMATION_MIN_X_LO
  sta formation_x_lo
  lda #FORMATION_MIN_X_HI
  sta formation_x_hi
  lda #$01
  sta formation_dir
  jmp formation_store_x

formation_move_right:
  inc formation_x_lo
  bne formation_check_max
  inc formation_x_hi

formation_check_max:
  lda formation_x_hi
  cmp #FORMATION_MAX_X_HI
  bcc formation_store_x
  bne formation_clamp_max
  lda formation_x_lo
  cmp #FORMATION_MAX_X_LO
  bcc formation_store_x

formation_clamp_max:
  lda #FORMATION_MAX_X_LO
  sta formation_x_lo
  lda #FORMATION_MAX_X_HI
  sta formation_x_hi
  lda #$ff
  sta formation_dir

formation_store_x:
  jsr store_formation_x

formation_done:
  rts

update_formation_animation:
  lda formation_frame
  .for (var i = 0; i < FORMATION_ANIMATION_SHIFT; i++) {
    lsr
  }
  and #%00000011
  tax

  lda flagship_animation_sequence, x
  sta SPRITE_POINTERS
  sta SPRITE_POINTERS + 3

  lda escort_animation_sequence, x
  sta SPRITE_POINTERS + 4
  sta SPRITE_POINTERS + 5

  lda grunt_animation_sequence, x
  sta SPRITE_POINTERS + 6
  sta SPRITE_POINTERS + 7
  rts

update_player:
  jsr read_player_input
  lda effective_left
  bne player_move_left_update

  lda effective_right
  bne player_move_right_update
  jmp handle_fire_input

player_move_left_update:
  jsr player_move_left
  jmp handle_fire_input

player_move_right_update:
  jsr player_move_right

handle_fire_input:
  lda effective_fire
  beq fire_released

  lda fire_locked
  bne fire_done

  lda #$01
  sta fire_locked

  lda shot_active
  bne fire_done

  jsr spawn_player_shot
fire_done:
  rts

fire_released:
  lda #$00
  sta fire_locked
  rts

read_player_input:
  lda JOYSTICK_PORT_2
  sta joystick_state

  and #%00000100
  beq joystick_left_pressed
  lda #$00
  sta effective_left
  jmp joystick_right_check
joystick_left_pressed:
  lda #$01
  sta effective_left
joystick_right_check:
  lda joystick_state
  and #%00001000
  beq joystick_right_pressed
  lda #$00
  sta effective_right
  jmp joystick_fire_check
joystick_right_pressed:
  lda #$01
  sta effective_right
joystick_fire_check:
  lda joystick_state
  and #FIRE_MASK
  beq joystick_fire_pressed
  lda #$00
  sta effective_fire
  rts
joystick_fire_pressed:
  lda #$01
  sta effective_fire
  rts

update_shot:
  lda shot_active
  beq shot_done

  jsr check_shot_collision
  bcc shot_continue
  jsr deactivate_shot
  rts

shot_continue:
  lda shot_y
  sec
  sbc #SHOT_SPEED
  sta shot_y
  cmp #SHOT_MIN_Y
  bcc shot_remove

  sta SPRITE2_Y
  rts

shot_remove:
  jsr deactivate_shot
shot_done:
  rts

check_shot_collision:
  lda formation_slot0_alive
  beq check_slot1
  lda formation_slot0_x_lo
  sta target_x_lo
  lda formation_slot0_x_hi
  sta target_x_hi
  lda #FORMATION_TOP_Y
  sta target_y
  jsr shot_hits_target
  bcc check_slot1
  jsr destroy_slot0
  sec
  rts

check_slot1:
  lda formation_slot1_alive
  beq check_slot2
  lda formation_slot1_x_lo
  sta target_x_lo
  lda formation_slot1_x_hi
  sta target_x_hi
  lda #FORMATION_TOP_Y
  sta target_y
  jsr shot_hits_target
  bcc check_slot2
  jsr destroy_slot1
  sec
  rts

check_slot2:
  lda formation_slot2_alive
  beq check_slot3
  lda formation_slot2_x_lo
  sta target_x_lo
  lda formation_slot2_x_hi
  sta target_x_hi
  lda #FORMATION_MID_Y
  sta target_y
  jsr shot_hits_target
  bcc check_slot3
  jsr destroy_slot2
  sec
  rts

check_slot3:
  lda formation_slot3_alive
  beq check_slot4
  lda formation_slot3_x_lo
  sta target_x_lo
  lda formation_slot3_x_hi
  sta target_x_hi
  lda #FORMATION_MID_Y
  sta target_y
  jsr shot_hits_target
  bcc check_slot4
  jsr destroy_slot3
  sec
  rts

check_slot4:
  lda formation_slot4_alive
  beq check_slot5
  lda formation_slot4_x_lo
  sta target_x_lo
  lda formation_slot4_x_hi
  sta target_x_hi
  lda #FORMATION_BOTTOM_Y
  sta target_y
  jsr shot_hits_target
  bcc check_slot5
  jsr destroy_slot4
  sec
  rts

check_slot5:
  lda formation_slot5_alive
  beq no_shot_hit
  lda formation_slot5_x_lo
  sta target_x_lo
  lda formation_slot5_x_hi
  sta target_x_hi
  lda #FORMATION_BOTTOM_Y
  sta target_y
  jsr shot_hits_target
  bcc no_shot_hit
  jsr destroy_slot5
  sec
  rts

no_shot_hit:
  clc
  rts

shot_hits_target:
  lda shot_y
  cmp target_y
  bcc check_shot_bottom
  sec
  sbc target_y
  cmp #21
  bcs target_miss

check_shot_bottom:
  lda shot_y
  clc
  adc #SHOT_HIT_BOTTOM_OFFSET
  cmp target_y
  bcc target_miss

  lda shot_x_lo
  clc
  adc #SHOT_HIT_LEFT_OFFSET
  sta shot_left_lo
  lda shot_x_hi
  adc #$00
  sta shot_left_hi

  lda shot_x_lo
  clc
  adc #SHOT_HIT_RIGHT_OFFSET
  sta shot_right_lo
  lda shot_x_hi
  adc #$00
  sta shot_right_hi

  lda shot_right_hi
  cmp target_x_hi
  bcc target_miss
  bne check_target_right_edge
  lda shot_right_lo
  cmp target_x_lo
  bcc target_miss

check_target_right_edge:
  lda target_x_lo
  clc
  adc #23
  sta target_right_lo
  lda target_x_hi
  adc #$00
  sta target_right_hi

  lda target_right_hi
  cmp shot_left_hi
  bcc target_miss
  bne target_hit
  lda target_right_lo
  cmp shot_left_lo
  bcc target_miss

target_hit:
  sec
  rts

target_miss:
  clc
  rts

spawn_player_shot:
  lda player_x_lo
  sta shot_x_lo
  lda player_x_hi
  sta shot_x_hi
  jsr store_shot_x

  lda #SHOT_START_Y
  sta shot_y
  sta SPRITE2_Y

  lda SPRITE_ENABLE
  ora #%00000100
  sta SPRITE_ENABLE

  lda #$01
  sta shot_active
  rts

deactivate_shot:
  lda #$00
  sta shot_active
  sta shot_y

  lda SPRITE_ENABLE
  and #%11111011
  sta SPRITE_ENABLE

  lda SPRITE_X_MSB
  and #%11111011
  sta SPRITE_X_MSB
  rts

destroy_slot0:
  lda #$00
  sta formation_slot0_alive
  lda SPRITE_ENABLE
  and #%11111110
  sta SPRITE_ENABLE
  jmp award_flagship_score

destroy_slot1:
  lda #$00
  sta formation_slot1_alive
  lda SPRITE_ENABLE
  and #%11110111
  sta SPRITE_ENABLE
  jmp award_flagship_score

destroy_slot2:
  lda #$00
  sta formation_slot2_alive
  lda SPRITE_ENABLE
  and #%11101111
  sta SPRITE_ENABLE
  jmp award_escort_score

destroy_slot3:
  lda #$00
  sta formation_slot3_alive
  lda SPRITE_ENABLE
  and #%11011111
  sta SPRITE_ENABLE
  jmp award_escort_score

destroy_slot4:
  lda #$00
  sta formation_slot4_alive
  lda SPRITE_ENABLE
  and #%10111111
  sta SPRITE_ENABLE
  jmp award_grunt_score

destroy_slot5:
  lda #$00
  sta formation_slot5_alive
  lda SPRITE_ENABLE
  and #%01111111
  sta SPRITE_ENABLE
  jmp award_grunt_score

award_flagship_score:
  lda #SCORE_FLAGSHIP_LO
  sta score_award_lo
  lda #SCORE_FLAGSHIP_MID
  sta score_award_mid
  lda #SCORE_FLAGSHIP_HI
  sta score_award_hi
  jsr add_score_award
  jmp start_hit_flash

award_escort_score:
  lda #SCORE_ESCORT_LO
  sta score_award_lo
  lda #SCORE_ESCORT_MID
  sta score_award_mid
  lda #SCORE_ESCORT_HI
  sta score_award_hi
  jsr add_score_award
  jmp start_hit_flash

award_grunt_score:
  lda #SCORE_GRUNT_LO
  sta score_award_lo
  lda #SCORE_GRUNT_MID
  sta score_award_mid
  lda #SCORE_GRUNT_HI
  sta score_award_hi
  jsr add_score_award
  jmp start_hit_flash

add_score_award:
  sed
  clc
  lda score_total_lo
  adc score_award_lo
  sta score_total_lo
  lda score_total_mid
  adc score_award_mid
  sta score_total_mid
  lda score_total_hi
  adc score_award_hi
  sta score_total_hi
  cld
  rts

start_hit_flash:
  lda #$04
  sta hit_flash_timer
  lda #HIT_FLASH_COLOR
  sta BORDER_COLOR
  rts

player_move_left:
  lda player_x_lo
  bne player_dec_low
  dec player_x_hi
player_dec_low:
  dec player_x_lo

  lda player_x_hi
  cmp #PLAYER_MIN_X_HI
  bcc player_clamp_min
  bne player_store_x
  lda player_x_lo
  cmp #PLAYER_MIN_X_LO
  bcc player_clamp_min
  jmp player_store_x

player_clamp_min:
  lda #PLAYER_MIN_X_LO
  sta player_x_lo
  lda #PLAYER_MIN_X_HI
  sta player_x_hi
  jmp player_store_x

player_move_right:
  inc player_x_lo
  bne player_check_max
  inc player_x_hi

player_check_max:
  lda player_x_hi
  cmp #PLAYER_MAX_X_HI
  bcc player_store_x
  bne player_clamp_max
  lda player_x_lo
  cmp #PLAYER_MAX_X_LO
  bcc player_store_x

player_clamp_max:
  lda #PLAYER_MAX_X_LO
  sta player_x_lo
  lda #PLAYER_MAX_X_HI
  sta player_x_hi

player_store_x:
  jsr store_player_x
  rts

store_formation_x:
  lda formation_x_lo
  clc
  adc #FORMATION_SLOT0_OFFSET
  sta formation_slot0_x_lo
  sta SPRITE0_X
  lda formation_x_hi
  adc #$00
  sta formation_slot0_x_hi

  lda formation_x_lo
  clc
  adc #FORMATION_SLOT1_OFFSET
  sta formation_slot1_x_lo
  sta SPRITE3_X
  lda formation_x_hi
  adc #$00
  sta formation_slot1_x_hi

  lda formation_x_lo
  clc
  adc #FORMATION_SLOT2_OFFSET
  sta formation_slot2_x_lo
  sta SPRITE4_X
  lda formation_x_hi
  adc #$00
  sta formation_slot2_x_hi

  lda formation_x_lo
  clc
  adc #FORMATION_SLOT3_OFFSET
  sta formation_slot3_x_lo
  sta SPRITE5_X
  lda formation_x_hi
  adc #$00
  sta formation_slot3_x_hi

  lda formation_x_lo
  clc
  adc #FORMATION_SLOT4_OFFSET
  sta formation_slot4_x_lo
  sta SPRITE6_X
  lda formation_x_hi
  adc #$00
  sta formation_slot4_x_hi

  lda formation_x_lo
  clc
  adc #FORMATION_SLOT5_OFFSET
  sta formation_slot5_x_lo
  sta SPRITE7_X
  lda formation_x_hi
  adc #$00
  sta formation_slot5_x_hi

  lda SPRITE_X_MSB
  and #FORMATION_MSB_CLEAR_MASK
  ldx formation_slot0_x_hi
  beq formation_slot0_msb_done
  ora #FORMATION_SLOT0_MASK
formation_slot0_msb_done:
  ldx formation_slot1_x_hi
  beq formation_slot1_msb_done
  ora #FORMATION_SLOT1_MASK
formation_slot1_msb_done:
  ldx formation_slot2_x_hi
  beq formation_slot2_msb_done
  ora #FORMATION_SLOT2_MASK
formation_slot2_msb_done:
  ldx formation_slot3_x_hi
  beq formation_slot3_msb_done
  ora #FORMATION_SLOT3_MASK
formation_slot3_msb_done:
  ldx formation_slot4_x_hi
  beq formation_slot4_msb_done
  ora #FORMATION_SLOT4_MASK
formation_slot4_msb_done:
  ldx formation_slot5_x_hi
  beq formation_slot5_msb_done
  ora #FORMATION_SLOT5_MASK
formation_slot5_msb_done:
  sta SPRITE_X_MSB
  rts

store_player_x:
  lda player_x_lo
  sta SPRITE1_X
  lda SPRITE_X_MSB
  and #%11111101
  ldx player_x_hi
  beq player_store_x_done
  ora #%00000010
player_store_x_done:
  sta SPRITE_X_MSB
  rts

store_shot_x:
  lda shot_x_lo
  sta SPRITE2_X
  lda SPRITE_X_MSB
  and #%11111011
  ldx shot_x_hi
  beq shot_store_x_done
  ora #%00000100
shot_store_x_done:
  sta SPRITE_X_MSB
  rts

formation_x_lo:
  .byte FORMATION_START_X_LO
formation_x_hi:
  .byte FORMATION_START_X_HI
formation_dir:
  .byte $01
formation_frame:
  .byte $00
formation_slot0_x_lo:
  .byte FORMATION_START_X_LO + FORMATION_SLOT0_OFFSET
formation_slot0_x_hi:
  .byte FORMATION_START_X_HI
formation_slot1_x_lo:
  .byte FORMATION_START_X_LO + FORMATION_SLOT1_OFFSET
formation_slot1_x_hi:
  .byte FORMATION_START_X_HI
formation_slot2_x_lo:
  .byte FORMATION_START_X_LO + FORMATION_SLOT2_OFFSET
formation_slot2_x_hi:
  .byte FORMATION_START_X_HI
formation_slot3_x_lo:
  .byte FORMATION_START_X_LO + FORMATION_SLOT3_OFFSET
formation_slot3_x_hi:
  .byte FORMATION_START_X_HI
formation_slot4_x_lo:
  .byte FORMATION_START_X_LO + FORMATION_SLOT4_OFFSET
formation_slot4_x_hi:
  .byte FORMATION_START_X_HI
formation_slot5_x_lo:
  .byte FORMATION_START_X_LO + FORMATION_SLOT5_OFFSET
formation_slot5_x_hi:
  .byte FORMATION_START_X_HI
formation_slot0_alive:
  .byte $01
formation_slot1_alive:
  .byte $01
formation_slot2_alive:
  .byte $01
formation_slot3_alive:
  .byte $01
formation_slot4_alive:
  .byte $01
formation_slot5_alive:
  .byte $01
player_x_lo:
  .byte PLAYER_START_X_LO
player_x_hi:
  .byte PLAYER_START_X_HI
shot_x_lo:
  .byte $00
shot_x_hi:
  .byte $00
shot_y:
  .byte $00
shot_active:
  .byte $00
effective_left:
  .byte $00
effective_right:
  .byte $00
effective_fire:
  .byte $00
fire_locked:
  .byte $00
hit_flash_timer:
  .byte $00
joystick_state:
  .byte $00
target_x_lo:
  .byte $00
target_x_hi:
  .byte $00
target_y:
  .byte $00
target_right_lo:
  .byte $00
target_right_hi:
  .byte $00
shot_left_lo:
  .byte $00
shot_left_hi:
  .byte $00
shot_right_lo:
  .byte $00
shot_right_hi:
  .byte $00
score_total_lo:
  .byte $00
score_total_mid:
  .byte $00
score_total_hi:
  .byte $00
score_award_lo:
  .byte $00
score_award_mid:
  .byte $00
score_award_hi:
  .byte $00

hud_row0:
  .byte 19,3,15,18,5,32,48,48,48,48,32,32,32,32,32,32,32,32,32,12,9,22,5,19,32,51,0

flagship_animation_sequence:
  .byte FLAGSHIP_SPRITE0_PTR,FLAGSHIP_SPRITE1_PTR,FLAGSHIP_SPRITE0_PTR,FLAGSHIP_SPRITE1_PTR
escort_animation_sequence:
  .byte ESCORT_SPRITE0_PTR,ESCORT_SPRITE1_PTR,ESCORT_SPRITE0_PTR,ESCORT_SPRITE1_PTR
grunt_animation_sequence:
  .byte GRUNT_SPRITE0_PTR,GRUNT_SPRITE1_PTR,GRUNT_SPRITE0_PTR,GRUNT_SPRITE1_PTR

* = $2000 "Enemy Sprites"

.import binary "generated_enemy_sprites.bin"

* = $2240 "Player Sprite"

player_sprite:
  .byte $00,$00,$00
  .byte $00,$00,$00
  .byte $00,$00,$00
  .byte $00,$18,$00
  .byte $00,$3c,$00
  .byte $00,$7e,$00
  .byte $00,$ff,$00
  .byte $01,$ff,$80
  .byte $03,$ff,$c0
  .byte $07,$ff,$e0
  .byte $0f,$ff,$f0
  .byte $1f,$ff,$f8
  .byte $3f,$ff,$fc
  .byte $7f,$ff,$fe
  .byte $ff,$ff,$ff
  .byte $1f,$ff,$f8
  .byte $0f,$ff,$f0
  .byte $0c,$66,$30
  .byte $18,$00,$18
  .byte $30,$00,$0c
  .byte $60,$00,$06
  .byte $00

* = $2280 "Shot Sprite"

shot_sprite:
  .byte $00,$ff,$00
  .byte $00,$ff,$00
  .byte $00,$ff,$00
  .byte $00,$ff,$00
  .byte $00,$ff,$00
  .byte $00,$ff,$00
  .byte $00,$ff,$00
  .byte $00,$ff,$00
  .byte $00,$00,$00
  .byte $00,$00,$00
  .byte $00,$00,$00
  .byte $00,$00,$00
  .byte $00,$00,$00
  .byte $00,$00,$00
  .byte $00,$00,$00
  .byte $00,$00,$00
  .byte $00,$00,$00
  .byte $00,$00,$00
  .byte $00,$00,$00
  .byte $00,$00,$00
  .byte $00,$00,$00
  .byte $00

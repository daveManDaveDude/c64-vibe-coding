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
.label FLAGSHIP_DIVE_COLOR = $08
.label ESCORT_DIVE_COLOR = $06
.label GRUNT_DIVE_COLOR = $0b
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
.label PLAYER_SPRITE_PTR = $c0
.label SHOT_COLOR = $01
.label SHOT_SPRITE_PTR = $c1
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
.label DIVE_SLOT_NONE = $ff
.label DIVE_DIRECTION_LEFT = $00
.label DIVE_DIRECTION_RIGHT = $01
.label DIVE_START_DELAY = 80
.label DIVE_RETRY_DELAY = 32
.label DIVE_PHASE0_TICKS = 18
.label DIVE_PHASE1_TICKS = 20
.label DIVE_EXIT_Y = 246
.label DIVE_ANIMATION_RATE = 4
.label DIVE_ANIMATION_MAX_FRAME = 9

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
  jsr init_dive_attack

main_loop:
  jsr wait_frame
  jsr update_effects
  jsr update_player
  jsr update_shot
  jsr update_formation
  jsr update_dive_attack
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

init_dive_attack:
  lda #$00
  sta dive_active
  sta dive_phase
  sta dive_timer
  sta dive_direction
  sta dive_column_toggle
  sta dive_anim_frame
  sta dive_anim_tick
  sta dive_sprite_pointer
  sta dive_sprite_color
  sta dive_x_lo
  sta dive_x_hi
  sta dive_y

  lda #DIVE_SLOT_NONE
  sta dive_slot

  lda #DIVE_START_DELAY
  sta dive_delay
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

  lda #FLAGSHIP_COLOR
  sta SPRITE0_COLOR
  sta SPRITE3_COLOR
  lda #ESCORT_COLOR
  sta SPRITE4_COLOR
  sta SPRITE5_COLOR
  lda #GRUNT_COLOR
  sta SPRITE6_COLOR
  sta SPRITE7_COLOR
  rts

update_dive_attack:
  lda dive_active
  beq dive_wait_for_launch

  jsr update_dive_animation

  lda dive_phase
  beq dive_phase0_update
  cmp #$01
  beq dive_phase1_update
  jmp dive_phase2_update

dive_wait_for_launch:
  lda dive_delay
  beq dive_try_launch
  dec dive_delay
  rts

dive_try_launch:
  jsr launch_dive_if_possible
  rts

dive_phase0_update:
  jsr move_dive_outward
  jsr steer_dive_toward_player
  inc dive_y
  dec dive_timer
  bne dive_store_position

  lda #$01
  sta dive_phase
  lda #DIVE_PHASE1_TICKS
  sta dive_timer
  jmp dive_store_position

dive_phase1_update:
  jsr sweep_dive_outward_once
  jsr steer_dive_toward_player
  jsr steer_dive_toward_player
  lda dive_y
  clc
  adc #$02
  sta dive_y
  dec dive_timer
  bne dive_store_position

  lda #$02
  sta dive_phase
  jmp dive_store_position

dive_phase2_update:
  jsr steer_dive_toward_player
  jsr steer_dive_toward_player
  lda dive_y
  clc
  adc #$03
  sta dive_y
  cmp #DIVE_EXIT_Y
  bcs finish_dive_return

dive_store_position:
  jsr store_dive_position
  rts

finish_dive_return:
  jsr store_formation_x
  jsr restore_dive_slot_y

  lda #$00
  sta dive_active
  sta dive_phase
  sta dive_timer
  sta dive_anim_frame
  sta dive_anim_tick

  lda #DIVE_SLOT_NONE
  sta dive_slot

  lda #DIVE_START_DELAY
  sta dive_delay
  rts

launch_dive_if_possible:
  lda dive_column_toggle
  beq launch_left_column_first

launch_right_column_first:
  jsr try_launch_slot5
  bcs dive_launch_success
  jsr try_launch_slot3
  bcs dive_launch_success
  jsr try_launch_slot1
  bcs dive_launch_success
  jsr try_launch_slot4
  bcs dive_launch_success
  jsr try_launch_slot2
  bcs dive_launch_success
  jsr try_launch_slot0
  bcs dive_launch_success
  lda #DIVE_RETRY_DELAY
  sta dive_delay
  clc
  rts

launch_left_column_first:
  jsr try_launch_slot4
  bcs dive_launch_success
  jsr try_launch_slot2
  bcs dive_launch_success
  jsr try_launch_slot0
  bcs dive_launch_success
  jsr try_launch_slot5
  bcs dive_launch_success
  jsr try_launch_slot3
  bcs dive_launch_success
  jsr try_launch_slot1
  bcs dive_launch_success
  lda #DIVE_RETRY_DELAY
  sta dive_delay
  clc
  rts

dive_launch_success:
  lda dive_column_toggle
  eor #$01
  sta dive_column_toggle
  sec
  rts

try_launch_slot0:
  lda formation_slot0_alive
  bne launch_slot0
  clc
  rts
launch_slot0:
  lda #$00
  sta dive_slot
  lda formation_slot0_x_lo
  sta dive_x_lo
  lda formation_slot0_x_hi
  sta dive_x_hi
  lda #FORMATION_TOP_Y
  sta dive_y
  lda #DIVE_DIRECTION_LEFT
  sta dive_direction
  jmp begin_dive

try_launch_slot1:
  lda formation_slot1_alive
  bne launch_slot1
  clc
  rts
launch_slot1:
  lda #$01
  sta dive_slot
  lda formation_slot1_x_lo
  sta dive_x_lo
  lda formation_slot1_x_hi
  sta dive_x_hi
  lda #FORMATION_TOP_Y
  sta dive_y
  lda #DIVE_DIRECTION_RIGHT
  sta dive_direction
  jmp begin_dive

try_launch_slot2:
  lda formation_slot2_alive
  bne launch_slot2
  clc
  rts
launch_slot2:
  lda #$02
  sta dive_slot
  lda formation_slot2_x_lo
  sta dive_x_lo
  lda formation_slot2_x_hi
  sta dive_x_hi
  lda #FORMATION_MID_Y
  sta dive_y
  lda #DIVE_DIRECTION_LEFT
  sta dive_direction
  jmp begin_dive

try_launch_slot3:
  lda formation_slot3_alive
  bne launch_slot3
  clc
  rts
launch_slot3:
  lda #$03
  sta dive_slot
  lda formation_slot3_x_lo
  sta dive_x_lo
  lda formation_slot3_x_hi
  sta dive_x_hi
  lda #FORMATION_MID_Y
  sta dive_y
  lda #DIVE_DIRECTION_RIGHT
  sta dive_direction
  jmp begin_dive

try_launch_slot4:
  lda formation_slot4_alive
  bne launch_slot4
  clc
  rts
launch_slot4:
  lda #$04
  sta dive_slot
  lda formation_slot4_x_lo
  sta dive_x_lo
  lda formation_slot4_x_hi
  sta dive_x_hi
  lda #FORMATION_BOTTOM_Y
  sta dive_y
  lda #DIVE_DIRECTION_LEFT
  sta dive_direction
  jmp begin_dive

try_launch_slot5:
  lda formation_slot5_alive
  bne launch_slot5
  clc
  rts
launch_slot5:
  lda #$05
  sta dive_slot
  lda formation_slot5_x_lo
  sta dive_x_lo
  lda formation_slot5_x_hi
  sta dive_x_hi
  lda #FORMATION_BOTTOM_Y
  sta dive_y
  lda #DIVE_DIRECTION_RIGHT
  sta dive_direction
  jmp begin_dive

begin_dive:
  lda #$01
  sta dive_active
  lda #$00
  sta dive_phase
  sta dive_anim_frame
  sta dive_anim_tick
  lda #DIVE_PHASE0_TICKS
  sta dive_timer
  lda #DIVE_START_DELAY
  sta dive_delay
  jsr store_dive_position
  sec
  rts

update_dive_animation:
  lda dive_anim_frame
  cmp #DIVE_ANIMATION_MAX_FRAME
  bcs dive_animation_done

  inc dive_anim_tick
  lda dive_anim_tick
  cmp #DIVE_ANIMATION_RATE
  bcc dive_animation_done

  lda #$00
  sta dive_anim_tick
  inc dive_anim_frame
dive_animation_done:
  rts

move_dive_outward:
  lda dive_direction
  beq dive_outward_left
  jsr dive_move_right_one
  jsr dive_move_right_one
  jsr dive_move_right_one
  rts

dive_outward_left:
  jsr dive_move_left_one
  jsr dive_move_left_one
  jsr dive_move_left_one
  rts

sweep_dive_outward_once:
  lda dive_direction
  beq sweep_dive_left_once
  jsr dive_move_right_one
  rts

sweep_dive_left_once:
  jsr dive_move_left_one
  rts

steer_dive_toward_player:
  lda dive_x_hi
  cmp player_x_hi
  bcc steer_dive_right
  bne steer_dive_left

  lda dive_x_lo
  cmp player_x_lo
  bcc steer_dive_right
  beq steer_dive_done

steer_dive_left:
  jsr dive_move_left_one
  rts

steer_dive_right:
  jsr dive_move_right_one

steer_dive_done:
  rts

dive_move_left_one:
  lda dive_x_lo
  bne dive_dec_low
  dec dive_x_hi
dive_dec_low:
  dec dive_x_lo

  lda dive_x_hi
  cmp #PLAYER_MIN_X_HI
  bcc dive_clamp_min
  bne dive_move_left_done
  lda dive_x_lo
  cmp #PLAYER_MIN_X_LO
  bcs dive_move_left_done

dive_clamp_min:
  lda #PLAYER_MIN_X_LO
  sta dive_x_lo
  lda #PLAYER_MIN_X_HI
  sta dive_x_hi
dive_move_left_done:
  rts

dive_move_right_one:
  inc dive_x_lo
  bne dive_check_max
  inc dive_x_hi

dive_check_max:
  lda dive_x_hi
  cmp #PLAYER_MAX_X_HI
  bcc dive_move_right_done
  bne dive_clamp_max
  lda dive_x_lo
  cmp #PLAYER_MAX_X_LO
  bcc dive_move_right_done

dive_clamp_max:
  lda #PLAYER_MAX_X_LO
  sta dive_x_lo
  lda #PLAYER_MAX_X_HI
  sta dive_x_hi
dive_move_right_done:
  rts

store_dive_position:
  jsr select_dive_animation_frame
  lda dive_slot
  beq store_dive_position_slot0
  cmp #$01
  beq store_dive_position_slot1
  cmp #$02
  beq store_dive_position_slot2
  cmp #$03
  beq store_dive_position_slot3
  cmp #$04
  beq store_dive_position_slot4
  cmp #$05
  beq store_dive_position_slot5
  rts

store_dive_position_slot0:
  jmp store_dive_slot0

store_dive_position_slot1:
  jmp store_dive_slot1

store_dive_position_slot2:
  jmp store_dive_slot2

store_dive_position_slot3:
  jmp store_dive_slot3

store_dive_position_slot4:
  jmp store_dive_slot4

store_dive_position_slot5:
  jmp store_dive_slot5

store_dive_slot0:
  lda dive_x_lo
  sta SPRITE0_X
  lda dive_y
  sta SPRITE0_Y
  lda SPRITE_X_MSB
  and #%11111110
  ldx dive_x_hi
  beq store_dive_slot0_done
  ora #FORMATION_SLOT0_MASK
store_dive_slot0_done:
  sta SPRITE_X_MSB
  lda dive_sprite_pointer
  sta SPRITE_POINTERS
  lda dive_sprite_color
  sta SPRITE0_COLOR
  rts

store_dive_slot1:
  lda dive_x_lo
  sta SPRITE3_X
  lda dive_y
  sta SPRITE3_Y
  lda SPRITE_X_MSB
  and #%11110111
  ldx dive_x_hi
  beq store_dive_slot1_done
  ora #FORMATION_SLOT1_MASK
store_dive_slot1_done:
  sta SPRITE_X_MSB
  lda dive_sprite_pointer
  sta SPRITE_POINTERS + 3
  lda dive_sprite_color
  sta SPRITE3_COLOR
  rts

store_dive_slot2:
  lda dive_x_lo
  sta SPRITE4_X
  lda dive_y
  sta SPRITE4_Y
  lda SPRITE_X_MSB
  and #%11101111
  ldx dive_x_hi
  beq store_dive_slot2_done
  ora #FORMATION_SLOT2_MASK
store_dive_slot2_done:
  sta SPRITE_X_MSB
  lda dive_sprite_pointer
  sta SPRITE_POINTERS + 4
  lda dive_sprite_color
  sta SPRITE4_COLOR
  rts

store_dive_slot3:
  lda dive_x_lo
  sta SPRITE5_X
  lda dive_y
  sta SPRITE5_Y
  lda SPRITE_X_MSB
  and #%11011111
  ldx dive_x_hi
  beq store_dive_slot3_done
  ora #FORMATION_SLOT3_MASK
store_dive_slot3_done:
  sta SPRITE_X_MSB
  lda dive_sprite_pointer
  sta SPRITE_POINTERS + 5
  lda dive_sprite_color
  sta SPRITE5_COLOR
  rts

store_dive_slot4:
  lda dive_x_lo
  sta SPRITE6_X
  lda dive_y
  sta SPRITE6_Y
  lda SPRITE_X_MSB
  and #%10111111
  ldx dive_x_hi
  beq store_dive_slot4_done
  ora #FORMATION_SLOT4_MASK
store_dive_slot4_done:
  sta SPRITE_X_MSB
  lda dive_sprite_pointer
  sta SPRITE_POINTERS + 6
  lda dive_sprite_color
  sta SPRITE6_COLOR
  rts

store_dive_slot5:
  lda dive_x_lo
  sta SPRITE7_X
  lda dive_y
  sta SPRITE7_Y
  lda SPRITE_X_MSB
  and #%01111111
  ldx dive_x_hi
  beq store_dive_slot5_done
  ora #FORMATION_SLOT5_MASK
store_dive_slot5_done:
  sta SPRITE_X_MSB
  lda dive_sprite_pointer
  sta SPRITE_POINTERS + 7
  lda dive_sprite_color
  sta SPRITE7_COLOR
  rts

select_dive_animation_frame:
  ldx dive_anim_frame
  lda dive_slot
  cmp #$02
  bcc select_flagship_dive_animation
  cmp #$04
  bcc select_escort_dive_animation

  lda grunt_dive_animation_sequence, x
  sta dive_sprite_pointer
  lda grunt_dive_animation_colors, x
  sta dive_sprite_color
  rts

select_escort_dive_animation:
  lda escort_dive_animation_sequence, x
  sta dive_sprite_pointer
  lda escort_dive_animation_colors, x
  sta dive_sprite_color
  rts

select_flagship_dive_animation:
  lda flagship_dive_animation_sequence, x
  sta dive_sprite_pointer
  lda flagship_dive_animation_colors, x
  sta dive_sprite_color
  rts

restore_dive_slot_y:
  lda dive_slot
  beq restore_dive_slot0_y
  cmp #$01
  beq restore_dive_slot1_y
  cmp #$02
  beq restore_dive_slot2_y
  cmp #$03
  beq restore_dive_slot3_y
  cmp #$04
  beq restore_dive_slot4_y
  cmp #$05
  beq restore_dive_slot5_y
  rts

restore_dive_slot0_y:
  lda #FORMATION_TOP_Y
  sta SPRITE0_Y
  rts

restore_dive_slot1_y:
  lda #FORMATION_TOP_Y
  sta SPRITE3_Y
  rts

restore_dive_slot2_y:
  lda #FORMATION_MID_Y
  sta SPRITE4_Y
  rts

restore_dive_slot3_y:
  lda #FORMATION_MID_Y
  sta SPRITE5_Y
  rts

restore_dive_slot4_y:
  lda #FORMATION_BOTTOM_Y
  sta SPRITE6_Y
  rts

restore_dive_slot5_y:
  lda #FORMATION_BOTTOM_Y
  sta SPRITE7_Y
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
  lda dive_active
  beq check_slot0
  lda dive_x_lo
  sta target_x_lo
  lda dive_x_hi
  sta target_x_hi
  lda dive_y
  sta target_y
  jsr shot_hits_target
  bcc check_slot0
  jsr destroy_current_dive_slot
  sec
  rts

check_slot0:
  lda dive_active
  beq check_slot0_alive
  lda dive_slot
  beq check_slot1
check_slot0_alive:
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
  lda dive_active
  beq check_slot1_alive
  lda dive_slot
  cmp #$01
  beq check_slot2
check_slot1_alive:
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
  lda dive_active
  beq check_slot2_alive
  lda dive_slot
  cmp #$02
  beq check_slot3
check_slot2_alive:
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
  lda dive_active
  beq check_slot3_alive
  lda dive_slot
  cmp #$03
  beq check_slot4
check_slot3_alive:
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
  lda dive_active
  beq check_slot4_alive
  lda dive_slot
  cmp #$04
  beq check_slot5
check_slot4_alive:
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
  lda dive_active
  beq check_slot5_alive
  lda dive_slot
  cmp #$05
  beq no_shot_hit
check_slot5_alive:
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

destroy_current_dive_slot:
  lda dive_slot
  beq destroy_current_dive_slot0
  cmp #$01
  beq destroy_current_dive_slot1
  cmp #$02
  beq destroy_current_dive_slot2
  cmp #$03
  beq destroy_current_dive_slot3
  cmp #$04
  beq destroy_current_dive_slot4
  cmp #$05
  beq destroy_current_dive_slot5
  rts

destroy_current_dive_slot0:
  jmp destroy_slot0

destroy_current_dive_slot1:
  jmp destroy_slot1

destroy_current_dive_slot2:
  jmp destroy_slot2

destroy_current_dive_slot3:
  jmp destroy_slot3

destroy_current_dive_slot4:
  jmp destroy_slot4

destroy_current_dive_slot5:
  jmp destroy_slot5

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
  lda #$00
  jsr clear_dive_if_slot
  lda SPRITE_ENABLE
  and #%11111110
  sta SPRITE_ENABLE
  jmp award_flagship_score

destroy_slot1:
  lda #$00
  sta formation_slot1_alive
  lda #$01
  jsr clear_dive_if_slot
  lda SPRITE_ENABLE
  and #%11110111
  sta SPRITE_ENABLE
  jmp award_flagship_score

destroy_slot2:
  lda #$00
  sta formation_slot2_alive
  lda #$02
  jsr clear_dive_if_slot
  lda SPRITE_ENABLE
  and #%11101111
  sta SPRITE_ENABLE
  jmp award_escort_score

destroy_slot3:
  lda #$00
  sta formation_slot3_alive
  lda #$03
  jsr clear_dive_if_slot
  lda SPRITE_ENABLE
  and #%11011111
  sta SPRITE_ENABLE
  jmp award_escort_score

destroy_slot4:
  lda #$00
  sta formation_slot4_alive
  lda #$04
  jsr clear_dive_if_slot
  lda SPRITE_ENABLE
  and #%10111111
  sta SPRITE_ENABLE
  jmp award_grunt_score

destroy_slot5:
  lda #$00
  sta formation_slot5_alive
  lda #$05
  jsr clear_dive_if_slot
  lda SPRITE_ENABLE
  and #%01111111
  sta SPRITE_ENABLE
  jmp award_grunt_score

clear_dive_if_slot:
  tax
  lda dive_active
  beq clear_dive_done
  cpx dive_slot
  bne clear_dive_done

  lda #$00
  sta dive_active
  sta dive_phase
  sta dive_timer

  lda #DIVE_SLOT_NONE
  sta dive_slot

  lda #DIVE_START_DELAY
  sta dive_delay
clear_dive_done:
  rts

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
dive_active:
  .byte $00
dive_slot:
  .byte DIVE_SLOT_NONE
dive_phase:
  .byte $00
dive_timer:
  .byte $00
dive_direction:
  .byte $00
dive_delay:
  .byte DIVE_START_DELAY
dive_column_toggle:
  .byte $00
dive_anim_frame:
  .byte $00
dive_anim_tick:
  .byte $00
dive_sprite_pointer:
  .byte $00
dive_sprite_color:
  .byte $00
dive_x_lo:
  .byte $00
dive_x_hi:
  .byte $00
dive_y:
  .byte $00
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
flagship_dive_animation_sequence:
  .byte FLAGSHIP_SPRITE2_PTR,$89,$8a,$8b,$8c,$8d,$8e,$8f,$90,$91
flagship_dive_animation_colors:
  .byte FLAGSHIP_COLOR,FLAGSHIP_DIVE_COLOR,FLAGSHIP_DIVE_COLOR,FLAGSHIP_DIVE_COLOR,FLAGSHIP_DIVE_COLOR,FLAGSHIP_DIVE_COLOR,FLAGSHIP_DIVE_COLOR,FLAGSHIP_DIVE_COLOR,FLAGSHIP_DIVE_COLOR,FLAGSHIP_DIVE_COLOR
escort_dive_animation_sequence:
  .byte FLAGSHIP_SPRITE0_PTR,$92,$93,$94,$95,$96,$97,$98,$99,$9a
escort_dive_animation_colors:
  .byte FLAGSHIP_COLOR,ESCORT_DIVE_COLOR,ESCORT_DIVE_COLOR,ESCORT_DIVE_COLOR,ESCORT_DIVE_COLOR,ESCORT_DIVE_COLOR,ESCORT_DIVE_COLOR,ESCORT_DIVE_COLOR,ESCORT_DIVE_COLOR,ESCORT_DIVE_COLOR
grunt_dive_animation_sequence:
  .byte GRUNT_SPRITE2_PTR,$9b,$9c,$9d,$9e,$9f,$a0,$a1,$a2,$a3
grunt_dive_animation_colors:
  .byte GRUNT_COLOR,GRUNT_DIVE_COLOR,GRUNT_DIVE_COLOR,GRUNT_DIVE_COLOR,GRUNT_DIVE_COLOR,GRUNT_DIVE_COLOR,GRUNT_DIVE_COLOR,GRUNT_DIVE_COLOR,GRUNT_DIVE_COLOR,GRUNT_DIVE_COLOR

* = $2000 "Arcade Sprites"

.import binary "generated_arcade_sprites.bin"

* = $3000 "Player Sprite"

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

* = $3040 "Shot Sprite"

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

BasicUpstart2(start)

.label VIC_BANK_SELECT = $dd00
.label SCREEN_RAM = $0400
.label SPRITE_POINTERS = SCREEN_RAM + $03f8
.label COLOR_RAM = $d800
.label BORDER_COLOR = $d020
.label BACKGROUND_COLOR = $d021
.label RASTER = $d012
.label IRQ_STATUS = $d019
.label IRQ_ENABLE = $d01a
.label IRQ_VECTOR_LO = $0314
.label IRQ_VECTOR_HI = $0315
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
.label CIA1_IRQ_CONTROL = $dc0d
.label CIA2_IRQ_CONTROL = $dd0d
.label CPU_PORT = $01
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
.label SCREEN_PTR = $fb
.label COLOR_PTR = $fd
.label CHARSET_RAM = $3800

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
.label ARCADE_SPRITE_PTR_BASE = $89
.label FLAGSHIP_SPRITE0_PTR = ARCADE_SPRITE_PTR_BASE + 0
.label FLAGSHIP_SPRITE1_PTR = ARCADE_SPRITE_PTR_BASE + 1
.label FLAGSHIP_SPRITE2_PTR = ARCADE_SPRITE_PTR_BASE + 2
.label ESCORT_SPRITE0_PTR = ARCADE_SPRITE_PTR_BASE + 3
.label ESCORT_SPRITE1_PTR = ARCADE_SPRITE_PTR_BASE + 4
.label ESCORT_SPRITE2_PTR = ARCADE_SPRITE_PTR_BASE + 5
.label GRUNT_SPRITE0_PTR = ARCADE_SPRITE_PTR_BASE + 6
.label GRUNT_SPRITE1_PTR = ARCADE_SPRITE_PTR_BASE + 7
.label GRUNT_SPRITE2_PTR = ARCADE_SPRITE_PTR_BASE + 8
.label FORMATION_SLOT0_MASK = %00000001
.label FORMATION_SLOT1_MASK = %00001000
.label FORMATION_SLOT2_MASK = %00010000
.label FORMATION_SLOT3_MASK = %00100000
.label FORMATION_SLOT4_MASK = %01000000
.label FORMATION_SLOT5_MASK = %10000000
.label FORMATION_SPRITE_MASK = %11111001
.label FORMATION_MSB_CLEAR_MASK = %00000110
.label PLAYER_COLOR = $02
.label PLAYER_WHITE_COLOR = $0f
.label PLAYER_CYAN_COLOR = $03
.label PLAYER_START_X_LO = $a8
.label PLAYER_START_X_HI = $00
.label PLAYER_Y = 228
.label PLAYFIELD_LEFT_X_LO = $18
.label PLAYFIELD_LEFT_X_HI = $00
.label PLAYFIELD_TOP_Y = 50
.label PLAYER_MIN_X_LO = $18
.label PLAYER_MIN_X_HI = $00
.label PLAYER_MAX_X_LO = $40
.label PLAYER_MAX_X_HI = $01
.label PLAYER_WHITE_SPRITE_PTR = $c9
.label PLAYER_RED_SPRITE_PTR = $ca
.label PLAYER_CYAN_SPRITE_PTR = $cb
.label SHOT_COLOR = $01
.label SHOT_SPRITE_PTR = $cc
.label SHOT_START_Y = PLAYER_Y - 12
.label SHOT_SPEED = 10
.label SHOT_MIN_Y = 16
.label SHOT_HIT_LEFT_OFFSET = 11
.label SHOT_HIT_RIGHT_OFFSET = 12
.label SHOT_HIT_BOTTOM_OFFSET = 13
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
.label DIVE_ANIMATION_RATE = 1
.label DIVE_ANIMATION_MAX_FRAME = 9
.label DIVE_FIRE_HOLD_TICKS = 10
.label ENEMY_BULLET_LIMIT = 2
.label ENEMY_BULLET_CHAR_BASE = 64
.label ENEMY_BULLET_COLOR = $01
.label ENEMY_BULLET_SPEED = 2
.label ENEMY_BULLET_START_X_OFFSET = 11
.label ENEMY_BULLET_START_Y_OFFSET = 12
.label ENEMY_BULLET_FIRE_COOLDOWN = 28
.label ENEMY_BULLET_FIRE_MIN_Y = 104
.label ENEMY_BULLET_FIRE_MAX_Y = 156
.label ENEMY_BULLET_MAX_Y = 248
.label ENEMY_EXPLOSION_COLOR = $07
.label ENEMY_EXPLOSION_FRAME_TICKS = 6
.label ENEMY_EXPLOSION_SPRITE0_PTR = $d6
.label ENEMY_EXPLOSION_SPRITE1_PTR = $d7
.label ENEMY_EXPLOSION_SPRITE2_PTR = $d8
.label ENEMY_EXPLOSION_SPRITE3_PTR = $d9
.label PLAYER_TOP_SPLIT_RASTER = 40
.label PLAYER_BOTTOM_SPLIT_RASTER = 170
.label RASTER_PHASE_TOP = $00
.label RASTER_PHASE_BOTTOM = $01
.label PLAYER_RESPAWN_DELAY = 40
// Match the visible union of the extracted player ship layers.
.label PLAYER_HIT_TOP_OFFSET = 0
.label PLAYER_HIT_BOTTOM_OFFSET = 15
.label PLAYER_HIT_LEFT_OFFSET = 6
.label PLAYER_HIT_RIGHT_OFFSET = 18
.label PLAYER_HIT_MIN_Y = PLAYER_Y + PLAYER_HIT_TOP_OFFSET
.label PLAYER_HIT_MAX_Y = PLAYER_Y + PLAYER_HIT_BOTTOM_OFFSET + 1
.label DIVE_HIT_BOTTOM_OFFSET = 20
.label DIVE_HIT_RIGHT_OFFSET = 23
.label ENEMY_BULLET_HIT_BOTTOM_OFFSET = 3
.label ENEMY_BULLET_HIT_RIGHT_OFFSET = 1

* = $1000 "Main Program"

start:
  sei
  cld
  jsr init_vic
  jsr init_charset
  jsr clear_screen
  jsr draw_hud
  jsr init_score
  jsr init_formation
  jsr init_player
  jsr init_shot
  jsr init_dive_attack
  jsr init_enemy_fire
  jsr init_raster_irq
  cli

main_loop:
  jsr wait_frame
  jsr update_effects
  jsr update_player
  jsr update_shot
  jsr update_formation
  jsr update_dive_attack
  jsr update_enemy_hit_animations
  jsr update_enemy_fire
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
  lda #$1e
  sta MEMORY_SETUP

  lda #$00
  sta BACKGROUND_COLOR
  lda #BORDER_BASE_COLOR
  sta BORDER_COLOR
  rts

init_charset:
  lda CPU_PORT
  sta cpu_port_backup
  and #%11111011
  sta CPU_PORT

  ldx #$00
copy_charset_loop:
  lda $d000, x
  sta CHARSET_RAM + $000, x
  lda $d100, x
  sta CHARSET_RAM + $100, x
  lda $d200, x
  sta CHARSET_RAM + $200, x
  lda $d300, x
  sta CHARSET_RAM + $300, x
  lda $d400, x
  sta CHARSET_RAM + $400, x
  lda $d500, x
  sta CHARSET_RAM + $500, x
  lda $d600, x
  sta CHARSET_RAM + $600, x
  lda $d700, x
  sta CHARSET_RAM + $700, x
  inx
  bne copy_charset_loop

  lda cpu_port_backup
  sta CPU_PORT

  ldx #$00
copy_enemy_bullet_charset_page0:
  lda enemy_bullet_charset, x
  sta CHARSET_RAM + (ENEMY_BULLET_CHAR_BASE * 8), x
  inx
  bne copy_enemy_bullet_charset_page0

  ldx #$00
copy_enemy_bullet_charset_page1:
  lda enemy_bullet_charset + $100, x
  sta CHARSET_RAM + (ENEMY_BULLET_CHAR_BASE * 8) + $100, x
  inx
  bne copy_enemy_bullet_charset_page1
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
  lda #PLAYER_RED_SPRITE_PTR
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

  lda SPRITE_MULTICOLOR
  and #%11111101
  sta SPRITE_MULTICOLOR

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
  sta dive_fire_hold_timer
  sta dive_x_lo
  sta dive_x_hi
  sta dive_y

  lda #DIVE_SLOT_NONE
  sta dive_slot

  lda #DIVE_START_DELAY
  sta dive_delay
  rts

init_enemy_fire:
  ldx #$00
init_enemy_fire_loop:
  lda #$00
  sta enemy_bullet_active, x
  sta enemy_bullet_x_lo, x
  sta enemy_bullet_x_hi, x
  sta enemy_bullet_y, x
  inx
  cpx #ENEMY_BULLET_LIMIT
  bcc init_enemy_fire_loop

  lda #$00
  sta enemy_fire_cooldown
  sta player_respawn_timer
  sta player_left_lo
  sta player_left_hi
  sta player_right_lo
  sta player_right_hi
  sta enemy_bullet_row
  sta enemy_bullet_col
  sta player_extra_visible
  lda #$00
  sta player_white_slot
  lda #$01
  sta player_cyan_slot
  lda #RASTER_PHASE_TOP
  sta raster_phase
  sta formation_restore_anim_index
  rts

init_raster_irq:
  lda #$7f
  sta CIA1_IRQ_CONTROL
  sta CIA2_IRQ_CONTROL
  lda CIA1_IRQ_CONTROL
  lda CIA2_IRQ_CONTROL

  lda #<raster_irq
  sta IRQ_VECTOR_LO
  lda #>raster_irq
  sta IRQ_VECTOR_HI

  lda VIC_CTRL1
  and #%01111111
  sta VIC_CTRL1
  lda #PLAYER_TOP_SPLIT_RASTER
  sta RASTER

  lda #$01
  sta IRQ_ENABLE
  lda #$01
  sta IRQ_STATUS
  rts

raster_irq:
  lda #$01
  sta IRQ_STATUS
  lda raster_phase
  beq raster_irq_top_phase

  lda #RASTER_PHASE_TOP
  sta raster_phase
  lda #PLAYER_TOP_SPLIT_RASTER
  sta RASTER
  lda #$01
  sta player_extra_visible
  jsr draw_player_extra_layers
  jmp raster_irq_done

raster_irq_top_phase:
  lda #RASTER_PHASE_BOTTOM
  sta raster_phase
  lda #PLAYER_BOTTOM_SPLIT_RASTER
  sta RASTER
  lda #$00
  sta player_extra_visible
  jsr restore_player_extra_slots_for_top

raster_irq_done:
  jmp $ea81

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
  tay

  lda formation_slot0_alive
  beq formation_anim_slot1
  ldx #$00
  jsr slot_reserved_for_player_bottom
  bcs formation_anim_slot1
  lda flagship_animation_sequence, y
  sta SPRITE_POINTERS
  lda #FLAGSHIP_COLOR
  sta SPRITE0_COLOR
formation_anim_slot1:
  lda formation_slot1_alive
  beq formation_anim_slot2
  ldx #$01
  jsr slot_reserved_for_player_bottom
  bcs formation_anim_slot2
  lda flagship_animation_sequence, y
  sta SPRITE_POINTERS + 3
  lda #FLAGSHIP_COLOR
  sta SPRITE3_COLOR
formation_anim_slot2:
  lda formation_slot2_alive
  beq formation_anim_slot3
  ldx #$02
  jsr slot_reserved_for_player_bottom
  bcs formation_anim_slot3
  lda escort_animation_sequence, y
  sta SPRITE_POINTERS + 4
  lda #ESCORT_COLOR
  sta SPRITE4_COLOR
formation_anim_slot3:
  lda formation_slot3_alive
  beq formation_anim_slot4
  ldx #$03
  jsr slot_reserved_for_player_bottom
  bcs formation_anim_slot4
  lda escort_animation_sequence, y
  sta SPRITE_POINTERS + 5
  lda #ESCORT_COLOR
  sta SPRITE5_COLOR
formation_anim_slot4:
  lda formation_slot4_alive
  beq formation_anim_slot5
  ldx #$04
  jsr slot_reserved_for_player_bottom
  bcs formation_anim_slot5
  lda grunt_animation_sequence, y
  sta SPRITE_POINTERS + 6
  lda #GRUNT_COLOR
  sta SPRITE6_COLOR
formation_anim_slot5:
  lda formation_slot5_alive
  beq formation_anim_done
  ldx #$05
  jsr slot_reserved_for_player_bottom
  bcs formation_anim_done
  lda grunt_animation_sequence, y
  sta SPRITE_POINTERS + 7
  lda #GRUNT_COLOR
  sta SPRITE7_COLOR
formation_anim_done:
  rts

update_dive_attack:
  lda dive_active
  beq dive_wait_for_launch

  lda #$00
  sta dive_moved_this_tick

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
  lda dive_fire_hold_timer
  beq dive_phase2_track_player
  dec dive_fire_hold_timer
  jmp dive_phase2_move_down

dive_phase2_track_player:
  jsr steer_dive_toward_player
  jsr steer_dive_toward_player
dive_phase2_move_down:
  lda dive_y
  clc
  adc #$03
  sta dive_y
  cmp #DIVE_EXIT_Y
  bcs finish_dive_return

dive_store_position:
  jsr update_dive_animation
  jsr store_dive_position
  jsr dive_hits_player
  bcc dive_store_position_done
  jsr handle_player_hit
dive_store_position_done:
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
  sta dive_fire_hold_timer

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
  sta dive_fire_hold_timer
  lda #DIVE_PHASE0_TICKS
  sta dive_timer
  lda #DIVE_START_DELAY
  sta dive_delay
  jsr store_dive_position
  sec
  rts

update_dive_animation:
  inc dive_anim_tick
  lda dive_anim_tick
  cmp #DIVE_ANIMATION_RATE
  bcc dive_animation_return

  lda #$00
  sta dive_anim_tick
  lda dive_moved_this_tick
  beq unwind_dive_animation

  lda dive_anim_frame
  cmp #DIVE_ANIMATION_MAX_FRAME
  bcs dive_animation_return
  inc dive_anim_frame
dive_animation_return:
  rts

unwind_dive_animation:
  lda dive_anim_frame
  beq dive_animation_return
  dec dive_anim_frame
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
  sta dive_prev_x_lo
  lda dive_x_hi
  sta dive_prev_x_hi

  lda dive_x_lo
  bne dive_dec_low
  dec dive_x_hi
dive_dec_low:
  dec dive_x_lo

  lda dive_x_hi
  cmp #PLAYER_MIN_X_HI
  bcc dive_clamp_min
  bne dive_mark_left_motion
  lda dive_x_lo
  cmp #PLAYER_MIN_X_LO
  bcs dive_mark_left_motion

dive_clamp_min:
  lda #PLAYER_MIN_X_LO
  sta dive_x_lo
  lda #PLAYER_MIN_X_HI
  sta dive_x_hi
dive_mark_left_motion:
  lda dive_x_lo
  cmp dive_prev_x_lo
  bne dive_left_changed
  lda dive_x_hi
  cmp dive_prev_x_hi
  beq dive_move_left_done
dive_left_changed:
  lda #$01
  sta dive_moved_this_tick
dive_move_left_done:
  rts

dive_move_right_one:
  lda dive_x_lo
  sta dive_prev_x_lo
  lda dive_x_hi
  sta dive_prev_x_hi

  inc dive_x_lo
  bne dive_check_max
  inc dive_x_hi

dive_check_max:
  lda dive_x_hi
  cmp #PLAYER_MAX_X_HI
  bcc dive_mark_right_motion
  bne dive_clamp_max
  lda dive_x_lo
  cmp #PLAYER_MAX_X_LO
  bcc dive_mark_right_motion

dive_clamp_max:
  lda #PLAYER_MAX_X_LO
  sta dive_x_lo
  lda #PLAYER_MAX_X_HI
  sta dive_x_hi
dive_mark_right_motion:
  lda dive_x_lo
  cmp dive_prev_x_lo
  bne dive_right_changed
  lda dive_x_hi
  cmp dive_prev_x_hi
  beq dive_move_right_done
dive_right_changed:
  lda #$01
  sta dive_moved_this_tick
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

update_enemy_fire:
  jsr erase_enemy_bullets

  ldx #$00
update_enemy_fire_loop:
  lda enemy_bullet_active, x
  beq update_enemy_fire_next

  lda enemy_bullet_y, x
  clc
  adc #ENEMY_BULLET_SPEED
  sta enemy_bullet_y, x
  cmp #ENEMY_BULLET_MAX_Y
  bcs deactivate_enemy_bullet

  jsr enemy_bullet_hits_player
  bcc update_enemy_fire_next
  jsr handle_player_hit
  rts

deactivate_enemy_bullet:
  lda #$00
  sta enemy_bullet_active, x

update_enemy_fire_next:
  inx
  cpx #ENEMY_BULLET_LIMIT
  bcc update_enemy_fire_loop

  jsr try_spawn_enemy_bullet
  jsr draw_enemy_bullets
  rts

try_spawn_enemy_bullet:
  lda player_respawn_timer
  bne try_spawn_enemy_bullet_done

  lda enemy_fire_cooldown
  beq enemy_fire_ready
  dec enemy_fire_cooldown
  rts

enemy_fire_ready:
  lda dive_active
  beq try_spawn_enemy_bullet_done
  lda dive_phase
  cmp #$01
  bcc try_spawn_enemy_bullet_done
  lda dive_y
  cmp #ENEMY_BULLET_FIRE_MIN_Y
  bcc try_spawn_enemy_bullet_done
  cmp #ENEMY_BULLET_FIRE_MAX_Y
  bcs try_spawn_enemy_bullet_done

  jsr find_free_enemy_bullet_slot
  bcc try_spawn_enemy_bullet_done

  lda dive_x_lo
  clc
  adc #ENEMY_BULLET_START_X_OFFSET
  sta enemy_bullet_x_lo, x
  lda dive_x_hi
  adc #$00
  sta enemy_bullet_x_hi, x

  lda dive_y
  clc
  adc #ENEMY_BULLET_START_Y_OFFSET
  sta enemy_bullet_y, x

  lda #$01
  sta enemy_bullet_active, x
  lda #ENEMY_BULLET_FIRE_COOLDOWN
  sta enemy_fire_cooldown
  lda #DIVE_FIRE_HOLD_TICKS
  sta dive_fire_hold_timer

try_spawn_enemy_bullet_done:
  rts

find_free_enemy_bullet_slot:
  ldx #$00
find_free_enemy_bullet_slot_loop:
  lda enemy_bullet_active, x
  beq find_free_enemy_bullet_slot_found
  inx
  cpx #ENEMY_BULLET_LIMIT
  bcc find_free_enemy_bullet_slot_loop
  clc
  rts

find_free_enemy_bullet_slot_found:
  sec
  rts

erase_enemy_bullets:
  ldx #$00
erase_enemy_bullets_loop:
  lda enemy_bullet_active, x
  beq erase_enemy_bullets_next
  jsr erase_enemy_bullet_cell
erase_enemy_bullets_next:
  inx
  cpx #ENEMY_BULLET_LIMIT
  bcc erase_enemy_bullets_loop
  rts

draw_enemy_bullets:
  ldx #$00
draw_enemy_bullets_loop:
  lda enemy_bullet_active, x
  beq draw_enemy_bullets_next
  jsr draw_enemy_bullet_cell
draw_enemy_bullets_next:
  inx
  cpx #ENEMY_BULLET_LIMIT
  bcc draw_enemy_bullets_loop
  rts

clear_enemy_bullets:
  jsr erase_enemy_bullets

  ldx #$00
clear_enemy_bullets_loop:
  lda #$00
  sta enemy_bullet_active, x
  sta enemy_bullet_x_lo, x
  sta enemy_bullet_x_hi, x
  sta enemy_bullet_y, x
  inx
  cpx #ENEMY_BULLET_LIMIT
  bcc clear_enemy_bullets_loop

  lda #ENEMY_BULLET_FIRE_COOLDOWN
  sta enemy_fire_cooldown
  rts

draw_enemy_bullet_cell:
  jsr compute_enemy_bullet_cell
  ldy enemy_bullet_row
  lda screen_row_lo, y
  sta SCREEN_PTR
  lda screen_row_hi, y
  sta SCREEN_PTR + 1
  ldy enemy_bullet_col
  lda enemy_bullet_char
  sta (SCREEN_PTR), y

  ldy enemy_bullet_row
  lda color_row_lo, y
  sta COLOR_PTR
  lda color_row_hi, y
  sta COLOR_PTR + 1
  ldy enemy_bullet_col
  lda #ENEMY_BULLET_COLOR
  sta (COLOR_PTR), y
  rts

erase_enemy_bullet_cell:
  jsr compute_enemy_bullet_cell
  ldy enemy_bullet_row
  lda screen_row_lo, y
  sta SCREEN_PTR
  lda screen_row_hi, y
  sta SCREEN_PTR + 1
  ldy enemy_bullet_col
  lda #$20
  sta (SCREEN_PTR), y

  ldy enemy_bullet_row
  lda color_row_lo, y
  sta COLOR_PTR
  lda color_row_hi, y
  sta COLOR_PTR + 1
  ldy enemy_bullet_col
  lda #PLAYFIELD_TEXT_COLOR
  sta (COLOR_PTR), y
  rts

compute_enemy_bullet_cell:
  lda enemy_bullet_y, x
  sec
  sbc #PLAYFIELD_TOP_Y
  sta enemy_bullet_row

  lda enemy_bullet_x_lo, x
  sec
  sbc #PLAYFIELD_LEFT_X_LO
  sta enemy_bullet_col
  lda enemy_bullet_x_hi, x
  sbc #PLAYFIELD_LEFT_X_HI
  tay

  // Enemy bullets are stored in sprite-space pixels but rendered with
  // character cells, so convert into playfield-local coordinates first.
  lda enemy_bullet_row
  and #%00000111
  asl
  asl
  asl
  sta enemy_bullet_char

  lda enemy_bullet_col
  and #%00000111
  clc
  adc enemy_bullet_char
  clc
  adc #ENEMY_BULLET_CHAR_BASE
  sta enemy_bullet_char

  lda enemy_bullet_row
  lsr
  lsr
  lsr
  sta enemy_bullet_row

  lda enemy_bullet_col
  lsr
  lsr
  lsr
  sta enemy_bullet_col

  cpy #$00
  beq enemy_bullet_col_done
  lda enemy_bullet_col
  clc
  adc #32
  sta enemy_bullet_col
enemy_bullet_col_done:
  rts

enemy_bullet_hits_player:
  lda player_respawn_timer
  bne enemy_bullet_miss

  lda enemy_bullet_y, x
  cmp #PLAYER_HIT_MAX_Y
  bcs enemy_bullet_miss
  cmp #PLAYER_HIT_MIN_Y
  bcs enemy_bullet_check_horizontal
  clc
  adc #ENEMY_BULLET_HIT_BOTTOM_OFFSET
  cmp #PLAYER_HIT_MIN_Y
  bcc enemy_bullet_miss

enemy_bullet_check_horizontal:
  jsr compute_player_hitbox

  lda enemy_bullet_x_lo, x
  clc
  adc #ENEMY_BULLET_HIT_RIGHT_OFFSET
  sta target_right_lo
  lda enemy_bullet_x_hi, x
  adc #$00
  sta target_right_hi

  lda target_right_hi
  cmp player_left_hi
  bcc enemy_bullet_miss
  bne enemy_bullet_check_right
  lda target_right_lo
  cmp player_left_lo
  bcc enemy_bullet_miss

enemy_bullet_check_right:
  lda player_right_hi
  cmp enemy_bullet_x_hi, x
  bcc enemy_bullet_miss
  bne enemy_bullet_hit
  lda player_right_lo
  cmp enemy_bullet_x_lo, x
  bcc enemy_bullet_miss

enemy_bullet_hit:
  sec
  rts

enemy_bullet_miss:
  clc
  rts

compute_player_hitbox:
  lda player_x_lo
  clc
  adc #PLAYER_HIT_LEFT_OFFSET
  sta player_left_lo
  lda player_x_hi
  adc #$00
  sta player_left_hi

  lda player_x_lo
  clc
  adc #PLAYER_HIT_RIGHT_OFFSET
  sta player_right_lo
  lda player_x_hi
  adc #$00
  sta player_right_hi
  rts

dive_hits_player:
  lda player_respawn_timer
  bne dive_hits_player_miss

  lda dive_y
  cmp #PLAYER_HIT_MAX_Y
  bcs dive_hits_player_miss
  cmp #PLAYER_HIT_MIN_Y
  bcs dive_hits_player_check_horizontal
  clc
  adc #DIVE_HIT_BOTTOM_OFFSET
  cmp #PLAYER_HIT_MIN_Y
  bcc dive_hits_player_miss

dive_hits_player_check_horizontal:
  jsr compute_player_hitbox

  lda dive_x_lo
  clc
  adc #DIVE_HIT_RIGHT_OFFSET
  sta target_right_lo
  lda dive_x_hi
  adc #$00
  sta target_right_hi

  lda target_right_hi
  cmp player_left_hi
  bcc dive_hits_player_miss
  bne dive_hits_player_check_right
  lda target_right_lo
  cmp player_left_lo
  bcc dive_hits_player_miss

dive_hits_player_check_right:
  lda player_right_hi
  cmp dive_x_hi
  bcc dive_hits_player_miss
  bne dive_hits_player_hit
  lda player_right_lo
  cmp dive_x_lo
  bcc dive_hits_player_miss

dive_hits_player_hit:
  sec
  rts

dive_hits_player_miss:
  clc
  rts

handle_player_hit:
  lda player_respawn_timer
  bne handle_player_hit_done

  jsr deactivate_shot
  jsr clear_enemy_bullets

  lda #PLAYER_RESPAWN_DELAY
  sta player_respawn_timer

  lda #$00
  sta effective_left
  sta effective_right
  sta effective_fire
  sta fire_locked

  lda SPRITE_ENABLE
  and #%11111101
  sta SPRITE_ENABLE

  jsr start_hit_flash
handle_player_hit_done:
  rts

respawn_player:
  lda #PLAYER_START_X_LO
  sta player_x_lo
  lda #PLAYER_START_X_HI
  sta player_x_hi
  jsr store_player_x

  lda SPRITE_ENABLE
  ora #%00000010
  sta SPRITE_ENABLE

  lda #ENEMY_BULLET_FIRE_COOLDOWN
  sta enemy_fire_cooldown
  rts

update_player:
  lda player_respawn_timer
  beq update_player_controls
  dec player_respawn_timer
  bne update_player_done
  jsr respawn_player
update_player_done:
  rts

update_player_controls:
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
  lda #SHOT_SPRITE_PTR
  sta SPRITE_POINTERS + 2
  lda #SHOT_COLOR
  sta SPRITE2_COLOR
  lda SPRITE_MULTICOLOR
  and #%11111011
  sta SPRITE_MULTICOLOR

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
  sta shot_x_lo
  sta shot_x_hi
  sta shot_y
  sta SPRITE2_Y
  lda SPRITE_ENABLE
  and #%11111011
  sta SPRITE_ENABLE
  lda SPRITE_X_MSB
  and #%11111011
  sta SPRITE_X_MSB
  rts

update_enemy_hit_animations:
  ldx #$00
enemy_hit_anim_loop:
  lda slot_explosion_timer, x
  beq enemy_hit_anim_next
  dec slot_explosion_timer, x
  bne enemy_hit_anim_next

  inc slot_explosion_frame, x
  lda slot_explosion_frame, x
  cmp #$04
  bcc advance_slot_explosion
  txa
  jsr finish_slot_explosion
  jmp enemy_hit_anim_next

advance_slot_explosion:
  lda #ENEMY_EXPLOSION_FRAME_TICKS
  sta slot_explosion_timer, x
  txa
  jsr set_slot_explosion_frame

enemy_hit_anim_next:
  inx
  cpx #$06
  bcc enemy_hit_anim_loop
  rts

start_slot_explosion:
  tax
  lda #$00
  sta slot_explosion_frame, x
  lda #ENEMY_EXPLOSION_FRAME_TICKS
  sta slot_explosion_timer, x
  txa
  jmp set_slot_explosion_frame

finish_slot_explosion:
  tax
  lda #$00
  sta slot_explosion_timer, x
  sta slot_explosion_frame, x
  txa
  beq finish_slot0_explosion
  cmp #$01
  beq finish_slot1_explosion
  cmp #$02
  beq finish_slot2_explosion
  cmp #$03
  beq finish_slot3_explosion
  cmp #$04
  beq finish_slot4_explosion
  jmp finish_slot5_explosion

finish_slot0_explosion:
  lda SPRITE_ENABLE
  and #%11111110
  sta SPRITE_ENABLE
  rts

finish_slot1_explosion:
  lda SPRITE_ENABLE
  and #%11110111
  sta SPRITE_ENABLE
  rts

finish_slot2_explosion:
  lda SPRITE_ENABLE
  and #%11101111
  sta SPRITE_ENABLE
  rts

finish_slot3_explosion:
  lda SPRITE_ENABLE
  and #%11011111
  sta SPRITE_ENABLE
  rts

finish_slot4_explosion:
  lda SPRITE_ENABLE
  and #%10111111
  sta SPRITE_ENABLE
  rts

finish_slot5_explosion:
  lda SPRITE_ENABLE
  and #%01111111
  sta SPRITE_ENABLE
  rts

destroy_slot0:
  lda #$00
  sta formation_slot0_alive
  lda #$00
  jsr store_slot_explosion_position
  lda #$00
  jsr clear_dive_if_slot
  lda #$00
  jsr start_slot_explosion
  jmp award_flagship_score

destroy_slot1:
  lda #$00
  sta formation_slot1_alive
  lda #$01
  jsr store_slot_explosion_position
  lda #$01
  jsr clear_dive_if_slot
  lda #$01
  jsr start_slot_explosion
  jmp award_flagship_score

destroy_slot2:
  lda #$00
  sta formation_slot2_alive
  lda #$02
  jsr store_slot_explosion_position
  lda #$02
  jsr clear_dive_if_slot
  lda #$02
  jsr start_slot_explosion
  jmp award_escort_score

destroy_slot3:
  lda #$00
  sta formation_slot3_alive
  lda #$03
  jsr store_slot_explosion_position
  lda #$03
  jsr clear_dive_if_slot
  lda #$03
  jsr start_slot_explosion
  jmp award_escort_score

destroy_slot4:
  lda #$00
  sta formation_slot4_alive
  lda #$04
  jsr store_slot_explosion_position
  lda #$04
  jsr clear_dive_if_slot
  lda #$04
  jsr start_slot_explosion
  jmp award_grunt_score

destroy_slot5:
  lda #$00
  sta formation_slot5_alive
  lda #$05
  jsr store_slot_explosion_position
  lda #$05
  jsr clear_dive_if_slot
  lda #$05
  jsr start_slot_explosion
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
  sta dive_fire_hold_timer

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
  lda formation_x_hi
  adc #$00
  sta formation_slot0_x_hi
  lda formation_slot0_alive
  beq formation_slot0_store_done
  ldx #$00
  jsr slot_reserved_for_player_bottom
  bcs formation_slot0_store_done
  lda formation_slot0_x_lo
  sta SPRITE0_X
  lda SPRITE_X_MSB
  and #%11111110
  ldx formation_slot0_x_hi
  beq formation_slot0_store_msb_done
  ora #FORMATION_SLOT0_MASK
formation_slot0_store_msb_done:
  sta SPRITE_X_MSB
formation_slot0_store_done:

  lda formation_x_lo
  clc
  adc #FORMATION_SLOT1_OFFSET
  sta formation_slot1_x_lo
  lda formation_x_hi
  adc #$00
  sta formation_slot1_x_hi
  lda formation_slot1_alive
  beq formation_slot1_store_done
  ldx #$01
  jsr slot_reserved_for_player_bottom
  bcs formation_slot1_store_done
  lda formation_slot1_x_lo
  sta SPRITE3_X
  lda SPRITE_X_MSB
  and #%11110111
  ldx formation_slot1_x_hi
  beq formation_slot1_store_msb_done
  ora #FORMATION_SLOT1_MASK
formation_slot1_store_msb_done:
  sta SPRITE_X_MSB
formation_slot1_store_done:

  lda formation_x_lo
  clc
  adc #FORMATION_SLOT2_OFFSET
  sta formation_slot2_x_lo
  lda formation_x_hi
  adc #$00
  sta formation_slot2_x_hi
  lda formation_slot2_alive
  beq formation_slot2_store_done
  ldx #$02
  jsr slot_reserved_for_player_bottom
  bcs formation_slot2_store_done
  lda formation_slot2_x_lo
  sta SPRITE4_X
  lda SPRITE_X_MSB
  and #%11101111
  ldx formation_slot2_x_hi
  beq formation_slot2_store_msb_done
  ora #FORMATION_SLOT2_MASK
formation_slot2_store_msb_done:
  sta SPRITE_X_MSB
formation_slot2_store_done:

  lda formation_x_lo
  clc
  adc #FORMATION_SLOT3_OFFSET
  sta formation_slot3_x_lo
  lda formation_x_hi
  adc #$00
  sta formation_slot3_x_hi
  lda formation_slot3_alive
  beq formation_slot3_store_done
  ldx #$03
  jsr slot_reserved_for_player_bottom
  bcs formation_slot3_store_done
  lda formation_slot3_x_lo
  sta SPRITE5_X
  lda SPRITE_X_MSB
  and #%11011111
  ldx formation_slot3_x_hi
  beq formation_slot3_store_msb_done
  ora #FORMATION_SLOT3_MASK
formation_slot3_store_msb_done:
  sta SPRITE_X_MSB
formation_slot3_store_done:

  lda formation_x_lo
  clc
  adc #FORMATION_SLOT4_OFFSET
  sta formation_slot4_x_lo
  lda formation_x_hi
  adc #$00
  sta formation_slot4_x_hi
  lda formation_slot4_alive
  beq formation_slot4_store_done
  ldx #$04
  jsr slot_reserved_for_player_bottom
  bcs formation_slot4_store_done
  lda formation_slot4_x_lo
  sta SPRITE6_X
  lda SPRITE_X_MSB
  and #%10111111
  ldx formation_slot4_x_hi
  beq formation_slot4_store_msb_done
  ora #FORMATION_SLOT4_MASK
formation_slot4_store_msb_done:
  sta SPRITE_X_MSB
formation_slot4_store_done:

  lda formation_x_lo
  clc
  adc #FORMATION_SLOT5_OFFSET
  sta formation_slot5_x_lo
  lda formation_x_hi
  adc #$00
  sta formation_slot5_x_hi
  lda formation_slot5_alive
  beq formation_slot5_store_done
  ldx #$05
  jsr slot_reserved_for_player_bottom
  bcs formation_slot5_store_done
  lda formation_slot5_x_lo
  sta SPRITE7_X
  lda SPRITE_X_MSB
  and #%01111111
  ldx formation_slot5_x_hi
  beq formation_slot5_store_msb_done
  ora #FORMATION_SLOT5_MASK
formation_slot5_store_msb_done:
  sta SPRITE_X_MSB
formation_slot5_store_done:
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

* = $4000 "Player Reuse Routines"

slot_available_for_player:
  lda dive_active
  beq slot_available_yes
  cpx dive_slot
  beq slot_available_no
slot_available_yes:
  sec
  rts
slot_available_no:
  clc
  rts

slot_reserved_for_player_bottom:
  lda player_extra_visible
  beq slot_reserved_for_player_bottom_no
  txa
  cmp player_white_slot
  beq slot_reserved_for_player_bottom_yes
  cmp player_cyan_slot
  beq slot_reserved_for_player_bottom_yes
slot_reserved_for_player_bottom_no:
  clc
  rts
slot_reserved_for_player_bottom_yes:
  sec
  rts

select_player_extra_slots:
  ldx #$00
select_player_white_slot:
  jsr slot_available_for_player
  bcs player_white_slot_found
  inx
  cpx #$06
  bcc select_player_white_slot
  rts
player_white_slot_found:
  stx player_white_slot

  ldx #$00
select_player_cyan_slot:
  cpx player_white_slot
  beq player_cyan_slot_next
  jsr slot_available_for_player
  bcs player_cyan_slot_found
player_cyan_slot_next:
  inx
  cpx #$06
  bcc select_player_cyan_slot
  rts
player_cyan_slot_found:
  stx player_cyan_slot
  rts

draw_player_extra_layers:
  lda player_respawn_timer
  bne draw_player_extra_layers_done

  jsr select_player_extra_slots

  ldx player_white_slot
  lda #PLAYER_WHITE_SPRITE_PTR
  sta player_reuse_pointer
  lda #PLAYER_WHITE_COLOR
  sta player_reuse_color
  jsr store_player_reused_slot

  ldx player_cyan_slot
  lda #PLAYER_CYAN_SPRITE_PTR
  sta player_reuse_pointer
  lda #PLAYER_CYAN_COLOR
  sta player_reuse_color
  jsr store_player_reused_slot

draw_player_extra_layers_done:
  rts

store_player_reused_slot:
  txa
  bne store_player_reused_slot_check1
  jmp store_player_reused_slot0
store_player_reused_slot_check1:
  cmp #$01
  bne store_player_reused_slot_check2
  jmp store_player_reused_slot1
store_player_reused_slot_check2:
  cmp #$02
  bne store_player_reused_slot_check3
  jmp store_player_reused_slot2
store_player_reused_slot_check3:
  cmp #$03
  bne store_player_reused_slot_check4
  jmp store_player_reused_slot3
store_player_reused_slot_check4:
  cmp #$04
  bne store_player_reused_slot_check5
  jmp store_player_reused_slot4
store_player_reused_slot_check5:
  jmp store_player_reused_slot5

store_player_reused_slot0:
  lda player_x_lo
  sta SPRITE0_X
  lda #PLAYER_Y
  sta SPRITE0_Y
  lda SPRITE_X_MSB
  and #%11111110
  ldx player_x_hi
  beq store_player_reused_slot0_msb_done
  lda SPRITE_X_MSB
  and #%11111110
  ora #FORMATION_SLOT0_MASK
store_player_reused_slot0_msb_done:
  sta SPRITE_X_MSB
  lda player_reuse_pointer
  sta SPRITE_POINTERS
  lda player_reuse_color
  sta SPRITE0_COLOR
  lda SPRITE_MULTICOLOR
  and #%11111110
  sta SPRITE_MULTICOLOR
  lda SPRITE_ENABLE
  ora #FORMATION_SLOT0_MASK
  sta SPRITE_ENABLE
  rts

store_player_reused_slot1:
  lda player_x_lo
  sta SPRITE3_X
  lda #PLAYER_Y
  sta SPRITE3_Y
  lda SPRITE_X_MSB
  and #%11110111
  ldx player_x_hi
  beq store_player_reused_slot1_msb_done
  lda SPRITE_X_MSB
  and #%11110111
  ora #FORMATION_SLOT1_MASK
store_player_reused_slot1_msb_done:
  sta SPRITE_X_MSB
  lda player_reuse_pointer
  sta SPRITE_POINTERS + 3
  lda player_reuse_color
  sta SPRITE3_COLOR
  lda SPRITE_MULTICOLOR
  and #%11110111
  sta SPRITE_MULTICOLOR
  lda SPRITE_ENABLE
  ora #FORMATION_SLOT1_MASK
  sta SPRITE_ENABLE
  rts

store_player_reused_slot2:
  lda player_x_lo
  sta SPRITE4_X
  lda #PLAYER_Y
  sta SPRITE4_Y
  lda SPRITE_X_MSB
  and #%11101111
  ldx player_x_hi
  beq store_player_reused_slot2_msb_done
  lda SPRITE_X_MSB
  and #%11101111
  ora #FORMATION_SLOT2_MASK
store_player_reused_slot2_msb_done:
  sta SPRITE_X_MSB
  lda player_reuse_pointer
  sta SPRITE_POINTERS + 4
  lda player_reuse_color
  sta SPRITE4_COLOR
  lda SPRITE_MULTICOLOR
  and #%11101111
  sta SPRITE_MULTICOLOR
  lda SPRITE_ENABLE
  ora #FORMATION_SLOT2_MASK
  sta SPRITE_ENABLE
  rts

store_player_reused_slot3:
  lda player_x_lo
  sta SPRITE5_X
  lda #PLAYER_Y
  sta SPRITE5_Y
  lda SPRITE_X_MSB
  and #%11011111
  ldx player_x_hi
  beq store_player_reused_slot3_msb_done
  lda SPRITE_X_MSB
  and #%11011111
  ora #FORMATION_SLOT3_MASK
store_player_reused_slot3_msb_done:
  sta SPRITE_X_MSB
  lda player_reuse_pointer
  sta SPRITE_POINTERS + 5
  lda player_reuse_color
  sta SPRITE5_COLOR
  lda SPRITE_MULTICOLOR
  and #%11011111
  sta SPRITE_MULTICOLOR
  lda SPRITE_ENABLE
  ora #FORMATION_SLOT3_MASK
  sta SPRITE_ENABLE
  rts

store_player_reused_slot4:
  lda player_x_lo
  sta SPRITE6_X
  lda #PLAYER_Y
  sta SPRITE6_Y
  lda SPRITE_X_MSB
  and #%10111111
  ldx player_x_hi
  beq store_player_reused_slot4_msb_done
  lda SPRITE_X_MSB
  and #%10111111
  ora #FORMATION_SLOT4_MASK
store_player_reused_slot4_msb_done:
  sta SPRITE_X_MSB
  lda player_reuse_pointer
  sta SPRITE_POINTERS + 6
  lda player_reuse_color
  sta SPRITE6_COLOR
  lda SPRITE_MULTICOLOR
  and #%10111111
  sta SPRITE_MULTICOLOR
  lda SPRITE_ENABLE
  ora #FORMATION_SLOT4_MASK
  sta SPRITE_ENABLE
  rts

store_player_reused_slot5:
  lda player_x_lo
  sta SPRITE7_X
  lda #PLAYER_Y
  sta SPRITE7_Y
  lda SPRITE_X_MSB
  and #%01111111
  ldx player_x_hi
  beq store_player_reused_slot5_msb_done
  lda SPRITE_X_MSB
  and #%01111111
  ora #FORMATION_SLOT5_MASK
store_player_reused_slot5_msb_done:
  sta SPRITE_X_MSB
  lda player_reuse_pointer
  sta SPRITE_POINTERS + 7
  lda player_reuse_color
  sta SPRITE7_COLOR
  lda SPRITE_MULTICOLOR
  and #%01111111
  sta SPRITE_MULTICOLOR
  lda SPRITE_ENABLE
  ora #FORMATION_SLOT5_MASK
  sta SPRITE_ENABLE
  rts

restore_player_extra_slots_for_top:
  lda formation_frame
  .for (var i = 0; i < FORMATION_ANIMATION_SHIFT; i++) {
    lsr
  }
  and #%00000011
  sta formation_restore_anim_index

  ldx player_white_slot
  jsr restore_player_reused_slot_for_top
  ldx player_cyan_slot
  cpx player_white_slot
  beq restore_player_extra_slots_done
  jsr restore_player_reused_slot_for_top
restore_player_extra_slots_done:
  rts

restore_player_reused_slot_for_top:
  lda dive_active
  beq restore_player_slot_check_explosion
  cpx dive_slot
  bne restore_player_slot_check_explosion
  jsr store_dive_position
  rts

restore_player_slot_check_explosion:
  lda slot_explosion_timer, x
  beq restore_player_slot_check_alive
  txa
  jsr set_slot_explosion_frame
  rts

restore_player_slot_check_alive:
  lda formation_slot0_alive, x
  beq restore_player_slot_disable
  txa
  bne restore_player_slot_alive_check1
  jmp restore_player_slot0_top
restore_player_slot_alive_check1:
  cmp #$01
  bne restore_player_slot_alive_check2
  jmp restore_player_slot1_top
restore_player_slot_alive_check2:
  cmp #$02
  bne restore_player_slot_alive_check3
  jmp restore_player_slot2_top
restore_player_slot_alive_check3:
  cmp #$03
  bne restore_player_slot_alive_check4
  jmp restore_player_slot3_top
restore_player_slot_alive_check4:
  cmp #$04
  bne restore_player_slot_alive_check5
  jmp restore_player_slot4_top
restore_player_slot_alive_check5:
  jmp restore_player_slot5_top

restore_player_slot_disable:
  txa
  bne restore_player_slot_disable_check1
  jmp disable_player_slot0_top
restore_player_slot_disable_check1:
  cmp #$01
  bne restore_player_slot_disable_check2
  jmp disable_player_slot1_top
restore_player_slot_disable_check2:
  cmp #$02
  bne restore_player_slot_disable_check3
  jmp disable_player_slot2_top
restore_player_slot_disable_check3:
  cmp #$03
  bne restore_player_slot_disable_check4
  jmp disable_player_slot3_top
restore_player_slot_disable_check4:
  cmp #$04
  bne restore_player_slot_disable_check5
  jmp disable_player_slot4_top
restore_player_slot_disable_check5:
  jmp disable_player_slot5_top

restore_player_slot0_top:
  lda formation_slot0_x_lo
  sta SPRITE0_X
  lda #FORMATION_TOP_Y
  sta SPRITE0_Y
  lda SPRITE_X_MSB
  and #%11111110
  ldx formation_slot0_x_hi
  beq restore_player_slot0_top_msb_done
  ora #FORMATION_SLOT0_MASK
restore_player_slot0_top_msb_done:
  sta SPRITE_X_MSB
  ldy formation_restore_anim_index
  lda flagship_animation_sequence, y
  sta SPRITE_POINTERS
  lda #FLAGSHIP_COLOR
  sta SPRITE0_COLOR
  lda SPRITE_MULTICOLOR
  ora #FORMATION_SLOT0_MASK
  sta SPRITE_MULTICOLOR
  lda SPRITE_ENABLE
  ora #FORMATION_SLOT0_MASK
  sta SPRITE_ENABLE
  rts

restore_player_slot1_top:
  lda formation_slot1_x_lo
  sta SPRITE3_X
  lda #FORMATION_TOP_Y
  sta SPRITE3_Y
  lda SPRITE_X_MSB
  and #%11110111
  ldx formation_slot1_x_hi
  beq restore_player_slot1_top_msb_done
  ora #FORMATION_SLOT1_MASK
restore_player_slot1_top_msb_done:
  sta SPRITE_X_MSB
  ldy formation_restore_anim_index
  lda flagship_animation_sequence, y
  sta SPRITE_POINTERS + 3
  lda #FLAGSHIP_COLOR
  sta SPRITE3_COLOR
  lda SPRITE_MULTICOLOR
  ora #FORMATION_SLOT1_MASK
  sta SPRITE_MULTICOLOR
  lda SPRITE_ENABLE
  ora #FORMATION_SLOT1_MASK
  sta SPRITE_ENABLE
  rts

restore_player_slot2_top:
  lda formation_slot2_x_lo
  sta SPRITE4_X
  lda #FORMATION_MID_Y
  sta SPRITE4_Y
  lda SPRITE_X_MSB
  and #%11101111
  ldx formation_slot2_x_hi
  beq restore_player_slot2_top_msb_done
  ora #FORMATION_SLOT2_MASK
restore_player_slot2_top_msb_done:
  sta SPRITE_X_MSB
  ldy formation_restore_anim_index
  lda escort_animation_sequence, y
  sta SPRITE_POINTERS + 4
  lda #ESCORT_COLOR
  sta SPRITE4_COLOR
  lda SPRITE_MULTICOLOR
  ora #FORMATION_SLOT2_MASK
  sta SPRITE_MULTICOLOR
  lda SPRITE_ENABLE
  ora #FORMATION_SLOT2_MASK
  sta SPRITE_ENABLE
  rts

restore_player_slot3_top:
  lda formation_slot3_x_lo
  sta SPRITE5_X
  lda #FORMATION_MID_Y
  sta SPRITE5_Y
  lda SPRITE_X_MSB
  and #%11011111
  ldx formation_slot3_x_hi
  beq restore_player_slot3_top_msb_done
  ora #FORMATION_SLOT3_MASK
restore_player_slot3_top_msb_done:
  sta SPRITE_X_MSB
  ldy formation_restore_anim_index
  lda escort_animation_sequence, y
  sta SPRITE_POINTERS + 5
  lda #ESCORT_COLOR
  sta SPRITE5_COLOR
  lda SPRITE_MULTICOLOR
  ora #FORMATION_SLOT3_MASK
  sta SPRITE_MULTICOLOR
  lda SPRITE_ENABLE
  ora #FORMATION_SLOT3_MASK
  sta SPRITE_ENABLE
  rts

restore_player_slot4_top:
  lda formation_slot4_x_lo
  sta SPRITE6_X
  lda #FORMATION_BOTTOM_Y
  sta SPRITE6_Y
  lda SPRITE_X_MSB
  and #%10111111
  ldx formation_slot4_x_hi
  beq restore_player_slot4_top_msb_done
  ora #FORMATION_SLOT4_MASK
restore_player_slot4_top_msb_done:
  sta SPRITE_X_MSB
  ldy formation_restore_anim_index
  lda grunt_animation_sequence, y
  sta SPRITE_POINTERS + 6
  lda #GRUNT_COLOR
  sta SPRITE6_COLOR
  lda SPRITE_MULTICOLOR
  ora #FORMATION_SLOT4_MASK
  sta SPRITE_MULTICOLOR
  lda SPRITE_ENABLE
  ora #FORMATION_SLOT4_MASK
  sta SPRITE_ENABLE
  rts

restore_player_slot5_top:
  lda formation_slot5_x_lo
  sta SPRITE7_X
  lda #FORMATION_BOTTOM_Y
  sta SPRITE7_Y
  lda SPRITE_X_MSB
  and #%01111111
  ldx formation_slot5_x_hi
  beq restore_player_slot5_top_msb_done
  ora #FORMATION_SLOT5_MASK
restore_player_slot5_top_msb_done:
  sta SPRITE_X_MSB
  ldy formation_restore_anim_index
  lda grunt_animation_sequence, y
  sta SPRITE_POINTERS + 7
  lda #GRUNT_COLOR
  sta SPRITE7_COLOR
  lda SPRITE_MULTICOLOR
  ora #FORMATION_SLOT5_MASK
  sta SPRITE_MULTICOLOR
  lda SPRITE_ENABLE
  ora #FORMATION_SLOT5_MASK
  sta SPRITE_ENABLE
  rts

disable_player_slot0_top:
  lda SPRITE_ENABLE
  and #%11111110
  sta SPRITE_ENABLE
  rts

disable_player_slot1_top:
  lda SPRITE_ENABLE
  and #%11110111
  sta SPRITE_ENABLE
  rts

disable_player_slot2_top:
  lda SPRITE_ENABLE
  and #%11101111
  sta SPRITE_ENABLE
  rts

disable_player_slot3_top:
  lda SPRITE_ENABLE
  and #%11011111
  sta SPRITE_ENABLE
  rts

disable_player_slot4_top:
  lda SPRITE_ENABLE
  and #%10111111
  sta SPRITE_ENABLE
  rts

disable_player_slot5_top:
  lda SPRITE_ENABLE
  and #%01111111
  sta SPRITE_ENABLE
  rts

* = $4500 "Main Data"

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
slot_explosion_timer:
  .fill 6, $00
slot_explosion_frame:
  .fill 6, $00
explosion_slot_x_lo:
  .fill 6, $00
explosion_slot_x_hi:
  .fill 6, $00
explosion_slot_y:
  .fill 6, $00
dive_moved_this_tick:
  .byte $00
dive_prev_x_lo:
  .byte $00
dive_prev_x_hi:
  .byte $00
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
dive_fire_hold_timer:
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
player_white_slot:
  .byte $00
player_cyan_slot:
  .byte $01
player_reuse_pointer:
  .byte $00
player_reuse_color:
  .byte $00
raster_phase:
  .byte RASTER_PHASE_TOP
player_extra_visible:
  .byte $00
formation_restore_anim_index:
  .byte $00
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
enemy_bullet_active:
  .fill ENEMY_BULLET_LIMIT, $00
enemy_bullet_x_lo:
  .fill ENEMY_BULLET_LIMIT, $00
enemy_bullet_x_hi:
  .fill ENEMY_BULLET_LIMIT, $00
enemy_bullet_y:
  .fill ENEMY_BULLET_LIMIT, $00
enemy_fire_cooldown:
  .byte $00
player_respawn_timer:
  .byte $00
player_left_lo:
  .byte $00
player_left_hi:
  .byte $00
player_right_lo:
  .byte $00
player_right_hi:
  .byte $00
enemy_bullet_row:
  .byte $00
enemy_bullet_col:
  .byte $00
enemy_bullet_char:
  .byte $00
enemy_explosion_pointer:
  .byte $00
cpu_port_backup:
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
  .byte FLAGSHIP_SPRITE2_PTR,ARCADE_SPRITE_PTR_BASE + 9,ARCADE_SPRITE_PTR_BASE + 10,ARCADE_SPRITE_PTR_BASE + 11,ARCADE_SPRITE_PTR_BASE + 12,ARCADE_SPRITE_PTR_BASE + 13,ARCADE_SPRITE_PTR_BASE + 14,ARCADE_SPRITE_PTR_BASE + 15,ARCADE_SPRITE_PTR_BASE + 16,ARCADE_SPRITE_PTR_BASE + 17
flagship_dive_animation_colors:
  .byte FLAGSHIP_COLOR,FLAGSHIP_DIVE_COLOR,FLAGSHIP_DIVE_COLOR,FLAGSHIP_DIVE_COLOR,FLAGSHIP_DIVE_COLOR,FLAGSHIP_DIVE_COLOR,FLAGSHIP_DIVE_COLOR,FLAGSHIP_DIVE_COLOR,FLAGSHIP_DIVE_COLOR,FLAGSHIP_DIVE_COLOR
escort_dive_animation_sequence:
  .byte FLAGSHIP_SPRITE0_PTR,ARCADE_SPRITE_PTR_BASE + 18,ARCADE_SPRITE_PTR_BASE + 19,ARCADE_SPRITE_PTR_BASE + 20,ARCADE_SPRITE_PTR_BASE + 21,ARCADE_SPRITE_PTR_BASE + 22,ARCADE_SPRITE_PTR_BASE + 23,ARCADE_SPRITE_PTR_BASE + 24,ARCADE_SPRITE_PTR_BASE + 25,ARCADE_SPRITE_PTR_BASE + 26
escort_dive_animation_colors:
  .byte FLAGSHIP_COLOR,ESCORT_DIVE_COLOR,ESCORT_DIVE_COLOR,ESCORT_DIVE_COLOR,ESCORT_DIVE_COLOR,ESCORT_DIVE_COLOR,ESCORT_DIVE_COLOR,ESCORT_DIVE_COLOR,ESCORT_DIVE_COLOR,ESCORT_DIVE_COLOR
grunt_dive_animation_sequence:
  .byte GRUNT_SPRITE2_PTR,ARCADE_SPRITE_PTR_BASE + 27,ARCADE_SPRITE_PTR_BASE + 28,ARCADE_SPRITE_PTR_BASE + 29,ARCADE_SPRITE_PTR_BASE + 30,ARCADE_SPRITE_PTR_BASE + 31,ARCADE_SPRITE_PTR_BASE + 32,ARCADE_SPRITE_PTR_BASE + 33,ARCADE_SPRITE_PTR_BASE + 34,ARCADE_SPRITE_PTR_BASE + 35
grunt_dive_animation_colors:
  .byte GRUNT_COLOR,GRUNT_DIVE_COLOR,GRUNT_DIVE_COLOR,GRUNT_DIVE_COLOR,GRUNT_DIVE_COLOR,GRUNT_DIVE_COLOR,GRUNT_DIVE_COLOR,GRUNT_DIVE_COLOR,GRUNT_DIVE_COLOR,GRUNT_DIVE_COLOR
enemy_explosion_sequence:
  .byte ENEMY_EXPLOSION_SPRITE3_PTR,ENEMY_EXPLOSION_SPRITE0_PTR,ENEMY_EXPLOSION_SPRITE1_PTR,ENEMY_EXPLOSION_SPRITE2_PTR
screen_row_lo:
  .for (var row = 0; row < 25; row++) {
    .byte <(SCREEN_RAM + (row * 40))
  }
screen_row_hi:
  .for (var row = 0; row < 25; row++) {
    .byte >(SCREEN_RAM + (row * 40))
  }
color_row_lo:
  .for (var row = 0; row < 25; row++) {
    .byte <(COLOR_RAM + (row * 40))
  }
color_row_hi:
  .for (var row = 0; row < 25; row++) {
    .byte >(COLOR_RAM + (row * 40))
  }

* = $2240 "Arcade Sprites"

.import binary "generated_arcade_sprites.bin"

* = $3240 "Player White Sprite"

player_overlay_sprite:
  .import binary "generated_player_overlay.bin"

* = $3280 "Player Red Sprite"

player_sprite:
  .import binary "generated_player_sprite.bin"

* = $32c0 "Player Cyan Sprite"

player_extra_sprite:
  .import binary "generated_player_extra.bin"

* = $3300 "Shot Sprite"

shot_sprite:
  .byte $00,$18,$00
  .byte $00,$18,$00
  .byte $00,$18,$00
  .byte $00,$18,$00
  .byte $00,$18,$00
  .byte $00,$18,$00
  .byte $00,$18,$00
  .byte $00,$18,$00
  .byte $00,$18,$00
  .byte $00,$18,$00
  .byte $00,$18,$00
  .byte $00,$18,$00
  .byte $00,$18,$00
  .byte $00,$18,$00
  .byte $00,$00,$00
  .byte $00,$00,$00
  .byte $00,$00,$00
  .byte $00,$00,$00
  .byte $00,$00,$00
  .byte $00,$00,$00
  .byte $00,$00,$00
  .byte $00

* = $3340 "Enemy Bullet Charset Data"

enemy_bullet_charset:
  .for (var sy = 0; sy < 8; sy++) {
    .for (var sx = 0; sx < 8; sx++) {
      .for (var row = 0; row < 8; row++) {
        .if (row >= sy && row <= sy + 3 && row < 8) {
          .byte (192 >> sx)
        } else {
          .byte $00
        }
      }
    }
  }
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

* = $3580 "Enemy Explosion Sprite 0"

enemy_explosion_sprite0:
  .byte $00,$00,$00
  .byte $00,$00,$00
  .byte $00,$00,$00
  .byte $00,$00,$00
  .byte $33,$03,$00
  .byte $00,$cf,$00
  .byte $3f,$f3,$c0
  .byte $0f,$fc,$00
  .byte $0f,$f3,$00
  .byte $30,$cc,$c0
  .byte $cc,$f3,$00
  .byte $33,$f0,$c0
  .byte $00,$c0,$00
  .byte $00,$00,$00
  .byte $00,$00,$00
  .byte $00,$00,$00
  .byte $00,$00,$00
  .byte $00,$00,$00
  .byte $00,$00,$00
  .byte $00,$00,$00
  .byte $00,$00,$00
  .byte $00

* = $35c0 "Enemy Explosion Sprite 1"

enemy_explosion_sprite1:
  .byte $00,$00,$00
  .byte $00,$60,$00
  .byte $04,$90,$00
  .byte $00,$40,$00
  .byte $12,$40,$00
  .byte $25,$f8,$00
  .byte $13,$c2,$00
  .byte $07,$dc,$00
  .byte $3f,$e0,$00
  .byte $23,$88,$00
  .byte $1a,$44,$00
  .byte $3c,$b0,$00
  .byte $12,$b0,$00
  .byte $22,$58,$00
  .byte $01,$00,$00
  .byte $00,$10,$00
  .byte $00,$00,$00
  .byte $00,$00,$00
  .byte $00,$00,$00
  .byte $00,$00,$00
  .byte $00,$00,$00
  .byte $00

* = $3600 "Enemy Explosion Sprite 2"

enemy_explosion_sprite2:
  .byte $90,$50,$00
  .byte $60,$44,$00
  .byte $34,$c8,$00
  .byte $08,$80,$00
  .byte $5c,$b1,$00
  .byte $0f,$f2,$00
  .byte $23,$ec,$00
  .byte $ff,$e0,$00
  .byte $0f,$f8,$00
  .byte $11,$ec,$00
  .byte $36,$82,$00
  .byte $44,$42,$00
  .byte $88,$c8,$00
  .byte $10,$8c,$00
  .byte $51,$02,$00
  .byte $84,$01,$00
  .byte $00,$00,$00
  .byte $00,$00,$00
  .byte $00,$00,$00
  .byte $00,$00,$00
  .byte $00,$00,$00
  .byte $00

* = $3640 "Enemy Explosion Sprite 3"

enemy_explosion_sprite3:
  .byte $00,$00,$00
  .byte $00,$00,$00
  .byte $00,$08,$00
  .byte $00,$78,$00
  .byte $00,$fc,$00
  .byte $07,$ff,$80
  .byte $07,$ff,$c0
  .byte $0f,$ff,$e0
  .byte $03,$ff,$f0
  .byte $07,$ff,$c0
  .byte $07,$ff,$80
  .byte $07,$ff,$c0
  .byte $07,$3f,$c0
  .byte $02,$10,$00
  .byte $00,$00,$00
  .byte $00,$00,$00
  .byte $00,$00,$00
  .byte $00,$00,$00
  .byte $00,$00,$00
  .byte $00,$00,$00
  .byte $00,$00,$00
  .byte $00

* = $4700 "Explosion Frame Routines"

set_slot_explosion_frame:
  tax
  jsr slot_reserved_for_player_bottom
  bcs set_slot_explosion_skip
  ldy slot_explosion_frame, x
  lda enemy_explosion_sequence, y
  sta enemy_explosion_pointer
  txa
  beq set_slot_explosion_frame0
  cmp #$01
  beq set_slot_explosion_frame1
  cmp #$02
  beq set_slot_explosion_frame2
  cmp #$03
  beq set_slot_explosion_frame3
  cmp #$04
  beq set_slot_explosion_frame4
  jmp set_slot_explosion_frame5
set_slot_explosion_frame0:
  jmp set_slot0_explosion_frame
set_slot_explosion_frame1:
  jmp set_slot1_explosion_frame
set_slot_explosion_frame2:
  jmp set_slot2_explosion_frame
set_slot_explosion_frame3:
  jmp set_slot3_explosion_frame
set_slot_explosion_frame4:
  jmp set_slot4_explosion_frame
set_slot_explosion_frame5:
  jmp set_slot5_explosion_frame
set_slot_explosion_skip:
  rts

set_slot0_explosion_frame:
  lda explosion_slot_x_lo, x
  sta SPRITE0_X
  lda explosion_slot_y, x
  sta SPRITE0_Y
  lda SPRITE_X_MSB
  and #%11111110
  ldy explosion_slot_x_hi, x
  beq set_slot0_explosion_msb_done
  ora #FORMATION_SLOT0_MASK
set_slot0_explosion_msb_done:
  sta SPRITE_X_MSB
  lda SPRITE_MULTICOLOR
  and #%11111110
  sta SPRITE_MULTICOLOR
  lda enemy_explosion_pointer
  sta SPRITE_POINTERS
  lda #ENEMY_EXPLOSION_COLOR
  sta SPRITE0_COLOR
  lda SPRITE_ENABLE
  ora #FORMATION_SLOT0_MASK
  sta SPRITE_ENABLE
  rts

set_slot1_explosion_frame:
  lda explosion_slot_x_lo, x
  sta SPRITE3_X
  lda explosion_slot_y, x
  sta SPRITE3_Y
  lda SPRITE_X_MSB
  and #%11110111
  ldy explosion_slot_x_hi, x
  beq set_slot1_explosion_msb_done
  ora #FORMATION_SLOT1_MASK
set_slot1_explosion_msb_done:
  sta SPRITE_X_MSB
  lda SPRITE_MULTICOLOR
  and #%11110111
  sta SPRITE_MULTICOLOR
  lda enemy_explosion_pointer
  sta SPRITE_POINTERS + 3
  lda #ENEMY_EXPLOSION_COLOR
  sta SPRITE3_COLOR
  lda SPRITE_ENABLE
  ora #FORMATION_SLOT1_MASK
  sta SPRITE_ENABLE
  rts

set_slot2_explosion_frame:
  lda explosion_slot_x_lo, x
  sta SPRITE4_X
  lda explosion_slot_y, x
  sta SPRITE4_Y
  lda SPRITE_X_MSB
  and #%11101111
  ldy explosion_slot_x_hi, x
  beq set_slot2_explosion_msb_done
  ora #FORMATION_SLOT2_MASK
set_slot2_explosion_msb_done:
  sta SPRITE_X_MSB
  lda SPRITE_MULTICOLOR
  and #%11101111
  sta SPRITE_MULTICOLOR
  lda enemy_explosion_pointer
  sta SPRITE_POINTERS + 4
  lda #ENEMY_EXPLOSION_COLOR
  sta SPRITE4_COLOR
  lda SPRITE_ENABLE
  ora #FORMATION_SLOT2_MASK
  sta SPRITE_ENABLE
  rts

set_slot3_explosion_frame:
  lda explosion_slot_x_lo, x
  sta SPRITE5_X
  lda explosion_slot_y, x
  sta SPRITE5_Y
  lda SPRITE_X_MSB
  and #%11011111
  ldy explosion_slot_x_hi, x
  beq set_slot3_explosion_msb_done
  ora #FORMATION_SLOT3_MASK
set_slot3_explosion_msb_done:
  sta SPRITE_X_MSB
  lda SPRITE_MULTICOLOR
  and #%11011111
  sta SPRITE_MULTICOLOR
  lda enemy_explosion_pointer
  sta SPRITE_POINTERS + 5
  lda #ENEMY_EXPLOSION_COLOR
  sta SPRITE5_COLOR
  lda SPRITE_ENABLE
  ora #FORMATION_SLOT3_MASK
  sta SPRITE_ENABLE
  rts

set_slot4_explosion_frame:
  lda explosion_slot_x_lo, x
  sta SPRITE6_X
  lda explosion_slot_y, x
  sta SPRITE6_Y
  lda SPRITE_X_MSB
  and #%10111111
  ldy explosion_slot_x_hi, x
  beq set_slot4_explosion_msb_done
  ora #FORMATION_SLOT4_MASK
set_slot4_explosion_msb_done:
  sta SPRITE_X_MSB
  lda SPRITE_MULTICOLOR
  and #%10111111
  sta SPRITE_MULTICOLOR
  lda enemy_explosion_pointer
  sta SPRITE_POINTERS + 6
  lda #ENEMY_EXPLOSION_COLOR
  sta SPRITE6_COLOR
  lda SPRITE_ENABLE
  ora #FORMATION_SLOT4_MASK
  sta SPRITE_ENABLE
  rts

set_slot5_explosion_frame:
  lda explosion_slot_x_lo, x
  sta SPRITE7_X
  lda explosion_slot_y, x
  sta SPRITE7_Y
  lda SPRITE_X_MSB
  and #%01111111
  ldy explosion_slot_x_hi, x
  beq set_slot5_explosion_msb_done
  ora #FORMATION_SLOT5_MASK
set_slot5_explosion_msb_done:
  sta SPRITE_X_MSB
  lda SPRITE_MULTICOLOR
  and #%01111111
  sta SPRITE_MULTICOLOR
  lda enemy_explosion_pointer
  sta SPRITE_POINTERS + 7
  lda #ENEMY_EXPLOSION_COLOR
  sta SPRITE7_COLOR
  lda SPRITE_ENABLE
  ora #FORMATION_SLOT5_MASK
  sta SPRITE_ENABLE
  rts

store_slot_explosion_position:
  tax
  lda dive_active
  beq store_slot_explosion_position_formation
  cpx dive_slot
  bne store_slot_explosion_position_formation

  lda dive_x_lo
  sta explosion_slot_x_lo, x
  lda dive_x_hi
  sta explosion_slot_x_hi, x
  lda dive_y
  sta explosion_slot_y, x
  rts

store_slot_explosion_position_formation:
  txa
  beq store_slot0_explosion_position
  cmp #$01
  beq store_slot1_explosion_position
  cmp #$02
  beq store_slot2_explosion_position
  cmp #$03
  beq store_slot3_explosion_position
  cmp #$04
  beq store_slot4_explosion_position
  jmp store_slot5_explosion_position

store_slot0_explosion_position:
  lda formation_slot0_x_lo
  sta explosion_slot_x_lo, x
  lda formation_slot0_x_hi
  sta explosion_slot_x_hi, x
  lda #FORMATION_TOP_Y
  sta explosion_slot_y, x
  rts

store_slot1_explosion_position:
  lda formation_slot1_x_lo
  sta explosion_slot_x_lo, x
  lda formation_slot1_x_hi
  sta explosion_slot_x_hi, x
  lda #FORMATION_TOP_Y
  sta explosion_slot_y, x
  rts

store_slot2_explosion_position:
  lda formation_slot2_x_lo
  sta explosion_slot_x_lo, x
  lda formation_slot2_x_hi
  sta explosion_slot_x_hi, x
  lda #FORMATION_MID_Y
  sta explosion_slot_y, x
  rts

store_slot3_explosion_position:
  lda formation_slot3_x_lo
  sta explosion_slot_x_lo, x
  lda formation_slot3_x_hi
  sta explosion_slot_x_hi, x
  lda #FORMATION_MID_Y
  sta explosion_slot_y, x
  rts

store_slot4_explosion_position:
  lda formation_slot4_x_lo
  sta explosion_slot_x_lo, x
  lda formation_slot4_x_hi
  sta explosion_slot_x_hi, x
  lda #FORMATION_BOTTOM_Y
  sta explosion_slot_y, x
  rts

store_slot5_explosion_position:
  lda formation_slot5_x_lo
  sta explosion_slot_x_lo, x
  lda formation_slot5_x_hi
  sta explosion_slot_x_hi, x
  lda #FORMATION_BOTTOM_Y
  sta explosion_slot_y, x
  rts

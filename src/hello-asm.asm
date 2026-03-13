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
.label BACKGROUND_MULTICOLOR_1 = $d022
.label BACKGROUND_MULTICOLOR_2 = $d023
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
// Keep the copied charset below the sprite asset block at $2480-$3cbf.
.label CHARSET_RAM = $0800

.label HUD_TEXT_COLOR = $01
.label PLAYFIELD_TEXT_COLOR = $0e
.label HUD_SCORE_COL = 6
.label HUD_LIVES_COL = 31
.label STATUS_ROW = 13
.label STATUS_PROMPT_ROW = 15
.label READY_MESSAGE_COL = 17
.label WAVE_CLEAR_MESSAGE_COL = 15
.label GAME_OVER_MESSAGE_COL = 15
.label PRESS_FIRE_MESSAGE_COL = 15
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
.label FORMATION_START_X_LO = $2e
.label FORMATION_START_X_HI = $00
.label FORMATION_TOP_Y = 68
.label FORMATION_MID_Y = 92
.label FORMATION_BOTTOM_Y = 116
.label FORMATION_CHAR_TRIM_TOP_ROWS = 4
.label FORMATION_CHAR_BAND_TOP_Y = PLAYFIELD_TOP_Y + (FORMATION_CHAR_BAND_TOP_ROW * 8)
.label FORMATION_CHAR_BAND_MID_Y = PLAYFIELD_TOP_Y + (FORMATION_CHAR_BAND_MID_ROW * 8)
.label FORMATION_CHAR_BAND_BOTTOM_Y = PLAYFIELD_TOP_Y + (FORMATION_CHAR_BAND_BOTTOM_ROW * 8)
.label FORMATION_CHAR_TOP_Y = FORMATION_CHAR_BAND_TOP_Y - FORMATION_CHAR_TRIM_TOP_ROWS
.label FORMATION_CHAR_MID_Y = FORMATION_CHAR_BAND_MID_Y - FORMATION_CHAR_TRIM_TOP_ROWS
.label FORMATION_CHAR_BOTTOM_Y = FORMATION_CHAR_BAND_BOTTOM_Y - FORMATION_CHAR_TRIM_TOP_ROWS
.label FORMATION_SCROLL_START_RASTER = FORMATION_CHAR_BAND_TOP_Y - 1
.label FORMATION_SCROLL_END_RASTER = FORMATION_CHAR_BAND_BOTTOM_Y + 8
.label FORMATION_RENDER_START_RASTER = FORMATION_SCROLL_END_RASTER + 1
.label FORMATION_CHAR_MIN_X_LO = $1a
.label FORMATION_CHAR_MIN_X_HI = $00
.label FORMATION_CHAR_MAX_X_LO = $24
.label FORMATION_CHAR_MAX_X_HI = $01
.label FORMATION_RIGHT_BOUNCE_ALLOWANCE = 28
.label FORMATION_TOP_SLOT_COUNT = 4
.label FORMATION_MID_SLOT_COUNT = 6
.label FORMATION_BOTTOM_SLOT_COUNT = 8
.label FORMATION_SLOT_COUNT = FORMATION_TOP_SLOT_COUNT + FORMATION_MID_SLOT_COUNT + FORMATION_BOTTOM_SLOT_COUNT
.label FORMATION_TOP_SLOT_END = FORMATION_TOP_SLOT_COUNT
.label FORMATION_MID_SLOT_END = FORMATION_TOP_SLOT_COUNT + FORMATION_MID_SLOT_COUNT
.label FORMATION_DIVE_CANDIDATE_COUNT = 8
.label FORMATION_SLOT_X_STRIDE = 2
.label FORMATION_SLOT0_OFFSET = 60
.label FORMATION_SLOT1_OFFSET = 90
.label FORMATION_SLOT2_OFFSET = 120
.label FORMATION_SLOT3_OFFSET = 150
.label FORMATION_SLOT4_OFFSET = 30
.label FORMATION_SLOT5_OFFSET = 60
.label FORMATION_SLOT6_OFFSET = 90
.label FORMATION_SLOT7_OFFSET = 120
.label FORMATION_SLOT8_OFFSET = 150
.label FORMATION_SLOT9_OFFSET = 180
.label FORMATION_SLOT10_OFFSET = 0
.label FORMATION_SLOT11_OFFSET = 30
.label FORMATION_SLOT12_OFFSET = 60
.label FORMATION_SLOT13_OFFSET = 90
.label FORMATION_SLOT14_OFFSET = 120
.label FORMATION_SLOT15_OFFSET = 150
.label FORMATION_SLOT16_OFFSET = 180
.label FORMATION_SLOT17_OFFSET = 210
.label FORMATION_COLUMN_LEFT_MASK = %00000001
.label FORMATION_COLUMN_RIGHT_MASK = %00000010
.label FORMATION_CHAR_RIGHT_ONLY_MIN_X = ((FORMATION_CHAR_MIN_X_HI << 8) | FORMATION_CHAR_MIN_X_LO) - FORMATION_SLOT1_OFFSET
.label FORMATION_CHAR_RIGHT_ONLY_MIN_X_LO = <FORMATION_CHAR_RIGHT_ONLY_MIN_X
.label FORMATION_CHAR_RIGHT_ONLY_MIN_X_HI = >FORMATION_CHAR_RIGHT_ONLY_MIN_X
.label FORMATION_CHAR_SINGLE_COLUMN_MAX_X = ((FORMATION_CHAR_MAX_X_HI << 8) | FORMATION_CHAR_MAX_X_LO) + FORMATION_SLOT1_OFFSET
.label FORMATION_CHAR_SINGLE_COLUMN_MAX_X_LO = <FORMATION_CHAR_SINGLE_COLUMN_MAX_X
.label FORMATION_CHAR_SINGLE_COLUMN_MAX_X_HI = >FORMATION_CHAR_SINGLE_COLUMN_MAX_X
.label FORMATION_CHAR_DYNAMIC_MAX_X = ((FORMATION_CHAR_MAX_X_HI << 8) | FORMATION_CHAR_MAX_X_LO) + FORMATION_RIGHT_BOUNCE_ALLOWANCE
.label FORMATION_CHAR_DYNAMIC_MAX_X_LO = <FORMATION_CHAR_DYNAMIC_MAX_X
.label FORMATION_CHAR_DYNAMIC_MAX_X_HI = >FORMATION_CHAR_DYNAMIC_MAX_X
.label FORMATION_MOVE_PERIOD = 2
.label FORMATION_CLEAR_STRATEGY_EDGE_GLOBAL = $00
.label FORMATION_CLEAR_STRATEGY_ROWWISE = $01
.label ARCADE_SPRITE_PTR_BASE = $92
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
.label SPRITE0_MASK = %00000001
.label SPRITE1_MASK = %00000010
.label SPRITE2_MASK = %00000100
.label SPRITE3_MASK = %00001000
.label SPRITE4_MASK = %00010000
.label SPRITE5_MASK = %00100000
.label SPRITE6_MASK = %01000000
.label SPRITE7_MASK = %10000000
.label FORMATION_SPRITE_MASK = %11111001
.label FORMATION_MSB_CLEAR_MASK = %00000110
.label CHAR_MODE_DYNAMIC_SPRITE_MASK = SPRITE0_MASK | SPRITE3_MASK | SPRITE4_MASK | SPRITE5_MASK | SPRITE6_MASK | SPRITE7_MASK
.label CHAR_MODE_STATIC_SPRITE_MASK = SPRITE1_MASK | SPRITE2_MASK
.label CHAR_MODE_EFFECT_SLOT_COUNT = 5
.label DIVE_VIC_SPRITE_SLOT = 0
.label DIVE_SPRITE_MASK = SPRITE0_MASK
.label PLAYER_BOTTOM_LEFT_SPRITE_MASK = SPRITE3_MASK
.label PLAYER_BOTTOM_RIGHT_SPRITE_MASK = SPRITE4_MASK
.label PLAYER_COLOR = $02
.label PLAYER_WHITE_COLOR = $0f
.label PLAYER_CYAN_COLOR = $03
.label PLAYER_START_X_LO = $a8
.label PLAYER_START_X_HI = $00
.label PLAYER_Y = 228
.label PLAYER_EXPLOSION_MULTI0_COLOR = $07
.label PLAYER_EXPLOSION_MULTI1_COLOR = $04
.label PLAYER_EXPLOSION_COLOR = $02
.label PLAYER_EXPLOSION_PTR_BASE = $e3
.label PLAYER_EXPLOSION_FRAME_TICKS = 5
.label PLAYER_EXPLOSION_FRAME_COUNT = 4
.label PLAYER_EXPLOSION_TILE_OFFSET = 16
.label PLAYER_EXPLOSION_LEFT_OFFSET = 4
.label PLAYER_EXPLOSION_TOP_OFFSET = 8
.label PLAYFIELD_LEFT_X_LO = $18
.label PLAYFIELD_LEFT_X_HI = $00
.label PLAYFIELD_TOP_Y = 50
.label PLAYER_MIN_X_LO = $18
.label PLAYER_MIN_X_HI = $00
.label PLAYER_MAX_X_LO = $40
.label PLAYER_MAX_X_HI = $01
.label PLAYER_WHITE_SPRITE_PTR = $d2
.label PLAYER_RED_SPRITE_PTR = $d3
.label PLAYER_CYAN_SPRITE_PTR = $d4
.label SHOT_COLOR = $01
.label SHOT_SPRITE_PTR = $d5
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
.label FORMATION_CHAR_BASE = 96
.label FORMATION_CHAR_SLOT_STRIDE = 4
.label FORMATION_CHAR_MULTICOLOR_FLAG = $08
.label FORMATION_CHAR_BAND_ORIGIN_COL = 0
.label FORMATION_CHAR_BAND_WIDTH = 40
.label FORMATION_CHAR_BAND_HEIGHT = 5
.label FORMATION_CHAR_BAND_TOP_ROW = 6
.label FORMATION_CHAR_BAND_MID_ROW = 8
.label FORMATION_CHAR_BAND_BOTTOM_ROW = 10
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
.label ENEMY_BULLET_CHAR_BASE = 192
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
.label ENEMY_EXPLOSION_SPRITE0_PTR = $df
.label ENEMY_EXPLOSION_SPRITE1_PTR = $e0
.label ENEMY_EXPLOSION_SPRITE2_PTR = $e1
.label ENEMY_EXPLOSION_SPRITE3_PTR = $e2
.label ENEMY_EXPLOSION_HEIGHT = 21
.label ENEMY_EXPLOSION_BOTTOM_OVERLAP_Y = PLAYER_BOTTOM_SPLIT_RASTER - (ENEMY_EXPLOSION_HEIGHT - 1)
.label VIC_CTRL2_TEXT_MULTICOLOR = $18
.label PLAYER_TOP_SPLIT_RASTER = 40
.label PLAYER_BOTTOM_SPLIT_RASTER = 170
.label RASTER_PHASE_TOP = $00
.label RASTER_PHASE_FORMATION_SCROLL_ON = $01
.label RASTER_PHASE_FORMATION_SCROLL_OFF = $02
.label RASTER_PHASE_BOTTOM = $03
.label GAME_STATE_READY = $00
.label GAME_STATE_PLAYING = $01
.label GAME_STATE_PLAYER_HIT = $02
.label GAME_STATE_RESPAWN = $03
.label GAME_STATE_GAME_OVER = $04
.label GAME_STATE_WAVE_CLEAR = $05
.label INITIAL_PLAYER_LIVES = 3
.label READY_DELAY = 50
.label PLAYER_HIT_DELAY = 48
.label PLAYER_RESPAWN_DELAY = 40
.label WAVE_CLEAR_DELAY = 64
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
  jsr init_shot
  jsr init_dive_attack
  jsr init_enemy_fire
  jsr init_raster_irq
  jsr start_new_game
  cli

main_loop:
  jsr wait_frame
  lda #$00
  sta frame_capture_ready
  jsr update_effects
  jsr update_game_state
  jsr update_player
  jsr update_shot
  jsr update_formation
  jsr update_dive_attack
  jsr update_enemy_hit_animations
  jsr update_enemy_fire
  jsr render_formation_if_dirty
  lda #$01
  sta frame_capture_ready
  inc frame_capture_counter
  jmp main_loop

render_formation_if_dirty:
  lda formation_render_dirty
  beq render_formation_if_dirty_done
  jsr render_formation
  lda #$00
  sta formation_render_dirty
render_formation_if_dirty_done:
  rts

init_vic:
  lda VIC_BANK_SELECT
  and #%11111100
  ora #%00000011
  sta VIC_BANK_SELECT

  lda #$1b
  sta VIC_CTRL1
  lda #VIC_CTRL2_TEXT_MULTICOLOR
  sta VIC_CTRL2
  lda #$12
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
  jsr update_score_display
  rts

update_score_display:
  lda score_total_hi
  ldx #HUD_SCORE_COL
  jsr write_bcd_score_digits
  lda score_total_mid
  ldx #(HUD_SCORE_COL + 2)
  jsr write_bcd_score_digits
  lda score_total_lo
  ldx #(HUD_SCORE_COL + 4)
  jsr write_bcd_score_digits
  rts

write_bcd_score_digits:
  pha
  .for (var i = 0; i < 4; i++) {
    lsr
  }
  clc
  adc #$30
  sta SCREEN_RAM, x
  lda #HUD_TEXT_COLOR
  sta COLOR_RAM, x
  inx
  pla
  and #$0f
  clc
  adc #$30
  sta SCREEN_RAM, x
  lda #HUD_TEXT_COLOR
  sta COLOR_RAM, x
  rts

update_lives_display:
  lda player_lives
  cmp #$0a
  bcc update_lives_display_store
  lda #$09
update_lives_display_store:
  clc
  adc #$30
  sta SCREEN_RAM + HUD_LIVES_COL
  lda #HUD_TEXT_COLOR
  sta COLOR_RAM + HUD_LIVES_COL
  rts

clear_status_area:
  ldx #$00
clear_status_area_loop:
  lda #$20
  sta SCREEN_RAM + (STATUS_ROW * 40), x
  sta SCREEN_RAM + (STATUS_PROMPT_ROW * 40), x
  lda #PLAYFIELD_TEXT_COLOR
  sta COLOR_RAM + (STATUS_ROW * 40), x
  sta COLOR_RAM + (STATUS_PROMPT_ROW * 40), x
  inx
  cpx #40
  bcc clear_status_area_loop
  rts

show_ready_message:
  jsr clear_status_area
  ldx #$00
show_ready_message_loop:
  lda ready_message, x
  beq show_ready_message_done
  sta SCREEN_RAM + (STATUS_ROW * 40) + READY_MESSAGE_COL, x
  lda #HUD_TEXT_COLOR
  sta COLOR_RAM + (STATUS_ROW * 40) + READY_MESSAGE_COL, x
  inx
  bne show_ready_message_loop
show_ready_message_done:
  rts

show_wave_clear_message:
  jsr clear_status_area
  ldx #$00
show_wave_clear_message_loop:
  lda wave_clear_message, x
  beq show_wave_clear_message_done
  sta SCREEN_RAM + (STATUS_ROW * 40) + WAVE_CLEAR_MESSAGE_COL, x
  lda #HUD_TEXT_COLOR
  sta COLOR_RAM + (STATUS_ROW * 40) + WAVE_CLEAR_MESSAGE_COL, x
  inx
  bne show_wave_clear_message_loop
show_wave_clear_message_done:
  rts

show_game_over_message:
  jsr clear_status_area
  ldx #$00
show_game_over_message_loop:
  lda game_over_message, x
  beq show_game_over_message_done
  sta SCREEN_RAM + (STATUS_ROW * 40) + GAME_OVER_MESSAGE_COL, x
  lda #HUD_TEXT_COLOR
  sta COLOR_RAM + (STATUS_ROW * 40) + GAME_OVER_MESSAGE_COL, x
  inx
  bne show_game_over_message_loop
show_game_over_message_done:
  rts

show_press_fire_message:
  ldx #$00
show_press_fire_message_loop:
  lda press_fire_message, x
  beq show_press_fire_message_done
  sta SCREEN_RAM + (STATUS_PROMPT_ROW * 40) + PRESS_FIRE_MESSAGE_COL, x
  lda #HUD_TEXT_COLOR
  sta COLOR_RAM + (STATUS_PROMPT_ROW * 40) + PRESS_FIRE_MESSAGE_COL, x
  inx
  bne show_press_fire_message_loop
show_press_fire_message_done:
  rts

clear_player_input_state:
  lda #$00
  sta effective_left
  sta effective_right
  sta effective_fire
  sta joystick_state
  rts

lock_fire_until_release:
  lda #$01
  sta fire_locked
  rts

init_formation:
  lda #FORMATION_START_X_LO
  sta formation_x_lo
  lda #FORMATION_START_X_HI
  sta formation_x_hi

  lda #$01
  sta formation_dir
  ldx #$00
init_formation_alive_loop:
  sta formation_slot0_alive, x
  inx
  cpx #FORMATION_SLOT_COUNT
  bcc init_formation_alive_loop

  lda #$00
  sta formation_frame
  sta formation_anim_index
  lda #FORMATION_MOVE_PERIOD
  sta formation_move_timer
  lda #$01
  sta formation_render_dirty
  lda #$00
  sta formation_full_redraw_pending
  jsr init_formation_renderer
  jsr update_formation_bounds
  jsr update_formation_animation_state
  jsr update_formation_slot_positions
  jsr render_formation
  rts

init_formation_renderer:
  lda #$00
  sta SPRITE_X_MSB
  sta SPRITE_PRIORITY
  sta SPRITE_X_EXPAND
  sta SPRITE_Y_EXPAND
  sta SPRITE_MULTICOLOR
  sta SPRITE_ENABLE
  lda #FORMATION_MULTI0_COLOR
  sta SPRITE_MULTICOLOR_0
  sta BACKGROUND_MULTICOLOR_1
  lda #FORMATION_MULTI1_COLOR
  sta SPRITE_MULTICOLOR_1
  sta BACKGROUND_MULTICOLOR_2
  jsr clear_formation_char_band
  jsr clear_formation_char_glyphs
  lda #$00
  sta formation_char_render_mask_pending
  sta formation_char_render_mask_pending_hi
  sta formation_char_render_mask_pending_hi2
  sta formation_char_render_mask
  sta formation_char_render_mask_hi
  sta formation_char_render_mask_hi2
  sta formation_full_redraw_pending
  ldx #$00
init_formation_renderer_slot_loop:
  sta formation_char_last_col, x
  sta formation_char_last_clear_count, x
  inx
  cpx #FORMATION_SLOT_COUNT
  bcc init_formation_renderer_slot_loop
  rts

init_player:
  jmp restore_player_ship

restore_player_ship:
  jsr finish_player_explosion

  lda #$01
  sta player_visible
  lda #$00
  sta enemy_attack_active

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

  lda #ENEMY_BULLET_FIRE_COOLDOWN
  sta enemy_fire_cooldown
  rts

hide_player_ship:
  lda #$00
  sta player_visible

  lda SPRITE_ENABLE
  and #%11111101
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
  sta dive_launch_counter
  sta dive_launch_y_debug
  sta dive_launch_hold

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
  sta game_state
  sta game_state_timer
  sta player_lives
  sta player_visible
  sta enemy_attack_active
  sta player_respawn_timer
  sta player_left_lo
  sta player_left_hi
  sta player_right_lo
  sta player_right_hi
  sta enemy_bullet_row
  sta enemy_bullet_col
  sta player_extra_visible
  sta player_explosion_active
  sta player_explosion_timer
  sta player_explosion_frame
  sta player_explosion_x_lo
  sta player_explosion_x_hi
  sta player_explosion_y
  sta player_explosion_top_left_pointer
  sta player_explosion_top_right_pointer
  sta player_explosion_bottom_left_pointer
  sta player_explosion_bottom_right_pointer
  sta player_effect_x_lo
  sta player_effect_x_hi
  sta player_effect_y
  sta player_effect_pointer
  sta player_effect_color
  sta frame_capture_ready
  sta frame_capture_counter
  sta player_bottom_sprite_mask_debug
  lda #RASTER_PHASE_TOP
  sta raster_phase
  sta formation_anim_index
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
  cmp #RASTER_PHASE_FORMATION_SCROLL_ON
  beq raster_irq_formation_scroll_on_phase
  cmp #RASTER_PHASE_FORMATION_SCROLL_OFF
  beq raster_irq_formation_scroll_off_phase

  lda #RASTER_PHASE_TOP
  sta raster_phase
  lda #PLAYER_TOP_SPLIT_RASTER
  sta RASTER
  lda #VIC_CTRL2_TEXT_MULTICOLOR
  sta VIC_CTRL2
  lda #$01
  sta player_extra_visible
  jsr draw_player_bottom_effects
  jmp raster_irq_done

raster_irq_top_phase:
  lda #RASTER_PHASE_FORMATION_SCROLL_ON
  sta raster_phase
  lda #FORMATION_SCROLL_START_RASTER
  sta RASTER
  lda #VIC_CTRL2_TEXT_MULTICOLOR
  sta VIC_CTRL2
  lda #FORMATION_MULTI0_COLOR
  sta SPRITE_MULTICOLOR_0
  lda #FORMATION_MULTI1_COLOR
  sta SPRITE_MULTICOLOR_1
  lda #$00
  sta player_extra_visible
  sta player_bottom_sprite_mask_debug
  jsr render_char_mode_top_sprites
  jmp raster_irq_done

raster_irq_formation_scroll_on_phase:
  lda #RASTER_PHASE_FORMATION_SCROLL_OFF
  sta raster_phase
  lda #FORMATION_SCROLL_END_RASTER
  sta RASTER
  lda formation_render_scroll_phase
  ora #VIC_CTRL2_TEXT_MULTICOLOR
  sta VIC_CTRL2
  jmp raster_irq_done

raster_irq_formation_scroll_off_phase:
  lda #RASTER_PHASE_BOTTOM
  sta raster_phase
  lda #PLAYER_BOTTOM_SPLIT_RASTER
  sta RASTER
  lda #VIC_CTRL2_TEXT_MULTICOLOR
  sta VIC_CTRL2
  jmp raster_irq_done

raster_irq_done:
  jmp $ea81

wait_frame:
wait_for_bottom_phase_clear:
  lda raster_phase
  cmp #RASTER_PHASE_BOTTOM
  beq wait_for_bottom_phase_clear
wait_for_bottom_phase:
  lda raster_phase
  cmp #RASTER_PHASE_BOTTOM
  bne wait_for_bottom_phase
wait_for_bottom_split_line:
  lda RASTER
  cmp #PLAYER_BOTTOM_SPLIT_RASTER
  beq wait_for_bottom_split_line
  rts

clear_active_dive_state:
  lda #$00
  sta dive_active
  sta dive_phase
  sta dive_timer
  sta dive_anim_frame
  sta dive_anim_tick
  sta dive_fire_hold_timer
  sta dive_launch_hold

  lda #DIVE_SLOT_NONE
  sta dive_slot

  lda #DIVE_START_DELAY
  sta dive_delay
  jsr disable_char_mode_dive_sprite
  rts

cancel_active_dive:
  lda dive_active
  beq cancel_active_dive_done
  jsr update_formation_slot_positions
  jsr clear_active_dive_state
  jsr mark_formation_full_redraw
cancel_active_dive_done:
  rts

mark_formation_full_redraw:
  lda #$01
  sta formation_full_redraw_pending
  sta formation_render_dirty
  rts

clear_enemy_hit_animations:
  ldx #$00
clear_enemy_hit_animations_loop:
  lda #$00
  sta slot_explosion_timer, x
  sta slot_explosion_frame, x
  inx
  cpx #FORMATION_SLOT_COUNT
  bcc clear_enemy_hit_animations_loop
  rts

reset_wave_runtime:
  jsr deactivate_shot
  jsr clear_enemy_bullets
  jsr clear_enemy_hit_animations
  jsr cancel_active_dive
  jsr finish_player_explosion
  jsr clear_player_input_state
  lda #$00
  sta player_respawn_timer
  rts

start_new_wave:
  jsr reset_wave_runtime
  jsr init_formation
  jsr restore_player_ship
  jsr enter_ready_state
  rts

start_new_game:
  jsr draw_hud
  jsr init_score
  lda #INITIAL_PLAYER_LIVES
  sta player_lives
  jsr update_lives_display
  jsr start_new_wave
  rts

enter_ready_state:
  lda #GAME_STATE_READY
  sta game_state
  lda #READY_DELAY
  sta game_state_timer
  lda #$00
  sta player_respawn_timer
  jsr clear_player_input_state
  jsr lock_fire_until_release
  jsr show_ready_message
  rts

enter_playing_state:
  lda #GAME_STATE_PLAYING
  sta game_state
  lda #$00
  sta game_state_timer
  sta player_respawn_timer
  jsr clear_status_area
  rts

enter_player_hit_state:
  lda player_lives
  beq enter_player_hit_state_done
  dec player_lives
  jsr update_lives_display
  jsr deactivate_shot
  jsr clear_enemy_bullets
  jsr cancel_active_dive
  jsr start_player_explosion
  jsr hide_player_ship
  jsr clear_player_input_state
  jsr lock_fire_until_release
  lda #GAME_STATE_PLAYER_HIT
  sta game_state
  lda #PLAYER_HIT_DELAY
  sta game_state_timer
  lda #$00
  sta player_respawn_timer
  jsr clear_status_area
  jsr start_hit_flash
enter_player_hit_state_done:
  rts

enter_respawn_state:
  jsr restore_player_ship
  lda #GAME_STATE_RESPAWN
  sta game_state
  lda #PLAYER_RESPAWN_DELAY
  sta game_state_timer
  sta player_respawn_timer
  jsr clear_player_input_state
  jsr lock_fire_until_release
  jsr show_ready_message
  rts

enter_wave_clear_state:
  jsr deactivate_shot
  jsr clear_enemy_bullets
  lda #GAME_STATE_WAVE_CLEAR
  sta game_state
  lda #WAVE_CLEAR_DELAY
  sta game_state_timer
  lda #$00
  sta player_respawn_timer
  jsr clear_player_input_state
  jsr lock_fire_until_release
  jsr show_wave_clear_message
  rts

enter_game_over_state:
  jsr finish_player_explosion
  jsr hide_player_ship
  lda #GAME_STATE_GAME_OVER
  sta game_state
  lda #$00
  sta game_state_timer
  sta player_respawn_timer
  jsr clear_player_input_state
  jsr lock_fire_until_release
  jsr show_game_over_message
  jsr show_press_fire_message
  rts

update_game_state:
  lda game_state
  beq update_ready_state
  cmp #GAME_STATE_PLAYING
  beq update_game_state_done
  cmp #GAME_STATE_PLAYER_HIT
  beq update_player_hit_state
  cmp #GAME_STATE_RESPAWN
  beq update_respawn_state
  cmp #GAME_STATE_GAME_OVER
  beq update_game_over_state
  jmp update_wave_clear_state

update_ready_state:
  lda game_state_timer
  beq update_ready_state_done
  dec game_state_timer
  bne update_game_state_done
update_ready_state_done:
  jmp enter_playing_state

update_player_hit_state:
  lda game_state_timer
  beq update_player_hit_state_done
  dec game_state_timer
  bne update_game_state_done
update_player_hit_state_done:
  lda player_lives
  bne update_player_hit_respawn
  jmp enter_game_over_state
update_player_hit_respawn:
  jmp enter_respawn_state

update_respawn_state:
  lda game_state_timer
  beq update_respawn_state_done
  dec game_state_timer
  lda game_state_timer
  sta player_respawn_timer
  bne update_game_state_done
update_respawn_state_done:
  jmp enter_playing_state

update_game_over_state:
  jsr read_player_input
  lda effective_fire
  beq update_game_over_wait_release
  lda fire_locked
  bne update_game_state_done
  jmp start_new_game

update_game_over_wait_release:
  lda #$00
  sta fire_locked
  rts

update_wave_clear_state:
  lda game_state_timer
  beq update_wave_clear_state_done
  dec game_state_timer
  bne update_game_state_done
update_wave_clear_state_done:
  jmp start_new_wave

update_game_state_done:
  rts

player_can_be_hit:
  lda game_state
  cmp #GAME_STATE_PLAYING
  bne player_cannot_be_hit
  lda player_visible
  beq player_cannot_be_hit
  sec
  rts

player_cannot_be_hit:
  clc
  rts

check_wave_cleared:
  lda game_state
  cmp #GAME_STATE_PLAYING
  bne check_wave_cleared_done

  ldx #$00
check_wave_cleared_loop:
  lda formation_slot0_alive, x
  bne check_wave_cleared_done
  inx
  cpx #FORMATION_SLOT_COUNT
  bcc check_wave_cleared_loop

  jsr enter_wave_clear_state
check_wave_cleared_done:
  rts

update_effects:
  lda hit_flash_timer
  beq effects_check_player_explosion

  dec hit_flash_timer
  lda #HIT_FLASH_COLOR
  sta BORDER_COLOR

  lda hit_flash_timer
  bne effects_check_player_explosion

  lda #BORDER_BASE_COLOR
  sta BORDER_COLOR
effects_check_player_explosion:
  jsr update_player_explosion
effects_done:
  rts

update_formation:
  lda game_state
  cmp #GAME_STATE_PLAYING
  beq update_formation_active
  jmp formation_done

update_formation_active:
  inc formation_frame
  jsr update_formation_animation_state
  dec formation_move_timer
  beq formation_move_timer_elapsed
  jmp formation_done
formation_move_timer_elapsed:
  lda #FORMATION_MOVE_PERIOD
  sta formation_move_timer

formation_move_tick:
  jsr update_formation_bounds

  lda formation_dir
  bpl formation_move_right

formation_move_left:
  lda formation_x_lo
  bne formation_dec_low
  dec formation_x_hi
formation_dec_low:
  dec formation_x_lo

  lda formation_x_lo
  sec
  sbc formation_bound_min_lo
  lda formation_x_hi
  sbc formation_bound_min_hi
  bvc formation_check_min_sign
  eor #$80
formation_check_min_sign:
  bmi formation_clamp_min
  jmp formation_store_x

formation_clamp_min:
  lda formation_bound_min_lo
  sta formation_x_lo
  lda formation_bound_min_hi
  sta formation_x_hi
  lda #$01
  sta formation_dir
  jmp formation_store_x

formation_move_right:
  inc formation_x_lo
  bne formation_check_max
  inc formation_x_hi

formation_check_max:
  lda formation_x_lo
  sec
  sbc formation_bound_max_lo
  lda formation_x_hi
  sbc formation_bound_max_hi
  bvc formation_check_max_sign
  eor #$80
formation_check_max_sign:
  bmi formation_store_x
  jmp formation_clamp_char_max

formation_clamp_char_max:
  lda formation_bound_max_lo
  sta formation_x_lo
  lda formation_bound_max_hi
  sta formation_x_hi
  lda #$ff
  sta formation_dir

formation_store_x:
  jsr update_formation_slot_positions
  lda formation_anchor_col
  cmp formation_render_anchor_col
  bne formation_store_x_mark_dirty
  jmp formation_done
formation_store_x_mark_dirty:
  lda #$01
  sta formation_render_dirty

formation_done:
  rts

update_formation_animation_state:
  lda formation_frame
  .for (var i = 0; i < FORMATION_ANIMATION_SHIFT; i++) {
    lsr
  }
  and #%00000011
  cmp formation_anim_index
  beq update_formation_animation_state_done
  sta formation_anim_index
  lda #$01
  sta formation_render_dirty
update_formation_animation_state_done:
  rts

update_formation_bounds:
  ldx #$00
update_formation_bounds_find_first_live:
  lda formation_slot0_alive, x
  bne update_formation_bounds_first_live_found
  inx
  cpx #FORMATION_SLOT_COUNT
  bcc update_formation_bounds_find_first_live

  lda #$00
  sta formation_live_min_offset
  sta formation_live_max_offset
  jmp update_formation_bounds_store

update_formation_bounds_first_live_found:
  lda formation_slot_offset_table, x
  sta formation_live_min_offset
  sta formation_live_max_offset
  inx

update_formation_bounds_scan:
  cpx #FORMATION_SLOT_COUNT
  bcs update_formation_bounds_store
  lda formation_slot0_alive, x
  beq update_formation_bounds_next

  lda formation_slot_offset_table, x
  cmp formation_live_min_offset
  bcs update_formation_bounds_check_max
  sta formation_live_min_offset

update_formation_bounds_check_max:
  lda formation_slot_offset_table, x
  cmp formation_live_max_offset
  bcc update_formation_bounds_next
  sta formation_live_max_offset

update_formation_bounds_next:
  inx
  cpx #FORMATION_SLOT_COUNT
  bcc update_formation_bounds_scan

update_formation_bounds_store:
  lda #FORMATION_CHAR_MIN_X_LO
  sec
  sbc formation_live_min_offset
  sta formation_bound_min_lo
  lda #FORMATION_CHAR_MIN_X_HI
  sbc #$00
  sta formation_bound_min_hi
  lda #FORMATION_CHAR_DYNAMIC_MAX_X_LO
  sec
  sbc formation_live_max_offset
  sta formation_bound_max_lo
  lda #FORMATION_CHAR_DYNAMIC_MAX_X_HI
  sbc #$00
  sta formation_bound_max_hi
  rts

update_dive_attack:
  lda game_state
  cmp #GAME_STATE_PLAYING
  beq update_dive_attack_active
  rts

update_dive_attack_active:
  lda enemy_attack_active
  bne update_dive_attack_run
  rts

update_dive_attack_run:
  lda dive_active
  beq dive_wait_for_launch

  lda #$00
  sta dive_moved_this_tick
  lda dive_launch_hold
  beq update_dive_attack_phase_check
  jsr store_dive_position
  dec dive_launch_hold
  rts

update_dive_attack_phase_check:
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
  jsr update_formation_slot_positions
  jsr clear_active_dive_state
  jsr mark_formation_full_redraw
  rts

launch_dive_if_possible:
  lda dive_column_toggle
  beq launch_dive_left_column_first

  lda #<formation_launch_order_right_first
  sta SCREEN_PTR
  lda #>formation_launch_order_right_first
  sta SCREEN_PTR + 1
  jmp launch_dive_order_ready

launch_dive_left_column_first:
  lda #<formation_launch_order_left_first
  sta SCREEN_PTR
  lda #>formation_launch_order_left_first
  sta SCREEN_PTR + 1

launch_dive_order_ready:
  ldy #$00
launch_dive_if_possible_loop:
  lda (SCREEN_PTR), y
  tax
  jsr try_launch_slot
  bcs dive_launch_success
  iny
  cpy #FORMATION_DIVE_CANDIDATE_COUNT
  bcc launch_dive_if_possible_loop
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

try_launch_slot:
  lda formation_slot0_alive, x
  bne try_launch_slot_begin
  clc
  rts
try_launch_slot_begin:
  txa
  sta dive_slot
  jsr load_formation_slot_position
  sta dive_x_lo
  sty dive_x_hi
  lda formation_slot_dive_direction_table, x
  sta dive_direction
  jmp begin_dive

begin_dive:
  ldx dive_slot
  jsr load_slot_visual_y
  sta dive_y
  sta dive_launch_y_debug
  inc dive_launch_counter
  lda #$01
  sta dive_launch_hold
  jsr clear_dive_slot_char_handoff
  jsr mark_formation_full_redraw
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
  jmp store_dive_position_char

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

update_enemy_fire:
  lda game_state
  cmp #GAME_STATE_PLAYING
  beq update_enemy_fire_active
  rts

update_enemy_fire_active:
  lda enemy_attack_active
  beq update_enemy_fire_done
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
update_enemy_fire_done:
  rts

try_spawn_enemy_bullet:
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
  jsr player_can_be_hit
  bcc enemy_bullet_miss

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
  jsr player_can_be_hit
  bcc dive_hits_player_miss

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
  jsr player_can_be_hit
  bcc handle_player_hit_done
  jsr enter_player_hit_state
handle_player_hit_done:
  rts

respawn_player:
  jmp restore_player_ship

update_player:
  lda game_state
  cmp #GAME_STATE_PLAYING
  beq update_player_controls
  cmp #GAME_STATE_RESPAWN
  beq update_player_controls
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

start_player_explosion:
  lda #$01
  sta player_explosion_active
  lda #$00
  sta player_explosion_frame
  lda #PLAYER_EXPLOSION_FRAME_TICKS
  sta player_explosion_timer

  lda player_x_lo
  sec
  sbc #PLAYER_EXPLOSION_LEFT_OFFSET
  sta player_explosion_x_lo
  lda player_x_hi
  sbc #$00
  sta player_explosion_x_hi

  lda #(PLAYER_Y - PLAYER_EXPLOSION_TOP_OFFSET)
  sta player_explosion_y
  rts

update_player_explosion:
  lda player_explosion_active
  beq update_player_explosion_done

  lda player_explosion_timer
  beq update_player_explosion_advance
  dec player_explosion_timer
  bne update_player_explosion_done

update_player_explosion_advance:
  inc player_explosion_frame
  lda player_explosion_frame
  cmp #PLAYER_EXPLOSION_FRAME_COUNT
  bcc update_player_explosion_next_frame
  jmp finish_player_explosion

update_player_explosion_next_frame:
  lda #PLAYER_EXPLOSION_FRAME_TICKS
  sta player_explosion_timer
update_player_explosion_done:
  rts

finish_player_explosion:
  lda #$00
  sta player_explosion_active
  sta player_explosion_timer
  sta player_explosion_frame

  lda SPRITE_ENABLE
  and #%11111001
  sta SPRITE_ENABLE

  lda SPRITE_X_MSB
  and #%11111001
  sta SPRITE_X_MSB

  lda SPRITE_MULTICOLOR
  and #%11111001
  sta SPRITE_MULTICOLOR
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
  lda game_state
  cmp #GAME_STATE_PLAYING
  beq update_shot_active
  cmp #GAME_STATE_RESPAWN
  beq update_shot_active
shot_done:
  rts

update_shot_active:
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
  rts

check_shot_collision:
  lda dive_active
  beq check_shot_collision_slots
  lda dive_x_lo
  sta target_x_lo
  lda dive_x_hi
  sta target_x_hi
  lda dive_y
  sta target_y
  jsr shot_hits_target
  bcc check_shot_collision_slots
  jsr destroy_current_dive_slot
  sec
  rts

check_shot_collision_slots:
  ldx #$00
check_shot_collision_slot_loop:
  lda dive_active
  beq check_shot_collision_slot_alive
  cpx dive_slot
  beq check_shot_collision_next_slot
check_shot_collision_slot_alive:
  lda formation_slot0_alive, x
  beq check_shot_collision_next_slot
  jsr load_formation_slot_position
  sta target_x_lo
  sty target_x_hi
  jsr load_slot_visual_y
  sta target_y
  jsr shot_hits_target
  bcc check_shot_collision_next_slot
  txa
  jsr destroy_slot
  sec
  rts
check_shot_collision_next_slot:
  inx
  cpx #FORMATION_SLOT_COUNT
  bcc check_shot_collision_slot_loop

no_shot_hit:
  clc
  rts

destroy_current_dive_slot:
  lda dive_slot
  cmp #DIVE_SLOT_NONE
  beq destroy_current_dive_slot_done
  jmp destroy_slot
destroy_current_dive_slot_done:
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
  sta enemy_attack_active
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

enemy_hit_anim_next:
  inx
  cpx #FORMATION_SLOT_COUNT
  bcc enemy_hit_anim_loop
  rts

start_slot_explosion:
  tax
  lda #$00
  sta slot_explosion_frame, x
  lda #ENEMY_EXPLOSION_FRAME_TICKS
  sta slot_explosion_timer, x
  rts

finish_slot_explosion:
  tax
  lda #$00
  sta slot_explosion_timer, x
  sta slot_explosion_frame, x
  rts

destroy_slot:
  tax
  lda formation_slot0_alive, x
  bne destroy_slot_live
  rts
destroy_slot_live:
  lda #$00
  sta formation_slot0_alive, x
  jsr mark_formation_full_redraw
  txa
  pha
  jsr clear_dive_slot_char_handoff_if_active
  jsr update_formation_bounds
  jsr update_formation_slot_positions
  pla
  tax
  txa
  jsr store_slot_explosion_position
  txa
  jsr clear_dive_if_slot
  txa
  jsr start_slot_explosion
  jmp award_score_for_slot

clear_dive_if_slot:
  tax
  lda dive_active
  beq clear_dive_done
  cpx dive_slot
  bne clear_dive_done

  jsr clear_active_dive_state
clear_dive_done:
  rts

clear_dive_slot_char_handoff_if_active:
  lda dive_active
  beq clear_dive_slot_char_handoff_if_active_done
  txa
  cmp dive_slot
  bne clear_dive_slot_char_handoff_if_active_done
  jmp clear_dive_slot_char_handoff
clear_dive_slot_char_handoff_if_active_done:
  rts

award_score_for_slot:
  lda formation_slot_score_lo_table, x
  sta score_award_lo
  lda formation_slot_score_mid_table, x
  sta score_award_mid
  lda formation_slot_score_hi_table, x
  sta score_award_hi
  jsr add_score_award
  jsr check_wave_cleared
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
  jsr update_score_display
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

update_formation_slot_positions:
  ldx #$00
update_formation_slot_positions_loop:
  txa
  asl
  tay
  lda formation_x_lo
  clc
  adc formation_slot_offset_table, x
  sta formation_slot0_x_lo, y
  lda formation_x_hi
  adc #$00
  sta formation_slot0_x_hi, y
  inx
  cpx #FORMATION_SLOT_COUNT
  bcc update_formation_slot_positions_loop

  lda formation_x_lo
  clc
  adc formation_live_min_offset
  sta formation_char_relative_lo
  lda formation_x_hi
  adc #$00
  sta formation_char_relative_hi

update_formation_shift_phase_store:
  lda formation_char_relative_lo
  sec
  sbc #PLAYFIELD_LEFT_X_LO
  sta formation_char_relative_lo
  lda formation_char_relative_hi
  sbc #PLAYFIELD_LEFT_X_HI
  sta formation_char_relative_hi

  lda formation_char_relative_lo
  and #%00000111
  sta formation_shift_phase

  lsr formation_char_relative_hi
  ror formation_char_relative_lo
  lsr formation_char_relative_hi
  ror formation_char_relative_lo
  lsr formation_char_relative_hi
  ror formation_char_relative_lo

  lda formation_char_relative_lo
  sta formation_anchor_col
  cmp formation_render_anchor_col
  bne update_formation_shift_phase_store_done
  lda formation_shift_phase
  sta formation_render_scroll_phase
update_formation_shift_phase_store_done:
  rts

load_formation_slot_position:
  txa
  asl
  tay
  lda formation_slot0_x_lo, y
  pha
  lda formation_slot0_x_hi, y
  tay
  pla
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

* = $4000 "Player Effect Routines"

draw_player_bottom_effects:
  lda player_explosion_active
  beq draw_player_bottom_effects_player
  jsr draw_player_explosion
  jmp render_char_mode_enemy_effects_bottom
draw_player_bottom_effects_player:
  jsr draw_player_extra_layers
  jmp render_char_mode_enemy_effects_bottom

draw_player_extra_layers:
  jmp draw_player_extra_layers_char

draw_player_explosion:
  jmp draw_player_explosion_char

store_player_explosion_sprite1:
  lda player_explosion_x_lo
  sta SPRITE1_X
  lda player_explosion_y
  sta SPRITE1_Y
  lda SPRITE_X_MSB
  and #%11111101
  ldy player_explosion_x_hi
  beq store_player_explosion_sprite1_msb_done
  ora #%00000010
store_player_explosion_sprite1_msb_done:
  sta SPRITE_X_MSB
  lda player_explosion_top_left_pointer
  sta SPRITE_POINTERS + 1
  lda #PLAYER_EXPLOSION_COLOR
  sta SPRITE1_COLOR
  lda SPRITE_MULTICOLOR
  ora #%00000010
  sta SPRITE_MULTICOLOR
  lda SPRITE_ENABLE
  ora #%00000010
  sta SPRITE_ENABLE
  rts

store_player_explosion_sprite2:
  lda player_explosion_x_lo
  clc
  adc #PLAYER_EXPLOSION_TILE_OFFSET
  sta SPRITE2_X
  lda player_explosion_y
  sta SPRITE2_Y
  ldy player_explosion_x_hi
  tya
  adc #$00
  tay
  lda SPRITE_X_MSB
  and #%11111011
  cpy #$00
  beq store_player_explosion_sprite2_msb_done
  ora #%00000100
store_player_explosion_sprite2_msb_done:
  sta SPRITE_X_MSB
  lda player_explosion_top_right_pointer
  sta SPRITE_POINTERS + 2
  lda #PLAYER_EXPLOSION_COLOR
  sta SPRITE2_COLOR
  lda SPRITE_MULTICOLOR
  ora #%00000100
  sta SPRITE_MULTICOLOR
  lda SPRITE_ENABLE
  ora #%00000100
  sta SPRITE_ENABLE
  rts

render_formation:
  lda formation_shift_phase
  sta formation_render_scroll_phase
  lda #$00
  sta formation_char_render_mask_pending
  sta formation_char_render_mask_pending_hi
  sta formation_char_render_mask_pending_hi2
  lda formation_full_redraw_pending
  beq render_formation_check_edge_clear
  jsr clear_formation_char_band
  lda #$00
  sta formation_full_redraw_pending
  jmp render_formation_slots
render_formation_check_edge_clear:
  lda formation_anchor_col
  cmp formation_render_anchor_col
  beq render_formation_slots
  lda formation_clear_strategy
  cmp #FORMATION_CLEAR_STRATEGY_ROWWISE
  beq render_formation_edge_clear_rowwise
  jsr clear_formation_char_exposed_columns_global
  jmp render_formation_slots
render_formation_edge_clear_rowwise:
  jsr clear_formation_char_exposed_columns_rowwise
render_formation_slots:
  ldx #$00
render_formation_slot_state_loop:
  jsr render_formation_char_slot_state
  inx
  cpx #FORMATION_SLOT_COUNT
  bcc render_formation_slot_state_loop
  lda formation_char_render_mask_pending
  sta formation_char_render_mask
  lda formation_char_render_mask_pending_hi
  sta formation_char_render_mask_hi
  lda formation_char_render_mask_pending_hi2
  sta formation_char_render_mask_hi2
  lda formation_anchor_col
  sta formation_render_anchor_col
  rts

render_formation_char_slot_state:
  lda dive_active
  beq render_formation_char_slot_check_explosion
  cpx dive_slot
  beq render_formation_char_slot_clear
render_formation_char_slot_check_explosion:
  lda slot_explosion_timer, x
  beq render_formation_char_slot_check_alive
render_formation_char_slot_clear:
  jsr load_formation_slot_position
  sta formation_char_slot_x_lo
  sty formation_char_slot_x_hi
  ldy formation_char_row_table, x
  jsr clear_formation_char_slot_screen
  rts
render_formation_char_slot_check_alive:
  lda formation_slot0_alive, x
  beq render_formation_char_slot_disable
  jmp draw_formation_char_slot
render_formation_char_slot_disable:
  rts

draw_formation_char_slot:
  ldy formation_anim_index
  lda formation_anim_frame_offset_table, y
  clc
  adc formation_slot_char_frame_base_table, x
  sta formation_char_value
  jsr load_formation_slot_position
  sta formation_char_slot_x_lo
  sty formation_char_slot_x_hi
  lda formation_char_color_table, x
  sta formation_char_color
  ldy formation_char_row_table, x
  jsr draw_formation_char_slot_common
  lda formation_char_render_mask_pending
  ora formation_char_render_bit_table, x
  sta formation_char_render_mask_pending
  lda formation_char_render_mask_pending_hi
  ora formation_char_render_bit_hi_table, x
  sta formation_char_render_mask_pending_hi
  lda formation_char_render_mask_pending_hi2
  ora formation_char_render_bit_hi2_table, x
  sta formation_char_render_mask_pending_hi2
  rts

draw_formation_char_slot_common:
  sty formation_char_row

  lda formation_char_slot_x_lo
  sec
  sbc #PLAYFIELD_LEFT_X_LO
  sta formation_char_relative_lo
  lda formation_char_slot_x_hi
  sbc #PLAYFIELD_LEFT_X_HI
  sta formation_char_relative_hi

  jsr prepare_formation_char_slot_column
  sta formation_char_last_col, x
  lda formation_char_clear_count
  sta formation_char_last_clear_count, x

  jsr update_formation_char_slot_glyphs

  ldy formation_char_row
  lda screen_row_lo, y
  sta SCREEN_PTR
  lda screen_row_hi, y
  sta SCREEN_PTR + 1
  lda color_row_lo, y
  sta COLOR_PTR
  lda color_row_hi, y
  sta COLOR_PTR + 1

  txa
  pha
  ldy formation_char_col
  ldx #$00
draw_formation_char_slot_common_loop:
  cpy #(FORMATION_CHAR_BAND_ORIGIN_COL + FORMATION_CHAR_BAND_WIDTH)
  bcs draw_formation_char_slot_common_done
  txa
  clc
  adc formation_char_glyph_base
  sta (SCREEN_PTR), y
  lda formation_char_color
  ora #FORMATION_CHAR_MULTICOLOR_FLAG
  sta (COLOR_PTR), y
  iny
  inx
  cpx #$04
  bcc draw_formation_char_slot_common_loop
draw_formation_char_slot_common_done:
  pla
  tax
  rts

prepare_formation_char_slot_column:
  lda formation_char_relative_lo
  sec
  sbc formation_render_scroll_phase
  sta formation_char_relative_lo
  lda formation_char_relative_hi
  sbc #$00
  sta formation_char_relative_hi

  lda #$00
  sta formation_char_glyph_skip
  lda #$04
  sta formation_char_clear_count
  lda formation_char_relative_hi
  bpl prepare_formation_char_slot_column_shift
  lda #$01
  sta formation_char_glyph_skip

prepare_formation_char_slot_column_shift:
  lda formation_char_relative_lo
  and #%00000111
  sta formation_char_shift_phase_local

  lsr formation_char_relative_hi
  ror formation_char_relative_lo
  lsr formation_char_relative_hi
  ror formation_char_relative_lo
  lsr formation_char_relative_hi
  ror formation_char_relative_lo

  lda formation_char_relative_lo
  clc
  adc #FORMATION_CHAR_BAND_ORIGIN_COL
  sta formation_char_col

  lda formation_char_glyph_skip
  beq prepare_formation_char_slot_column_done
  lda #FORMATION_CHAR_BAND_ORIGIN_COL
  sta formation_char_col
prepare_formation_char_slot_column_done:
  lda formation_char_col
  rts

clear_formation_char_slot_screen:
  sty formation_char_row

  lda formation_char_slot_x_lo
  sec
  sbc #PLAYFIELD_LEFT_X_LO
  sta formation_char_relative_lo
  lda formation_char_slot_x_hi
  sbc #PLAYFIELD_LEFT_X_HI
  sta formation_char_relative_hi

  jsr prepare_formation_char_slot_column

  ldy formation_char_row
  lda screen_row_lo, y
  sta SCREEN_PTR
  lda screen_row_hi, y
  sta SCREEN_PTR + 1
  lda color_row_lo, y
  sta COLOR_PTR
  lda color_row_hi, y
  sta COLOR_PTR + 1

  txa
  pha
  ldy formation_char_col
  ldx #$00
clear_formation_char_slot_screen_loop:
  cpy #(FORMATION_CHAR_BAND_ORIGIN_COL + FORMATION_CHAR_BAND_WIDTH)
  bcs clear_formation_char_slot_screen_done
  lda #$20
  sta (SCREEN_PTR), y
  lda #PLAYFIELD_TEXT_COLOR
  sta (COLOR_PTR), y
  iny
  inx
  cpx formation_char_clear_count
  bcc clear_formation_char_slot_screen_loop
clear_formation_char_slot_screen_done:
  pla
  tax
  rts

clear_formation_char_slot_saved:
  txa
  pha

  lda formation_char_row_table, x
  tay
  lda screen_row_lo, y
  sta SCREEN_PTR
  lda screen_row_hi, y
  sta SCREEN_PTR + 1
  lda color_row_lo, y
  sta COLOR_PTR
  lda color_row_hi, y
  sta COLOR_PTR + 1

  lda formation_char_last_col, x
  tay
  lda formation_char_last_clear_count, x
  sta formation_char_clear_count
  ldx #$00
clear_formation_char_slot_saved_loop:
  cpy #(FORMATION_CHAR_BAND_ORIGIN_COL + FORMATION_CHAR_BAND_WIDTH)
  bcs clear_formation_char_slot_saved_done
  lda #$20
  sta (SCREEN_PTR), y
  lda #PLAYFIELD_TEXT_COLOR
  sta (COLOR_PTR), y
  iny
  inx
  cpx formation_char_clear_count
  bcc clear_formation_char_slot_saved_loop
clear_formation_char_slot_saved_done:
  pla
  tax
  rts

update_formation_char_slot_glyphs:
  jsr load_formation_char_glyph_slot

  lda formation_char_value
  clc
  adc #>formation_bitmap_shifted_frames
  sta SCREEN_PTR + 1
  lda formation_char_shift_phase_local
  asl
  asl
  asl
  asl
  asl
  sta SCREEN_PTR

  ldy #$00
update_formation_char_slot_glyphs_loop:
  lda (SCREEN_PTR), y
  sta (COLOR_PTR), y
  iny
  cpy #$20
  bcc update_formation_char_slot_glyphs_loop
  rts

// Slot glyphs now span multiple charset pages, so use table-driven
// addresses instead of relying on wrapped 8-bit offsets.
load_formation_char_glyph_slot:
  lda formation_char_glyph_base_table, x
  sta formation_char_glyph_base
  lda formation_char_glyph_addr_lo_table, x
  sta COLOR_PTR
  lda formation_char_glyph_addr_hi_table, x
  sta COLOR_PTR + 1
  rts

clear_formation_char_slot_glyphs:
  jsr load_formation_char_glyph_slot
  lda #$00
  ldy #$00
clear_formation_char_slot_glyphs_loop:
  sta (COLOR_PTR), y
  iny
  cpy #$20
  bcc clear_formation_char_slot_glyphs_loop
  rts

clear_formation_char_glyphs:
  ldx #$00
clear_formation_char_glyphs_loop:
  jsr clear_formation_char_slot_glyphs
  inx
  cpx #FORMATION_SLOT_COUNT
  bcc clear_formation_char_glyphs_loop
  rts

clear_formation_char_band:
  ldx #$00
clear_formation_char_band_loop:
  lda formation_char_band_rows, x
  tay
  lda screen_row_lo, y
  sta SCREEN_PTR
  lda screen_row_hi, y
  sta SCREEN_PTR + 1
  lda color_row_lo, y
  sta COLOR_PTR
  lda color_row_hi, y
  sta COLOR_PTR + 1

  ldy #FORMATION_CHAR_BAND_ORIGIN_COL
clear_formation_char_band_row_loop:
  lda #$20
  sta (SCREEN_PTR), y
  lda #PLAYFIELD_TEXT_COLOR
  sta (COLOR_PTR), y
  iny
  cpy #(FORMATION_CHAR_BAND_ORIGIN_COL + FORMATION_CHAR_BAND_WIDTH)
  bcc clear_formation_char_band_row_loop

  inx
  cpx #FORMATION_CHAR_BAND_HEIGHT
  bcc clear_formation_char_band_loop
  rts

clear_formation_char_exposed_columns_global:
  lda formation_live_max_offset
  sec
  sbc formation_live_min_offset
  lsr
  lsr
  lsr
  clc
  adc #$04
  sta formation_clear_row_width_cols

  lda #$00
  sta formation_clear_row_offset_cols

  ldx #$00
clear_formation_char_exposed_columns_global_loop:
  jsr clear_formation_char_exposed_columns_apply_row
  inx
  cpx #FORMATION_CHAR_BAND_HEIGHT
  bcc clear_formation_char_exposed_columns_global_loop
  rts

clear_formation_char_exposed_columns_rowwise:
  ldx #$00
clear_formation_char_exposed_columns_rowwise_loop:
  jsr clear_formation_char_exposed_columns_prepare_rowwise
  inx
  cpx #FORMATION_CHAR_BAND_HEIGHT
  bcc clear_formation_char_exposed_columns_rowwise_loop
  rts

clear_formation_char_exposed_columns_prepare_rowwise:
  lda #$ff
  sta formation_clear_row_min_offset
  lda #$00
  sta formation_clear_row_max_offset

  ldy formation_clear_slot_scan_start_table, x
  lda formation_clear_slot_scan_end_table, x
  sta formation_clear_scan_end
clear_formation_char_exposed_columns_scan_loop:
  cpy formation_clear_scan_end
  bcs clear_formation_char_exposed_columns_scan_done
  lda formation_slot0_alive, y
  beq clear_formation_char_exposed_columns_scan_next

  lda formation_slot_offset_table, y
  cmp formation_clear_row_min_offset
  bcs clear_formation_char_exposed_columns_check_max
  sta formation_clear_row_min_offset
clear_formation_char_exposed_columns_check_max:
  lda formation_slot_offset_table, y
  cmp formation_clear_row_max_offset
  bcc clear_formation_char_exposed_columns_scan_next
  sta formation_clear_row_max_offset
clear_formation_char_exposed_columns_scan_next:
  iny
  jmp clear_formation_char_exposed_columns_scan_loop

clear_formation_char_exposed_columns_scan_done:
  lda formation_clear_row_min_offset
  cmp #$ff
  bne clear_formation_char_exposed_columns_prepare_rowwise_live
  jmp clear_formation_char_exposed_columns_done
clear_formation_char_exposed_columns_prepare_rowwise_live:
  sec
  sbc formation_live_min_offset
  lsr
  lsr
  lsr
  sta formation_clear_row_offset_cols

  lda formation_clear_row_max_offset
  sec
  sbc formation_live_min_offset
  lsr
  lsr
  lsr
  clc
  adc #$04
  sec
  sbc formation_clear_row_offset_cols
  sta formation_clear_row_width_cols

clear_formation_char_exposed_columns_apply_row:
  lda formation_render_anchor_col
  clc
  adc formation_clear_row_offset_cols
  sta formation_clear_old_start_col
  lda formation_anchor_col
  clc
  adc formation_clear_row_offset_cols
  sta formation_clear_new_start_col

  lda formation_anchor_col
  cmp formation_render_anchor_col
  bcc clear_formation_char_exposed_columns_left
  lda formation_clear_old_start_col
  sta formation_clear_start_col
  lda formation_clear_new_start_col
  sta formation_clear_end_col
  jmp clear_formation_char_exposed_columns_clamp

clear_formation_char_exposed_columns_left:
  lda formation_clear_new_start_col
  clc
  adc formation_clear_row_width_cols
  sta formation_clear_start_col
  lda formation_clear_old_start_col
  clc
  adc formation_clear_row_width_cols
  sta formation_clear_end_col

clear_formation_char_exposed_columns_clamp:
  lda formation_clear_start_col
  cmp formation_clear_end_col
  bcs clear_formation_char_exposed_columns_done
  cmp #(FORMATION_CHAR_BAND_ORIGIN_COL + FORMATION_CHAR_BAND_WIDTH)
  bcs clear_formation_char_exposed_columns_done

  lda formation_clear_end_col
  cmp #(FORMATION_CHAR_BAND_ORIGIN_COL + FORMATION_CHAR_BAND_WIDTH)
  bcc clear_formation_char_exposed_columns_row
  lda #(FORMATION_CHAR_BAND_ORIGIN_COL + FORMATION_CHAR_BAND_WIDTH)
  sta formation_clear_end_col

clear_formation_char_exposed_columns_row:
  lda formation_char_band_rows, x
  tay
  lda screen_row_lo, y
  sta SCREEN_PTR
  lda screen_row_hi, y
  sta SCREEN_PTR + 1
  lda color_row_lo, y
  sta COLOR_PTR
  lda color_row_hi, y
  sta COLOR_PTR + 1

  ldy formation_clear_start_col
clear_formation_char_exposed_columns_row_loop:
  lda #$20
  sta (SCREEN_PTR), y
  lda #PLAYFIELD_TEXT_COLOR
  sta (COLOR_PTR), y
  iny
  cpy formation_clear_end_col
  bcc clear_formation_char_exposed_columns_row_loop

clear_formation_char_exposed_columns_done:
  rts

* = $4d40 "Main Data"

formation_x_lo:
  .byte FORMATION_START_X_LO
formation_x_hi:
  .byte FORMATION_START_X_HI
formation_dir:
  .byte $01
formation_frame:
  .byte $00
formation_move_timer:
  .byte FORMATION_MOVE_PERIOD
formation_bound_min_lo:
  .byte FORMATION_CHAR_MIN_X_LO
formation_bound_min_hi:
  .byte FORMATION_CHAR_MIN_X_HI
formation_bound_max_lo:
  .byte FORMATION_CHAR_MAX_X_LO
formation_bound_max_hi:
  .byte FORMATION_CHAR_MAX_X_HI
formation_live_min_offset:
  .byte FORMATION_SLOT10_OFFSET
formation_live_max_offset:
  .byte FORMATION_SLOT17_OFFSET
formation_slot0_x_lo:
  .byte <(FORMATION_START_X_LO + FORMATION_SLOT0_OFFSET)
formation_slot0_x_hi:
  .byte >(FORMATION_START_X_LO + FORMATION_SLOT0_OFFSET)
formation_slot1_x_lo:
  .byte <(FORMATION_START_X_LO + FORMATION_SLOT1_OFFSET)
formation_slot1_x_hi:
  .byte >(FORMATION_START_X_LO + FORMATION_SLOT1_OFFSET)
formation_slot2_x_lo:
  .byte <(FORMATION_START_X_LO + FORMATION_SLOT2_OFFSET)
formation_slot2_x_hi:
  .byte >(FORMATION_START_X_LO + FORMATION_SLOT2_OFFSET)
formation_slot3_x_lo:
  .byte <(FORMATION_START_X_LO + FORMATION_SLOT3_OFFSET)
formation_slot3_x_hi:
  .byte >(FORMATION_START_X_LO + FORMATION_SLOT3_OFFSET)
formation_slot4_x_lo:
  .byte <(FORMATION_START_X_LO + FORMATION_SLOT4_OFFSET)
formation_slot4_x_hi:
  .byte >(FORMATION_START_X_LO + FORMATION_SLOT4_OFFSET)
formation_slot5_x_lo:
  .byte <(FORMATION_START_X_LO + FORMATION_SLOT5_OFFSET)
formation_slot5_x_hi:
  .byte >(FORMATION_START_X_LO + FORMATION_SLOT5_OFFSET)
formation_slot6_x_lo:
  .byte <(FORMATION_START_X_LO + FORMATION_SLOT6_OFFSET)
formation_slot6_x_hi:
  .byte >(FORMATION_START_X_LO + FORMATION_SLOT6_OFFSET)
formation_slot7_x_lo:
  .byte <(FORMATION_START_X_LO + FORMATION_SLOT7_OFFSET)
formation_slot7_x_hi:
  .byte >(FORMATION_START_X_LO + FORMATION_SLOT7_OFFSET)
formation_slot8_x_lo:
  .byte <(FORMATION_START_X_LO + FORMATION_SLOT8_OFFSET)
formation_slot8_x_hi:
  .byte >(FORMATION_START_X_LO + FORMATION_SLOT8_OFFSET)
formation_slot9_x_lo:
  .byte <(FORMATION_START_X_LO + FORMATION_SLOT9_OFFSET)
formation_slot9_x_hi:
  .byte >(FORMATION_START_X_LO + FORMATION_SLOT9_OFFSET)
formation_slot10_x_lo:
  .byte <(FORMATION_START_X_LO + FORMATION_SLOT10_OFFSET)
formation_slot10_x_hi:
  .byte >(FORMATION_START_X_LO + FORMATION_SLOT10_OFFSET)
formation_slot11_x_lo:
  .byte <(FORMATION_START_X_LO + FORMATION_SLOT11_OFFSET)
formation_slot11_x_hi:
  .byte >(FORMATION_START_X_LO + FORMATION_SLOT11_OFFSET)
formation_slot12_x_lo:
  .byte <(FORMATION_START_X_LO + FORMATION_SLOT12_OFFSET)
formation_slot12_x_hi:
  .byte >(FORMATION_START_X_LO + FORMATION_SLOT12_OFFSET)
formation_slot13_x_lo:
  .byte <(FORMATION_START_X_LO + FORMATION_SLOT13_OFFSET)
formation_slot13_x_hi:
  .byte >(FORMATION_START_X_LO + FORMATION_SLOT13_OFFSET)
formation_slot14_x_lo:
  .byte <(FORMATION_START_X_LO + FORMATION_SLOT14_OFFSET)
formation_slot14_x_hi:
  .byte >(FORMATION_START_X_LO + FORMATION_SLOT14_OFFSET)
formation_slot15_x_lo:
  .byte <(FORMATION_START_X_LO + FORMATION_SLOT15_OFFSET)
formation_slot15_x_hi:
  .byte >(FORMATION_START_X_LO + FORMATION_SLOT15_OFFSET)
formation_slot16_x_lo:
  .byte <(FORMATION_START_X_LO + FORMATION_SLOT16_OFFSET)
formation_slot16_x_hi:
  .byte >(FORMATION_START_X_LO + FORMATION_SLOT16_OFFSET)
formation_slot17_x_lo:
  .byte <(FORMATION_START_X_LO + FORMATION_SLOT17_OFFSET)
formation_slot17_x_hi:
  .byte >(FORMATION_START_X_LO + FORMATION_SLOT17_OFFSET)
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
formation_slot6_alive:
  .byte $01
formation_slot7_alive:
  .byte $01
formation_slot8_alive:
  .byte $01
formation_slot9_alive:
  .byte $01
formation_slot10_alive:
  .byte $01
formation_slot11_alive:
  .byte $01
formation_slot12_alive:
  .byte $01
formation_slot13_alive:
  .byte $01
formation_slot14_alive:
  .byte $01
formation_slot15_alive:
  .byte $01
formation_slot16_alive:
  .byte $01
formation_slot17_alive:
  .byte $01
slot_explosion_timer:
  .fill FORMATION_SLOT_COUNT, $00
slot_explosion_frame:
  .fill FORMATION_SLOT_COUNT, $00
explosion_slot_x_lo:
  .fill FORMATION_SLOT_COUNT, $00
explosion_slot_x_hi:
  .fill FORMATION_SLOT_COUNT, $00
explosion_slot_y:
  .fill FORMATION_SLOT_COUNT, $00
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
dive_launch_counter:
  .byte $00
dive_launch_y_debug:
  .byte $00
dive_launch_hold:
  .byte $00
player_x_lo:
  .byte PLAYER_START_X_LO
player_x_hi:
  .byte PLAYER_START_X_HI
player_visible:
  .byte $00
player_lives:
  .byte $00
player_effect_x_lo:
  .byte $00
player_effect_x_hi:
  .byte $00
player_effect_y:
  .byte $00
player_effect_pointer:
  .byte $00
player_effect_color:
  .byte $00
raster_phase:
  .byte RASTER_PHASE_TOP
player_extra_visible:
  .byte $00
player_bottom_sprite_mask_debug:
  .byte $00
formation_anim_index:
  .byte $00
formation_shift_phase:
  .byte $00
formation_anchor_col:
  .byte $00
formation_render_scroll_phase:
  .byte $00
formation_render_anchor_col:
  .byte $00
formation_render_dirty:
  .byte $01
formation_clear_strategy:
  .byte FORMATION_CLEAR_STRATEGY_ROWWISE
formation_full_redraw_pending:
  .byte $00
formation_clear_row_min_offset:
  .byte $00
formation_clear_row_max_offset:
  .byte $00
formation_clear_row_offset_cols:
  .byte $00
formation_clear_row_width_cols:
  .byte $00
formation_clear_scan_end:
  .byte $00
formation_clear_old_start_col:
  .byte $00
formation_clear_new_start_col:
  .byte $00
formation_clear_start_col:
  .byte $00
formation_clear_end_col:
  .byte $00
frame_capture_counter:
  .byte $00
frame_capture_ready:
  .byte $00
game_state:
  .byte GAME_STATE_READY
game_state_timer:
  .byte $00
enemy_attack_active:
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
player_explosion_active:
  .byte $00
player_explosion_timer:
  .byte $00
player_explosion_frame:
  .byte $00
player_explosion_x_lo:
  .byte $00
player_explosion_x_hi:
  .byte $00
player_explosion_y:
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
formation_char_value:
  .byte $00
formation_char_glyph_base:
  .byte $00
formation_char_color:
  .byte $00
formation_char_row:
  .byte $00
formation_char_col:
  .byte $00
formation_char_slot_x_lo:
  .byte $00
formation_char_slot_x_hi:
  .byte $00
formation_char_relative_lo:
  .byte $00
formation_char_relative_hi:
  .byte $00
formation_char_shift_phase_local:
  .byte $00
formation_char_glyph_skip:
  .byte $00
formation_char_clear_count:
  .byte $04
formation_char_last_col:
  .fill FORMATION_SLOT_COUNT, $00
formation_char_last_clear_count:
  .fill FORMATION_SLOT_COUNT, $00
formation_char_render_mask_pending:
  .byte $00
formation_char_render_mask_pending_hi:
  .byte $00
formation_char_render_mask_pending_hi2:
  .byte $00
formation_char_render_mask:
  .byte $00
formation_char_render_mask_hi:
  .byte $00
formation_char_render_mask_hi2:
  .byte $00
enemy_explosion_pointer:
  .byte $00
char_mode_effect_source_slot:
  .byte $00
char_mode_effect_target_slot:
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
  .byte 19,3,15,18,5,32,48,48,48,48,48,48,32,32,32,32,32,32,32,32,32,32,32,32,32,12,9,22,5,19,32,51,0
ready_message:
  .byte 18,5,1,4,25,0
wave_clear_message:
  .byte 23,1,22,5,32,3,12,5,1,18,0
game_over_message:
  .byte 7,1,13,5,32,15,22,5,18,0
press_fire_message:
  .byte 16,18,5,19,19,32,6,9,18,5,0

flagship_animation_sequence:
  .byte FLAGSHIP_SPRITE0_PTR,FLAGSHIP_SPRITE1_PTR,FLAGSHIP_SPRITE0_PTR,FLAGSHIP_SPRITE1_PTR
escort_animation_sequence:
  .byte ESCORT_SPRITE0_PTR,ESCORT_SPRITE1_PTR,ESCORT_SPRITE0_PTR,ESCORT_SPRITE1_PTR
grunt_animation_sequence:
  .byte GRUNT_SPRITE0_PTR,GRUNT_SPRITE1_PTR,GRUNT_SPRITE0_PTR,GRUNT_SPRITE1_PTR
flagship_dive_animation_sequence:
  .byte FLAGSHIP_SPRITE0_PTR,ARCADE_SPRITE_PTR_BASE + 9,ARCADE_SPRITE_PTR_BASE + 10,ARCADE_SPRITE_PTR_BASE + 11,ARCADE_SPRITE_PTR_BASE + 12,ARCADE_SPRITE_PTR_BASE + 13,ARCADE_SPRITE_PTR_BASE + 14,ARCADE_SPRITE_PTR_BASE + 15,ARCADE_SPRITE_PTR_BASE + 16,ARCADE_SPRITE_PTR_BASE + 17
flagship_dive_animation_colors:
  .byte FLAGSHIP_COLOR,FLAGSHIP_DIVE_COLOR,FLAGSHIP_DIVE_COLOR,FLAGSHIP_DIVE_COLOR,FLAGSHIP_DIVE_COLOR,FLAGSHIP_DIVE_COLOR,FLAGSHIP_DIVE_COLOR,FLAGSHIP_DIVE_COLOR,FLAGSHIP_DIVE_COLOR,FLAGSHIP_DIVE_COLOR
escort_dive_animation_sequence:
  .byte ESCORT_SPRITE0_PTR,ARCADE_SPRITE_PTR_BASE + 18,ARCADE_SPRITE_PTR_BASE + 19,ARCADE_SPRITE_PTR_BASE + 20,ARCADE_SPRITE_PTR_BASE + 21,ARCADE_SPRITE_PTR_BASE + 22,ARCADE_SPRITE_PTR_BASE + 23,ARCADE_SPRITE_PTR_BASE + 24,ARCADE_SPRITE_PTR_BASE + 25,ARCADE_SPRITE_PTR_BASE + 26
escort_dive_animation_colors:
  .byte ESCORT_COLOR,ESCORT_DIVE_COLOR,ESCORT_DIVE_COLOR,ESCORT_DIVE_COLOR,ESCORT_DIVE_COLOR,ESCORT_DIVE_COLOR,ESCORT_DIVE_COLOR,ESCORT_DIVE_COLOR,ESCORT_DIVE_COLOR,ESCORT_DIVE_COLOR
grunt_dive_animation_sequence:
  .byte GRUNT_SPRITE0_PTR,ARCADE_SPRITE_PTR_BASE + 27,ARCADE_SPRITE_PTR_BASE + 28,ARCADE_SPRITE_PTR_BASE + 29,ARCADE_SPRITE_PTR_BASE + 30,ARCADE_SPRITE_PTR_BASE + 31,ARCADE_SPRITE_PTR_BASE + 32,ARCADE_SPRITE_PTR_BASE + 33,ARCADE_SPRITE_PTR_BASE + 34,ARCADE_SPRITE_PTR_BASE + 35
grunt_dive_animation_colors:
  .byte GRUNT_COLOR,GRUNT_DIVE_COLOR,GRUNT_DIVE_COLOR,GRUNT_DIVE_COLOR,GRUNT_DIVE_COLOR,GRUNT_DIVE_COLOR,GRUNT_DIVE_COLOR,GRUNT_DIVE_COLOR,GRUNT_DIVE_COLOR,GRUNT_DIVE_COLOR
enemy_explosion_sequence:
  .byte ENEMY_EXPLOSION_SPRITE3_PTR,ENEMY_EXPLOSION_SPRITE0_PTR,ENEMY_EXPLOSION_SPRITE1_PTR,ENEMY_EXPLOSION_SPRITE2_PTR
formation_char_band_rows:
  .byte FORMATION_CHAR_BAND_TOP_ROW,FORMATION_CHAR_BAND_TOP_ROW + 1,FORMATION_CHAR_BAND_MID_ROW,FORMATION_CHAR_BAND_MID_ROW + 1,FORMATION_CHAR_BAND_BOTTOM_ROW
formation_clear_slot_scan_start_table:
  .byte $00,$00,FORMATION_TOP_SLOT_END,FORMATION_TOP_SLOT_END,FORMATION_MID_SLOT_END
formation_clear_slot_scan_end_table:
  .byte FORMATION_TOP_SLOT_END,FORMATION_TOP_SLOT_END,FORMATION_MID_SLOT_END,FORMATION_MID_SLOT_END,FORMATION_SLOT_COUNT
formation_char_row_table:
  .byte FORMATION_CHAR_BAND_TOP_ROW,FORMATION_CHAR_BAND_TOP_ROW,FORMATION_CHAR_BAND_TOP_ROW,FORMATION_CHAR_BAND_TOP_ROW,FORMATION_CHAR_BAND_MID_ROW,FORMATION_CHAR_BAND_MID_ROW,FORMATION_CHAR_BAND_MID_ROW,FORMATION_CHAR_BAND_MID_ROW,FORMATION_CHAR_BAND_MID_ROW,FORMATION_CHAR_BAND_MID_ROW,FORMATION_CHAR_BAND_BOTTOM_ROW,FORMATION_CHAR_BAND_BOTTOM_ROW,FORMATION_CHAR_BAND_BOTTOM_ROW,FORMATION_CHAR_BAND_BOTTOM_ROW,FORMATION_CHAR_BAND_BOTTOM_ROW,FORMATION_CHAR_BAND_BOTTOM_ROW,FORMATION_CHAR_BAND_BOTTOM_ROW,FORMATION_CHAR_BAND_BOTTOM_ROW
formation_slot_visual_y_table:
  .byte FORMATION_CHAR_TOP_Y,FORMATION_CHAR_TOP_Y,FORMATION_CHAR_TOP_Y,FORMATION_CHAR_TOP_Y,FORMATION_CHAR_MID_Y,FORMATION_CHAR_MID_Y,FORMATION_CHAR_MID_Y,FORMATION_CHAR_MID_Y,FORMATION_CHAR_MID_Y,FORMATION_CHAR_MID_Y,FORMATION_CHAR_BOTTOM_Y,FORMATION_CHAR_BOTTOM_Y,FORMATION_CHAR_BOTTOM_Y,FORMATION_CHAR_BOTTOM_Y,FORMATION_CHAR_BOTTOM_Y,FORMATION_CHAR_BOTTOM_Y,FORMATION_CHAR_BOTTOM_Y,FORMATION_CHAR_BOTTOM_Y
formation_slot_offset_table:
  .byte FORMATION_SLOT0_OFFSET,FORMATION_SLOT1_OFFSET,FORMATION_SLOT2_OFFSET,FORMATION_SLOT3_OFFSET,FORMATION_SLOT4_OFFSET,FORMATION_SLOT5_OFFSET,FORMATION_SLOT6_OFFSET,FORMATION_SLOT7_OFFSET,FORMATION_SLOT8_OFFSET,FORMATION_SLOT9_OFFSET,FORMATION_SLOT10_OFFSET,FORMATION_SLOT11_OFFSET,FORMATION_SLOT12_OFFSET,FORMATION_SLOT13_OFFSET,FORMATION_SLOT14_OFFSET,FORMATION_SLOT15_OFFSET,FORMATION_SLOT16_OFFSET,FORMATION_SLOT17_OFFSET
formation_slot_column_bit_table:
  .byte FORMATION_COLUMN_LEFT_MASK,FORMATION_COLUMN_LEFT_MASK,FORMATION_COLUMN_RIGHT_MASK,FORMATION_COLUMN_RIGHT_MASK,FORMATION_COLUMN_LEFT_MASK,FORMATION_COLUMN_LEFT_MASK,FORMATION_COLUMN_LEFT_MASK,FORMATION_COLUMN_RIGHT_MASK,FORMATION_COLUMN_RIGHT_MASK,FORMATION_COLUMN_RIGHT_MASK,FORMATION_COLUMN_LEFT_MASK,FORMATION_COLUMN_LEFT_MASK,FORMATION_COLUMN_LEFT_MASK,FORMATION_COLUMN_LEFT_MASK,FORMATION_COLUMN_RIGHT_MASK,FORMATION_COLUMN_RIGHT_MASK,FORMATION_COLUMN_RIGHT_MASK,FORMATION_COLUMN_RIGHT_MASK
formation_launch_order_left_first:
  .byte $0d,$0c,$0b,$0a,$0e,$0f,$10,$11
formation_launch_order_right_first:
  .byte $0e,$0f,$10,$11,$0d,$0c,$0b,$0a
formation_slot_dive_direction_table:
  .byte DIVE_DIRECTION_LEFT,DIVE_DIRECTION_LEFT,DIVE_DIRECTION_RIGHT,DIVE_DIRECTION_RIGHT,DIVE_DIRECTION_LEFT,DIVE_DIRECTION_LEFT,DIVE_DIRECTION_LEFT,DIVE_DIRECTION_RIGHT,DIVE_DIRECTION_RIGHT,DIVE_DIRECTION_RIGHT,DIVE_DIRECTION_LEFT,DIVE_DIRECTION_LEFT,DIVE_DIRECTION_LEFT,DIVE_DIRECTION_LEFT,DIVE_DIRECTION_RIGHT,DIVE_DIRECTION_RIGHT,DIVE_DIRECTION_RIGHT,DIVE_DIRECTION_RIGHT
formation_char_render_bit_table:
  .byte %00000001,%00000010,%00000100,%00001000,%00010000,%00100000,%01000000,%10000000,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
formation_char_render_bit_hi_table:
  .byte $00,$00,$00,$00,$00,$00,$00,$00,%00000001,%00000010,%00000100,%00001000,%00010000,%00100000,%01000000,%10000000,$00,$00
formation_char_render_bit_hi2_table:
  .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,%00000001,%00000010
formation_char_clear_bit_table:
  .byte %11111110,%11111101,%11111011,%11110111,%11101111,%11011111,%10111111,%01111111,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
formation_char_clear_bit_hi_table:
  .byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,%11111110,%11111101,%11111011,%11110111,%11101111,%11011111,%10111111,%01111111,$ff,$ff
formation_char_clear_bit_hi2_table:
  .byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,%11111110,%11111101
formation_char_glyph_base_table:
  .fill FORMATION_SLOT_COUNT, FORMATION_CHAR_BASE + (i * FORMATION_CHAR_SLOT_STRIDE)
formation_char_glyph_addr_lo_table:
  .fill FORMATION_SLOT_COUNT, <(CHARSET_RAM + ((FORMATION_CHAR_BASE + (i * FORMATION_CHAR_SLOT_STRIDE)) * 8))
formation_char_glyph_addr_hi_table:
  .fill FORMATION_SLOT_COUNT, >(CHARSET_RAM + ((FORMATION_CHAR_BASE + (i * FORMATION_CHAR_SLOT_STRIDE)) * 8))
formation_char_color_table:
  .byte FLAGSHIP_COLOR,FLAGSHIP_COLOR,FLAGSHIP_COLOR,FLAGSHIP_COLOR,ESCORT_COLOR,ESCORT_COLOR,ESCORT_COLOR,ESCORT_COLOR,ESCORT_COLOR,ESCORT_COLOR,GRUNT_COLOR,GRUNT_COLOR,GRUNT_COLOR,GRUNT_COLOR,GRUNT_COLOR,GRUNT_COLOR,GRUNT_COLOR,GRUNT_COLOR
formation_slot_char_frame_base_table:
  .byte $00,$00,$00,$00,$02,$02,$02,$02,$02,$02,$04,$04,$04,$04,$04,$04,$04,$04
formation_anim_frame_offset_table:
  .byte $00,$01,$00,$01
formation_slot_score_lo_table:
  .byte SCORE_FLAGSHIP_LO,SCORE_FLAGSHIP_LO,SCORE_FLAGSHIP_LO,SCORE_FLAGSHIP_LO,SCORE_ESCORT_LO,SCORE_ESCORT_LO,SCORE_ESCORT_LO,SCORE_ESCORT_LO,SCORE_ESCORT_LO,SCORE_ESCORT_LO,SCORE_GRUNT_LO,SCORE_GRUNT_LO,SCORE_GRUNT_LO,SCORE_GRUNT_LO,SCORE_GRUNT_LO,SCORE_GRUNT_LO,SCORE_GRUNT_LO,SCORE_GRUNT_LO
formation_slot_score_mid_table:
  .byte SCORE_FLAGSHIP_MID,SCORE_FLAGSHIP_MID,SCORE_FLAGSHIP_MID,SCORE_FLAGSHIP_MID,SCORE_ESCORT_MID,SCORE_ESCORT_MID,SCORE_ESCORT_MID,SCORE_ESCORT_MID,SCORE_ESCORT_MID,SCORE_ESCORT_MID,SCORE_GRUNT_MID,SCORE_GRUNT_MID,SCORE_GRUNT_MID,SCORE_GRUNT_MID,SCORE_GRUNT_MID,SCORE_GRUNT_MID,SCORE_GRUNT_MID,SCORE_GRUNT_MID
formation_slot_score_hi_table:
  .byte SCORE_FLAGSHIP_HI,SCORE_FLAGSHIP_HI,SCORE_FLAGSHIP_HI,SCORE_FLAGSHIP_HI,SCORE_ESCORT_HI,SCORE_ESCORT_HI,SCORE_ESCORT_HI,SCORE_ESCORT_HI,SCORE_ESCORT_HI,SCORE_ESCORT_HI,SCORE_GRUNT_HI,SCORE_GRUNT_HI,SCORE_GRUNT_HI,SCORE_GRUNT_HI,SCORE_GRUNT_HI,SCORE_GRUNT_HI,SCORE_GRUNT_HI,SCORE_GRUNT_HI
player_explosion_top_left_sequence:
  .byte PLAYER_EXPLOSION_PTR_BASE + 0,PLAYER_EXPLOSION_PTR_BASE + 4,PLAYER_EXPLOSION_PTR_BASE + 8,PLAYER_EXPLOSION_PTR_BASE + 12
player_explosion_top_right_sequence:
  .byte PLAYER_EXPLOSION_PTR_BASE + 1,PLAYER_EXPLOSION_PTR_BASE + 5,PLAYER_EXPLOSION_PTR_BASE + 9,PLAYER_EXPLOSION_PTR_BASE + 13
player_explosion_bottom_left_sequence:
  .byte PLAYER_EXPLOSION_PTR_BASE + 2,PLAYER_EXPLOSION_PTR_BASE + 6,PLAYER_EXPLOSION_PTR_BASE + 10,PLAYER_EXPLOSION_PTR_BASE + 14
player_explosion_bottom_right_sequence:
  .byte PLAYER_EXPLOSION_PTR_BASE + 3,PLAYER_EXPLOSION_PTR_BASE + 7,PLAYER_EXPLOSION_PTR_BASE + 11,PLAYER_EXPLOSION_PTR_BASE + 15
player_explosion_top_left_pointer:
  .byte $00
player_explosion_top_right_pointer:
  .byte $00
player_explosion_bottom_left_pointer:
  .byte $00
player_explosion_bottom_right_pointer:
  .byte $00
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

* = $5a00 "Char Mode Sprite Routines"

load_slot_visual_y:
  lda formation_slot_visual_y_table, x
  rts

clear_dive_slot_char_handoff:
  ldx dive_slot
  cpx #FORMATION_SLOT_COUNT
  bcs clear_dive_slot_char_handoff_done
  jsr clear_formation_char_slot_saved
  lda formation_char_render_mask
  and formation_char_clear_bit_table, x
  sta formation_char_render_mask
  lda formation_char_render_mask_hi
  and formation_char_clear_bit_hi_table, x
  sta formation_char_render_mask_hi
  lda formation_char_render_mask_hi2
  and formation_char_clear_bit_hi2_table, x
  sta formation_char_render_mask_hi2
  lda formation_char_render_mask_pending
  and formation_char_clear_bit_table, x
  sta formation_char_render_mask_pending
  lda formation_char_render_mask_pending_hi
  and formation_char_clear_bit_hi_table, x
  sta formation_char_render_mask_pending_hi
  lda formation_char_render_mask_pending_hi2
  and formation_char_clear_bit_hi2_table, x
  sta formation_char_render_mask_pending_hi2
clear_dive_slot_char_handoff_done:
  rts

draw_player_extra_layers_char:
  lda player_visible
  bne draw_player_extra_layers_char_visible
  rts
draw_player_extra_layers_char_visible:
  jsr store_char_mode_player_bottom_left
  jsr store_char_mode_player_bottom_right
  rts

draw_player_explosion_char:
  lda #PLAYER_EXPLOSION_MULTI0_COLOR
  sta SPRITE_MULTICOLOR_0
  lda #PLAYER_EXPLOSION_MULTI1_COLOR
  sta SPRITE_MULTICOLOR_1

  ldy player_explosion_frame
  lda player_explosion_top_left_sequence, y
  sta player_explosion_top_left_pointer
  lda player_explosion_top_right_sequence, y
  sta player_explosion_top_right_pointer
  lda player_explosion_bottom_left_sequence, y
  sta player_explosion_bottom_left_pointer
  lda player_explosion_bottom_right_sequence, y
  sta player_explosion_bottom_right_pointer

  jsr store_player_explosion_sprite1
  jsr store_player_explosion_sprite2

  lda player_explosion_x_lo
  sta player_effect_x_lo
  lda player_explosion_x_hi
  sta player_effect_x_hi
  lda player_explosion_y
  clc
  adc #PLAYER_EXPLOSION_TILE_OFFSET
  sta player_effect_y
  lda player_explosion_bottom_left_pointer
  sta player_effect_pointer
  lda #PLAYER_EXPLOSION_COLOR
  sta player_effect_color
  jsr store_char_mode_player_explosion_bottom_left

  lda player_explosion_x_lo
  clc
  adc #PLAYER_EXPLOSION_TILE_OFFSET
  sta player_effect_x_lo
  lda player_explosion_x_hi
  adc #$00
  sta player_effect_x_hi
  lda player_explosion_y
  clc
  adc #PLAYER_EXPLOSION_TILE_OFFSET
  sta player_effect_y
  lda player_explosion_bottom_right_pointer
  sta player_effect_pointer
  lda #PLAYER_EXPLOSION_COLOR
  sta player_effect_color
  jmp store_char_mode_player_explosion_bottom_right

store_dive_position_char:
  lda dive_x_lo
  sta SPRITE0_X
  lda dive_y
  sta SPRITE0_Y
  lda SPRITE_X_MSB
  and #%11111110
  ldx dive_x_hi
  beq store_dive_position_char_done
  ora #DIVE_SPRITE_MASK
store_dive_position_char_done:
  sta SPRITE_X_MSB
  lda dive_sprite_pointer
  sta SPRITE_POINTERS
  lda dive_sprite_color
  sta SPRITE0_COLOR
  lda SPRITE_MULTICOLOR
  ora #DIVE_SPRITE_MASK
  sta SPRITE_MULTICOLOR
  lda SPRITE_ENABLE
  ora #DIVE_SPRITE_MASK
  sta SPRITE_ENABLE
  rts

store_char_mode_player_bottom_left:
  lda player_x_lo
  sta SPRITE3_X
  lda #PLAYER_Y
  sta SPRITE3_Y
  lda SPRITE_X_MSB
  and #%11110111
  ldx player_x_hi
  beq store_char_mode_player_bottom_left_msb_done
  ora #PLAYER_BOTTOM_LEFT_SPRITE_MASK
store_char_mode_player_bottom_left_msb_done:
  sta SPRITE_X_MSB
  lda #PLAYER_WHITE_SPRITE_PTR
  sta SPRITE_POINTERS + 3
  lda #PLAYER_WHITE_COLOR
  sta SPRITE3_COLOR
  lda SPRITE_MULTICOLOR
  and #%11110111
  sta SPRITE_MULTICOLOR
  lda SPRITE_ENABLE
  ora #PLAYER_BOTTOM_LEFT_SPRITE_MASK
  sta SPRITE_ENABLE
  rts

store_char_mode_player_bottom_right:
  lda player_x_lo
  sta SPRITE4_X
  lda #PLAYER_Y
  sta SPRITE4_Y
  lda SPRITE_X_MSB
  and #%11101111
  ldx player_x_hi
  beq store_char_mode_player_bottom_right_msb_done
  ora #PLAYER_BOTTOM_RIGHT_SPRITE_MASK
store_char_mode_player_bottom_right_msb_done:
  sta SPRITE_X_MSB
  lda #PLAYER_CYAN_SPRITE_PTR
  sta SPRITE_POINTERS + 4
  lda #PLAYER_CYAN_COLOR
  sta SPRITE4_COLOR
  lda SPRITE_MULTICOLOR
  and #%11101111
  sta SPRITE_MULTICOLOR
  lda SPRITE_ENABLE
  ora #PLAYER_BOTTOM_RIGHT_SPRITE_MASK
  sta SPRITE_ENABLE
  lda #(PLAYER_BOTTOM_LEFT_SPRITE_MASK | PLAYER_BOTTOM_RIGHT_SPRITE_MASK)
  sta player_bottom_sprite_mask_debug
  rts

store_char_mode_player_explosion_bottom_left:
  lda player_effect_x_lo
  sta SPRITE3_X
  lda player_effect_y
  sta SPRITE3_Y
  lda SPRITE_X_MSB
  and #%11110111
  ldy player_effect_x_hi
  beq store_char_mode_player_explosion_bottom_left_msb_done
  ora #PLAYER_BOTTOM_LEFT_SPRITE_MASK
store_char_mode_player_explosion_bottom_left_msb_done:
  sta SPRITE_X_MSB
  lda player_effect_pointer
  sta SPRITE_POINTERS + 3
  lda player_effect_color
  sta SPRITE3_COLOR
  lda SPRITE_MULTICOLOR
  ora #PLAYER_BOTTOM_LEFT_SPRITE_MASK
  sta SPRITE_MULTICOLOR
  lda SPRITE_ENABLE
  ora #PLAYER_BOTTOM_LEFT_SPRITE_MASK
  sta SPRITE_ENABLE
  rts

store_char_mode_player_explosion_bottom_right:
  lda player_effect_x_lo
  sta SPRITE4_X
  lda player_effect_y
  sta SPRITE4_Y
  lda SPRITE_X_MSB
  and #%11101111
  ldy player_effect_x_hi
  beq store_char_mode_player_explosion_bottom_right_msb_done
  ora #PLAYER_BOTTOM_RIGHT_SPRITE_MASK
store_char_mode_player_explosion_bottom_right_msb_done:
  sta SPRITE_X_MSB
  lda player_effect_pointer
  sta SPRITE_POINTERS + 4
  lda player_effect_color
  sta SPRITE4_COLOR
  lda SPRITE_MULTICOLOR
  ora #PLAYER_BOTTOM_RIGHT_SPRITE_MASK
  sta SPRITE_MULTICOLOR
  lda SPRITE_ENABLE
  ora #PLAYER_BOTTOM_RIGHT_SPRITE_MASK
  sta SPRITE_ENABLE
  lda #(PLAYER_BOTTOM_LEFT_SPRITE_MASK | PLAYER_BOTTOM_RIGHT_SPRITE_MASK)
  sta player_bottom_sprite_mask_debug
  rts

disable_char_mode_dive_sprite:
  lda SPRITE_ENABLE
  and #%11111110
  sta SPRITE_ENABLE
  lda SPRITE_X_MSB
  and #%11111110
  sta SPRITE_X_MSB
  lda SPRITE_MULTICOLOR
  and #%11111110
  sta SPRITE_MULTICOLOR
  rts

disable_char_mode_dynamic_sprites:
  lda SPRITE_ENABLE
  and #CHAR_MODE_STATIC_SPRITE_MASK
  sta SPRITE_ENABLE
  lda SPRITE_X_MSB
  and #CHAR_MODE_STATIC_SPRITE_MASK
  sta SPRITE_X_MSB
  lda SPRITE_MULTICOLOR
  and #CHAR_MODE_STATIC_SPRITE_MASK
  sta SPRITE_MULTICOLOR
  lda #$00
  sta player_bottom_sprite_mask_debug
  rts

render_char_mode_top_sprites:
  jsr disable_char_mode_dynamic_sprites
  lda dive_active
  beq render_char_mode_top_effects
  jsr store_dive_position
render_char_mode_top_effects:
  jmp render_char_mode_enemy_effects

render_char_mode_enemy_effects:
  ldx #$00
  ldy #$00
render_char_mode_enemy_effects_loop:
  lda slot_explosion_timer, x
  beq render_char_mode_enemy_effects_next
  cpy #CHAR_MODE_EFFECT_SLOT_COUNT
  bcs render_char_mode_enemy_effects_done
  stx char_mode_effect_source_slot
  sty char_mode_effect_target_slot
  ldy slot_explosion_frame, x
  lda enemy_explosion_sequence, y
  sta enemy_explosion_pointer
  ldx char_mode_effect_source_slot
  ldy char_mode_effect_target_slot
  jsr store_char_mode_enemy_effect
  ldy char_mode_effect_target_slot
  iny
render_char_mode_enemy_effects_next:
  inx
  cpx #FORMATION_SLOT_COUNT
  bcc render_char_mode_enemy_effects_loop
render_char_mode_enemy_effects_done:
  rts

render_char_mode_enemy_effects_bottom:
  lda #$00
  sta player_bottom_sprite_mask_debug
  ldx #$00
  ldy #$00
render_char_mode_enemy_effects_bottom_loop:
  lda slot_explosion_timer, x
  beq render_char_mode_enemy_effects_bottom_next
  lda explosion_slot_y, x
  cmp #ENEMY_EXPLOSION_BOTTOM_OVERLAP_Y
  bcc render_char_mode_enemy_effects_bottom_next
  cpy #$03
  bcs render_char_mode_enemy_effects_bottom_done
  stx char_mode_effect_source_slot
  sty char_mode_effect_target_slot
  ldy slot_explosion_frame, x
  lda enemy_explosion_sequence, y
  sta enemy_explosion_pointer
  ldx char_mode_effect_source_slot
  ldy char_mode_effect_target_slot
  jsr store_char_mode_enemy_effect_bottom
  ldy char_mode_effect_target_slot
  iny
render_char_mode_enemy_effects_bottom_next:
  inx
  cpx #FORMATION_SLOT_COUNT
  bcc render_char_mode_enemy_effects_bottom_loop
render_char_mode_enemy_effects_bottom_done:
  rts

store_char_mode_enemy_effect:
  tya
  beq store_char_mode_enemy_effect_slot0
  cmp #$01
  beq store_char_mode_enemy_effect_slot1_jump
  cmp #$02
  beq store_char_mode_enemy_effect_slot2_jump
  cmp #$03
  beq store_char_mode_enemy_effect_slot3_jump
  jmp store_char_mode_enemy_effect_slot4

store_char_mode_enemy_effect_slot1_jump:
  jmp store_char_mode_enemy_effect_slot1

store_char_mode_enemy_effect_slot2_jump:
  jmp store_char_mode_enemy_effect_slot2

store_char_mode_enemy_effect_slot3_jump:
  jmp store_char_mode_enemy_effect_slot3

store_char_mode_enemy_effect_bottom:
  tya
  beq store_char_mode_enemy_effect_bottom_slot0
  cmp #$01
  beq store_char_mode_enemy_effect_bottom_slot1
  jmp store_char_mode_enemy_effect_bottom_slot2

store_char_mode_enemy_effect_bottom_slot0:
  jmp store_char_mode_enemy_effect_slot2

store_char_mode_enemy_effect_bottom_slot1:
  jmp store_char_mode_enemy_effect_slot3

store_char_mode_enemy_effect_bottom_slot2:
  jmp store_char_mode_enemy_effect_slot4

store_char_mode_enemy_effect_slot0:
  lda explosion_slot_x_lo, x
  sta SPRITE3_X
  lda explosion_slot_y, x
  sta SPRITE3_Y
  lda SPRITE_X_MSB
  and #%11110111
  ldy explosion_slot_x_hi, x
  beq store_char_mode_enemy_effect_slot0_msb_done
  ora #SPRITE3_MASK
store_char_mode_enemy_effect_slot0_msb_done:
  sta SPRITE_X_MSB
  lda SPRITE_MULTICOLOR
  and #%11110111
  sta SPRITE_MULTICOLOR
  lda enemy_explosion_pointer
  sta SPRITE_POINTERS + 3
  lda #ENEMY_EXPLOSION_COLOR
  sta SPRITE3_COLOR
  lda SPRITE_ENABLE
  ora #SPRITE3_MASK
  sta SPRITE_ENABLE
  rts

store_char_mode_enemy_effect_slot1:
  lda explosion_slot_x_lo, x
  sta SPRITE4_X
  lda explosion_slot_y, x
  sta SPRITE4_Y
  lda SPRITE_X_MSB
  and #%11101111
  ldy explosion_slot_x_hi, x
  beq store_char_mode_enemy_effect_slot1_msb_done
  ora #SPRITE4_MASK
store_char_mode_enemy_effect_slot1_msb_done:
  sta SPRITE_X_MSB
  lda SPRITE_MULTICOLOR
  and #%11101111
  sta SPRITE_MULTICOLOR
  lda enemy_explosion_pointer
  sta SPRITE_POINTERS + 4
  lda #ENEMY_EXPLOSION_COLOR
  sta SPRITE4_COLOR
  lda SPRITE_ENABLE
  ora #SPRITE4_MASK
  sta SPRITE_ENABLE
  rts

store_char_mode_enemy_effect_slot2:
  lda explosion_slot_x_lo, x
  sta SPRITE5_X
  lda explosion_slot_y, x
  sta SPRITE5_Y
  lda SPRITE_X_MSB
  and #%11011111
  ldy explosion_slot_x_hi, x
  beq store_char_mode_enemy_effect_slot2_msb_done
  ora #SPRITE5_MASK
store_char_mode_enemy_effect_slot2_msb_done:
  sta SPRITE_X_MSB
  lda SPRITE_MULTICOLOR
  and #%11011111
  sta SPRITE_MULTICOLOR
  lda enemy_explosion_pointer
  sta SPRITE_POINTERS + 5
  lda #ENEMY_EXPLOSION_COLOR
  sta SPRITE5_COLOR
  lda SPRITE_ENABLE
  ora #SPRITE5_MASK
  sta SPRITE_ENABLE
  rts

store_char_mode_enemy_effect_slot3:
  lda explosion_slot_x_lo, x
  sta SPRITE6_X
  lda explosion_slot_y, x
  sta SPRITE6_Y
  lda SPRITE_X_MSB
  and #%10111111
  ldy explosion_slot_x_hi, x
  beq store_char_mode_enemy_effect_slot3_msb_done
  ora #SPRITE6_MASK
store_char_mode_enemy_effect_slot3_msb_done:
  sta SPRITE_X_MSB
  lda SPRITE_MULTICOLOR
  and #%10111111
  sta SPRITE_MULTICOLOR
  lda enemy_explosion_pointer
  sta SPRITE_POINTERS + 6
  lda #ENEMY_EXPLOSION_COLOR
  sta SPRITE6_COLOR
  lda SPRITE_ENABLE
  ora #SPRITE6_MASK
  sta SPRITE_ENABLE
  rts

store_char_mode_enemy_effect_slot4:
  lda explosion_slot_x_lo, x
  sta SPRITE7_X
  lda explosion_slot_y, x
  sta SPRITE7_Y
  lda SPRITE_X_MSB
  and #%01111111
  ldy explosion_slot_x_hi, x
  beq store_char_mode_enemy_effect_slot4_msb_done
  ora #SPRITE7_MASK
store_char_mode_enemy_effect_slot4_msb_done:
  sta SPRITE_X_MSB
  lda SPRITE_MULTICOLOR
  and #%01111111
  sta SPRITE_MULTICOLOR
  lda enemy_explosion_pointer
  sta SPRITE_POINTERS + 7
  lda #ENEMY_EXPLOSION_COLOR
  sta SPRITE7_COLOR
  lda SPRITE_ENABLE
  ora #SPRITE7_MASK
  sta SPRITE_ENABLE
  rts

* = $5400 "Formation Char Bitmap Data"

formation_bitmap_shifted_frames:
  .import binary "generated_formation_char_bitmap.bin"

* = $2480 "Arcade Sprites"

.import binary "generated_arcade_sprites.bin"

* = $3480 "Player White Sprite"

player_overlay_sprite:
  .import binary "generated_player_overlay.bin"

* = $34c0 "Player Red Sprite"

player_sprite:
  .import binary "generated_player_sprite.bin"

* = $3500 "Player Cyan Sprite"

player_extra_sprite:
  .import binary "generated_player_extra.bin"

* = $3540 "Shot Sprite"

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

* = $3580 "Enemy Bullet Charset Data"

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

* = $37c0 "Enemy Explosion Sprite 0"

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

* = $3800 "Enemy Explosion Sprite 1"

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

* = $3840 "Enemy Explosion Sprite 2"

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

* = $3880 "Enemy Explosion Sprite 3"

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

* = $38c0 "Player Explosion Sprites"

player_explosion_sprites:
  .import binary "generated_player_explosion.bin"

* = $4b00 "Explosion Frame Routines"

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
  jsr load_formation_slot_position
  sta explosion_slot_x_lo, x
  tya
  sta explosion_slot_x_hi, x
  jsr load_slot_visual_y
  sta explosion_slot_y, x
  rts

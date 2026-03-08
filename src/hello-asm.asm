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
.label SPRITE0_COLOR = $d027
.label SPRITE1_X = $d002
.label SPRITE1_Y = $d003
.label SPRITE1_COLOR = $d028

.label HUD_TEXT_COLOR = $01
.label PLAYFIELD_TEXT_COLOR = $0e
.label ALIEN_COLOR = $05
.label ALIEN_START_X_LO = $18
.label ALIEN_START_X_HI = $00
.label ALIEN_Y = 60
.label ALIEN_MIN_X_LO = $18
.label ALIEN_MIN_X_HI = $00
.label ALIEN_MAX_X_LO = $40
.label ALIEN_MAX_X_HI = $01
.label ALIEN_SPRITE_PTR = $80
.label PLAYER_COLOR = $0f
.label PLAYER_START_X_LO = $a8
.label PLAYER_START_X_HI = $00
.label PLAYER_Y = 220
.label PLAYER_MIN_X_LO = $18
.label PLAYER_MIN_X_HI = $00
.label PLAYER_MAX_X_LO = $40
.label PLAYER_MAX_X_HI = $01
.label PLAYER_SPRITE_PTR = $81
.label player_min_x_lo = PLAYER_MIN_X_LO
.label player_min_x_hi = PLAYER_MIN_X_HI
.label player_max_x_lo = PLAYER_MAX_X_LO
.label player_max_x_hi = PLAYER_MAX_X_HI
.label alien_min_x_lo = ALIEN_MIN_X_LO
.label alien_min_x_hi = ALIEN_MIN_X_HI
.label alien_max_x_lo = ALIEN_MAX_X_LO
.label alien_max_x_hi = ALIEN_MAX_X_HI
.label AUTOPLAY_MODE_EXTERNAL = $00
.label AUTOPLAY_MODE_INTERNAL = $01
.label AUTOPLAY_STATUS_RUNNING = $00
.label AUTOPLAY_STATUS_PASSED = $01
.label AUTOPLAY_STATUS_FAILED = $80
.label AUTOPLAY_STAGE_LEFT = $00
.label AUTOPLAY_STAGE_IDLE = $01
.label AUTOPLAY_STAGE_RIGHT = $02
.label AUTOPLAY_STAGE_ALIEN = $03
.label AUTOPLAY_IDLE_FRAMES = 30
.label AUTOPLAY_FAIL_PLAYER_BOUNDS = $01
.label AUTOPLAY_FAIL_IDLE_DRIFT = $02
.label AUTOPLAY_FAIL_ALIEN_BOUNDS = $03

* = $1000 "Main Program"

start:
  sei
  jsr init_vic
  jsr clear_screen
  jsr draw_hud
  jsr init_alien
  jsr init_player
  jsr init_autoplay_state

main_loop:
  jsr wait_frame
  jsr update_autoplay_frame_counter
  jsr update_autoplay_script_input
  jsr update_player
  jsr update_alien
  jsr update_autoplay_script_state
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
  lda #$06
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

init_alien:
  lda #ALIEN_SPRITE_PTR
  sta SPRITE_POINTERS

  lda #ALIEN_START_X_LO
  sta alien_x_lo
  lda #ALIEN_START_X_HI
  sta alien_x_hi
  jsr store_alien_x

  lda #ALIEN_Y
  sta SPRITE0_Y

  lda #$01
  sta alien_dir

  lda #$00
  sta alien_frame
  sta SPRITE_X_MSB
  sta SPRITE_PRIORITY
  sta SPRITE_MULTICOLOR
  sta SPRITE_X_EXPAND
  sta SPRITE_Y_EXPAND

  lda #ALIEN_COLOR
  sta SPRITE0_COLOR

  lda #$01
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

wait_frame:
  lda #$ff
wait_for_line_255:
  cmp RASTER
  bne wait_for_line_255
wait_for_next_frame:
  cmp RASTER
  beq wait_for_next_frame
  rts

init_autoplay_state:
#if TEST_AUTOPLAY
  lda #AUTOPLAY_MODE_EXTERNAL
  sta autoplay_mode
  lda #AUTOPLAY_STATUS_RUNNING
  sta autoplay_status
  sta autoplay_stage
  sta autoplay_error_code
  sta autoplay_flags
  sta autoplay_input_bits
  lda #AUTOPLAY_IDLE_FRAMES
  sta autoplay_idle_timer
  lda #$00
  sta autoplay_frame_counter
  sta autoplay_frame_counter + 1
  lda alien_dir
  sta autoplay_last_alien_dir
  lda alien_x_lo
  sta autoplay_last_alien_x_lo
  lda alien_x_hi
  sta autoplay_last_alien_x_hi
#endif
  rts

update_autoplay_frame_counter:
#if TEST_AUTOPLAY
  inc autoplay_frame_counter
  bne autoplay_frame_counter_done
  inc autoplay_frame_counter + 1
autoplay_frame_counter_done:
#endif
  rts

update_autoplay_script_input:
#if TEST_AUTOPLAY
  lda autoplay_mode
  cmp #AUTOPLAY_MODE_INTERNAL
  bne autoplay_script_input_done
  lda autoplay_status
  bne autoplay_clear_input_bits
  lda autoplay_stage
  cmp #AUTOPLAY_STAGE_LEFT
  beq autoplay_drive_left
  cmp #AUTOPLAY_STAGE_RIGHT
  beq autoplay_drive_right
autoplay_clear_input_bits:
  lda #$00
  sta autoplay_input_bits
  jmp autoplay_script_input_done
autoplay_drive_left:
  lda #$01
  sta autoplay_input_bits
  jmp autoplay_script_input_done
autoplay_drive_right:
  lda #$02
  sta autoplay_input_bits
autoplay_script_input_done:
#endif
  rts

update_autoplay_script_state:
#if TEST_AUTOPLAY
  lda autoplay_mode
  cmp #AUTOPLAY_MODE_INTERNAL
  beq autoplay_check_script_status
  jmp autoplay_script_state_done
autoplay_check_script_status:
  lda autoplay_status
  beq autoplay_check_script_bounds
  jmp autoplay_script_state_done

autoplay_check_script_bounds:
  jsr check_autoplay_bounds
  lda autoplay_status
  beq autoplay_check_script_stage
  jmp autoplay_script_state_done

autoplay_check_script_stage:
  lda autoplay_stage
  cmp #AUTOPLAY_STAGE_LEFT
  beq autoplay_state_left
  cmp #AUTOPLAY_STAGE_IDLE
  beq autoplay_state_idle
  cmp #AUTOPLAY_STAGE_RIGHT
  beq autoplay_state_right
  cmp #AUTOPLAY_STAGE_ALIEN
  beq autoplay_state_alien
  jmp autoplay_script_state_done

autoplay_state_left:
  lda player_x_hi
  cmp #PLAYER_MIN_X_HI
  beq autoplay_check_left_lo
  jmp autoplay_script_state_done
autoplay_check_left_lo:
  lda player_x_lo
  cmp #PLAYER_MIN_X_LO
  beq autoplay_left_complete
  jmp autoplay_script_state_done
autoplay_left_complete:
  lda #AUTOPLAY_STAGE_IDLE
  sta autoplay_stage
  lda #AUTOPLAY_IDLE_FRAMES
  sta autoplay_idle_timer
  jmp autoplay_script_state_done

autoplay_state_idle:
  lda player_x_hi
  cmp #PLAYER_MIN_X_HI
  bne autoplay_idle_failed
  lda player_x_lo
  cmp #PLAYER_MIN_X_LO
  bne autoplay_idle_failed
  dec autoplay_idle_timer
  bne autoplay_script_state_done
  lda #AUTOPLAY_STAGE_RIGHT
  sta autoplay_stage
  jmp autoplay_script_state_done
autoplay_idle_failed:
  lda #AUTOPLAY_FAIL_IDLE_DRIFT
  jsr set_autoplay_failure
  jmp autoplay_script_state_done

autoplay_state_right:
  lda player_x_hi
  cmp #PLAYER_MAX_X_HI
  beq autoplay_check_right_lo
  jmp autoplay_script_state_done
autoplay_check_right_lo:
  lda player_x_lo
  cmp #PLAYER_MAX_X_LO
  beq autoplay_right_complete
  jmp autoplay_script_state_done
autoplay_right_complete:
  lda #AUTOPLAY_STAGE_ALIEN
  sta autoplay_stage
  lda #$00
  sta autoplay_flags
  lda alien_dir
  sta autoplay_last_alien_dir
  lda alien_x_lo
  sta autoplay_last_alien_x_lo
  lda alien_x_hi
  sta autoplay_last_alien_x_hi
  jmp autoplay_script_state_done

autoplay_state_alien:
  lda alien_x_lo
  cmp autoplay_last_alien_x_lo
  bne autoplay_alien_moved
  lda alien_x_hi
  cmp autoplay_last_alien_x_hi
  beq autoplay_check_alien_flip
autoplay_alien_moved:
  lda autoplay_flags
  ora #%00000001
  sta autoplay_flags
autoplay_check_alien_flip:
  lda alien_dir
  cmp autoplay_last_alien_dir
  bne autoplay_check_alien_moved_flag
  jmp autoplay_script_state_done
autoplay_check_alien_moved_flag:
  lda autoplay_flags
  and #%00000001
  bne autoplay_passed
  jmp autoplay_script_state_done
autoplay_passed:
  lda #AUTOPLAY_STATUS_PASSED
  sta autoplay_status
  lda #$00
  sta autoplay_input_bits
autoplay_script_state_done:
#endif
  rts

check_autoplay_bounds:
#if TEST_AUTOPLAY
  lda player_x_hi
  cmp #PLAYER_MIN_X_HI
  bcc autoplay_player_bounds_fail
  bne autoplay_check_player_max
  lda player_x_lo
  cmp #PLAYER_MIN_X_LO
  bcc autoplay_player_bounds_fail
autoplay_check_player_max:
  lda player_x_hi
  cmp #PLAYER_MAX_X_HI
  bcc autoplay_check_alien_min
  bne autoplay_player_bounds_fail
  lda player_x_lo
  cmp #PLAYER_MAX_X_LO
  bcs autoplay_check_player_equal_max
  jmp autoplay_check_alien_min
autoplay_check_player_equal_max:
  bne autoplay_player_bounds_fail
autoplay_check_alien_min:
  lda alien_x_hi
  cmp #ALIEN_MIN_X_HI
  bcc autoplay_alien_bounds_fail
  bne autoplay_check_alien_max
  lda alien_x_lo
  cmp #ALIEN_MIN_X_LO
  bcc autoplay_alien_bounds_fail
autoplay_check_alien_max:
  lda alien_x_hi
  cmp #ALIEN_MAX_X_HI
  bcc autoplay_bounds_done
  bne autoplay_alien_bounds_fail
  lda alien_x_lo
  cmp #ALIEN_MAX_X_LO
  bcc autoplay_bounds_done
  beq autoplay_bounds_done
autoplay_alien_bounds_fail:
  lda #AUTOPLAY_FAIL_ALIEN_BOUNDS
  jsr set_autoplay_failure
  jmp autoplay_bounds_done
autoplay_player_bounds_fail:
  lda #AUTOPLAY_FAIL_PLAYER_BOUNDS
  jsr set_autoplay_failure
autoplay_bounds_done:
#endif
  rts

set_autoplay_failure:
#if TEST_AUTOPLAY
  sta autoplay_error_code
  lda #AUTOPLAY_STATUS_FAILED
  sta autoplay_status
  lda #$00
  sta autoplay_input_bits
#endif
  rts

update_alien:
  inc alien_frame
  lda alien_frame
  and #$01
  bne alien_done

  lda alien_dir
  bpl alien_move_right

alien_move_left:
  lda alien_x_lo
  bne alien_dec_low
  dec alien_x_hi
alien_dec_low:
  dec alien_x_lo

  lda alien_x_hi
  cmp #ALIEN_MIN_X_HI
  bcc alien_clamp_min
  bne alien_store_x
  lda alien_x_lo
  cmp #ALIEN_MIN_X_LO
  bcc alien_clamp_min
  jmp alien_store_x

alien_clamp_min:
  lda #ALIEN_MIN_X_LO
  sta alien_x_lo
  lda #ALIEN_MIN_X_HI
  sta alien_x_hi
  lda #$01
  sta alien_dir
  jmp alien_store_x

alien_move_right:
  inc alien_x_lo
  bne alien_check_max
  inc alien_x_hi

alien_check_max:
  lda alien_x_hi
  cmp #ALIEN_MAX_X_HI
  bcc alien_store_x
  bne alien_clamp_max
  lda alien_x_lo
  cmp #ALIEN_MAX_X_LO
  bcc alien_store_x

alien_clamp_max:
  lda #ALIEN_MAX_X_LO
  sta alien_x_lo
  lda #ALIEN_MAX_X_HI
  sta alien_x_hi
  lda #$ff
  sta alien_dir

alien_store_x:
  jsr store_alien_x

alien_done:
  rts

update_player:
  jsr read_player_input
  lda effective_left
  bne player_move_left

  lda effective_right
  bne player_move_right
  rts

read_player_input:
#if TEST_AUTOPLAY
  lda autoplay_input_bits
  and #%00000001
  beq no_autoplay_left
  lda #$01
  sta effective_left
  jmp autoplay_right_check
no_autoplay_left:
  lda #$00
  sta effective_left
autoplay_right_check:
  lda autoplay_input_bits
  and #%00000010
  beq no_autoplay_right
  lda #$01
  sta effective_right
  rts
no_autoplay_right:
  lda #$00
  sta effective_right
  rts
#else
  lda JOYSTICK_PORT_2
  and #%00000100
  beq joystick_left_pressed
  lda #$00
  sta effective_left
  jmp joystick_right_check
joystick_left_pressed:
  lda #$01
  sta effective_left
joystick_right_check:
  lda JOYSTICK_PORT_2
  and #%00001000
  beq joystick_right_pressed
  lda #$00
  sta effective_right
  rts
joystick_right_pressed:
  lda #$01
  sta effective_right
  rts
#endif

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

store_alien_x:
  lda alien_x_lo
  sta SPRITE0_X
  lda SPRITE_X_MSB
  and #%11111110
  ldx alien_x_hi
  beq alien_store_x_done
  ora #%00000001
alien_store_x_done:
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

alien_x_lo:
  .byte ALIEN_START_X_LO
alien_x_hi:
  .byte ALIEN_START_X_HI
alien_dir:
  .byte $01
alien_frame:
  .byte $00
player_x_lo:
  .byte PLAYER_START_X_LO
player_x_hi:
  .byte PLAYER_START_X_HI
effective_left:
  .byte $00
effective_right:
  .byte $00
#if TEST_AUTOPLAY
autoplay_input_bits:
  .byte $00
autoplay_mode:
  .byte AUTOPLAY_MODE_EXTERNAL
autoplay_status:
  .byte AUTOPLAY_STATUS_RUNNING
autoplay_stage:
  .byte AUTOPLAY_STAGE_LEFT
autoplay_error_code:
  .byte $00
autoplay_idle_timer:
  .byte AUTOPLAY_IDLE_FRAMES
autoplay_flags:
  .byte $00
autoplay_frame_counter:
  .word $0000
autoplay_last_alien_dir:
  .byte $00
autoplay_last_alien_x_lo:
  .byte $00
autoplay_last_alien_x_hi:
  .byte $00
#endif

hud_row0:
  .byte 19,3,15,18,5,32,48,48,48,48,32,32,32,32,32,32,32,32,32,12,9,22,5,19,32,51,0

* = $2000 "Alien Sprite"

alien_sprite:
  .byte $00,$3c,$00
  .byte $00,$ff,$00
  .byte $03,$ff,$c0
  .byte $07,$7e,$e0
  .byte $0f,$ff,$f0
  .byte $0c,$ff,$30
  .byte $1f,$3c,$f8
  .byte $3f,$ff,$fc
  .byte $33,$ff,$cc
  .byte $7f,$3c,$fe
  .byte $fc,$ff,$3f
  .byte $f3,$ff,$cf
  .byte $3f,$3c,$fc
  .byte $0c,$ff,$30
  .byte $18,$c3,$18
  .byte $31,$81,$8c
  .byte $63,$00,$c6
  .byte $c6,$00,$63
  .byte $0c,$00,$30
  .byte $18,$00,$18
  .byte $30,$00,$0c
  .byte $00

* = $2040 "Player Sprite"

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

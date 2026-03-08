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
.label SPRITE_SPRITE_COLLISION = $d01e
.label JOYSTICK_PORT_2 = $dc00
.label SPRITE0_X = $d000
.label SPRITE0_Y = $d001
.label SPRITE0_COLOR = $d027
.label SPRITE1_X = $d002
.label SPRITE1_Y = $d003
.label SPRITE1_COLOR = $d028
.label SPRITE2_X = $d004
.label SPRITE2_Y = $d005
.label SPRITE2_COLOR = $d029

.label HUD_TEXT_COLOR = $01
.label PLAYFIELD_TEXT_COLOR = $0e
.label ALIEN_COLOR = $05
.label HIT_FLASH_COLOR = $01
.label BORDER_BASE_COLOR = $06
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
.label SHOT_COLOR = $01
.label SHOT_SPRITE_PTR = $82
.label SHOT_START_Y = PLAYER_Y - 12
.label SHOT_SPEED = 10
.label SHOT_MIN_Y = 16
.label FIRE_MASK = %00010000

* = $1000 "Main Program"

start:
  sei
  jsr init_vic
  jsr clear_screen
  jsr draw_hud
  jsr init_alien
  jsr init_player
  jsr init_shot

main_loop:
  jsr wait_frame
  jsr update_effects
  jsr update_player
  jsr update_shot
  jsr update_alien
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
  sta alien_alive

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

  lda SPRITE_ENABLE
  and #%11111011
  sta SPRITE_ENABLE

  lda SPRITE_X_MSB
  and #%11111011
  sta SPRITE_X_MSB

  lda SPRITE_SPRITE_COLLISION
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

update_alien:
  lda alien_alive
  beq alien_done

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

  lda SPRITE_SPRITE_COLLISION
  and #%00000101
  cmp #%00000101
  beq shot_hit

  lda shot_y
  sec
  sbc #SHOT_SPEED
  sta shot_y
  cmp #SHOT_MIN_Y
  bcc shot_remove

  sta SPRITE2_Y
  rts

shot_hit:
  jsr destroy_alien
  jsr deactivate_shot
  rts

shot_remove:
  jsr deactivate_shot
shot_done:
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

  lda SPRITE_SPRITE_COLLISION

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

destroy_alien:
  lda #$00
  sta alien_alive

  lda SPRITE_ENABLE
  and #%11111110
  sta SPRITE_ENABLE

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

alien_x_lo:
  .byte ALIEN_START_X_LO
alien_x_hi:
  .byte ALIEN_START_X_HI
alien_dir:
  .byte $01
alien_frame:
  .byte $00
alien_alive:
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

* = $2080 "Shot Sprite"

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

BasicUpstart2(start)

* = $1000 "Main Program"

.label CHROUT = $ffd2

start:
  ldx #0
print_loop:
  lda message, x
  beq done
  jsr CHROUT
  inx
  bne print_loop

done:
  rts

message:
  .text "HELLO FROM KICKASSEMBLER!"
  .byte 13, 0

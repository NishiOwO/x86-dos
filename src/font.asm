fdfont: times 5 db 0
        db 11111111b
        db 10000111b
        db 10000110b
        db 11111111b
        db 11100111b
        db 11100111b
        db 11111111b
        db 11111111b
        times 6 db 0
initfont:
  mov bl, 0
  mov bh, 19
  mov cx, 1
  mov dx, 1
  mov ax, ds
  mov es, ax
  mov bp, fdfont
  mov ax, 0x1100
  int 0x10
  ret
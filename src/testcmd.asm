tstcmd_g:
  push ax
  push bx
  push cx
  push dx
  pusha
  mov  ah, 0
  mov  al, 0x13
  int  0x10
  popa
  mov ah, 0
  int 0x16
  pusha
  mov  ah, 0
  mov  al, 0x3
  int  0x10
  popa
  pop dx
  pop cx
  pop bx
  pop ax
  ret
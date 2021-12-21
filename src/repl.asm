repl:
  ; Clear cmdbuf
  push di
  mov di, 160
  .L2:
  mov byte [cmdbuf + di], 0
  dec di
  cmp di, -1
  jnz .L2
  pop di
  mov byte [cmdbuflen], 0
  mov al, [drive]
  mov ah, 0x0e
  mov bh, 0
  int 0x10
  mov al, [colon]
  int 0x10
  mov al, [sep]
  int 0x10
  mov si, path
  cmp byte [si], 0
  je .skip
  xor bx, bx
  .rep1:
  mov  al, [si + bx]
  mov  ah, 0x0e
  mov  bh, 0
  int  0x10
  inc bx
  cmp byte [si + bx], 0
  je .skip
  jmp .rep1
  .skip:
  mov al, [prompt]
  mov ah, 0x0e
  mov bh, 0
  int 0x10
  
  .keyin:
  mov ah, 0
  int 0x16
  cmp al, 0x0D
  je .kenter
  cmp al, 0x08
  je .kbackspace
  jmp .cont
  
  .kenter:
  push cx
  mov ah, 03
  mov bh, 0
  int 0x10
  pop cx
  mov ah, 2
  mov bh, 0
  int 0x10
  call crlf
  
  call command
  
  call repl
  
  .kbackspace:
  cmp byte [cmdbuflen], 0
  je .keyin
  sub byte [cmdbuflen], 1
  push di
  mov di, [cmdbuflen]
  mov byte [cmdbuf + di], 0
  pop di
  mov al, 0x08
  mov ah, 0x0e
  mov bh, 0
  int 0x10
  mov al, 0x20
  mov ah, 0x0e
  mov bh, 0
  int 0x10
  mov al, 0x08
  mov ah, 0x0e
  mov bh, 0
  int 0x10
  jmp .keyin
  
  .cont:
  push di
  mov di, [cmdbuflen]
  mov byte [cmdbuf + di], al
  mov [cmdbuflen], di
  pop di
  mov ah, 0x0e
  mov bh, 0
  int 0x10
  inc byte [cmdbuflen]
  jmp .keyin
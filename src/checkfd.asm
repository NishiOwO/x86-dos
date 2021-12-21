s_dsig: db "86DSSYSTEM-DISK",0,0
s_dsiglen: equ $ - s_dsig - 1
checkfd:
  .resetfd:
  mov ax, 0x0000
  mov dl, 0x0
  int 0x13
  jc .kill
  .loadfd:
  mov ah, 0x02
  mov al, 17
  mov ch, 0
  mov cl, 1
  mov dh, 0
  mov dl, [drive_num]
  mov bx, buf
  mov es, bx
  xor bx, bx
  int 0x13
  jc .kill
  mov ax, buf
  mov es, ax
  xor bx, bx
  mov [iter3], bx
  
  .L1:
  mov bx, buf
  mov es, bx
  xor bx, bx
  mov bx, [iter3]
  mov dl, [es:bx]
  mov dh, [s_dsig + bx]
  cmp dl, dh
  jnz .kill
  inc byte [iter3]
  cmp byte [iter3], s_dsiglen
  jnz .L1
  xor bx, bx
  mov [iter3], bx
  
  
  ;jnz .kill
  
  .endlp:
  ; If FDA is 86D
  ret
  
  .kill:
  mov  ax, ds
  mov  es, ax
  mov  bp, derr
  mov  cx, derrlen
  mov  bx, 0x07
  mov  dh, 7
  mov  dl, 0
  mov  ax, 0x1301
  int  0x10
  .keyin:
  mov ah, 0
  int 0x16
  jmp reboot

readfdA:
  .resetfd:
  mov ax, 0x0000
  mov dl, [drive_num]
  int 0x13
  jc .resetfd
  .loadfd:
  mov ah, 0x02
  mov al, 17
  mov ch, 0
  mov cl, 1
  mov dl, [drive_num]
  mov dh, 0
  mov bx, buf
  mov es, bx
  xor bx, bx
  int 0x13
  jc .fd_notready
  mov ax, buf
  mov es, ax
  xor bx, bx
  
  cmp byte [es:0], '8'
  jne .fd_unkformat
  jmp .P6
  .P6:
  cmp byte [es:1], '6'
  jne .fd_unkformat
  jmp .PD
  .PD:
  cmp byte [es:2], 'D'
  jne .fd_unkformat
  
  mov al, 0
  ret
  
  .fd_notready:
  mov al, [drive]
  mov ah, 0x0e
  mov bh, 0
  int 0x10
  mov  ax, ds
  mov  es, ax
  mov  bp, derr_notready
  mov  cx, derr_notreadylen
  mov  bx, 0x07
  push cx
  mov ah, 03
  mov bh, 0
  int 0x10
  pop cx
  mov  ax, 0x1301
  int  0x10
  call crlf
  jmp .keyin
  
  .fd_unkformat:
  mov al, [drive]
  mov ah, 0x0e
  mov bh, 0
  int 0x10
  mov  ax, ds
  mov  es, ax
  mov  bp, derr_unkformat
  mov  cx, derr_unkformatlen
  mov  bx, 0x07
  push cx
  mov ah, 03
  mov bh, 0
  int 0x10
  pop cx
  mov  ax, 0x1301
  int  0x10
  call crlf
  jmp .keyin
  
  .keyin:
  mov  ax, ds
  mov  es, ax
  mov  bp, rf
  mov  cx, rflen
  mov  bx, 0x07
  push cx
  mov ah, 03
  mov bh, 0
  int 0x10
  pop cx
  mov ax, 0x1301
  int 0x10
  mov ah, 0
  int 0x16
  mov ah, 0x0e
  mov bh, 0
  int 0x10
  cmp al, 'f'
  je .keyinF
  cmp al, 'F'
  je .keyinF
  cmp al, 'r'
  je .keyinR
  cmp al, 'R'
  je .keyinR
  call crlf
  jmp .keyin
  .keyinF:
  mov al, 1
  call crlf
  ret
  .keyinR:
  call crlf
  jmp readfdA
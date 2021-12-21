cpu 386
org 0x7c00
bits 16

start:
  sect2dest equ 0x7e00
  mov ax, 0
  mov ds, ax
  mov es, ax
  mov ss, ax
  mov sp, 0x7e00
  
  .loadfd:
  xor ax, ax
  mov ds, ax
  mov ah, 0x2
  mov al, 63
  mov ch, 0
  mov cl, 2
  mov dh, 0
  mov dl, 0x80
  xor bx, bx
  mov es, bx
  mov bx, sect2dest
  int 0x13
  jc .loadfd
  
  mov ax, 0xb800
  mov es, ax
  mov byte [es:0], 'A'
  mov byte [es:1], 0x17
  
  ;mov ax, 0x2401
  ;int 0x15
  ;cli
  ;lgdt [gdt_pointer]
  ;mov eax, cr0
  ;or eax,0x1
  ;mov cr0, eax
  jmp sect2dest

times 510-($-$$) db 0

db 0x55
db 0xaa

main:
  mov  ah, 0x14
  mov  al, 1
  mov  bl, 0
  int  0x10
  
  mov  ah, 0
  mov  al, 0x13
  int  0x10
  mov  ah, 0
  mov  al, 0x3
  int  0x10
  
  call initfont
  
  .rp:
  mov  ax, ds
  mov  es, ax
  mov  bp, sqr
  mov  cx, 2
  mov  bh, 0
  mov  bl, [iter]
  mov  dl, [iter2]
  imul dx, 2
  mov  ax, 0x1300
  int  0x10
  inc byte [iter]
  inc byte [iter2]
  cmp byte [iter], 16
  je .reset
  cmp byte [iter2], 40
  jne .rp
  .reset:
  mov byte [iter], 0
  cmp byte [iter2], 40
  jne .rp
  
  mov  ax, ds
  mov  es, ax
  mov  bp, msg
  mov  cx, msglen
  mov  bx, 0x07
  mov  dh, 1
  mov  dl, 0
  mov  ax, 0x1301
  int  0x10
  mov  ax, ds
  mov  es, ax
  mov  bp, ver
  mov  cx, verlen
  mov  bx, 0x07
  mov  dh, 1
  mov  dl, msglen
  mov  ax, 0x1301
  int  0x10
  mov  ax, ds
  mov  es, ax
  mov  bp, msglc
  mov  cx, msglclen
  mov  bx, 0x07
  mov  dh, 2
  mov  dl, 0
  mov  ax, 0x1301
  int  0x10
  mov  ax, ds
  mov  es, ax
  mov  bp, msgcp
  mov  cx, msgcplen
  mov  bx, 0x07
  mov  dh, 3
  mov  dl, 0
  mov  ax, 0x1301
  int  0x10
  mov  ax, ds
  mov  es, ax
  mov  bp, msg2
  mov  cx, msg2len
  mov  bx, 0x07
  mov  dh, 3
  mov  dl, 0
  mov  ax, 0x1301
  int  0x10
  mov  ax, ds
  mov  es, ax
  mov  bp, msg3
  mov  cx, msg3len
  mov  bx, 0x07
  mov  dh, 5
  mov  dl, 0
  mov  ax, 0x1301
  int  0x10
  call crlf
  call crlf
  
  mov byte [cmdbuflen], 0
  
  call checkfd
  
  call repl
  
  jmp $

rebooting: db "Rebooting...",0
rebootinglen: equ $ - rebooting
reboot:
  mov al, 0xd
  mov ah, 0x0e
  mov bh, 0
  int 0x10
  mov al, 0xa
  mov ah, 0x0e
  mov bh, 0
  int 0x10
  mov  ax, ds
  mov  es, ax
  mov  bp, rebooting
  mov  cx, rebootinglen
  mov  bx, 0x07
  push cx
  mov ah, 03
  mov bh, 0
  int 0x10
  pop cx
  mov  ax, 0x1301
  int  0x10
  int 0x19

crlf:
  push bx
  push ax
  mov al, 0xd
  mov ah, 0x0e
  mov bh, 0
  int 0x10
  mov al, 0xa
  mov ah, 0x0e
  mov bh, 0
  int 0x10
  pop ax
  pop bx
  ret

%include "src/checkfd.asm"
%include "src/repl.asm"
%include "src/command.asm"
%include "src/testcmd.asm"
%include "src/font.asm"

section .data:
  license: incbin "LICENSE"
  licenselen: equ $ - license
  
  licensemsg: db "Press any key to go to next page"
  licensemsglen: equ $ - licensemsg
  
  helpTxt: incbin "HELP"
  helpTxtlen: equ $ - helpTxt
  
  msg: db 'The x86 Disk Operating System Version '
  msglen: equ $ - msg
  msglc: db "This software comes with absolutely no warranty, see 'lic' for details."
  msglclen: equ $ - msglc
  msgcp: db "(C) Copyright 2021 Nishi, TerraMaster85, c0repwn3r, GhostlyCoding"
  msgcplen: equ $ - msgcp
  msg2: db 0x0d,0x0a,"    All rights reserved."
  msg2len: equ $ - msg2
  msg3: db 0x0d,0x0a,"(Checking if the disk is on the A drive is the System Disk)"
  msg3len: equ $ - msg3
  ver: db "1.00 Rev. C"
  verlen: equ $ - ver
  
  derr: db 1,' Disk on A drive was (probably) not the System disk.         ',0xd,0xa,'Maybe because:',0xd,0xa," - Disk not the System Disk",0xd,0xa," - Disk was not inserted",0xd,0xa," - FDD Error",0xd,0xa,0xd,0xa,"Press any key to reboot."
  derrlen: equ $ - derr
  
  rf: db "Retry(R), Fail(F)? "
  rflen: equ $ - rf
  
  derr_notready: db " drive: Not ready"
  derr_notreadylen: equ $ - derr_notready
  derr_unkformat: db " drive: Unknown format"
  derr_unkformatlen: equ $ - derr_unkformat
  iter: db 0
  iter2: db 0
  iter3: db 0
  sqr: db 0xDB,0xDB
  drive: db 'A'
  drive_num: db 0
  colon: db ':'
  sep: db '\'
  prompt: db '>'
  path: times 30 db 0
  buf: times 1500000 db 0
  cmdbuf: times 160 db 0
  cmdbuflen: db 0
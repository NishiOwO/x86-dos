cmderr: db "Bad command or file name",0
cmderrlen: equ $ - cmderr
vol: db " Volume in drive ",0
vollen: equ $ - vol - 1
dirof: db " Directory of ",0
diroflen: equ $ - dirof - 1
dirbuf: dq 0
diriter: dw 34
someiter: db 0
rbaswarn: db "You're going to try to boot ROM-BASIC!",0xd,0xa,"It usually doesn't work on modern computers.",0xd,0xa,0
rbaswarnlen: equ $ - rbaswarn - 1
aus: db "Are you sure? (Y/N)",0
auslen: equ $ - aus
command:
  mov si, cmdbuf
  cmp byte [si], 0
  je .ret
  
  ; dir command
  cmp byte [si], 'd'
  je .dirI
  jmp .notDir
  .dirI:
    cmp byte [si + 1], 'i'
    je .dirR
    jmp .notDir
  .dirR:
    cmp byte [si + 2], 'r'
    je .dirSpc
    jmp .notDir
  .dirSpc:
    cmp byte [si + 3], ' '
    je .dir
    cmp byte [si + 3], 0
    je .dir
    jmp .notDir
  .dir:
    call crlf
    call readfdA
    cmp al, 1 
    je .ret
    mov  ax, ds
    mov  es, ax
    mov  bp, vol
    mov  cx, vollen
    mov  bx, 0x07
    push cx
    mov  ah, 03
    mov  bh, 0
    int  0x10
    pop  cx
    mov  ax, 0x1301
    int  0x10
    mov  al, [drive]
    mov  ah, 0x0e
    mov  bh, 0
    int  0x10
    mov  al, ' '
    mov  ah, 0x0e
    mov  bh, 0
    int  0x10
    mov  al, 'i'
    mov  ah, 0x0e
    mov  bh, 0
    int  0x10
    mov  al, 's'
    mov  ah, 0x0e
    mov  bh, 0
    int  0x10
    mov  al, ' '
    mov  ah, 0x0e
    mov  bh, 0
    int  0x10
    
    mov bx, buf
    mov es, bx
    xor bx, bx
    add bx, 4
    
    .L1:
    mov al, [es:bx]
    mov ah, 0x0e
    mov bh, 0
    int 0x10
    inc bx
    cmp bx, 34
    jne .L1
    
    call crlf
    
    mov  ax, ds
    mov  es, ax
    mov  bp, dirof
    mov  cx, diroflen
    mov  bx, 0x07
    push cx
    mov  ah, 03
    mov  bh, 0
    int  0x10
    pop  cx
    mov  ax, 0x1301
    int  0x10
    
    mov  al, [drive]
    mov  ah, 0x0e
    mov  bh, 0
    int  0x10
    mov  al, [colon]
    int  0x10
    mov  al, [sep]
    int  0x10
    
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
    cmp  al, 0
    je .skip
    jmp .rep1
    .skip:
    
    call crlf
    call crlf
    
    mov ax, buf
    mov es, ax
    xor bx, bx 
    mov word [diriter], 34
    add word bx, [diriter]
    .repread:
    add word [diriter], 30
    .rep2:
    mov  al, [es:bx]
    mov  ah, 0x0e
    mov  bh, 0
    int  0x10
    inc bx
    cmp word bx, [diriter]
    jne .rep2
    mov  al, ' '
    mov  ah, 0x0e
    mov  bh, 0
    int  0x10
    
    call crlf  
    
    call crlf
    
    jmp  .ret
  .notDir:
  ;reboot command
  cmp byte [si], 'r'
  je .rebootE
  jmp .notReboot
  .rebootE:
    cmp byte [si + 1], 'e'
    je .rebootB
    jmp .notReboot
  .rebootB:
    cmp byte [si + 2], 'b'
    je .rebootO1
    jmp .notReboot
  .rebootO1:
    cmp byte [si + 3], 'o'
    je .rebootO2
    jmp .notReboot
  .rebootO2:
    cmp byte [si + 4], 'o'
    je .rebootT
    jmp .notReboot
  .rebootT:
    cmp byte [si + 5], 't'
    je .rebootSpc
    jmp .notReboot
  .rebootSpc:
    cmp byte [si + 6], 0
    je .reboot
    cmp byte [si + 6], ' '
    je .reboot
    jmp .notReboot
  .reboot:
    call reboot
  .notReboot:
  ;ver command
  cmp byte [si], 'v'
  je .verE
  jmp .notVer
  .verE:
    cmp byte [si + 1], 'e'
    je .verR
    jmp .notVer
  .verR:
    cmp byte [si + 2], 'r'
    je .verSpc
    jmp .notVer
  .verSpc:
    cmp byte [si + 3], 0
    je .ver
    cmp byte [si + 3], ' '
    je .ver
    jmp .notVer
  .ver:
    mov  ax, ds
    mov  es, ax
    mov  bp, msg
    mov  cx, msglen
    mov  bx, 0x07
    push cx
    mov ah, 03
    mov bh, 0
    int 0x10
    pop cx
    mov  ax, 0x1301
    int  0x10
    mov  ax, ds
    mov  es, ax
    mov  bp, ver
    mov  cx, verlen
    mov  bx, 0x07
    push cx
    mov ah, 03
    mov bh, 0
    int 0x10
    pop cx
    mov  ax, 0x1301
    int  0x10
    call crlf
    jmp .ret
  .notVer:
  ;cls command
  cmp byte [si], 'c'
  je .clsL
  jmp .notCls
  .clsL:
    cmp byte [si + 1], 'l'
    je .clsS
    jmp .notCls
  .clsS:
    cmp byte [si + 2], 's'
    je .clsSpc
    jmp .notCls
  .clsSpc:
    cmp byte [si + 3], 0
    je .cls
    cmp byte [si + 3], ' '
    je .cls
    jmp .notCls
  .cls:
    pusha
    mov  ah, 0
    mov  al, 0x13
    int  0x10
    mov  ah, 0
    mov  al, 0x3
    int  0x10
    popa
    jmp .ret
  .notCls:
  ;lic command
  cmp byte [si], 'l'
  je .licL
  jmp .notLic
  .licL:
    cmp byte [si + 1], 'i'
    je .licI
    jmp .notLic
  .licI:
    cmp byte [si + 2], 'c'
    je .licSpc
    jmp .notLic
  .licSpc:
    cmp byte [si + 3], 0
    je .lic
    cmp byte [si + 4], ' '
    je .lic
    jmp .notLic
  .lic:
    pusha
    mov  ah, 0
    mov  al, 0x13
    int  0x10
    mov  ah, 0
    mov  al, 0x3
    int  0x10
    popa
    push ecx
    push eax
    push ebx
    xor ecx, ecx
    xor ax, ax
    xor bx, bx
    .repLic:
    cmp byte [license + ecx], 0xd
    je .incrAx
    cmp bx, 79
    je .incrAx
    jmp .skipIncr 
    .incrAx:
    inc ax
    xor bx, bx
    .skipIncr:
    push bx
    pusha
    mov al, [license + ecx]
    mov ah, 0x0e
    mov bh, 0
    int 0x10
    popa
    pop bx
    inc ecx
    inc bx
    cmp ax, 24
    je .resetAx
    jmp .skipReset
    .resetAx:
    pusha
    push bx
    push cx
    call crlf
    mov  ax, ds
    mov  es, ax
    mov  bp, licensemsg
    mov  cx, licensemsglen
    mov  bx, 0xf0
    mov  dl, 0
    mov  dh, 24
    mov  ax, 0x1300
    int  0x10
    mov ah, 0
    int 0x16
    pusha
    mov  ah, 0
    mov  al, 0x13
    int  0x10
    mov  ah, 0
    mov  al, 0x3
    int  0x10
    popa
    pop cx
    pop bx
    popa
    xor ax, ax
    xor bx, bx
    .skipReset:
    cmp ecx, licenselen
    jb .repLic
    pop ebx
    pop eax
    pop ecx
    call crlf
    jmp .ret
  .notLic:
  ;tst_g command
  cmp byte [si], 't'
  je .tst_gS
  jmp .notTst_g
  .tst_gS:
    cmp byte [si + 1], 's'
    je .tst_gT
    jmp .notTst_g
  .tst_gT:
    cmp byte [si + 2], 't'
    je .tst_gUb
    jmp .notTst_g
  .tst_gUb:
    cmp byte [si + 3], '_'
    je .tst_gG
    jmp .notTst_g
  .tst_gG:
    cmp byte [si + 4], 'g'
    je .tst_gSpc
    jmp .notTst_g
  .tst_gSpc:
    cmp byte [si + 5], 0
    je .tst_g
    cmp byte [si + 5], ' '
    je .tst_g
    jmp .notTst_g
  .tst_g:
    call tstcmd_g
    jmp .ret
  .notTst_g:
  ;rbas command
  ;Note, it usually doesn't work on modern computers.
  cmp byte [si], 'r'
  je .rbasB
  jmp .notRbas
  .rbasB:
    cmp byte [si + 1], 'b'
    je .rbasA
    jmp .notRbas
  .rbasA:
    cmp byte [si + 2], 'a'
    je .rbasS
    jmp .notRbas
  .rbasS:
    cmp byte [si + 3], 's'
    je .rbasSpc
    jmp .notRbas
  .rbasSpc:
    cmp byte [si + 4], 0
    je .rbas
    cmp byte [si + 4], ' '
    je .rbas
    jmp .notRbas
  .rbas:
    mov  ax, ds
    mov  es, ax
    mov  bp, rbaswarn
    mov  cx, rbaswarnlen
    mov  bx, 0x07
    push cx
    mov ah, 03
    mov bh, 0
    int 0x10
    pop cx
    mov  ax, 0x1301
    int  0x10
    .askaus:
    mov  ax, ds
    mov  es, ax
    mov  bp, aus
    mov  cx, auslen
    mov  bx, 0x07
    push cx
    mov ah, 03
    mov bh, 0
    int 0x10
    pop cx
    mov  ax, 0x1301
    int  0x10
    mov ah, 0
    int 0x16
    cmp al, 'Y'
    je .rbasY
    cmp al, 'y'
    je .rbasY
    cmp al, 'N'
    je .rbasN
    cmp al, 'n'
    je .rbasN
    call crlf
    jmp .askaus
    .rbasY:
    int 0x18
    .rbasN:
    call crlf
    jmp .ret
  .notRbas:
  ;help command
  cmp byte [si], 'h'
  je .helpE
  jmp .notHelp
  .helpE:
    cmp byte [si + 1], 'e'
    je .helpL
    jmp .notHelp
  .helpL:
    cmp byte [si + 2], 'l'
    je .helpP
    jmp .notHelp
  .helpP:
    cmp byte [si + 3], 'p'
    je .helpSpc
    jmp .notHelp
  .helpSpc:
    cmp byte [si + 4], 0
    je .help
    cmp byte [si + 4], ' '
    je .help
    jmp .notHelp
  .help:
    pusha
    mov  ah, 0
    mov  al, 0x13
    int  0x10
    mov  ah, 0
    mov  al, 0x3
    int  0x10
    popa
    push ecx
    push eax
    push ebx
    xor ecx, ecx
    xor ax, ax
    xor bx, bx
    .repHelp:
    cmp byte [helpTxt + ecx], 0xa
    je .incrAxHelp
    cmp bx, 79
    je .incrAxHelp
    jmp .skipIncrHelp 
    .incrAxHelp:
    inc ax
    xor bx, bx
    push bx
    push ax
    mov al, 0xd
    mov ah, 0x0e
    mov bh, 0
    int 0x10
    pop ax
    pop bx
    .skipIncrHelp:
    push bx
    pusha
    mov al, [helpTxt + ecx]
    mov ah, 0x0e
    mov bh, 0
    int 0x10
    popa
    pop bx
    inc ecx
    inc bx
    cmp ax, 24
    je .resetAxHelp
    jmp .skipResetHelp
    .resetAxHelp:
    pusha
    push bx
    push cx
    call crlf
    mov  ax, ds
    mov  es, ax
    mov  bp, licensemsg
    mov  cx, licensemsglen
    mov  bx, 0xf0
    mov  dl, 0
    mov  dh, 24
    mov  ax, 0x1300
    int  0x10
    mov ah, 0
    int 0x16
    pusha
    mov  ah, 0
    mov  al, 0x13
    int  0x10
    mov  ah, 0
    mov  al, 0x3
    int  0x10
    popa
    pop cx
    pop bx
    popa
    xor ax, ax
    xor bx, bx
    .skipResetHelp:
    cmp ecx, helpTxtlen
    jb .repHelp
    pop ebx
    pop eax
    pop ecx
    call crlf
    jmp .ret
  .notHelp:
  .badcmd:
    mov  ax, ds
    mov  es, ax
    mov  bp, cmderr
    mov  cx, cmderrlen
    mov  bx, 0x07
    push cx
    mov ah, 03
    mov bh, 0
    int 0x10
    pop cx
    mov  ax, 0x1301
    int  0x10
    call crlf
  .ret:
  ret
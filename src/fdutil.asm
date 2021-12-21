cpu 386
org 0x0000
db "86D"            ; Magic!
db "S"              ; System Disk
db "SYSTEM-DISK"    ; Name
times 34-($-$$) db 0

; File A.e86
; Description: Prints A to the console
file_a_e86: db "A.e86"
times 30-($-file_a_e86) db 0
dq file_a_e86_data_end - $
file_a_e86_data_start:
mov al, 'A'
mov ah, 0x0e
mov bh, 0
int 0x10
ret
file_a_e86_data_end:
; File B.e86
; Description: Prints B to the console
file_b_e86: db "B.e86"
times 30-($-file_b_e86) db 0
dq file_b_e86_data_end - $
file_b_e86_data_start:
mov al, 'B'
mov ah, 0x0e
mov bh, 0
int 0x10
ret
file_b_e86_data_end:
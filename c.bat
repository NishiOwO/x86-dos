cd "%0\.."
:a
nasm -fbin src\bootloader.asm -o bin\dos.bin
nasm -fbin src\fdutil.asm -o bin\fdutil.bin
@rem nasm -fbin src\nulfile.asm -o nulfile
@rem C:\MinGW\bin\gcc.exe -fno-asynchronous-unwind-tables -m32 -ffreestanding -S -o main.s main.c
@rem C:\MinGW\bin\gcc.exe -c main.s
@rem C:\MinGW\mingw32\bin\objcopy.exe -j .text -O binary main.o cmain
@rem type boot cmain > dos
busybox dd if=nulfile of=fdutil.img bs=1024 count=1440
busybox dd if=bin\fdutil.bin of=fdutil.img conv=notrunc
busybox dd if=nulfile of=doshdc.img bs=1024 count=20000
busybox dd if=bin\dos.bin of=doshdc.img conv=notrunc
"C:\Program Files\qemu\qemu-system-i386.exe" -boot c -hdc doshdc.img -m 512M -display gtk -fda fdutil.img
goto a
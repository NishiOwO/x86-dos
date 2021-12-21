nasm -fbin src/bootloader.asm -o bin/dos.bin
nasm -fbin src/fdutil.asm -o bin/fdutil.bin
dd if=/dev/zero of=fdutil.img bs=1024 count=1440 # create floppy placeholder
dd if=bin/fdutil.bin of=fdutil.img conv=notrunc
dd if=/dev/zero of=doshdc.img bs=1024 count=20000
dd if=bin/dos.bin of=doshdc.img conv=notrunc
qemu-system-i386 -hdc doshdc.img -fda fdutil.img -boot c
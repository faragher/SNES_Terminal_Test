..\..\cc65\bin\ca65.exe --cpu 65816 -o .\objects\hello.o .\hello.asm
..\..\cc65\bin\ld65.exe -C memmap.cfg .\objects\hello.o -o .\rom\VT100.smc

TC:=../tc/tc
TFS:=../tfs/tfstool

hdd.img: boot.bin kernel.bin
	cp boot.bin hdd.img
	truncate -s 64M hdd.img
	$(TFS) $@ format
	$(TFS) $@ reserve kernel.bin

%.bin: %.s
	nasm -f bin -o $@ $^

kernel.s: kernel.t
	$(TC) $^

run: hdd.img
	qemu-system-x86_64 -drive format=raw,file=$<

clean:
	rm -f hdd.img *.bin kernel.s

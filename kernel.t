asm {
	bits 64
	org 0x7E00
	jmp kernel_main
}

/*
 /* nested */
   comments!
*/

var tty_buffer: u16*;
var tty_width: u8;
var tty_height: u8;

var cursor_x: u8;
var cursor_y: u8;

fn clear_screen() {
	var index: u16 = 0;
	var entry: u16 = 0x8700 | ' ';
	while index < tty_width * tty_height {
		tty_buffer[index] = entry;
		index = index + 1;
	}
}

fn write_char(c: s8) {
	if c == '\n' {
		cursor_x = 0;
		cursor_y = cursor_y + 1;
		if cursor_y >= tty_height
			cursor_y = 0;
	} else {
		tty_buffer[cursor_x + tty_width * cursor_y] = 0x8700 | c;
		cursor_x = cursor_x + 1;
		if cursor_x >= tty_width {
			cursor_x = 0;
			cursor_y = cursor_y + 1;
			if cursor_y >= tty_height
				cursor_y = 0;
		}
	}
}

fn write_string(str: s8*) {
	while *str {
		write_char(*str);
		str = str + 1;
	}
}

fn kernel_main() {
	tty_buffer = (s16*) 0xB8000;
	tty_width = 80;
	tty_height = 25;

	cursor_x = 0;
	cursor_y = 0;

	clear_screen();
	write_string("Hello world from my own filesystem, language, compiler, bootloader and kernel!\n");
	write_string("Now I just need my own assembler, build system, text editor...\n");

	while 1;
}

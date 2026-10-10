OUTPUT_FORMAT(binary)
ENTRY(start)
SECTIONS
{
	. = 0x10000;
	.text : {*(.text)}
	.data : {*(.data)}
	.bss  : {*(.bss)}
}
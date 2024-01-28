


extern void _main(void);
extern int _putc(int c);

int print_args(int x1, int x2, int x3, int x4, int x5, int x6){

	_putc(x1);
	_putc(x2);
	_putc(x3);
	_putc(x4);
	_putc(x5);
	_putc(x6);
	return 0;
}


int main(void){

	_main();
	
	return 0;
}

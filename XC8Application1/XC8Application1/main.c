#define F_CPU 1000000
#include <avr/io.h>
#include <util/delay.h>
#include <stdio.h>
#include <avr/delay.h>

void main()
{
	DDRD |= 1 << DDRD4;
	DDRD &= ~(1 << DDRD2);
	_delay_ms(2000);
	
	while(1)
	{
		//Checks pin d4 for power cycling, if so, turns of thrust and power cycles for 2 seconds
		if ( (PIND & (1 << PIND2)) == (1 << PIND2) )
		{
			PORTD |= (1 << DDRD4);
			_delay_ms(2000);
			PORTD &= ~(1 << DDRD4);
			
		}
		
	}
}




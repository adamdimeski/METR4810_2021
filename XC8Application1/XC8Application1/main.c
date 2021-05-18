#define F_CPU 1000000
#include <avr/io.h>
#include <util/delay.h>
#include <stdio.h>
#include <avr/delay.h>

void main()
{
	_delay_ms(2000);
	//FOR TIMER1
	TCCR1A |= (1<<COM1A1)|(1<<COM1B1)|(1<<WGM11);        //NON Inverted PWM
	TCCR1B |= (1<<WGM13)|(1<<WGM12)|(1<<CS11)|(1<<CS10); //PRESCALER=64 MODE 14(FAST PWM)
	ICR1 = 312;  //fPWM=50Hz
	
	DDRB |= 1<<DDB5;   //PWM Pins as Output
	DDRD |= 1 << DDRD4;
	DDRD &= ~(1 << DDRD2);
	DDRD &= ~(1 << DDRD3);
	
	
	OCR1A = 15;
	_delay_ms(3000);
	while(1)
	{
		if ( (PIND & (1 << PIND2)) == (1 << PIND2) ) 
		{
			OCR1A = 18;
		} 
		else 
		{
			OCR1A = 15;
		}
		
		//Checks pin d4 for power cycling, if so, turns of thrust and power cycles for 2 seconds
		if ( (PIND & (1 << PIND3)) == (1 << PIND3) )
		{
			OCR1A = 0;
			PORTD |= (1 << DDRD4);
			_delay_ms(2000);
			PORTD &= ~(1 << DDRD4);
			
		}
		
	}
}




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
	
	
	OCR1A = 33;
	while(1)
	{
		if (PIND2)
		{
			OCR1A = 20;
			//set between 20 and 33
		}
		else
		{
			OCR1A = 33;
		}
		
	}
}




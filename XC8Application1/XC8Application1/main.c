#define F_CPU 1000000
#include <avr/io.h>
#include <util/delay.h>
#include <stdio.h>

void main()
{
	//FOR TIMER1
	TCCR1A|=(1<<COM1A1)|(1<<COM1B1)|(1<<WGM11);        //NON Inverted PWM
	TCCR1B|=(1<<WGM13)|(1<<WGM12)|(1<<CS11)|(1<<CS10); //PRESCALER=64 MODE 14(FAST PWM)
	ICR1=312;  //fPWM=50Hz
	DDRB = 1<<DDB5;   //PWM Pins as Output
	//OCR1A=30;  //90 degree
	//_delay_ms(3000);
	//OCR1A=15;
	//_delay_ms(3000);
	while(1)
	{
		
		OCR1A=15;
		_delay_ms(3000);
		OCR1A=18;
		_delay_ms(3000);
		
	}
}

int angle2duty(int angle)
{
	if (angle >= 0 && angle <= 180)
	{
		int dutyTime = 1 + 1*(angle/180) //time of pulse in ms
		int dutyCycle = (dutyTime/20) * 1023 //the duty cycle out of 1023
		return dutyCycle
	}
	else
	{
		return 0;
	}
}
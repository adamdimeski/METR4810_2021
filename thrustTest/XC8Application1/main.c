#define F_CPU 16000000
#include <avr/io.h>
#include <util/delay.h>
#include <stdio.h>





void USART_Init( unsigned int ubrr )
{
	/* Set baud rate */
	UBRR0H = (unsigned char)(ubrr>>8);
	UBRR0L = (unsigned char)ubrr;
	/* Enable receiver and transmitter */
	UCSR0B = (1<<RXEN0)|(1<<TXEN0);
	/* Set frame format: 8data, 2stop bit */
	UCSR0C = (1<<USBS0)|(3<<UCSZ00);
}

void USART_Transmit( unsigned char data )
{
	/* Wait for empty transmit buffer */
	while ( !( UCSR0A & (1<<UDRE0)) )
	;
	/* Put data into buffer, sends the data */
	UDR0 = data;
}

unsigned char USART_Receive( void )
{
	/* Wait for data to be received */
	while ( !(UCSR0A & (1<<RXC0)) )
	;
	/* Get and return received data from buffer */
	return UDR0;
}

int main()
{
	
	
	
	//FOR TIMER1
	TCCR1A|=(1<<COM1A1)|(1<<COM1B1)|(1<<WGM11);        //NON Inverted PWM
	TCCR1B|=(1<<WGM13)|(1<<WGM12)|(1<<CS11)|(1<<CS10); //PRESCALER=64 MODE 14(FAST PWM)
	ICR1=312;  //fPWM=50Hz
	DDRB = 1<<DDB5;   //PWM Pins as Output
	//OCR1A=30;  //90 degre
	//_delay_ms(3000);
	//OCR1A=15;
	//_delay_ms(3000);
	
	
	
	
		
		// Internally UART0_Init() is mapped to UART_Init()
		// You can notice First two(0,1) are called with parameter other two(2,3) with suffix

		/*Directly use the Channel suffixed interface UART0_Printf, where suffix "0" specifies the UART channel*/
		
		/*16 pwm = 11g thrust
		17 =37g
		18 = 62g
		19 = 77g
		20 = 82g
		21 = 98g
		25 = 147g
		30 = 230
		*/
		OCR1A=19;
		_delay_ms(1000);
		OCR1A=15;
		_delay_ms(1000000);
		
		
		
		
		
	
		
	
}
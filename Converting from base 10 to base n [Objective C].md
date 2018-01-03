Here is a quick snippet to convert any base 10 number to any base. In this example we're converting to base 4 with a length of 4

```c
//Convert to Base 4
int base = 4;

//With 4 places
//256	16	4	1
// 0	3	0	2
int places = 4;

//Our input number
int input = 50;

NSMutableString *newStr = [[NSMutableString alloc] init];
    
//We're going to loop through backwards the powers (256, 16, 4, 1 etc) and work out how many times our input evenly goes into it
for (int index = places; index > -1; i--)
{        
	// how many times does 50 go into the power
	int decimal = (int)((double)input / (double)(pow(base, index)));
	// whats the remainder, set it back to input
	input = (int)(input % (int)(pow(base, index)));

	// append the value to a string
	[newStr appendString:[NSString stringWithFormat:@"%i", decimal]];        
}
```
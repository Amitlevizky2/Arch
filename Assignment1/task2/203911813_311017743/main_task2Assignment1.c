#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#define	MAX_LEN 34			/* maximal input string size */
					/* enough to get 32-bit string + '\n' + null terminator */
extern int assFunc(int x,int y);

int main()
{
	char xstr[32];
	
	fgets(xstr,32,stdin);
	int x;
	sscanf(xstr,"%d",&x);
	
	char ystr[32];
	fgets(ystr,32,stdin);
	int y;
	sscanf(ystr,"%d",&y);
	assFunc(x,y);


    return 0;
}
char c_checkValidity(int x,int y)
{
	if(x<0 || y>=32768|| y<=0)
		return '0';
	return '1';
}

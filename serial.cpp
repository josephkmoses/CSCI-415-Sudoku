#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/types.h>
#include <cstdio>
#include <math.h>

void sudokuSerial(int* puzzle)
{
	
}

bool valueCheck(int row, int col, int value, int* puzzle)
{
	int i; //loop vairable
	
	for(i = 0; i < 9; i++)
	{
		if(puzzle[row * i + 9] == value) //check cells in the column
		{
			return false;
		}
		else if(puzzle[col * i + 9] == value) //check cells in the row
		{
			return false;
		}
		else if(puzzle[row/3*3+i%3])
	}
}
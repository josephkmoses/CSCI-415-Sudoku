#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/types.h>
#include <cstdio>
#include <math.h>

static bool finished;

void solve(int row, int col, int* puzzle, int counter, int startValue)
{
	if(counter == 81) //every cell has been visted
	{
		return true;
	}
	if(finished)
	{
		return true;
	}
	
	//loop of column and rows
	if(++col == 9)
	{
		col = 0;
		if(++row == 9)
		{
			row = 0;
		}
	}
	
	//skip cells that are already filled
	if(puzzle[row + col * 9] != 0)
	{
		return solve(row, col, puzzle, counter+1, startValue);
	}
	
	//if the cell is empty
	for(int val = 1; val <= 9; val++)
	{
		//loop through the values being checked recursively
		if(++startValue == 10)
		{
			startValue = 1;
		}
		
		//check if the value is allowed
		if(valueAllowedCheck(row, col, startValue, puzzle))
		{
			puzzle[row + col * 9] = startValue; //record if it is
			
			if(solve(row, col, puzzle, counter+1, startValue) //solve the next cell
			{
				return true;
			}
		}
	}
	puzzle[row + col *9] = 0; //set to zero if backtracking
	return false;
}

bool valueAllowedCheck(int row, int col, int value, int* puzzle)
{
	int i; //loop vairable
	
	for(i = 0; i < 9; i++)
	{
		if(puzzle[row * 9 + i] == value) //check cells in the row
		{
			return false;
		}
		else if(puzzle[col + i * 9] == value) //check cells in the column
		{
			return false;
		}
		else if(puzzle[(row/3*3+i%3) * 9 + (col/3*3+i/3) ] == value) //check the subsquare
		{
			return false;
		}
	}
	
	return true; //the value works
}
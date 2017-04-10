\#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/types.h>
#include <cstdio>
#include <math.h>
#include <time.h>
#include <iostream>
using namespace std;

static bool finished;

bool solve(int row, int col, int* puzzle, int counter, int startValue);
bool valueAllowedCheck(int row, int col, int value, int* puzzle);
void run(int* puzzle);

bool solve(int row, int col, int* puzzle, int counter, int startValue)
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

                        if(solve(row, col, puzzle, counter+1, startValue)) //solve the next cell
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

void run (int* puzzle) {
                int i = rand() % 8; //random row  (0-8)
                int j = rand() % 8; //random column  (0-8)
                int startVal = rand() % 9 +1; //Starting value (1-9) N


                //Timer start here

                if(solve(i,j,puzzle,0,startVal)) { //Does this need to be passing a pointer?
                        //the puzzle was solved
                        cout << "Puzzle Solved\n";
                }
                else {
                        cout << "Not Solved\n";
                }

                //timer end here

                if(!finished) {
                        finished = true;
                }



}

int main() {
      //clear easy puzzle
          int* easyPuzzle = (int*)malloc(81*sizeof(int));
          int inputEasy[81] = {0,7,0,  0,5,0,  8,0,6,  //row 1
                              8,0,0,  1,7,0,  9,5,2,  //row 2
                              0,2,5,  0,4,6,  3,0,0,    //row 3

                              0,0,0,  0,0,2,  0,0,0,   //row 4
                              0,0,4,  0,9,0,  2,0,0,   //row 5
                              0,0,0,  3,0,0,  0,0,0,    //row 6

                              0,0,8,  5,3,0,  6,1,0,    //row 7
                              3,5,1,  0,8,4,  0,0,9,    //row 8
                              4,0,7,  0,2,0,  0,0,0   //row 9
                           };

          //meduim
          int* meduimPuzzle = (int*)malloc(81*sizeof(int));
          int inputMeduim[81] = { 0,7,6,  3,0,0,  0,0,4,  //row 1
                              0,0,0,  0,1,0,  3,9,0,  //row2
                              3,2,9,  8,0,0,  5,0,0,   //row3

                              0,0,0,  0,0,2,  0,8,0,    //row4
                              2,0,0,  0,0,0,  0,0,1,  //row5
                              0,8,0,  9,0,0,  0,0,0,   //row6

                              0,0,2,  0,0,8,  6,4,9,  //row7
                              0,6,7,  0,4,0,  0,0,0,  //row8
                              9,0,0,  0,0,6,  7,5,0  //row9
                              };
        int* hardPuzzle = (int*)malloc(81*sizeof(int));
        int inputHard[81] = {0,0,3,  0,9,0,   0,5,0,  //row1
                          0,0,9,  0,0,2,  0,0,0,  //row2
                          0,0,0,  5,0,1,  8,0,0,  //row3

                          4,5,0,  0,7,3,  0,0,2,  //row4
                          0,0,0,  4,0,6,  0,0,0,  //row5
                          2,0,0,  1,8,0,  0,4,6,  //row6

                          0,0,2,  7,0,4,  0,0,0,  //row 7
                          0,0,0,  2,0,0,  5,0,0,  //row8
                          0,9,0,  0,1,0,  2,0,0   //row9
                          };

        int* evilPuzzle = (int*)malloc(81*sizeof(int));
        int inputEvil[81]= {6,0,0, 0,0,8,  9,4,0, //row1
                          9,0,0,  0,0,6,  1,0,0, //row2
                          0,7,0,  0,4,0,  0,0,0,  ///row3

                          2,0,0,  6,1,0,  0,0,0, //row4
                          0,0,0,  0,0,0,  2,0,0,  //row5
                          0,8,9,  0,0,2,  0,0,0,   //row6

                          0,0,0,  0,6,0,  0,0,5,  //row7
                          0,0,0,  0,0,0,  0,3,0,  //row8
                          8,0,0,  0,0,1,  6,0,0 //row9
                      };
      int* unsolveable = (int*)malloc(81*sizeof(int));
      int inputUnsolve[81] =   {1,2,3,   4,5,6,  7,8,0,  //row1
                                0,0,0,  0,0,0,  0,0,2,   //row2
                                0,0,0,  0,0,0,  0,0,3,  //row3

                                0,0,0,  0,0,0,  0,0,4,   //row4
                                0,0,0,  0,0,0,  0,0,5,   //row5
                                0,0,0,  0,0,0,  0,0,6,    //row6

                                0,0,0,  0,0,0,  0,0,7,  //row7
                                0,0,0,  0,0,0,  0,0,8,  //row8
                                0,0,0,  0,0,0,  0,0,9   //row9
                                };


  int i;
  for(i =0; i < 81; i++) {
    easyPuzzle[i] = inputEasy[i];
    meduimPuzzle[i] = inputMeduim[i];
    hardPuzzle[i] = inputHard[i];
    evilPuzzle[i] = inputEvil[i];
    unsolveable[i] = inputUnsolve[i];
    }
         run(hardPuzzle);
}

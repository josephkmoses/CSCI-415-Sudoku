#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/types.h>
#include <cstdio>
#include <math.h>
#include <sys/time.h>
#include <iostream>
#include <iomanip>
#include <string>
#include <algorithm>

using namespace std;

__device__ bool valueAllowedCheck(int row, int col, int value, int* puzzle)
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

__device__ bool solve(int row, int col, int* puzzle, int counter, int startValue, bool* finished)
{		
	if(counter == 81) //every cell has been visted
	{
			return true;
	}
	if(*finished)
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
	if(puzzle[row * 9 + col] != 0)
	{
			return solve(row, col, puzzle, counter+1, startValue, finished);
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
					puzzle[row * 9 + col] = startValue; //record if it is

					if(solve(row, col, puzzle, counter+1, startValue, finished)) //solve the next cell
					{
							return true;
					}
			}
	}
	puzzle[row * 9 + col] = 0; //set to zero if backtracking
	return false;
}


	
__global__ void parallelSudoku(int* puzzle, bool* finished, int* result)
{
	int i = threadIdx.x;	//the thread id
	int j = threadIdx.y;
    int startVal = (blockIdx.x * blockDim.x + threadIdx.x) % 9 +1; //Starting value (1-9) N
	
	__shared__ bool* sharedFinish = *finished;
	
	bool finishedTemp;
	int resultTemp;
	
	int puzzleArray [81];
	
	for(int i =0; i < 81; i++)
	{
		puzzleArray[i] = puzzle[i];
	}

	if(solve(i,j,puzzleArray,0,startVal, sharedFinish)) 
	{
		if(!*sharedFinish)//none of the threads have finished the puzzle
		{
			finishedTemp = true;
			finished = &finishedTemp;
			
			for(int i =0; i < 81; i++)
			{
				puzzle[i] = puzzleArray[i];
			}
			
			resultTemp = 1;
			(*result) = resultTemp;
		}
	}
	else
	{
		if(!*sharedFinish)//none of the threads have finished the puzzle
		{
			finishedTemp = false;
			finished = &finishedTemp;
		}
	}

}

void printPuzzle (int* puzzle ) {
    int i;
    int count =0;
    int mod;

    for(i =0; i< 81; i++) {
      mod = count % 3;
      if(count > 8){
        count =0;
        cout << "\n";
      }
      else if (mod == 0)
      {
        cout << "  ";
      }
        count ++;
        cout << puzzle[i];
        cout << " ";
    }

	cout << "\n";
}

// Copied from assignment 1
// BEGIN: timing and error checking routines (do not modify)

// Returns the current time in microseconds
long long start_timer() {
	struct timeval tv;
	gettimeofday(&tv, NULL);
	return tv.tv_sec * 1000000 + tv.tv_usec;
}


// Prints the time elapsed since the specified time
long long stop_timer(long long start_time, std::string name) {
	struct timeval tv;
	gettimeofday(&tv, NULL);
	long long end_time = tv.tv_sec * 1000000 + tv.tv_usec;
        std::cout << std::setprecision(5);	
	std::cout << name << ": " << ((float) (end_time - start_time)) / (1000 * 1000) << " sec\n";
	return end_time - start_time;
}

void checkErrors(const char label[])
{
  // we need to synchronise first to catch errors due to
  // asynchroneous operations that would otherwise
  // potentially go unnoticed

  cudaError_t err;

  err = cudaThreadSynchronize();
  if (err != cudaSuccess)
  {
    char *e = (char*) cudaGetErrorString(err);
    fprintf(stderr, "CUDA Error: %s (at %s)", e, label);
  }

  err = cudaGetLastError();
  if (err != cudaSuccess)
  {
    char *e = (char*) cudaGetErrorString(err);
    fprintf(stderr, "CUDA Error: %s (at %s)", e, label);
  }
}

// END: timing and error checking routines (do not modify)


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

	
	
	//host variables
	bool* h_finished = (bool*)malloc(sizeof(bool));
	bool finishedTemp = false;
	h_finished = &finishedTemp;
	int* h_puzzle = (int*)malloc(81*sizeof(int));
	int* h_result = (int*)malloc(sizeof(int));
	int resultTemp = 0;
	h_result = &resultTemp;
	
	int* d_puzzle;
	bool* d_finished;
	int* d_result;

	long long Total_GPU_start_time = start_timer();
	
	cudaMalloc((void**) &d_puzzle, 81*sizeof(int));
	checkErrors("cudaMalloc1");
	cudaMalloc((void**) &d_finished, sizeof(bool));
	checkErrors("cudaMalloc2");
	cudaMalloc((void**) &d_result, sizeof(int));
	checkErrors("cudaMalloc3");
	
	cudaMemcpy(d_puzzle, easyPuzzle, 81*sizeof(int), cudaMemcpyHostToDevice);
	checkErrors("cudaMemcpy1");
	cudaMemcpy(d_finished, h_finished, sizeof(bool), cudaMemcpyHostToDevice);
	checkErrors("cudaMemcpy2");
	cudaMemcpy(d_result, h_result, sizeof(int), cudaMemcpyHostToDevice);
	checkErrors("cudaMemcpy3");
	
	size_t stackSize = 30000;
	cudaDeviceSetLimit(cudaLimitStackSize, stackSize);
	
	checkErrors("stack size");
	
	dim3 threadsPerBlock(9,9);
	
	parallelSudoku<<<1 , threadsPerBlock>>>(d_puzzle, d_finished, d_result);
	checkErrors("kernel error");
	cudaDeviceSynchronize();
	
	cudaMemcpy(h_finished, d_finished, sizeof(bool), cudaMemcpyDeviceToHost);
	checkErrors("cudaMemcpy4");
	cudaMemcpy(h_puzzle, d_puzzle, 81*sizeof(int), cudaMemcpyDeviceToHost);
	checkErrors("cudaMemcpy5");
	cudaMemcpy(h_result, d_result, sizeof(int), cudaMemcpyDeviceToHost);
	checkErrors("cudaMemcpy6");
	
	long long GPU_total_run_time = stop_timer(Total_GPU_start_time, "\nGPU Total Run Time");
	
	if(*h_result == 1)
	{
		cout << "Solved\n";
	}
	else
	{
		cout << "Unsolved\n";
	}
	
	printPuzzle(h_puzzle); 
	
	return 0;
	
}

// Homework 1
// Color to Greyscale Conversion

//A common way to represent color images is known as RGBA - the color
//is specified by how much Red, Grean and Blue is in it.
//The 'A' stands for Alpha and is used for transparency, it will be
//ignored in this homework.

//Each channel Red, Blue, Green and Alpha is represented by one byte.
//Since we are using one byte for each color there are 256 different
//possible values for each color.  This means we use 4 bytes per pixel.

//Greyscale images are represented by a single intensity value per pixel
//which is one byte in size.

//To convert an image from color to grayscale one simple method is to
//set the intensity to the average of the RGB channels.  But we will
//use a more sophisticated method that takes into account how the eye 
//perceives color and weights the channels unequally.

//The eye responds most strongly to green followed by red and then blue.
//The NTSC (National Television System Committee) recommends the following
//formula for color to greyscale conversion:

//I = .299f * R + .587f * G + .114f * B

//Notice the trailing f's on the numbers which indicate that they are 
//single precision floating point constants and not double precision
//constants.

//You should fill in the kernel as well as set the block and grid sizes
//so that the entire image is processed.

#include "reference_calc.cpp"
#include "utils.h"
#include <stdio.h>

__global__
void rgba_to_greyscale(const uchar4* const rgbaImage,
                       unsigned char* const greyImage,
                       int numRows, int numCols)
{
    // find block number of the block to which the thread running the kernel belongs
    unsigned int blockNo = blockIdx.y * gridDim.x + blockIdx.x; 

    // threads per block
    unsigned int blockSize = blockDim.x * blockDim.y;
    
    // find the thread's number which is the linear index
    unsigned int threadNo = blockNo * (blockSize) + threadIdx.y * blockDim.x + threadIdx.x;
    
    // calculating greyscale intensity
    // check if thread out of image; note image is one dimension
    if(threadNo < numRows * numCols)
        greyImage[threadNo] = .299f * rgbaImage[threadNo].x + .587f * rgbaImage[threadNo].y + .114f * rgbaImage[threadNo].z;
}

void your_rgba_to_greyscale(const uchar4 * const h_rgbaImage, uchar4 * const d_rgbaImage,
                            unsigned char* const d_greyImage, size_t numRows, size_t numCols)
{
  // setting block size variables
  const unsigned short int BLOCKSIZE_X = 16;
  const unsigned short int BLOCKSIZE_Y = 16;
  // calculating grid size based on block size defined and image size
  const unsigned int GRIDSIZE_X = numCols / BLOCKSIZE_X + (((numCols % BLOCKSIZE_X) == 0) ? 0 : 1);
  const unsigned int GRIDSIZE_Y = numRows / BLOCKSIZE_Y + (((numRows % BLOCKSIZE_Y) == 0) ? 0 : 1);
  // defining block and grid sizes
  const dim3 blockSize(BLOCKSIZE_X, BLOCKSIZE_Y, 1);
  const dim3 gridSize(GRIDSIZE_X, GRIDSIZE_Y, 1);
  
  // calling kernel on grid x block
  rgba_to_greyscale<<<gridSize, blockSize>>>(d_rgbaImage, d_greyImage, numRows, numCols);
  
  cudaDeviceSynchronize(); checkCudaErrors(cudaGetLastError());
}

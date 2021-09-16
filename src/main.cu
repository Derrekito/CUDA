//#include <stdio.h>
//#include <stdint.h>
//#include <stdlib.h>
//#include <fstream>

#include <string>
#include <fstream>
#include <array>
#include <stdio.h>
#include <iostream>

#define DEBUG 2


using namespace std;

__global__ void getback(uint8_t *device_in, uint8_t *device_out, int NUM_COLS, int NUM_ROWS) {  
  int idx = blockIdx.x*blockDim.x + threadIdx.x;
  if(idx < NUM_COLS*NUM_ROWS){
    device_out[idx] = device_in[idx];
  }
}

int main(){
  const int NUM_THREADS = 1024;
  const int NUM_BLOCKS = 45938;
  const int NUM_COLS = 60000;
  const int NUM_ROWS = 784;
  const int NUM_BYTES = NUM_COLS * NUM_ROWS * sizeof(uint8_t);

  uint8_t *host_in = (uint8_t*) malloc(NUM_BYTES);
  uint8_t *host_out = (uint8_t*) malloc(NUM_BYTES); 

  uint8_t *device_in;
  uint8_t *device_out;

  cudaMalloc(&device_in, NUM_BYTES);
  cudaMalloc(&device_out, NUM_BYTES);

  int count=0;
    for(int i=0; i< NUM_COLS*NUM_ROWS; i++){
      *(host_in + i) = count;
      if(count == 255){count = 0;}
      else{count++;}
    }
    printf("\n");
  
#if DEBUG==1

  for(int i=0; i < NUM_COLS*NUM_ROWS; i++){
    printf("%d",host_in[i]);
  }
  printf("\n\n");
#endif

  cudaMemcpy(device_in, host_in, NUM_BYTES, cudaMemcpyHostToDevice);
//  cudaMemcpy(device_out, device_in, NUM_BYTES, cudaMemcpyDeviceToDevice); // copy pointers bypassing global function
  getback<<<NUM_BLOCKS,NUM_THREADS>>>(device_in, device_out, NUM_COLS, NUM_ROWS);

  cudaMemcpy(host_out, device_out, NUM_BYTES, cudaMemcpyDeviceToHost);

  cudaFree(device_in);
  cudaFree(device_out);
  
  cudaFreeHost(host_in);
  cudaFreeHost(host_out);

#if DEBUG==2
  for(int i=0; i<NUM_COLS*NUM_ROWS; i++){
    printf("%d ", *(host_out + i));
  }
  printf("\n");
#endif
}
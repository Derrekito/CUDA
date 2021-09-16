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

__global__ void getback(uint8_t *device_in, uint8_t *device_out, int NUM_ELM) {  
  int idx = blockIdx.x*blockDim.x + threadIdx.x;
  if(idx < NUM_ELM){
    device_out[idx] = device_in[idx];
  }
}

int main(){
  const int NUM_THREADS = 1024;
  const int NUM_BLOCKS = 2;
  const int NUM_ELM = 2048;
  const int NUM_BYTES = NUM_ELM * sizeof(uint8_t);

  uint8_t *host_in = (uint8_t*) malloc(NUM_BYTES);
  uint8_t *host_out = (uint8_t*) malloc(NUM_BYTES);

  uint8_t *device_in;
  uint8_t *device_out;

  cudaMalloc(&device_in, NUM_BYTES);
  cudaMalloc(&device_out, NUM_BYTES);

  int count=0;
  for(int i=0; i<NUM_ELM; i++){
    *(host_in + i) = count;
    if(count == 255){count = 0;}
    else{count++;}
  }
#if DEBUG==1
  for(int i=0; i< NUM_ELM; i++){
    printf("%d ", *(host_in + i));
  }
  printf("\n\n");
#endif

  cudaMemcpy(device_in, host_in, NUM_BYTES, cudaMemcpyHostToDevice);
//  cudaMemcpy(device_out, device_in, NUM_BYTES, cudaMemcpyDeviceToDevice); // copy pointers bypassing global function
  getback<<<NUM_BLOCKS,NUM_THREADS>>>(device_in, device_out, NUM_ELM);

  cudaMemcpy(host_out, device_out, NUM_BYTES, cudaMemcpyDeviceToHost);

  cudaFree(device_in);
  cudaFree(device_out);
#if DEBUG==2
  for(int i=0; i<NUM_ELM; i++){
    printf("%d ", *(host_out + i));
  }
  printf("\n");
#endif
}
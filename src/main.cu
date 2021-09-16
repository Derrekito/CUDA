//#include <stdio.h>
//#include <stdint.h>
//#include <stdlib.h>
//#include <fstream>
#include "mnist.h"
#include <string>
#include <fstream>
#include <array>
#include <stdio.h>
#include <iostream>

#define DEBUG 2


using namespace std;

__global__ void getback(uint8_t *device_in, uint8_t *device_out, int NUM_IMGS, int NUM_PIXELS) {  
  int idx = NUM_PIXELS*(blockIdx.x*blockDim.x + threadIdx.x);
  if(idx < NUM_IMGS * NUM_PIXELS){
    for(int i=0; i< NUM_PIXELS;i++){
      device_out[idx+i] = device_in[idx+i];
    }
  }
}

int main(int argc, char **argv){
  // dataset paths
  string base_dir = "data/";
  string img_path = base_dir+"train-images-idx3-ubyte";
  string label_path = base_dir+"train-labels-idx1-ubyte";

  // 60000/1024 ~ 59, where 1024 is MAX_THREADS
  const int NUM_THREADS = 1024;
  const int NUM_BLOCKS = 59;

  // dataset parameters
  uint32_t *NUM_IMGS = (uint32_t*) malloc(sizeof(uint32_t));
  uint32_t *NUM_LABELS = (uint32_t*) malloc(sizeof(uint32_t));
  uint32_t *NUM_COLS = (uint32_t*) malloc(sizeof(uint32_t));
  uint32_t *NUM_ROWS = (uint32_t*) malloc(sizeof(uint32_t));
  uint32_t *NUM_PIXELS = (uint32_t*) malloc(sizeof(uint32_t));
  uint32_t *NUM_BYTES = (uint32_t*) malloc(sizeof(uint32_t));

  // load host_in with the dataset
  uint8_t *host_in = load_mnist(img_path.c_str(), label_path.c_str(), NUM_IMGS, NUM_LABELS, NUM_COLS, 
             NUM_ROWS, NUM_PIXELS, NUM_BYTES);

  uint8_t *host_out = (uint8_t*) malloc(*NUM_BYTES); 

  uint8_t *device_in;
  uint8_t *device_out;

  // allocate device memory
  cudaMalloc(&device_in, *NUM_BYTES);
  cudaMalloc(&device_out, *NUM_BYTES);

  // copy host_in into device_in
  cudaMemcpy(device_in, host_in, *NUM_BYTES, cudaMemcpyHostToDevice);
  //cudaMemcpy(device_out, device_in, *NUM_BYTES, cudaMemcpyDeviceToDevice); // copy pointers bypassing global function
  getback<<<NUM_BLOCKS,NUM_THREADS>>>(device_in, device_out, *NUM_IMGS, *NUM_PIXELS);
  //cudaMemcpy(host_out, device_in, *NUM_BYTES, cudaMemcpyDeviceToHost); // copy pointers bypassing device_out 
  cudaMemcpy(host_out, device_out, *NUM_BYTES, cudaMemcpyDeviceToHost);

  // free device memory
  cudaFree(device_in);
  cudaFree(device_out);
  
  // free host memory
  cudaFreeHost(host_in);
  cudaFreeHost(host_out);

#if DEBUG==2
  // render image data in terminal!
  string color;
  int bin_offset = 232; // greyscale color range is 232-255
  string print_exp;
  for(int j=0;j<*NUM_IMGS * *NUM_PIXELS;j++){
    if(j%28==0){
	    if(j/28==0){printf("\n");}
	      printf("\n");
        printf("%3d: ",int(j/28));
    }

    color = to_string(host_out[j]/24+(host_out[j]%24!=0)+bin_offset); // 255-232+1 = 24 bins (some aliasing)
    print_exp = "\u001b[48;5;"+color+"m  "; // 8 bit 256 color code
    printf("%s",print_exp.c_str());
  }
  cout<<endl;
#endif
}
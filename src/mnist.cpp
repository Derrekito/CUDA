#include <iostream>
#include <stdlib.h>
#include <fstream>
#include <stdint.h>

#define MNIST_DEBUG 0

using namespace std;

uint32_t swap_endian(uint32_t val) {
  val = ((val << 8) & 0xFF00FF00) | ((val >> 8) & 0xFF00FF);
  return (val << 16) | (val >> 16);
}

void load_mnist(const char *img_path, const char *label_path, uint32_t *NUM_IMGS, uint32_t *NUM_LABELS,
  uint32_t *NUM_COLS, uint32_t *NUM_ROWS, uint32_t *NUM_PIXELS, uint32_t *NUM_BYTES,
	uint8_t *images){

  uint32_t magic;

  // Open files
  ifstream image_file(img_path, ios::in | ios::binary);
  ifstream label_file(label_path, ios::in | ios::binary);

  image_file.read(reinterpret_cast<char*>(&magic), 4); // extract 4 bytes
  magic = swap_endian(magic);
  if(magic != 2051){ // sanity check
    cout<<"Incorrect image file magic: "<<magic<<endl;
    exit (EXIT_FAILURE);
  }

  label_file.read(reinterpret_cast<char*>(&magic), 4); // extract 4 bytes
  magic = swap_endian(magic);
  if(magic != 2049){
    cout<<"Incorrect image file magic: "<<magic<<endl;
    exit (EXIT_FAILURE);
  }

  // Read number of images
  image_file.read(reinterpret_cast<char*>(&(*NUM_IMGS)), 4); // extract 4 bytes
  *NUM_IMGS = swap_endian(*NUM_IMGS);

  // Read number of labels
  label_file.read(reinterpret_cast<char*>(&(*NUM_LABELS)), 4); // extract 4 bytes
  *NUM_LABELS = swap_endian(*NUM_LABELS);
  
  // Sanity check
  if(*NUM_IMGS != *NUM_LABELS){
    cout<<"image file nums should equal to label num"<<endl;
    exit (EXIT_FAILURE);
  }

  // Read number of rows in each image
  image_file.read(reinterpret_cast<char*>(&(*NUM_ROWS)), 4);
  *NUM_ROWS = swap_endian(*NUM_ROWS);

  // Read number of columns in each image
  image_file.read(reinterpret_cast<char*>(&(*NUM_COLS)), 4);    
  *NUM_COLS = swap_endian(*NUM_COLS);

  // useful calculations
  *NUM_PIXELS = *NUM_ROWS * *NUM_COLS;
  *NUM_BYTES = (*NUM_IMGS) * *NUM_PIXELS * sizeof(uint8_t);
    
  image_file.read(reinterpret_cast<char*>(images),*NUM_BYTES);

#if MNIST_DEBUG == 1
    string color;
    int bin_offset = 232; // greyscale color range is 232-255
    string print_exp;
    for(int j=0;j<*NUM_IMGS * *NUM_ROWS * *NUM_COLS;j++){
      if(j%28==0){
	      if(j/28==0){printf("\n");}
	      printf("\n");
        printf("%3d: ",int(j/28));
      }

      color = to_string(images[j]/24+(images[j]%24!=0)+bin_offset); // 255-232+1 = 24 bins
      //printf("%s ",color.c_str());
            print_exp = "\u001b[48;5;"+color+"m  "; // 8 bit 256 color code
      printf("%s",print_exp.c_str());
    }
#endif
    
  printf("\u001b[0m");//reset terminal
  cout<<endl;
  cout<<"num of images: "<<*NUM_IMGS<<endl;
  cout<<"num of labels: "<<*NUM_LABELS<<endl;
  cout<<"image rows: "<<*NUM_ROWS<<", image cols: "<<*NUM_COLS<<endl;
}
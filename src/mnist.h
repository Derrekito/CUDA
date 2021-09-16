#include "mnist.cpp"

uint32_t swap_endian(uint32_t val);

void load_mnist(const char *img_path, const char *label_path, uint32_t *NUM_IMGS, 
								uint32_t *NUM_LABELS, uint32_t *NUM_COLS, uint32_t *NUM_ROWS, uint32_t *NUM_PIXELS, uint32_t *NUM_BYTES, uint8_t* images);

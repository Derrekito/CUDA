HOST_ARCH 	?= $(shell uname -m)
TARGET_ARCH 	?= $(HOST_ARCH)

# Location of the CUDA Toolkit
CUDA_PATH ?= /usr/local/cuda

HOST_COMPILER ?= g++
NVCC          := $(CUDA_PATH)/bin/nvcc -ccbin $(HOST_COMPILER)

# internal flags
NVCCFLAGS   := -m${TARGET_SIZE}
CCFLAGS     :=
LDFLAGS     :=

# Debug build flags
ifeq ($(dbg),1)
      NVCCFLAGS += -g -G
      BUILD_TYPE := debug
else
      BUILD_TYPE := release
endif

ALL_CCFLAGS :=
ALL_CCFLAGS += $(NVCCFLAGS)
ALL_CCFLAGS += $(EXTRA_NVCCFLAGS)
ALL_CCFLAGS += $(addprefix -Xcompiler ,$(CCFLAGS))
ALL_CCFLAGS += $(addprefix -Xcompiler ,$(EXTRA_CCFLAGS))

SAMPLE_ENABLED := 1

ALL_LDFLAGS :=
ALL_LDFLAGS += $(ALL_CCFLAGS)
ALL_LDFLAGS += $(addprefix -Xlinker ,$(LDFLAGS))
ALL_LDFLAGS += $(addprefix -Xlinker ,$(EXTRA_LDFLAGS))

# Common includes and paths for CUDA
INCLUDES  := -I../../Common
LIBRARIES :=

# MNIST dataset path
DATA_PATH = data
BUILD_PATH = build
SRC_PATH = src
EXEC_PATH = bin
TARGET = cuda-mnist

CPU_SOURCE_FILES := $(shell find $(SOURCEDIR) -name '*.cpp' ! -name ".\#*")
GPU_SOURCE_FILES := $(shell find $(SOURCEDIR) -name '*.cu' ! -name ".\#*")

all: clean build

build: 
	mkdir -p ${BUILD_PATH}
	mkdir -p ${EXEC_PATH}
	#$(NVCC) ${CPU_SOURCE_FILES} ${GPU_SOURCE_FILES} -lineinfo -o ${BUILD_PATH}/${TARGET}
	$(NVCC) ./src/main.cu -lineinfo -o ${EXEC_PATH}/${TARGET}

run: 
	./${EXEC_PATH}/${TARGET}

clean:
	rm -rf ${BUILD_PATH}
	rm -rf ${EXEC_PATH}
//来自chapter05 add_loop_long_blocks.cu

#include "../common/book.h"


/*
__global__ void add( int *a, int *b, int *c ) {
    int tid = threadIdx.x + blockIdx.x * blockDim.x;
    while (tid < N) {
        c[tid] = a[tid] + b[tid];
        tid += blockDim.x * gridDim.x;
    }
}
*/
//#define N 10
#define N (33 * 1024)

__global__ void add (int *a, int *b, int *c) {
	//int tid = threadIdx.x + blockIdx.x * blockDim.x;
	int tid = threadIdx.x + blockIdx.x * blockDim.x;
	printf ("blockdim: %d\n", blockDim.x);	
	printf ("blockIdx: %d\n", blockIdx.x);	
	printf ("gridDim: %d\n", gridDim.x);	
    while (tid < N) {
        c[tid] = a[tid] + b[tid];
        tid += blockDim.x * gridDim.x;
    }
	//c[tid] = a[tid] + b[tid];
	
}

int main (void) {
	int *a, *b, *c;
	int *dev_a, *dev_b, *dev_c;

	a = (int*)malloc(N * sizeof(int));
	b = (int*)malloc(N * sizeof(int));
	c = (int*)malloc(N * sizeof(int));
	
    HANDLE_ERROR( cudaMalloc( (void**)&dev_a, N * sizeof(int) ) );
    HANDLE_ERROR( cudaMalloc( (void**)&dev_b, N * sizeof(int) ) );
    HANDLE_ERROR( cudaMalloc( (void**)&dev_c, N * sizeof(int) ) );

    for (int i=0; i<N; i++) {
        a[i] = i;
        b[i] = 2 * i;
    }

	
    HANDLE_ERROR( cudaMemcpy( dev_a, a, N * sizeof(int), cudaMemcpyHostToDevice ) );
    HANDLE_ERROR( cudaMemcpy( dev_b, b, N * sizeof(int), cudaMemcpyHostToDevice ) );

	//add<<<N/2, 2>>> (dev_a, dev_b, dev_c);
	add<<<128, 128>>> (dev_a, dev_b, dev_c);

    HANDLE_ERROR( cudaMemcpy( c, dev_c, N * sizeof(int), cudaMemcpyDeviceToHost ) );

	
    for (int i=0; i<N; i++) {
    	if (c[i] != i + 2 * i) {
			printf ("error: %d", i);
		}
	}
		
    HANDLE_ERROR( cudaFree( dev_a ) );
    HANDLE_ERROR( cudaFree( dev_b ) );
    HANDLE_ERROR( cudaFree( dev_c ) );

    free( a );
    free( b );
    free( c );

	printf ("correct!\n");
    return 0;
}

#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>
#include <errno.h>
int main (int argc, char** argv){
	if (argc != 2){
		printf("Usage : %s <trancate vaule>", argv[0]);	
		return -1;
	}

	int tranc_num = atoi(argv[1]);
	int ret;
	
	ret = truncate ("./hello.txt",tranc_num);

	if (ret == -1) {
		perror("trancate");
		return -1;
	}
	return 0;
}

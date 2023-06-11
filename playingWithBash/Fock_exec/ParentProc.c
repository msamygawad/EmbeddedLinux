#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>
#include <errno.h>
#include <sys/types.h>
#include <sys/time.h>
#include <sys/wait.h>
#define PARENT_PROCESS_SEC 10
int main (int argc, char** argv){
    struct timeval timer;
    struct timeval timer_start;
    long lastTime = 0;

    pid_t pid1 = fork();

    if (pid1 == -1){
            perror ("fork1");
            exit(1);
    }
    
    if (!pid1) {
            char * const args[] = { "./ChildProc","6", NULL };
            int ret;

            ret = execv (args[0], args);

            if (ret == -1) {
                    perror ("execv");
                    exit (EXIT_FAILURE);
            }
    }

    pid_t pid2 = fork();
    if (pid2 == -1){
            perror ("fork2");
            exit(1);
    }
    if (!pid2) {
            char * const args[] = { "./ChildProc", "4" ,NULL };
            int ret;

            ret = execv (args[0], args);

            if (ret == -1) {
                    perror ("execv");
                    exit (EXIT_FAILURE);
            }
    }


    gettimeofday(&timer_start,NULL);
    lastTime =0;
    for (;;){
        gettimeofday(&timer,NULL);
        long x = timer.tv_sec-timer_start.tv_sec;
        if (x != lastTime){
            printf("Parent : %ld \n",x);
            lastTime =x;
            }
            if (x == PARENT_PROCESS_SEC)
                break;
    }
    wait(NULL);
    return 0;
}          

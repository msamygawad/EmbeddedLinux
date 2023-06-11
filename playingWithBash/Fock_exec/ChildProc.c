#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>
#include <errno.h>
#include <sys/types.h>
#include <sys/time.h>


int main (int argc, char** argv){
        long delay_time;
        if (argc == 2){
                delay_time = strtol(argv[1], NULL,10);
        }
        else{
                delay_time = 5;
        }
        pid_t pid = getpid();
        struct timeval timer;
        struct timeval timer_start;
        gettimeofday(&timer_start,NULL);
        long lastTime=0;
        for (;;)
        {       gettimeofday(&timer,NULL);
                long x = timer.tv_sec-timer_start.tv_sec;
                if (x != lastTime){
                        printf("PID %d  : %ld \n",pid,x);
                        lastTime =x;
                }
                
                if (x == delay_time){
                        printf("Child (%d) Finished \n", pid);
                        break;
                }
                        
        }
        return 0;
    
}          

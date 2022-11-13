#include <stdio.h>
//#include <SSDC.h>

struct file
    {
        int name;
        int w_r;
        int size;
        int t_arrival;
    };
    

int main(void)
{
    int global_time = 0;
    int time        = 0;
 
    // busy
    int sram_w_busy = 0;
    int dram_w_busy = 0;
    int nand_w_busy = 0;
    
    // files
    struct file file[3];
    FILE * fp;

    // array of each device
    int sram[3] = {};
    int dram[3] = {};
    int nand[3] = {};
    
    
    // storing requests from host
    fp = fopen("host_request.txt", "rt");
    for(int i = 0; i < 3; i++) {
        fscanf(fp, "%d %d %d %d", &file[i].name, &file[i].w_r, &file[i].size, &file[i].t_arrival);
        printf("%d, %d, %d, %d\n", file[i].name, file[i].w_r, file[i].size, file[i].t_arrival);

        sram_w_busy = 1;

        time        = file[i].t_arrival;
        global_time = time;
    }
    fclose(fp);

    while (sram_w_busy || dram_w_busy || nand_w_busy)
    {
        
        time++;
    }
    
    printf("result global time is %d ns\n", global_time);

    return 0;
}
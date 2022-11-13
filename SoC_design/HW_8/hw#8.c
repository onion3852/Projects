#include <stdio.h>
#include "SSDC.h"

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
    
    // files
    struct file file[3];
    FILE * fp;

    // busy & empty
    int pcieq_empty;
    int sram_w_busy;
    int sram_r_busy;
    int dram_w_busy;
    int nand_w_busy;

    // array of each device
    int sram[3] = {0, 0, 0};
    int dram[3] = {0, 0, 0};
    int nand[3] = {0, 0, 0};
    
    
    // storing requests from host
    fp = fopen("host_request.txt", "rt");
    for(int i = 0; i < 3; i++) {
        fscanf(fp, "%d %d %d %d", &file[i].name, &file[i].w_r, &file[i].size, &file[i].t_arrival);
        printf("%d, %d, %d, %d\n", file[i].name, file[i].w_r, file[i].size, file[i].t_arrival);

        pcieq_empty = 0;
        sram_w_busy = 1;
        time        = file[i].t_arrival;
        global_time = time;

        if(i == 0){
            sram[i] = sram[i] + t_SRAM_W;
        }
        else{
            sram[i] = sram[i-1] + t_SRAM_W;
        }
    }
    fclose(fp);
    printf("time is %d\n", time);
    printf("global time is %d\n", global_time);
    printf("%d, %d, %d\n", sram[0], sram[1], sram[2]);

    while (pcieq_empty || sram_w_busy || sram_r_busy || dram_w_busy || nand_w_busy)
    {
        process_pcieq(time, pcieq_empty, sram_w_busy);
        process_sramq();
        process_dramq();
        process_nandq();

        

        time++;
    }
    
    printf("result global time is %d ns\n", global_time);

    return 0;
}

// function
void process_pcieq(int time, int empty, int busy) 
{
    if(!empty && !busy){
        if(time){

        }
    }
    else if(empty){
        busy = 0;
    }
}

void process_sramq()
{
    
}

void process_dramq()
{
    
}

void process_nandq()
{
    
}
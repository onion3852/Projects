#include <stdio.h>
#include "SSDC.h"

struct host_request
    {
        int name;
        int w_r;
        int size;
        int t_arrival;
    };

int main(void)
{
    // time
    int global_time = 0;
    int time        = 0;
    
    int file_num = 0;
    int sram_num = 0;
    int dram_num = 0;
    int nand_num = 0;
    int temp_p = 0;  // pcieq temp variable
    int temp_s = 0;  // sramq temp variable
    int temp_d = 0;  // dramq temp variable
    int temp_n = 0;  // nandq temp variable

    // files
    struct host_request file[3];
    FILE * fp;

    // empty
    int pcieq_empty;
    int sramq_empty;
    int dramq_empty;
    int nandq_empty;
    // busy
    int sram_w_busy;
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
        if(i == 0){
            sram[i] = sram[i] + t_SRAM_W;
            temp_s  = sram[0];
        }

        time        = file[i].t_arrival;
        global_time = time;
    }
    fclose(fp);
    printf("time is %d\n", time);
    printf("global time is %d\n", global_time);
    printf("%d, %d, %d\n", sram[0], sram[1], sram[2]);

    while (!pcieq_empty || sram_w_busy || dram_w_busy || nand_w_busy)
    {
        process_pcieq(time, global_time, pcieq_empty, sram_w_busy, sram_num, sram[sram_num], file_num, &file[file_num]);
        process_sramq(time, global_time, sram_w_busy, sram_num, sram[sram_num], file_num, &file[file_num]);
        process_dramq();
        process_nandq();

        

        time++;
    }
    
    printf("global time is %d ns\n", global_time);

    return 0;
}


// function part
void process_pcieq(int time, int global_time, int p_empty, int w_busy, int sram_num, int sram[sram_num], int file_num, struct host_request *q) 
{
    if(w_busy && (time >= sram[sram_num])){
        // sram write done...
        // clear pcieq of completed request
        if(file_num <= 2){
            q -> name      = 0;
            q -> w_r       = 0;
            q -> size      = 0;
            q -> t_arrival = 0;
            file_num++;

            global_time = time;
            w_busy      = 0;
            sram_em
        }
        return;
    }
    if(!w_busy){
        if((file_num <= 2)){
            // start sram write for next file 
            sram_num ++; 
            
            w_busy = 1;
        }
        return;
    }
}

void process_sramq(int time, int global_time, int temp_p, int w_busy, int sram_num, int sram[sram_num], int file_num, struct host_request *q)
{
    if(w_busy && (time >= temp_p)){
        // sram write done...
        // clear pcieq of completed request
        if(file_num <= 2){
            q -> name      = NULL;
            q -> w_r       = NULL;
            q -> size      = NULL;
            q -> t_arrival = NULL;
            file_num++;

            global_time = time;
            w_busy      = 0;
        }
        return;
    }
    if(!w_busy){
        if((file_num <= 2)){
            // start sram write for next file 
            sram_num ++; 
            temp_p = sram[sram_num];
            
            w_busy = 1;
        }
        return;
    }
}

void process_dramq()
{
    
}

void process_nandq()
{
    
}
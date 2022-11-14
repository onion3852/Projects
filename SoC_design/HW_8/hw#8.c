#include <stdio.h>
#include "SSDC.h"

struct host_request
    {
        int name;
        int w_r;
        int size;
        int t_arrival;
    };

void process_pcieq(int time, int *global_time, int *p_empty, int *s_empty, int *w_busy, int *sram_num, int *sram, int *file_num, struct host_request *q);
void process_sramq(int time, int *global_time, int *w_busy, int *s_empty, int *sram_num, int *sram, int *file_num, struct host_request *q);

int main(void)
{
    // time
    int global_time = 0;
    int time        = 0;
    
    int file_num = 0;
    int sram_num = 0;
    int dram_num = 0;
    int nand_num = 0;

    // files
    struct host_request file[3];
    FILE * fp;

    // empty
    int pcieq_empty = 1;
    int sramq_empty = 1;
    int dramq_empty = 1;
    int nandq_empty = 1;
    // busy
    int sram_w_busy = 0;
    int dram_w_busy = 0;
    int nand_w_busy = 0;

    // array of writting end time for each device
    int sram[3] = {0, 0, 0};
    int dram[3] = {0, 0, 0};
    int nand[3] = {0, 0, 0};
    
    
    // storing requests from host using fscanf()
    fp = fopen("host_request.txt", "rt");
    for(int i = 0; i < 3; i++) {
        fscanf(fp, "%d %d %d %d", &file[i].name, &file[i].w_r, &file[i].size, &file[i].t_arrival);
        printf("%d, %d, %d, %d\n", file[i].name,  file[i].w_r,  file[i].size,  file[i].t_arrival);

        pcieq_empty = 0;    // pcieq is now not empty
        sram_w_busy = 1;    // SRAM write for the 1st file begins
        if(i == 0){
            sram[i] = sram[i] + t_SRAM_W;  // SRAM wirte end time(= 4096 ns) for the 1st file
        }
        
        // set global time when host_request arrives
        time        = file[i].t_arrival;
        global_time = time;
    }
    fclose(fp);

    // 
    while (/*!pcieq_empty || !sramq_empty || !dramq_empty || !nandq_empty || sram_w_busy || dram_w_busy || nand_w_busy*/time < 8200)
    {
        printf("while loop start !\n");
        printf("current file_num is %d\n", file_num);
        printf("current time is %d\n", time);
        printf("--------------------\n\n");
        printf("process_check function start !\n");
        process_pcieq(time, &global_time, &pcieq_empty, &sramq_empty, &sram_w_busy, &sram_num, sram, &file_num, &file[file_num]);
        process_sramq(time, &global_time, &sram_w_busy, &sramq_empty, &sram_num, sram, &file_num, &file[file_num]);
      //process_dramq();
      //process_nandq();
        time++;
    }

    return 0;
}


// function part
void process_pcieq(int time, int *global_time, int *p_empty, int *s_empty, int *w_busy, int *sram_num, int *sram, int *file_num, struct host_request *q) 
{
    if(*w_busy && (time < sram[*sram_num])){
        // writting is in progress
        printf("SRAM writting is in progress!!!\n");
        printf("writting end time is %d / current time is %d\n", sram[*sram_num], time);
    }
    else if(!*w_busy && !*p_empty){
        // sram write task is done.
        // if sramq is empty(sram write port isn't busy) while pcieq isn't,
        // sramq will get new task
        printf("sram write of next file will start !\n");
        sram[*sram_num] = time + t_SRAM_W;
        printf("end time will be %d ns\n", sram[*sram_num]);
        *w_busy  = 1;
        *s_empty = 0;

        // clear completed task in pcieq
        if(*file_num <= 2){
            q -> name      = 0;
            q -> w_r       = 0;
            q -> size      = 0;
            q -> t_arrival = 0;
            (*file_num)++;  // move to next file
        }
    }
    else if(!*w_busy){
        if((*file_num > 2)){
            // pcieq is empty now because all sram write task is done
            *p_empty = 1;
        }
    }
    return;
}

void process_sramq(int time, int *global_time, int *w_busy, int *s_empty, int *sram_num, int *sram, int *file_num, struct host_request *q)
{
    if(*w_busy && (time == sram[*sram_num])){
        // sram write done, write port isn't busy now
        // sramq is empty now
        *w_busy  = 0;
        *s_empty = 1;

        // global time is changed to current time
        *global_time = time;

        // clear 'sram write end time' array of completed task
        sram[*sram_num] = 0;
        (*sram_num)++;

        //
        
        return;
    }
    if(!*w_busy){
        if((*file_num <= 2)){
            // start sram write for next file 
            (*sram_num) ++; 
            sram[*sram_num];
            
            *w_busy = 1;
        }
        return;
    }
}

//void process_dramq()
//{
//    
//}
//
//void process_nandq()
//{
//    
//}
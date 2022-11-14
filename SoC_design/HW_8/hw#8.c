#include <stdio.h>
#include "SSDC.h"

struct host_request
    {
        int name;
        int w_r;
        int size;
        int t_arrival;
    };

void process_pcieq(int time, int *global_time, int *p_empty, int *s_empty, int *s_w_busy,
                   int *sram_num, int *sram, int *file_num, struct host_request *q);

void process_sramq(int time, int *global_time, int *s_empty, int *d_empty, int *s_w_busy, int *d_w_busy,
                   int *sram_num, int *sram, int *dram_num, int *dram);

                   
// main
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
    while (/*!pcieq_empty || !sramq_empty || !dramq_empty || !nandq_empty || sram_w_busy || dram_w_busy || nand_w_busy*/time < 8195)
    {
        printf("while loop start !\n");
        printf("current time is %d\n", time);
        printf("--------------------\n\n");
        printf("process_check function start !\n");
        process_pcieq(time, &global_time, &pcieq_empty, &sramq_empty, &sram_w_busy, 
                      &sram_num, sram, &file_num, &file[file_num]);
        process_sramq(time, &global_time, &sramq_empty, &dramq_empty, &sram_w_busy, &dram_w_busy, 
                      &sram_num, sram, &dram_num, dram);
                      
      //process_dramq();
      //process_nandq();
        time++;
    }
    printf("global time : %d\n", global_time);
    printf("");
    return 0;
}


// function part
void process_pcieq(int time, int *global_time, int *p_empty, int *s_empty, int *s_w_busy, 
                   int *sram_num, int *sram, int *file_num, struct host_request *q) 
{
    if(*s_w_busy && (time < sram[*sram_num])){
        // sram writting is in progress
        printf("SRAM writting for file[%d] is in progress!!!\n", *sram_num);
        printf("SRAM writting for file[%d] end time is %d / current time is %d\n", *sram_num, sram[*sram_num], time);
    }
    else if(!*s_w_busy && !*p_empty){
        // sram write task is done.
        // if sramq is empty(sram write port isn't busy) while pcieq isn't,
        // sramq will get new task
        printf("sram write of file[%d] will start !\n", *sram_num);
        sram[*sram_num] = time + t_SRAM_W - 1;
        printf("end time will be %d ns\n", sram[*sram_num]);
        *s_w_busy  = 1;
        *s_empty = 0;

        // delete the completed task in pcieq
        if(*file_num <= 2){
            q -> name      = 0;
            q -> w_r       = 0;
            q -> size      = 0;
            q -> t_arrival = 0;
            (*file_num)++;  // move to next file
        }
    }
    else if(!*s_w_busy){
        if((*file_num > 2)){
            // pcieq is empty now because all sram write task is done
            *p_empty = 1;
        }
    }
    return;
}

void process_sramq(int time, int *global_time, int *s_empty, int *d_empty, int *s_w_busy, int *d_w_busy,
                   int *sram_num, int *sram, int *dram_num, int *dram)
{
    if(*s_w_busy && (time == sram[*sram_num])){
        // sram write done, sramq is emptyand write port isn't busy now
        printf("SRAM write for file[%d] is done !\n", *sram_num);
        *s_w_busy = 0;
        *s_empty  = 1;

        // global time is changed to current time
        *global_time = time;

        // clear 'sram write end time' array of completed task
        sram[*sram_num] = 0;
        (*sram_num)++;
    }
    else if(!*d_w_busy && !*d_empty){
        // dram write task is done.
        // if dramq is empty(dram write port isn't busy) while other task is left,
        // dramq will get new task
        printf("dram write of file[%d] will start !\n", *dram_num);
        dram[*dram_num] = time + t_DRAM_W - 1;
        printf("end time will be %d ns\n", dram[*dram_num]);
        *d_w_busy = 1;
        *d_empty  = 0;
        }
    if(*d_w_busy && (time < dram[*dram_num])){
        // dram writting is in progress
        printf("DRAM writting for file[%d] is in progress!!!\n", *dram_num);
        printf("DRAM writting for file[%d] end time is %d / current time is %d\n", *dram_num, dram[*dram_num], time);
    }
    return;
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
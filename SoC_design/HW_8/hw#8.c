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
// void process_sramq();

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
    int pcieq_empty = 1;
    int sramq_empty = 1;
    int dramq_empty = 1;
    int nandq_empty = 1;
    // busy
    int sram_w_busy = 0;
    int dram_w_busy = 0;
    int nand_w_busy = 0;

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
    printf("sram busy is %d\n", sram_w_busy);
    printf("sram_num is %d\n", sram_num);
    printf("sram[sram_num] is %d\n", sram[sram_num]);

    while (/*!pcieq_empty || !sramq_empty || !dramq_empty || !nandq_empty || sram_w_busy || dram_w_busy || nand_w_busy*/time < 8200)
    {
        printf("--------------------\n");
        printf("file_num is %d\n", file_num);
        printf("sram_num is %d\n", sram_num);
        printf("time is %d\n", time);
        printf("--------------------\n\n\n");
        process_pcieq(time, &global_time, &pcieq_empty, &sramq_empty, &sram_w_busy, &sram_num, sram, &file_num, &file[file_num]);
      //process_sramq(time, global_time, sram_w_busy, sram_num, sram[sram_num], file_num, &file[file_num]);
      //process_dramq();
      //process_nandq();
        time++;
    }

    return 0;
}


// function part
void process_pcieq(int time, int *global_time, int *p_empty, int *s_empty, int *w_busy, int *sram_num, int *sram, int *file_num, struct host_request *q) 
{
    if(*w_busy && (time >= sram[*sram_num])){
        // sram write done...
        // clear pcieq of completed request
        printf("first condition!!!\n");
        if(*file_num <= 2){
            q -> name      = 0;
            q -> w_r       = 0;
            q -> size      = 0;
            q -> t_arrival = 0;
            (*file_num)++;

            *global_time = time;    // sram write done time is now the global time 
            *w_busy      = 0;       // sram write port isn't busy
            *s_empty     = 1;       // sramq is empty

            // clear sram array of completed request 
            sram[*sram_num] = 0;

            printf("sram_num is %d\n", *sram_num);
            printf("file_num is %d\n", *file_num);
            printf("global time is %d\n", *global_time);
            printf("sram[sram_num]is %d\n", sram[*sram_num]);
        
            // start sram write for next file
            // sramq becomes not empty
            (*sram_num)++;
            printf("start new file write to sram!!!\n");
            printf("sram_num is %d\n", *sram_num);
            sram[*sram_num] = time + t_SRAM_W;
            *w_busy  = 1;
            *s_empty = 0;
        }
    }
    else if(*w_busy && (time < sram[*sram_num])){
        printf("sram writting is in progress!!!\n");
        printf("writting end time is %d\n", sram[*sram_num]);
    }
    else if(!*w_busy){
        if((*file_num > 2)){
            // pcieq is empty now because all sram write task is done
            *p_empty = 1;
        }
    }
    return;
}

void process_sramq(int time, int global_time, int temp_p, int w_busy, int sram_num, int sram[sram_num], int file_num, struct host_request *q)
{
    if(w_busy && (time >= temp_p)){
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

//void process_dramq()
//{
//    
//}
//
//void process_nandq()
//{
//    
//}
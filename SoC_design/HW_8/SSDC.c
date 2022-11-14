#include "SSDC.h"

// function part
void process_pcieq(int time, int *global_time, int *p_empty, int *s_empty, int *s_w_busy, 
                   int *sram_num, int *sram, int *file_num, struct host_request *q) 
{
    if(*s_w_busy && (time < sram[*sram_num]) && (*sram_num < 3)){
        // sram writting is in progress
        printf("SRAM writting for file[%d] is in progress!!!\n", *sram_num);
        printf("SRAM writting for file[%d] end time is %d / current time is %d\n", *sram_num, sram[*sram_num], time);
    }
    else if(!*s_w_busy && !*p_empty && (*sram_num < 3)){
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
        // sram write done, sramq is empty and write port isn't busy now
        printf("SRAM write for file[%d] is done !\n", *sram_num);
        *s_w_busy = 0;
        *s_empty  = 1;
        // dram write of first file will start
        if(*sram_num == 0){
            *d_empty = 0;
        }

        // global time is changed to current time
        *global_time = time;

        // clear 'sram write end time' array of completed task
        sram[*sram_num] = 0;
        (*sram_num)++;
    }
    else if(!*d_w_busy && !*d_empty && (*dram_num < 3)){
        // dram write task is done.
        // if dramq is empty(dram write port isn't busy) while other task is left,
        // dramq will get new task
        printf("dram write of file[%d] will start !\n", *dram_num);
        dram[*dram_num] = time + t_DRAM_W - 1;
        printf("end time will be %d ns\n", dram[*dram_num]);
        *d_w_busy = 1;
        *d_empty  = 0;
        }
    else if(*d_w_busy && (time < dram[*dram_num]) && (*dram_num < 3)){
        // dram writting is in progress
        printf("DRAM writting for file[%d] is in progress!!!\n", *dram_num);
        printf("DRAM writting for file[%d] end time is %d / current time is %d\n", *dram_num, dram[*dram_num], time);
    }

    return;
}

void process_dramq(int time, int *global_time, int *d_empty, int *n_empty, int *d_w_busy, int *n_w_busy,
                   int *dram_num, int *dram, int *nand_num, int *nand)
{
    if(*d_w_busy && (time == dram[*dram_num])){
        // dram write done, dramq is empty and write port isn't busy now
        printf("DRAM write for file[%d] is done !\n", *dram_num);
        *d_w_busy = 0;
        *d_empty  = 1;
        // if dram write tasks remain, dramq will not become empty
        if(*dram_num < 2){
            *d_empty = 0;
        }

        // global time is changed to current time
        *global_time = time;

        // clear 'dram write end time' array of completed task
        dram[*dram_num] = 0;
        (*dram_num)++;

        // nand write task goes to nandq
        // but dram read(nand write) starts when every dram write is done
        // so nand write port is not busy yet
        *n_empty  = 0;
        *n_w_busy = 0;

        // if all dram write is done,
        // nand write end time array can be defined
        if(*dram_num == 3){
            for(int k = 0; k < 3; k++){
                nand[k] = time + ((k + 1) *100/*t_NAND_W*/);
            }
            // nand write will start
            *n_w_busy = 1;
        }
    }

    return;
}

void process_nandq(int time, int *global_time, int *n_empty, int *n_w_busy, int *nand_num, int *nand)
{
    if(*n_w_busy && (time < nand[*nand_num]) && (*nand_num <= 2)){
        // nand writting is in progress
        printf("NAND writting for file[%d] is in progress!!!\n", *nand_num);
        printf("NAND writting for file[%d] end time is %d / current time is %d\n", *nand_num, nand[*nand_num], time);
    }
    else if(*n_w_busy && (time == nand[*nand_num])){
        // nand write done, nandq is empty and write port isn't busy now
        printf("NAND write for file[%d] is done !\n", *nand_num);
        *n_w_busy = 0;
        *n_empty  = 1;
        // if nand write tasks remain, nandq will not become empty
        // and next file write will begin
        if(!*n_w_busy && *nand_num < 2){
            *n_w_busy = 1;
            *n_empty  = 0;
        }

        // global time is changed to current time
        *global_time = time;

        // clear 'nand write end time' array of completed task
        nand[*nand_num] = 0;
        (*nand_num)++; 
        if(*nand_num >= 3){
            *n_w_busy = 0;
            *n_empty  = 1;
        }
    }

    return;
}
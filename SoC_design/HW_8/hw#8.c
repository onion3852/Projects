#include "SSDC.h"
                   
int main(void)
{
    // time
    int time               = 0;
    int global_time        = 0;
    int arr_global_time[12] = {0,};
    
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

    // array of 'writting task end time' for each device
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

        // global time changes when any task is done
        // storing every global time value in array
        if(global_time > arr_global_time[11]){
            for(int k = 0; k < 11; k++){
                arr_global_time[k] = arr_global_time[k + 1];
            }
            arr_global_time[11] = global_time;
        }
    }
    fclose(fp);

    while (time < 20346)
    {
        printf("while loop start !\n");
        printf("current time is %d\n", time);
        printf("--------------------\n\n");
        printf("process_check function start !\n");
        printf("nandq is %d, %d, %d\n", nand[0], nand[1], nand[2]);

        process_pcieq(time, &global_time, &pcieq_empty, &sramq_empty, &sram_w_busy, 
                      &sram_num, sram, &file_num, &file[file_num]);

        process_sramq(time, &global_time, &sramq_empty, &dramq_empty, &sram_w_busy, &dram_w_busy, 
                      &sram_num, sram, &dram_num, dram);
                      
        process_dramq(time, &global_time, &dramq_empty, &nandq_empty, &dram_w_busy, &nand_w_busy,
                      &dram_num, dram, &nand_num, nand);

        process_nandq(time, &global_time, &nandq_empty, &nand_w_busy, &nand_num, nand);

        // global time changes when any task is done
        // storing every global time value in array
        if(global_time > arr_global_time[11]){
            for(int k = 0; k < 11; k++){
                arr_global_time[k] = arr_global_time[k + 1];
            }
            arr_global_time[11] = global_time;
        }
        
        time++;
    }

    printf("global time : %d\n\n", global_time);
    printf("every global time value is\n");
    for(int i = 0; i < 12; i++){
        printf("%d ns\n", arr_global_time[i]);
    }

    return 0;
}
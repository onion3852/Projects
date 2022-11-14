#ifndef __SSDC_H__
#define __SSDC_H__

#include <stdio.h>

#define t_SRAM_W 4096
#define t_SRAM_R 4096
#define t_DRAM_R 4800
#define t_DRAM_W 4416
#define t_NAND_W 1402750

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

void process_dramq(int time, int *global_time, int *d_empty, int *n_empty, int *d_w_busy, int *n_w_busy,
                   int *dram_num, int *dram, int *nand_num, int *nand);

void process_nandq(int time, int *global_time, int *n_empty, int *n_w_busy, int *nand_num, int *nand);

#endif
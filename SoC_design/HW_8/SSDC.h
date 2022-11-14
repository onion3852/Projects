#ifndef _SSDC.H_

#define _SSDC.H_

struct host_req
{
    int name;
    int w_r;
    int size;
    int t_arrival;
};

#define t_SRAM_W 4096
#define t_SRAM_R 4096
#define t_DRAM_R 4800
#define t_DRAM_W 4416
#define t_NAND_W 1402750

#endif
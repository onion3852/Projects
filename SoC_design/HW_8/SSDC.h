#ifndef _SSDC.H_
#define _SSDC.H_
#include <stdio.h>

void process_pcieq();
void process_sramq();
void process_dramq();
void process_nandq();

#define SRAM_W_d = 4096;
#define SRAM_R_d = 4096;
#define DRAM_W_d = 4416;
#define DRAM_R_d = 4800;
#define NAND_W_d = 1402750;

#endif
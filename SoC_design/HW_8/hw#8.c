#include <stdio.h>
//#include <SSDC.h>

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
    
    // files
    struct file file[3];

    // array of each device
    int sram[3] = {};
    int dram[3] = {};
    int nand[3] = {};
    FILE * fp;
    
    fp = fopen("host_request.txt", "rt");
    for(int i = 0; i < 3; i++) {
        fscanf(fp, "%d %d %d %d", &file[i].name, &file[i].w_r, &file[i].size, &file[i].t_arrival);
        printf("%d, %d, %d, %d\n", file[i].name, file[i].w_r, file[i].size, file[i].t_arrival);
    }
    fclose(fp);

    //while (1)
    //{
        
    //}
    
    return 0;
}
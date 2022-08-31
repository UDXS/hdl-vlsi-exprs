#include <cstdio>
#include <verilated.h>
#include "Vanfsqrt_sqrt.h"

#define VERBOSE 0

#if VERBOSE
#define verbprintf(...) printf(__VA_ARGS__)
#else
#define verbprintf(...)
#endif


int main(int argc, char** argv) {
    puts("Anf Sqrt Tiny - Davit Margarian");

    Verilated::commandArgs(argc, argv);



    Vanfsqrt_sqrt* dut = new Vanfsqrt_sqrt;
    dut->clk = 0;
    dut->eval();

    for (int i = 0; i < 128; i++) {

        dut->query = i;

        for (int i = 0; i < 17; i++){
            dut->clk = 1;
            dut->eval();
            dut->clk = 0;
            dut->eval();
        }

        printf("sqrt(%d) = %d\n", dut->query, dut->result);
    }

    fflush(stdout);
    int sample = 0;

    dut->final();
}
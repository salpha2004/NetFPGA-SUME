/*******************************************************************************
 *
 *  NetFPGA-SUME http://www.netfpga.org
 *
 *  File:
 *        wraxi.c
 *
 *  Project:
 *        nic
 *
 *  Author:
 *        Mario Flajslik
 *        Noa Zilberman
 *
 *  Description:
 *        Example C application that shows how to use the driver to write AXI
 *        registers on the NetFPGA card.
 *        Usage example: ./wraxi 0x7d400000 0xa5a5
 *
 *        NIC project contains 8 AXI registers that can be read/written for
 *        test purposes (they have no effect on the NIC). Check hw/system.mhs
 *        file to find the the AXI addresses (under dma section look for
 *        C_BASEADDR; the addresses are C_BASEADDR...C_BASEADDR+7) 
 *
 *  Copyright notice:
 *        Copyright (C) 2010, 2011 The Board of Trustees of The Leland Stanford
 *                                 Junior University
 *
 *  Licence:
 *        This file is part of the NetFPGA 10G development base package.
 *
 *        This file is free code: you can redistribute it and/or modify it under
 *        the terms of the GNU Lesser General Public License version 2.1 as
 *        published by the Free Software Foundation.
 *
 *        This package is distributed in the hope that it will be useful, but
 *        WITHOUT ANY WARRANTY; without even the implied warranty of
 *        MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 *        Lesser General Public License for more details.
 *
 *        You should have received a copy of the GNU Lesser General Public
 *        License along with the NetFPGA source package.  If not, see
 *        http://www.gnu.org/licenses/.
 *
 */

#include <fcntl.h>
#include <sys/ioctl.h>
#include <stdio.h>
#include <stdint.h>
#include <string.h>

#define SUME_IOCTL_CMD_READ_STAT (SIOCDEVPRIVATE+0)
#define SUME_IOCTL_CMD_WRITE_REG (SIOCDEVPRIVATE+1)
#define SUME_IOCTL_CMD_READ_REG (SIOCDEVPRIVATE+2)

int main(int argc, char* argv[]){
    int f;
    long v;
    uint64_t addr;
    uint64_t val;

    if(argc < 3){
        printf("usage: wraxi reg_addr(in hex) reg_val(in_hex)\n\n");
        return 0;
    }
    else{
        sscanf(argv[1], "%llx", &addr);
        sscanf(argv[2], "%llx", &val);
    }

    //----------------------------------------------------
    //-- open SUME file descriptor for all the fun stuff
    //----------------------------------------------------
    char* devfilename = "/dev/SUME";
    int g_devFile = -1;
    g_devFile = open(devfilename, O_RDWR);
    if(g_devFile < 0){
        perror("/dev/SUME");
        return 0;
    }
    
    printf("\n");

    // High 32 bits are the AXI address,
    // low 32 bits are the value written to that address
    v = (addr << 32) + val;
//    printf("v %x\n",v);
//    if(ioctl(f, SUME_IOCTL_CMD_WRITE_REG, v) < 0){
   if(ioctl(g_devFile, SUME_IOCTL_CMD_WRITE_REG, &v) < 0){
         perror("SUME ioctl failed");
        return 0;
    }
    printf("\n");

    close(f);
    
    return 0;
}

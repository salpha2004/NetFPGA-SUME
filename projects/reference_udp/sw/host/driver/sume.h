/*******************************************************************************
 *
 *  NetFPGA-SUME http://www.netfpga.org
 *
 *  File:
 *        sume.h
 *
 *  Project:
 *        nic
 *
 *  Author:
 *        Noa
 *
 *  Description:
 *        Function prototypes for nf10fops.c
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

#ifndef SUME_H
#define SUME_H

//#include <linux/fs.h>
#include <linux/if.h>


#define SUME_IOCTL_CMD_READ_STAT (SIOCDEVPRIVATE+0)
#define SUME_IOCTL_CMD_WRITE_REG (SIOCDEVPRIVATE+1)
#define SUME_IOCTL_CMD_READ_REG (SIOCDEVPRIVATE+2)


#endif

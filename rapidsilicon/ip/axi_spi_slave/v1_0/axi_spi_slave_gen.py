#!/usr/bin/env python3
#
# This file is Copyright (c) 2022 RapidSilicon.
#
# SPDX-License-Identifier: MIT

import os
import sys
import json
import argparse
import shutil
import logging

from litex_sim.axi_spi_slave_litex_wrapper import AXISPISLAVE

from migen import *

from litex.build.generic_platform import *

from litex.build.osfpga import OSFPGAPlatform

from litex.soc.interconnect.axi import AXIInterface


# IOs/Interfaces -----------------------------------------------------------------------------------
def get_clkin_ios():
    return [
        ("axi_aclk",     0,    Pins(1)),
        ("axi_aresetn",  0,    Pins(1)),
    ]
    
def get_spi_ios():
    return [
        ("test_mode",    0,    Pins(1)),
        ("spi",          0,
            Subsignal("sclk",  Pins(1)),
            Subsignal("cs",    Pins(1)),
            Subsignal("mode",  Pins(2)),
            Subsignal("sdi0",  Pins(1)),
            Subsignal("sdi1",  Pins(1)),
            Subsignal("sdi2",  Pins(1)),
            Subsignal("sdi3",  Pins(1)),
            Subsignal("sdo0",  Pins(1)),
            Subsignal("sdo1",  Pins(1)),    
            Subsignal("sdo2",  Pins(1)), 
            Subsignal("sdo3",  Pins(1)), 
        )
    ]

# AXI SPI SLAVE Wrapper ----------------------------------------------------------------------------------
class AXISPISLAVEWrapper(Module):
    def __init__(self, platform, data_width, addr_width, id_width, user_width, dummy_cycles):
        
        # Clocking ---------------------------------------------------------------------------------
        platform.add_extension(get_clkin_ios())
        self.clock_domains.cd_sys  = ClockDomain()
        self.comb += self.cd_sys.clk.eq(platform.request("axi_aclk"))
        self.comb += self.cd_sys.rst.eq(platform.request("axi_aresetn"))

        # AXI ----------------------------------------------------------------------------------
        axi = AXIInterface(
            data_width      = data_width,
            address_width   = addr_width,
            id_width        = id_width,
            aw_user_width   = user_width,
            w_user_width    = user_width,
            b_user_width    = user_width,
            ar_user_width   = user_width,
            r_user_width    = user_width,
        )
        
        platform.add_extension(axi.get_ios("axi_master"))
        self.comb += axi.connect_to_pads(platform.request("axi_master"), mode="master")

        # AXI SPI SLAVE -----------------------------------------------------------------------
        self.submodules.spi_slave = spi_slave = AXISPISLAVE(platform, 
            m_axi           = axi,
            dummy_cycles    = dummy_cycles
            )
        
        # SPI IOS
        platform.add_extension(get_spi_ios())
        spi_pads = platform.request("spi")
        self.comb += [
            # Inputs
            spi_slave.spi_sclk.eq(spi_pads.sclk),
            spi_slave.spi_cs.eq(spi_pads.cs),
            spi_slave.spi_sdi0.eq(spi_pads.sdi0),
            spi_slave.spi_sdi1.eq(spi_pads.sdi1),
            spi_slave.spi_sdi2.eq(spi_pads.sdi2),
            spi_slave.spi_sdi3.eq(spi_pads.sdi3),
            # Outputs
            spi_pads.mode.eq(spi_slave.spi_mode),
            spi_pads.sdo0.eq(spi_slave.spi_sdo0),
            spi_pads.sdo1.eq(spi_slave.spi_sdo1),
            spi_pads.sdo2.eq(spi_slave.spi_sdo2),
            spi_pads.sdo3.eq(spi_slave.spi_sdo3),
        ]
        self.comb += spi_slave.test_mode.eq(platform.request("test_mode"))

# Build --------------------------------------------------------------------------------------------
def main():
    parser = argparse.ArgumentParser(description="AXI SPI SLAVE CORE")

    # Import Common Modules.
    common_path = os.path.join(os.path.dirname(__file__), "..", "..")
    sys.path.append(common_path)

    from common import RapidSiliconIPCatalogBuilder

    # Core Parameters.
    core_group = parser.add_argument_group(title="Core parameters")
    core_group.add_argument("--addr_width",   type=int,  default=32, choices=[8, 16, 32, 64], help="Address Width.")
    core_group.add_argument("--data_width",   type=int,  default=64, choices=[8, 16, 32],     help="Data Width.")
    core_group.add_argument("--user_width",   type=int,  default=6,  choices=range(1,9),      help="User Width.")
    core_group.add_argument("--id_width",     type=int,  default=3,  choices=range(1,17),     help="ID Width.")
    core_group.add_argument("--dummy_cycles", type=int,  default=32, choices=[16, 32],        help="Dummy Cycles.")

    # Build Parameters.
    build_group = parser.add_argument_group(title="Build parameters")
    build_group.add_argument("--build",         action="store_true",                    help="Build Core")
    build_group.add_argument("--build-dir",     default="./",                           help="Build Directory")
    build_group.add_argument("--build-name",    default="axi_spi_slave_wrapper",        help="Build Folder Name, Build RTL File Name and Module Name")

    # JSON Import/Template
    json_group = parser.add_argument_group(title="JSON Parameters")
    json_group.add_argument("--json",                                           help="Generate Core from JSON File")
    json_group.add_argument("--json-template",  action="store_true",            help="Generate JSON Template")

    args = parser.parse_args()

    # Import JSON (Optional) -----------------------------------------------------------------------
    if args.json:
        with open(args.json, 'rt') as f:
            t_args = argparse.Namespace()
            t_args.__dict__.update(json.load(f))
            args = parser.parse_args(namespace=t_args)

    # Export JSON Template (Optional) --------------------------------------------------------------
    if args.json_template:
        print(json.dumps(vars(args), indent=4))

    # Create Wrapper -------------------------------------------------------------------------------
    platform = OSFPGAPlatform(io=[], toolchain="raptor", device="gemini")
    module   = AXISPISLAVEWrapper(platform,
        addr_width   = args.addr_width,
        data_width   = args.data_width,
        user_width   = args.user_width,
        id_width     = args.id_width,
        dummy_cycles = args.dummy_cycles,
    )
    
    # Build Project --------------------------------------------------------------------------------
    if args.build:
        rs_builder = RapidSiliconIPCatalogBuilder(device="gemini", ip_name="axi_spi_slave")
        rs_builder.prepare(
            build_dir  = args.build_dir,
            build_name = args.build_name,
        )
        rs_builder.copy_files(gen_path=os.path.dirname(__file__))
        rs_builder.generate_tcl()
        rs_builder.generate_verilog(
            platform   = platform,
            module     = module,
        )

if __name__ == "__main__":
    main()

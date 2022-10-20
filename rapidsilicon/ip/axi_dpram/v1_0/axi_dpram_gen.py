#!/usr/bin/env python3
#
# This file is Copyright (c) 2022 RapidSilicon.
#
# SPDX-License-Identifier: MIT

import os
import json
import argparse
import shutil
import logging

from litex_sim.axi_dp_ram_litex_wrapper import AXIDPRAM

from migen import *

from litex.build.generic_platform import *

from litex.build.osfpga import OSFPGAPlatform

from litex.soc.interconnect.axi import AXIInterface


# IOs / Interface ----------------------------------------------------------------------------------
def get_clkin_ios():
    return [
        ("a_clk", 0, Pins(1)),
        ("a_rst", 0, Pins(1)),
        ("b_clk", 0, Pins(1)),
        ("b_rst", 0, Pins(1)),
    ]
    
# AXI-DPRAM Wrapper --------------------------------------------------------------------------------
class AXIDPRAMWrapper(Module):
    def __init__(self, platform, data_width, addr_width, id_width, a_pip_out, b_pip_out, a_interleave, b_interleave):
        
        platform.add_extension(get_clkin_ios())
        self.clock_domains.cd_sys = ClockDomain()
        self.comb += self.cd_sys.clk.eq(platform.request("a_clk"))
        self.comb += self.cd_sys.rst.eq(platform.request("a_rst"))
        self.comb += self.cd_sys.clk.eq(platform.request("b_clk"))
        self.comb += self.cd_sys.rst.eq(platform.request("b_rst"))
        
        # AXI
        s_axi_a = AXIInterface(
            data_width      = data_width,
            address_width   = addr_width,
            id_width        = id_width,
        )
        
        s_axi_b = AXIInterface(
            data_width      = data_width,
            address_width   = addr_width,
            id_width        = id_width,
        )
        
        platform.add_extension(s_axi_a.get_ios("s_axi_a"))
        self.comb += s_axi_a.connect_to_pads(platform.request("s_axi_a"), mode="slave")
        
        platform.add_extension(s_axi_b.get_ios("s_axi_b"))
        self.comb += s_axi_b.connect_to_pads(platform.request("s_axi_b"), mode="slave")
        
        # AXI-DPRAM -------------------------------------------------------------------------------
        self.submodules += AXIDPRAM(platform, s_axi_a, s_axi_b, 
            a_pipeline_output   =   a_pip_out, 
            b_pipeline_output   =   b_pip_out, 
            a_interleave        =   a_interleave, 
            b_interleave        =   b_interleave, 
            size                =   (2**addr_width)*(data_width/8)
            )

# Build --------------------------------------------------------------------------------------------
def main():
    parser = argparse.ArgumentParser(description="AXI DPRAM CORE")
    parser.formatter_class = lambda prog: argparse.ArgumentDefaultsHelpFormatter(prog,
        max_help_position = 10,
        width             = 120
    )

    # Core Parameters.
    core_group = parser.add_argument_group(title="Core parameters")
    core_group.add_argument("--data_width",     default=32,  type=int,    help="DPRAM Data Width 8,16,32,64,128,256")
    core_group.add_argument("--addr_width",     default=16,  type=int,    help="DPRAM Address Width from 8 to 16")
    core_group.add_argument("--id_width",       default=32,  type=int,    help="DPRAM ID Width from 1 to 32")
    core_group.add_argument("--a_pip_out",      default=0,   type=int,    help="DPRAM A Pipeline Output 0 or 1")
    core_group.add_argument("--b_pip_out",      default=0,   type=int,    help="DPRAM B Pipeline Output 0 or 1")
    core_group.add_argument("--a_interleave",   default=0,   type=int,    help="DPRAM A Interleave 0 or 1")
    core_group.add_argument("--b_interleave",   default=0,   type=int,    help="DPRAM B Interleave 0 or 1")

    # Build Parameters.
    build_group = parser.add_argument_group(title="Build parameters")
    build_group.add_argument("--build",         action="store_true",            help="Build Core")
    build_group.add_argument("--build-dir",     default="./",                   help="Build Directory")
    build_group.add_argument("--build-name",    default="axi_dpram_wrapper",    help="Build Folder Name, Build RTL File Name and Module Name")

    # JSON Import/Template
    json_group = parser.add_argument_group(title="JSON Parameters")
    json_group.add_argument("--json",                                    help="Generate Core from JSON File")
    json_group.add_argument("--json-template",  action="store_true",     help="Generate JSON Template")

    args = parser.parse_args()
    
    # Parameter Check -------------------------------------------------------------------------------
    logger = logging.getLogger("Invalid Parameter Value")
    
    # Data_Width
    data_width_param=[8, 16, 32, 64, 128, 256]
    if args.data_width not in data_width_param:
        logger.error("\nEnter a valid 'data_width'\n %s", data_width_param)
        exit()
    
    # Address Width
    addr_range=range(8, 17)
    if args.addr_width not in addr_range:
        logger.error("\nEnter a valid 'addr_width' from 8 to 16")
        exit()

    # ID_Width
    id_range=range(1, 33)
    if args.id_width not in id_range:
        logger.error("\nEnter a valid 'id_width' from 1 to 32")
        exit()
    
    # A_Pipeline_Output
    a_pip_range=range(2)
    if args.a_pip_out not in a_pip_range:
        logger.error("\nEnter a valid 'a_pip_out' 0 or 1")
        exit()

    # B_Pipeline_Output
    b_pip_range=range(2)
    if args.b_pip_out not in b_pip_range:
        logger.error("\nEnter a valid 'b_pip_out' 0 or 1")
        exit()

    # A_Interleave
    a_interleave_range=range(2)
    if args.a_interleave not in a_interleave_range:
        logger.error("\nEnter a valid 'a_interleave' 0 or 1")
        exit()

    # B_Interleave
    b_interleave_range=range(2)
    if args.b_interleave not in b_interleave_range:
        logger.error("\nEnter a valid 'b_interleave' 0 or 1")
        exit()

    # Import JSON (Optional) -----------------------------------------------------------------------
    if args.json:
        with open(args.json, 'rt') as f:
            t_args = argparse.Namespace()
            t_args.__dict__.update(json.load(f))
            args = parser.parse_args(namespace=t_args)
            
    # Export JSON Template (Optional) --------------------------------------------------------------
    if args.json_template:
        print(json.dumps(vars(args), indent=4))

    # Remove build extension when specified.
    args.build_name = os.path.splitext(args.build_name)[0]

    # Build Project Directory ----------------------------------------------------------------------

    import sys
    common_path = os.path.join(os.path.dirname(__file__), "..", "..")  # FIXME
    sys.path.append(common_path)                                       # FIXME
    from common import RapidSiliconIPCatalogBuilder
    rs_builder = RapidSiliconIPCatalogBuilder(device="gemini", ip_name="axi_dpram")

    if args.build:
        rs_builder.prepare(build_dir=args.build_dir, build_name=args.build_name)
        rs_builder.copy_files(gen_path=os.path.dirname(__file__))
        rs_builder.generate_tcl()

    # Create LiteX Core ----------------------------------------------------------------------------
    platform = OSFPGAPlatform(io=[], toolchain="raptor", device="gemini")
    module = AXIDPRAMWrapper(platform,
        data_width  = args.data_width,
        addr_width  = args.addr_width,
        id_width    = args.id_width,
        a_pip_out   = args.a_pip_out,
        b_pip_out   = args.b_pip_out,
        a_interleave= args.a_interleave,
        b_interleave= args.b_interleave                 
        )
    
    # Build
    if args.build:
        rs_builder.build(
            platform   = platform,
            module     = module,
        )

if __name__ == "__main__":
    main()

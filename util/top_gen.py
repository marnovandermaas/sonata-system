#!/usr/bin/env python3
# Copyright lowRISC contributors
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0

from mako.template import Template
import yaml

# First we parse the YAML input to get the parameters.

with open('data/blocks.yml', 'r') as file:
    block_parameters = yaml.safe_load(file)
with open('data/pins.yml', 'r') as file:
    pin_parameters = yaml.safe_load(file)

# Check block parameter structure.
for block in block_parameters.keys():
    if 'instances' not in block_parameters[block]:
        print('You must specify "instances" for ' + block)
        exit()
    else:
        if not isinstance(block_parameters[block]['instances'], int):
            print('Instances must be an integer for ' + bock)
            exit()

    if 'ios' not in block_parameters[block]:
        print('You must specify "ios" for ' + block)
        exit()
    else:
        for io in block_parameters[block]['ios']:
            if 'name' not in io:
                print('You must provide IO names for ' + block)
                exit()
            else:
                if io['name'] == 'ios':
                    if 'length' not in io:
                        print('Any block IO named "ios" must have a length key. See block ' + block)
                        exit()
            if 'type' not in io:
                print('You must provide IO types for ' + block)
                exit()
            else:
                io_type = io['type']
                if io_type == 'input':
                    if 'default' not in io:
                        print('You must provide a default value for input ' + io['name'] + ' in ' + block)
                        exit()
                elif io_type == 'in_out':
                    if 'combine' not in io:
                        print('You must provide a combine value for in_out ' + io['name'] + ' in ' + block)
                        exit()

gpio_num = block_parameters['gpio']['instances']
uart_num = block_parameters['uart']['instances']
i2c_num  = block_parameters['i2c'] ['instances']
spi_num  = block_parameters['spi'] ['instances']

# Check pin parameter structrue.
for pin in pin_parameters.keys():
    if 'block_ios' not in pin_parameters[pin]:
        print('You must specify "block_ios" for ' + pin)
        exit()
    else:
        for io in pin_parameters[pin]['block_ios']:
            if 'block' not in io:
                print('You must say which block to connect to for ' + pin)
                exit()
            else:
                if io['block'] not in block_parameters.keys():
                    print('Block referenced by pin ' + pin + ' must be a specified block:')
                    print(block_parameters.keys())
                    exit()
            if 'instance' not in io:
                print('You must specify which instance of ' + io['block'] + ' you want to connect pin ' + pin)
                exit()
            else:
                if not isinstance(io['instance'], int):
                    print('Instance must be an integer for ' + io['block'] + ' and ' + pin)
                    exit()
                if io['instance'] >= block_parameters[io['block']]['instances']:
                    print('Your specified index is too high for ' + io['block'] + ' and ' + pin)
                    exit()
            if 'io' not in io:
                print('You must specify which IO of ' + io['block'] + ' you want to connect ' + pin)
                exit()
    if 'length' in pin_parameters[pin]:
        if not isinstance(pin_parameters[pin]['length'], int):
            print('Length must be an integer for ' + pin)
            exit()

# Then we use those parameters to generate our SystemVerilog using Mako

xbar_spec = ('data/xbar_main.hjson', 'data/xbar_main_generated.hjson')
sonata_xbar_spec = ('rtl/templates/sonata_xbar_main.sv.tpl', 'rtl/bus/sonata_xbar_main.sv')
pkg_spec = ('rtl/templates/sonata_pkg.sv.tpl',       'rtl/system/sonata_pkg.sv')

specs = [xbar_spec, sonata_xbar_spec, pkg_spec]

for spec in specs:
    print('Generating from template: ' + spec[0])
    template = Template(filename=spec[0])
    content = template.render(gpio_num=gpio_num, uart_num=uart_num, i2c_num=i2c_num, spi_num=spi_num)
    with open(spec[1], 'w') as file:
        file.write(content)

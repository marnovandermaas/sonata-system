// Copyright lowRISC contributors (OpenTitan project).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
<% import math %>\
# ${(module_instance_name).upper()} register template
#
# Parameter (given by Python tool)
#  - src:    Number of Interrupt Sources
#  - target: Number of Targets that handle interrupt requests
#  - prio:   Max value of interrupt priorities
#  - module_instance_name: Module instance name.
{
  name:               "${module_instance_name}",
  human_name:         "RISC-V platform level interrupt controller",
  one_line_desc:      "Interrupt controller, adhering to RISC-V PLIC specification",
  one_paragraph_desc: '''
    rv_plic is an interrupt controller which handles multiple interrupt sources. Each interrupt
    source can be enabled or disabled, and can be given a priority. rv_plic generates an output
    that identifies the source with the highest priority amongst those that are currently asserted.
  '''
  // Unique comportable IP identifier defined under KNOWN_CIP_IDS in the regtool.
  cip_id:             "33",
  design_spec:        "../doc",
  dv_doc:             "../doc/dv",
  hw_checklist:       "../doc/checklist",
  sw_checklist:       "/sw/device/lib/dif/dif_${module_instance_name.lower()}",
  revisions: [
    {
      version:            "2.0.0",
      life_stage:         "L1",
      design_stage:       "D3",
      verification_stage: "V2",
      dif_stage:          "S2",
      commit_id:          "",
      notes:              "Use FPV to perform block level verification.",
    }
  ],
  clocking: [{clock: "clk_i", reset: "rst_ni"}],
  bus_interfaces: [
    { protocol: "tlul", direction: "device" }
  ],

  param_list: [
    { name: "NumSrc",
      desc: "Number of interrupt sources",
      type: "int",
      default: "${src}",
      local: "true"
    },
    { name: "NumTarget",
      desc: "Number of Targets (Harts)",
      type: "int",
      default: "${target}",
      local: "true",
    },
    { name: "PrioWidth",
      desc: "Width of priority signals",
      type: "int",
      default: "${(prio).bit_length()}",
      local: "true",
    },
  ],

  // In order to not disturb the PLIC address map, we place the alert test
  // register manually at a safe offset after the main CSRs.
  no_auto_alert_regs: "True",
  alert_list: [
    { name: "fatal_fault",
      desc: '''
      This fatal alert is triggered when a fatal TL-UL bus integrity fault is detected.
      '''
    }
  ],

  inter_signal_list: [
    { struct:  "logic",
      type:    "uni",
      name:    "irq",
      act:     "req",
      package: "",
      width:   "${target}"
    },

    { struct:  "logic",
      type:    "uni",
      name:    "irq_id",
      act:     "req",
      package: "",
    },

    { struct:  "logic",
      type:    "uni",
      name:    "msip",
      act:     "req",
      package: "",
      width:   "${target}"
    },
  ]

  features: [
    { name: "RV_PLIC.PRIORITY",
      desc: '''Each interrupt source can be given a configurable priority.'''
    }
    { name: "RV_PLIC.ENABLE",
      desc: '''Each target has an associated set of interrupt enable bits. Configuring these
               controls whether a target will be notified when the interrupt is triggered.
            '''
    }
  ]

  regwidth: "32",
  registers: [
% for i in range(src):
    { name: "PRIO${i}",
      desc: "Interrupt Source ${i} Priority",
      swaccess: "rw",
      hwaccess: "hro",
      fields: [
        { bits: "${(prio).bit_length()-1}:0" }
      ],
    }
% endfor
    { skipto: "0x00001000" }
    { multireg: {
        name: "IP",
        desc: "Interrupt Pending",
        count: "NumSrc",
        cname: "${(module_instance_name).upper()}",
        swaccess: "ro",
        hwaccess: "hwo",
        fields: [
          { bits: "0", name: "P", desc: "Interrupt Pending of Source" }
        ],
        tags: [// IP is driven by intr_src, cannot auto-predict
               "excl:CsrNonInitTests:CsrExclCheck"],
      }
    },
% for i in range(target):
    { skipto: "${"0x{:x}".format(0x00002000 + i * 0x100)}" }
    { multireg: {
        name: "IE${i}",
        desc: "Interrupt Enable for Target ${i}",
        count: "NumSrc",
        cname: "${(module_instance_name).upper()}",
        swaccess: "rw",
        hwaccess: "hro",
        fields: [
          { bits: "0", name: "E", desc: "Interrupt Enable of Source" }
        ],
      }
    }
% endfor
% for i in range(target):
    { skipto: "${"0x{:x}".format(0x00200000  + i * 0x1000)}" }
    { name: "THRESHOLD${i}",
      desc: "Threshold of priority for Target ${i}",
      swaccess: "rw",
      hwaccess: "hro",
      fields: [
        { bits: "${(prio).bit_length()-1}:0" }
      ],
    }
    { name: "CC${i}",
      desc: '''Claim interrupt by read, complete interrupt by write for Target ${i}.
      Value read/written is interrupt ID. Reading a value of 0 means no pending interrupts.''',
      swaccess: "rw",
      hwaccess: "hrw",
      hwext: "true",
      hwqe: "true",
      hwre: "true",
      fields: [
        { bits: "${(src-1).bit_length()-1}:0" }
      ],
      tags: [// CC register value is related to IP
             "excl:CsrNonInitTests:CsrExclCheck"],
    }
% endfor
  { skipto: "0x4000000" }
% for i in range(target):
    { name: "MSIP${i}",
      desc: '''msip for Hart ${i}.
      Write 1 to here asserts software interrupt for Hart msip_o[${i}], write 0 to clear.''',
      swaccess: "rw",
      hwaccess: "hro",
      fields: [
        { bits: "0",
          desc: "Software Interrupt Pending register",
        }
      ],
    }
% endfor
  ],
}

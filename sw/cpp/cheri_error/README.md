CHERI error test for Sonata
==========================

This triggers each type of CHERIoT exception.
See Table 7.3 in the [CHERIoT ISA](https://www.microsoft.com/en-us/research/uploads/prod/2023/02/cheriot-63e11a4f1e629.pdf).

Building
--------

This is built with a simple Makefile that expects to be passed the locations of various tools and the RTOS directory as part of the make invocation:

```
$ make CHERIOT_LLVM_ROOT=path/to/llvm/bin/ CHERIOT_RTOS_SDK=/path/to/cheriot-rtos/sdk/
```

This produces a `cpu0_irom.vmem` file that should be baked into the bitfile.


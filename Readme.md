# Issue with CVA6 + Verilator

See [this issue](https://github.com/YosysHQ/yosys/issues/3773).

This repo, backed by a docker image, is a minimal example to reproduce the issue.

## How to reproduce

This example will show `TEST FAILED`, and creates trace_instrumented.vcd:

```
make run_instrumented
```


This example will show `TEST SUCCEEDED`, and creates trace_vanilla.vcd

```
make run_vanilla
```

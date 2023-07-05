# Bob Pipes Throughput
Change throughput depending per pipe tier

### Download
Source code for factorio mod called BobPipesThroughput
https://mods.factorio.com/mod/BobPipesThroughput

### Parameters
- Base pipe throughput. Default 1. Values 0,1..10
- Pipe throughput per-tier multiplier. Default 0,25. Values 0..2

### Formula
Pipe throughput = `Base pipe throughput` + (tier - 1) * `Pipe throughput per-tier multiplier`

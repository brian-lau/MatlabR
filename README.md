# MatlabR
Connect Matlab to R using [RServe](https://rforge.net/Rserve/), a TCP/IP server that allows other programs to use facilities of R. A generic class (`MatR`) connects to RServe through its Java client.

# Installation

# Usage
On the machine running R (server):
```
library(RServe)
run.Rserve()
```
This should display:
```
-- running Rserve in this R session (pid=1234), 1 server(s) --
(This session will block until Rserve is shut down)
```
On the machine running Matlab (client):
```
r = MatR();
r.eval('seq(1,10)')
r.result.asDoubles()
```
which should return:
```
ans =
  10?1 int32 column vector
    1
    2
    3
    4
    5
    6
    7
    8
    9
   10
```

Contributions
--------------------------------
MatlabR Copyright (c) 2016 Brian Lau [brian.lau@upmc.fr](mailto:brian.lau@upmc.fr), [BSD-3](https://github.com/brian-lau/MatlabR/blob/master/LICENSE.txt)

[RServe](https://rforge.net/Rserve/) Copyright (c) Simon Urbanek, [GPL-2](https://www.gnu.org/licenses/old-licenses/gpl-2.0.en.html)

Please feel free to [fork](https://github.com/brian-lau/MatlabR/fork) and contribute!
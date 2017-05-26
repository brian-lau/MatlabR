# MatlabR
Connect Matlab to R using [RServe](https://rforge.net/Rserve/), a TCP/IP server that allows other programs to use facilities of R. A generic class (`MatR`) connects to RServe through its Java client, which renders the interface platform independent. This contrasts with other solutions which are Windows-only.

# Installation

# Usage
On the machine running R (server):
```
library(RServe)
run.Rserve()
-- running Rserve in this R session (pid=1234), 1 server(s) --
(This session will block until Rserve is shut down)
```
On the machine running Matlab (client):
```
r = MatR();
R version 3.3.3 (2017-03-06)
```
Evaluating simple commands:
```
r.eval('seq(1,10)');
r.result.asDoubles()

ans =
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
Assign variables to R workspace:
```
r.assign('x',1:5)
r.assign('y',0.5)
r.eval('x*y').result.asDoubles()

ans =

    0.5000
    1.0000
    1.5000
    2.0000
    2.5000
```

Contributions
--------------------------------
MatlabR Copyright (c) 2017 Brian Lau [brian.lau@upmc.fr](mailto:brian.lau@upmc.fr), [BSD-2](https://github.com/brian-lau/MatlabR/blob/master/LICENSE.txt)

[RServe](https://rforge.net/Rserve/) Copyright (c) Simon Urbanek, [GPL-2](https://www.gnu.org/licenses/old-licenses/gpl-2.0.en.html)

Please feel free to [fork](https://github.com/brian-lau/MatlabR/fork) and contribute!

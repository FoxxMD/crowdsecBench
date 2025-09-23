# Benchmark Results

## Load Paramaters

All loads were run with

```env
TARGET=50
DURATION=30
RANDOMIZE=true
```

So, 50 requests/s over a duration of 30 seconds using [`bench.sh`](../bench.sh)

### Rapberry Pi4

* [DietPi OS](https://dietpi.com/) (bullseye)
* Kernel `6.1.21-v8+`

![rpi4 results](plot_pi4.png)

### Raspberry Pi5

* [Rasperry Pi OS](https://www.raspberrypi.com/software/) (bookworm)
* Kernel `6.6.51+rpt-rpi-2712`

![rpi5 results](plot_pi5.png)

### i5-6500T

* Debian (bookworm)
* Kernel `6.1.0-38-amd64`

![i5-6500t results](plot_6500t.png)

### i5-13400

* Debian (bookworm)
* Kernel `6.1.0-38-amd64`
* 10core VM on Promxox
  
![i5-13400 results](plot_13400.png)

### 5700x

* Arch
* Kernel `6.14.7-arch2-1`
  
![5700x results](plot_5700x.png)
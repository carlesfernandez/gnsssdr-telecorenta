<!-- prettier-ignore-start -->
[comment]: # (
SPDX-License-Identifier: MIT
)

[comment]: # (
SPDX-FileCopyrightText: 2024 Carles Fernandez-Prades <cfernandez@cttc.es>
)
<!-- prettier-ignore-end -->

This repository contains the necessary data to build a Docker image with
[GNSS-SDR](https://gnss-sdr.org), including the appropriate software drivers to
support the [RTL-SDR v4](https://www.rtl-sdr.com/v4/) radio-frequency front-end,
and [GNU Octave](https://octave.org/) for graphical representation of results.
Additionally, this file provides instructions for downloading and using the
image immediately, eliminating the need for a build process.

![RTL-SDR v4](./pics/RTL-SDRv4.png "RTL-SDR v4")

The Docker image has already been built for you and is
[available on Docker Hub](https://hub.docker.com/repository/docker/carlesfernandez/gnsssdr-telecorenta/),
ready for download. Please refer to the instructions below.

Before using the image, ensure that your system is properly configured and that
you have gathered the necessary data from your specific setup. Please note that
GNSS-SDR processing requires substantial computational power, and not all
machines may be capable of sustaining real-time operation.

Table of Contents:

- [Preparing your setup](#preparing-your-setup)
  - [Radio-frequency front-end](#radio-frequency-front-end)
  - [Setup for Microsoft Windows](#setup-for-microsoft-windows)
  - [Setup for GNU/Linux](#setup-for-gnulinux)
- [Download and use the Docker image](#download-and-use-the-docker-image)
- [Example of a GNSS-SDR configuration file](#example-of-a-gnss-sdr-configuration-file)
- [Plotting results with GNU Octave](#plotting-results-with-gnu-octave)

# Preparing your setup

## Radio-frequency front-end

Any software-defined receiver requires two pieces of hardware to convert the
received electromagnetic waves into a stream of 0s and 1s. This process
involves:

- An antenna, which converts the received electromagnetic waves into voltage
  variations, and
- A device that amplifies, filters, and downconverts those voltage variations to
  baseband. This is followed by sampling and quantifying the signal, ultimately
  delivering a stream of 0s and 1s that a computer can process. This component
  is known as the _radio-frequency front-end_, which is precisely what the
  RTL-SDR v4 USB dongle performs.

To proceed, you will need an RTL-SDR v4 dongle and an **active** GPS antenna. An
_active_ antenna contains a built-in Low Noise Amplifier (LNA) that requires a
DC power supply delivered through the coaxial cable. Fortunately, the RTL-SDR v4
can supply this power. Simply connect your
[GPS antenna](https://es.rs-online.com/web/p/antenas-gps/1372773) to the USB
dongle, and the software configuration will handle the rest.

When connecting the SMA adapters, please make sure the male and female
connectors are correctly aligned before **gently** tightening them. If possible,
use a torque wrench to tighten the connectors. Be careful not to overload the
torque lever to avoid damaging the connector.

**When running the receiver, ensure that the antenna is placed where it has a
clear line of sight to a significant portion of the sky.**

## Setup for Microsoft Windows

To run the following commands, you must be using Windows 10 version 2004 or
later (Build 19041 and higher) or Windows 11.

1. Install the Windows Subsystem for Linux (WSL): Open PowerShell or the Windows
   Command Prompt in administrator mode by right-clicking and selecting "Run as
   administrator." Enter the following command and restart your computer:

   ```
   wsl --install
   ```

2. Install Docker Desktop from
   [here](https://docs.docker.com/desktop/install/windows-install/) and
   configure it to use WSL (this is the default option).

3. For the edition of GNSS-SDR configuration files, you will need a text editor.
   Suggested ones are [Visual Studio Code](https://code.visualstudio.com/),
   [Notepad++](https://notepad-plus-plus.org/), or
   [EditPad Lite](https://www.editpadlite.com/).

4. Download and install the USBIPD-WIN project by obtaining the `.msi` file from
   [this link](https://github.com/dorssel/usbipd-win/releases) and executing it.

5. Plug in your RTL-SDR v4 USB dongle.

6. List all USB devices connected to your system by opening PowerShell in
   administrator mode and running the following command:

   ```
   usbipd list
   ```

   Identify your dongle, which will appear as
   `Realtek Semiconductor Corp. RTL2838 DVB-T`. Make a note of its Bus and
   Device IDs.

7. Use the `usbipd bind` command to share the device, allowing it to be attached
   to WSL. Administrator privileges are required for this step. Replace `3-4`
   with the actual Bus and Device ID of your device:

   ```
   usbipd bind --busid 3-4
   ```

8. Attach the USB device to WSL (this step does not require an administrator
   prompt):

   ```
   usbipd attach --wsl --busid <busid>
   ```

   Replace `<busid>` with the same Bus number - Device ID you recorded in the
   previous step.

9. Verify the attached USB devices from the WSL command line by running

   ```
   lsusb
   ```

   in you terminal. You will get something like:

   ```
   Bus 004 Device 001: ID 1d6b:0003 Linux Foundation 3.0 root hub
   Bus 003 Device 004: ID 0b05:193b ASUSTek Computer, Inc. ITE Device(8295)
   Bus 003 Device 002: ID 0b05:19b6 ASUSTek Computer, Inc. N-KEY Device
   Bus 003 Device 004: ID 0bda:2838 Realtek Semiconductor Corp. RTL2838 DVB-T
   ```

   Your dongle should appear as `Realtek Semiconductor Corp. RTL2838 DVB-T`.
   Record its bus number and device ID. For example, if your device is listed as
   `Bus 003 Device 004: ...`, the path to your device will be
   `/dev/bus/usb/003/004`. **This is the path you need to use when running the
   Docker image, as [shown below](#download-and-use-the-docker-image).**

## Setup for GNU/Linux

The commands below have been tested in Ubuntu, but should be similar in other
GNU/Linux distributions.

1. Install and run Docker. Check https://docs.docker.com/desktop/install/linux/
   for instructions.

2. Plug in your RTL-SDR v4 USB dongle.

3. Use `lsusb` to get the address of your device:

   ```
   Bus 002 Device 002: ID 8087:8002 Intel Corp.
   Bus 002 Device 001: ID 1d6b:0002 Linux Foundation 2.0 root hub
   Bus 001 Device 002: ID 8087:800a Intel Corp.
   Bus 001 Device 001: ID 1d6b:0002 Linux Foundation 2.0 root hub
   Bus 003 Device 004: ID 0bda:2838 Realtek Semiconductor Corp. RTL2838 DVB-T
   Bus 003 Device 001: ID 1d6b:0002 Linux Foundation 2.0 root hub
   ```

   The dongle is identified as `Realtek Semiconductor Corp. RTL2838 DVB-T`. Take
   note of the bus number and the device ID. For instance, if your dongle
   appears at `Bus 003 Device 004: ...` then your device can be found at
   `/dev/bus/usb/003/004`. **This is the path you need to use when running the
   Docker image, as [shown below](#download-and-use-the-docker-image).**

**Note for Raspberry Pi 5 users**: You may need to blacklist the kernel module
`dvb_usb_rtl28xxu`. To do this, run

```
sudo nano /etc/modprobe.d/blacklist-rtl.conf
```

Add the following lines to the file:

```
blacklist dvb_usb_rtl28xxu
blacklist rtl2832
blacklist rtl2830
```

After saving the file and exiting the editor, reboot the system using:

```
sudo shutdown -r now
```

Once the system restarts, the RTL-SDR v4 USB dongle will be ready for use.

# Download and use the Docker image

To download the Docker image, run the following command in your terminal:

```
docker pull carlesfernandez/gnsssdr-telecorenta:latest
```

Verify that the image is functioning correctly by executing:

```
docker run -it --rm carlesfernandez/gnsssdr-telecorenta gnss-sdr --version
```

You should get something similar to:

```
gnss-sdr version 0.0.19.git-next-ff11347a0
```

You are now ready to use the image. Navigate to your preferred working
directory, copy your configuration file there (_e.g._, `rtl.conf`, see an
example of its content below), and run the following command:

```
docker run -it --rm -v $PWD:/home \
  --device=/dev/bus/usb/xxx/yyy:/dev/bus/usb/xxx/yyy \
  -e TZ=Europe/Madrid \
  carlesfernandez/gnsssdr-telecorenta \
  gnss-sdr --c=./rtl.conf
```

In this command, `xxx` and `yyy` represent the bus number and device ID obtained
in the previous steps. Adjust your
[TZ identifier](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones) as
required to obtain time solutions adapted to your time zone.

The software-defined GNSS receiver should now start operating. Stop the receiver
at any time by pressing key `q` and then key `[ENTER]`.

Please note that the antenna must have a clear line of sight to a significant
portion of the sky to receive signals from a sufficient number of satellites for
computing Position, Velocity, and Time (PVT) solutions.

# Example of a GNSS-SDR configuration file

Below is a sample configuration file for GNSS-SDR. Please copy and paste it into
a plain text file using your preferred text editor, and save it in the folder
from which you are running the Docker image. The suggested file name is
`rtl.conf`. For further details, refer to the
[GNSS-SDR configuration documentation](https://gnss-sdr.org/docs/sp-blocks/).

```
[GNSS-SDR]

;######### GLOBAL OPTIONS ##################
GNSS-SDR.internal_fs_sps=2000000

;######### SIGNAL_SOURCE CONFIG ############
SignalSource.implementation=Osmosdr_Signal_Source
SignalSource.item_type=gr_complex
SignalSource.sampling_frequency=2000000
SignalSource.freq=1575420000
SignalSource.AGC_enabled=true
SignalSource.osmosdr_args=rtl,bias=1

;######### SIGNAL_CONDITIONER CONFIG ############
SignalConditioner.implementation=Pass_Through

;######### CHANNELS GLOBAL CONFIG ############
Channels_1C.count=8
Channels.in_acquisition=1

;######### ACQUISITION GLOBAL CONFIG ############
Acquisition_1C.implementation=GPS_L1_CA_PCPS_Acquisition
Acquisition_1C.item_type=gr_complex
Acquisition_1C.pfa=0.01
Acquisition_1C.doppler_max=5000
Acquisition_1C.doppler_step=250

;######### TRACKING GLOBAL CONFIG ############
Tracking_1C.implementation=GPS_L1_CA_DLL_PLL_Tracking
Tracking_1C.item_type=gr_complex
Tracking_1C.pll_bw_hz=40.0
Tracking_1C.dll_bw_hz=4.0

;######### TELEMETRY DECODER GPS CONFIG ############
TelemetryDecoder_1C.implementation=GPS_L1_CA_Telemetry_Decoder

;######### OBSERVABLES CONFIG ############
Observables.implementation=Hybrid_Observables

;######### PVT CONFIG ############
PVT.implementation=RTKLIB_PVT
PVT.positioning_mode=Single
PVT.output_rate_ms=100
PVT.display_rate_ms=500
PVT.iono_model=Broadcast
PVT.trop_model=Saastamoinen
PVT.show_local_time_zone=true
```

# Plotting results with GNU Octave

GNSS-SDR can store some of its internal processing results in `.mat` files,
which are suitable for further analysis and visual representation using tools
such as MATLAB (commercial license) or GNU Octave (free and open-source). If you
already have either of these tools installed, you can use their GUI for an
improved user experience. However, if you don’t, this Docker image already
includes GNU Octave, so there’s no need to install additional software on your
host machine.

Here’s an example on how to use it:

1. Configure GNSS-SDR to store acquisition intermediate results by adding the
   following lines to your configuration file:

   ```
   Acquisition_1C.dump=true
   Acquisition_1C.dump_filename=acq_dump
   Acquisition_1C.dump_channel=0
   ```

   For further details, see the
   [GNSS-SDR documentation](https://gnss-sdr.org/docs/sp-blocks/acquisition/#plotting-results-with-matlaboctave).

2. Run GNSS-SDR as described above for 2-3 minutes. Remember to stop the
   receiver by pressing key `q`and then key `[ENTER]`.
3. Adapt the example script provided at
   [acquisition_grid.m](./octave_scripts/acquisition_grid.m) to your specific
   needs (make sure to set the correct `.mat` filename obtained by GNSS-SDR in
   line 20) and save it in your working folder.
4. Run GNU Octave from the Docker image with the following command:
   ```
   docker run -it --rm -v $PWD:/home carlesfernandez/gnsssdr-telecorenta octave --no-gui acquisition_grid.m
   ```
5. Convert the results to a PDF for easier visualization:
   ```
   docker run -it --rm -v $PWD:/home carlesfernandez/gnsssdr-telecorenta epspdf acq_result.eps acq_result.pdf
   ```

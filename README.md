<!-- prettier-ignore-start -->
[comment]: # (
SPDX-License-Identifier: MIT
)

[comment]: # (
SPDX-FileCopyrightText: 2024 Carles Fernandez-Prades <cfernandez@cttc.es>
)
<!-- prettier-ignore-end -->

gnsssdr-telecorenta
-------------------

This image contains GNSS-SDR with the drivers supporting the RTL-SDR v4 dongle.

![RTL-SDR v4](./pics/RTLSDRv4.png "RTL-SDR v4")

Pull the image. From your terminal:

```
docker pull carlesfernandez/gnsssdr-telecorenta:latest
```

Check that you can run it:
```
docker run -it --rm carlesfernandez/gnsssdr-telecorenta gnss-sdr –-version
```

You should get something similar to:
```
gnss-sdr version 0.0.19.git-next-ff11347a0
```

Connect your USB dongle.

Now you are ready to use the image:

```
docker run -it --rm carlesfernandez/gnsssdr-telecorenta \
 -v $PWD:/home \
 --privileged \
 gnss-sdr --c=./my_configuration_file.conf
```

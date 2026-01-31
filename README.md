# cpcd-container

This build a container for Silicon Lab's [cpc-daemon](https://github.com/SiliconLabs/cpc-daemon).

CPCd allows for multiprotocol communication on top of a single processor. One can for example run Thread and BLE at the same time. Refer to the [guide](https://docs.silabs.com/openthread/latest/multiprotocol-solution-linux/) for more details.

This container on it's own does not do much. You want to set this up, then run something like a OpenThread Border Router on top of it.

## Setup

The container can be run as a rootless podman container using quadlet.

```bash
cp cpcd.container ~/.config/containers/systemd/
systemctl --user daemon-reload
systemctl --user start cpcd
```

This might not always succeed the first time depending on the hardware you're running. You may need to adjust the SPI/UART params like the baud rate or the device path. See below.

## Configuration

CPCd is configured with cpcd.conf. The deafult for the container is included in the repo. To override a configuration, you can set the corresponding ENV variable. The format is `CPCD_SOME_OPT=abc` will translate to `some_option: abc` in the configuration. For example, setting `CPCD_UART_DEVICE_BAUD=460800` results in an override of `uart_device_baud: 460800` in the final `cpcd.conf`.

## License

See the [LICENSE](LICENSE.md) file for license rights and limitations (MIT).

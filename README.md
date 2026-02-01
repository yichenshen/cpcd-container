# cpcd-container

This build a container for Silicon Lab's [cpc-daemon](https://github.com/SiliconLabs/cpc-daemon).

CPCd allows for multiprotocol communication on top of a single processor. One can for example run Thread and BLE at the same time. Refer to the [guide](https://docs.silabs.com/openthread/latest/multiprotocol-solution-linux/) for more details.

This container on it's own does not do much. You want to set this up, then run something like a OpenThread Border Router on top of it.

## Setup

### Configuration

CPCd is configured with cpcd.conf. The deafult for the container is included in the repo. To override a configuration, you can set the corresponding ENV variable. The format is `CPCD_SOME_OPT=abc` will translate to `some_option: abc` in the configuration. For example, setting `CPCD_UART_DEVICE_BAUD=460800` results in an override of `uart_device_baud: 460800` in the final `cpcd.conf`.

### Binding Key

CPCd does encrypted communication, so you'll need to generate a binding key the first time. Refer to [this guide](https://github.com/SiliconLabs/cpc-daemon?tab=readme-ov-file#encrypted-serial-link). You can run this from cpcd within the container itself:

```bash
podman run --name=cpcd-setup -it --device=/dev/ttyACM0 -v /dev/shm:/dev/shm:rw --userns=keep-id -e CPCD_UART_DEVICE_BAUD=460800 --group-add=keep-groups ghcr.io/yichenshen/cpcd-container:latest /bin/bash
> cpcd -c cpcd.conf --bind ecdh
> cat /run/secrets/cpcd_key
```

Be sure to save this key in a secure place. If you delete it along with the setup container you might lock yourself out of the hardware.
Then put this in a file and load it into podman as a secret as cpcd_key. This is the default secret name used by the conf and quadlet file provided.

```
echo "<key>" > binding.key
cat binding.key | podman secret create cpcd_key -
```

### Container

The container can be run as a rootless podman container using quadlet.

```bash
cp cpcd.container ~/.config/containers/systemd/
systemctl --user daemon-reload
systemctl --user start cpcd
```

If there are errors, check the configuration, especially the baud rate is correct.

## License

See the [LICENSE](LICENSE.md) file for license rights and limitations (MIT).

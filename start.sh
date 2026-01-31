#!/bin/sh

# Path to the config file inside the container
CONF_FILE="/etc/cpcd.conf"

echo "Configuring cpcd..."

# 1. Look for all environment variables starting with CPCD_
# Example: CPCD_UART_DEVICE=/dev/ttyUSB0 -> uart_device: /dev/ttyUSB0
for var in $(env | grep '^CPCD_'); do
  # Extract the key and value
  # CPCD_UART_DEVICE=/dev/ttyUSB0 -> key=UART_DEVICE, val=/dev/ttyUSB0
  key_raw=$(echo "$var" | cut -d '=' -f 1 | sed 's/^CPCD_//')
  val=$(echo "$var" | cut -d '=' -f 2-)

  # Convert key to lowercase to match cpcd.conf format
  # UART_DEVICE -> uart_device
  key=$(echo "$key_raw" | tr '[:upper:]' '[:lower:]')

  # Use sed to update the config file.
  # This replaces lines like "uart_device: ..." or "# uart_device: ..."
  # It ensures the key exists and replaces the entire line.
  if grep -q "^#\? \?${key}:" "$CONF_FILE"; then
    echo "  Setting $key to $val"
    sed -i "s|^#\? \?${key}:.*|${key}: ${val}|" "$CONF_FILE"
  else
    echo "  Warning: $key not found in template, appending to end."
    echo "${key}: ${val}" >> "$CONF_FILE"
  fi
done

# Execute the daemon (passed via CMD in Dockerfile)
echo "Starting cpcd daemon..."
exec cpcd

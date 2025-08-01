#!/bin/bash

set -e

USERNAME="jargon"
SANDBOX_DIR="/opt/jargon"
HOST_VOLUME="/opt/host-volume"
CONTAINER_VOLUME="$SANDBOX_DIR/volumes"
ALLOWED_CMDS=(ls cat touch mkdir echo bash less rm ping find)

# Create user and sandbox directory
if ! id "$USERNAME" &>/dev/null; then
	sudo useradd -M -d "$SANDBOX_DIR" -s /bin/bash "$USERNAME"
fi

sudo mkdir -p "$SANDBOX_DIR"
sudo mkdir -p "$SANDBOX_DIR"/{bin,dev,proc,sys,tmp,volumes}
sudo chown -R "$USERNAME:$USERNAME" "$SANDBOX_DIR"

mkdir $HOST_VOLUME 2>/dev/null
mkdir $CONTAINER_VOLUME 2>/dev/null

# Copy essential commands
for cmd in "${ALLOWED_CMDS[@]}"; do
	CMD_PATH=$(which "$cmd")
	if [ -x "$CMD_PATH" ]; then
		sudo cp "$CMD_PATH" "$SANDBOX_DIR/bin/"
		sudo chown "$USERNAME:$USERNAME" "$SANDBOX_DIR/bin/$cmd"
	else
		echo "Warning: Command '$cmd' not found."
	fi
done

# Setup minimal /dev
sudo mknod -m 666 "$SANDBOX_DIR/dev/null" c 1 3 || true
sudo mknod -m 666 "$SANDBOX_DIR/dev/zero" c 1 5 || true
sudo mknod -m 666 "$SANDBOX_DIR/dev/tty" c 5 0 || true
sudo chown -R "$USERNAME:$USERNAME" "$SANDBOX_DIR/dev"

# Mount host volume (optional)
if [ -d "$HOST_VOLUME" ]; then
	sudo mount --bind "$HOST_VOLUME" "$CONTAINER_VOLUME"
	sudo chown -R "$USERNAME:$USERNAME" "$CONTAINER_VOLUME"
fi

# Create script to enter isolated container
ENTRY_SCRIPT="$SANDBOX_DIR/run_inside.sh"
cat <<EOF | sudo tee "$ENTRY_SCRIPT" >/dev/null
#!/bin/bash
mount -t proc proc /proc
mount -t sysfs sys /sys
mount -t tmpfs tmpfs /tmp
export PATH=/bin
exec /bin/bash
EOF

sudo chmod +x "$ENTRY_SCRIPT"
sudo chown "$USERNAME:$USERNAME" "$ENTRY_SCRIPT"

# Now run the container using unshare
sudo unshare \
	--fork \
	--pid \
	--mount \
	--uts \
	--ipc \
	--net \
	--user \
	--map-root-user \
	chroot "$SANDBOX_DIR" /run_inside.sh

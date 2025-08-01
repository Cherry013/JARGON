#!/bin/bash

# 1. Mount necessary virtual filesystems
mount -t proc proc /proc
mount -t sysfs sys /sys
mount -t tmpfs tmpfs /tmp

# 2. Only run chroot if we're not already inside it
if [[ "$INSIDE_CHROOT" != "1" ]]; then
	export INSIDE_CHROOT=1
	exec chroot . /run_inside.sh
fi

# Now inside the chroot jail

# 3. Bring up loopback interface (needed for apps using localhost)
ip link set lo up

# 4. Minimal environment
export PATH=/bin
export PS1="📦[\u@\h \W]\$ "

# 5. Optional: prevent user from changing PATH or PS1
readonly PATH
readonly PS1
export PATH PS1

# 6. Start shell
exec /bin/bash

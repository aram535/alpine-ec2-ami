#!/usr/bin/env sh

set -ex

# copy a directory into place
cp -a ./base "$TARGET/home/$EC2_USER/test"

# process a file and put it into place
tac ./aarch64 | rev > "$TARGET/home/$EC2_USER/test/46hcraa"

# set ownership of installed things
chroot "$TARGET" chown -R "$EC2_USER:$EC2_USER" "/home/$EC2_USER/test"

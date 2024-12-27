use strict;
use warnings;

# Replace with actual library/module and device path
use Device::USB;  # or other relevant module

my $usb = Device::USB->new;
my $device = $usb->find_device(0x2341, 0x005E);  # Replace with your VID and PID

if ($device) {
    print "Device found\n";
    $device->open;

    # Example communication
    $device->send_data("Command");
    my $response = $device->receive_data;
    print "Data received: $response\n";

    $device->close;
} else {
    die "Device not found";
}

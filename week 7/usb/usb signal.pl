use strict;
use warnings;
use Device::USB;

# Initialize USB and find the device
my $usb = Device::USB->new();
my $dev = $usb->find_device(0x047F, 0xAF01);  # Replace with your Vendor ID and Product ID

if ($dev) {
    print "Device found!\n";
} else {
    die "Device not found.\n";
}

# Open the device for communication
$dev->open() || die "Cannot open device: $!";

# Set the configuration and claim the interface
$dev->set_configuration(1) || die "Cannot set configuration: $!";
$dev->claim_interface(0) || die "Cannot claim interface: $!";

# Read input from the device in a loop
while (1) {
    my $buffer = '';  # Predefine the buffer
    
    # Attempt to read data from the device (modify the endpoint address and size as needed)
    my $ret = $dev->interrupt_read(0x81, $buffer, 64, 1000);  # Endpoint 0x81 is typical for input

    if ($ret > 0) {
        print "Data received: ", unpack("H*", $buffer), "\n";
        # You can now process the button presses and map them to custom actions
    }
    else {
        warn "No data received, or timeout occurred.\n";  # Handle timeout or no data
    }
}

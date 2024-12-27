use strict;
use warnings;
use Win32;
use Win32::SerialPort qw( :STAT 0.19 );
use constant ON => 1;
use constant OFF => 0;
use Time::HiRes qw/sleep/;


# my $PortObj = new Win32::SerialPort("COM5") || die "Can't open COM5: $^E\n";

#  $PortObj->user_msg(ON);
#       $PortObj->databits(8);
#       $PortObj->baudrate(9600);
#       $PortObj->parity("none");
#       $PortObj->stopbits(1);
#       $PortObj->handshake("none");    
#       $PortObj->buffers(4096, 4096);

#       $PortObj->write_settings || undef $PortObj;

 
#      for(my $i = 0;  $i < 10; $i++){
#         $PortObj->dtr_active(0);
#         $PortObj->rts_active(1);
#       sleep(0.1);
#         $PortObj->dtr_active(1);
#         $PortObj->rts_active(0);
#       sleep(0.1);

#      }


#     $PortObj->close || die "failed to close";
#     undef $PortObj;                               # frees memory back to perl



my $serial = Win32::SerialPort->new("COM3") || die "Can't open COM5: $^E\n";


$serial->baudrate(9600);
$serial->parity("none");
$serial->databits(8);
    $serial->stopbits(1);

# usleep(1000000);  # 1-second delay

print "Turn light on (1) or off (0)? ";
my $command = <STDIN>;
chomp($command);

if ($command eq '1' || $command eq '0') {
    $serial->write($command);
    print "Command sent to Arduino: $command\n";
} else {
    print "Invalid command.\n";
}

$serial->close();
use strict;
use warnings;
use Win32::SerialPort qw( :STAT 0.19 );
use Tk;

my $command = "";
my $received_number;

# Create Tk window for GUI
my $mw = MainWindow->new;
$mw->Label(-text => 'Communication with Arduino')->pack;
$mw->Label(-text => 'Click on a Button to control the LED')->pack;

$mw->Button(
    -text    => 'RED',
    -command => sub { 
        $command = "red\n";
     },
)->pack;

$mw->Button(
    -text    => 'Blau',
    -command => sub { 
        $command = "blau\n";
     },
)->pack;

$mw->Button(
    -text    => 'Gruen',
    -command => sub { 
        $command = "gruen\n";
     },
)->pack;

$mw->Button(
    -text    => 'RGB',
    -command => sub { 
        $command = "rgb\n";
     },
)->pack;

$mw->Button(
    -text    => 'All LED off',
    -command => sub { 
        $command = "off\n";
     },
)->pack;

$mw->Button(
    -text    => 'Start Game',
    -command => sub { 
        game();  # Call the game function
     },
)->pack;

# Create a text box for displaying received data
my $text_box = $mw->Text(
    -width  => 50,
    -height => 10
)->pack;

# Setup the serial port
my $serial = Win32::SerialPort->new("COM3") || die "Can't open COM3: $^E\n";
$serial->baudrate(9600);
$serial->parity("none");
$serial->databits(8);
$serial->stopbits(1);
$serial->handshake("none");
$serial->write_settings() || die "Failed to write settings\n";

$serial->read_interval(100);  # Set timeout to 100 milliseconds

# Main event loop to handle sending and receiving data
$mw->repeat(100, sub {
    if ($command) {
        # Send command to Arduino
        $serial->write($command);
        print "Command sent to Arduino: $command\n";
        $command = "";  # Clear the command after sending
    }

    my $data = $serial->input();  # Read data from Arduino
    
        print "Received from Arduino: $data\n";
        $text_box->insert('end', $data);  # Display received data in the text box
        $text_box->see('end');  # Scroll to the end of the text box
    
});

# Define the game function
sub game {
    my $gamewindow = MainWindow->new;
    $gamewindow->Label(-text => 'Game: Repeat the Pattern')->pack;

    my @inputs;
    my $number;

    $gamewindow->Button(
        -text    => 'Start',
        -command => sub { 
            $command = "start\n";
        },
    )->pack;

    $gamewindow->Button(
        -text    => 'RED',
        -command => sub { 
            push(@inputs, 2);
        },
    )->pack;

    $gamewindow->Button(
        -text    => 'Blau',
        -command => sub { 
            push(@inputs, 3);
        },
    )->pack;

    $gamewindow->Button(
        -text    => 'Gruen',
        -command => sub { 
            push(@inputs, 4);
        },
    )->pack;

    my $game_text_box = $gamewindow->Text(
        -width  => 50,
        -height => 10
    )->pack;

    $gamewindow->Button(
        -text    => 'Submit',
        -command => sub { 
            $number = join('', @inputs);  # Concatenate array values into a number
            $number = int($number);  # Convert to integer

            print "Entered number: $number\n";
            print "Received number: $received_number\n";
            
            # Check if entered number matches the one received from Arduino
            if ($number == $received_number) {
                $game_text_box->insert('end', "Correct!\n");
            } else {
                $game_text_box->insert('end', "Wrong!\n");
            }
        },
    )->pack;

    # Poll for incoming data from Arduino for the game
    $gamewindow->repeat(100, sub {
        my ($count, $data) = $serial->input(255);  
        if ($count > 0) {
            $received_number = $data;
            print "Received number from Arduino: $received_number\n";
        }
    });
}

MainLoop;

use strict;
use warnings;
use Win32::SerialPort qw( :STAT 0.19 );
use Tk;

my $connection = 0;
my $command = "";
our $received_number;
my $port;

# Create Tk window for GUI
my $mw = MainWindow->new();
$mw->geometry("450x500");
$mw->title("Communication with Arduino");
$mw->configure(-bg => '#149c90');

# Create two frames: top for controls, bottom for display
#my $button_frame    = $mw->Frame()->pack( -side => 'top', -fill => 'x' );
my $connect_frame_text = $mw->Frame(-bg => '#149c90')->pack( -side => 'top', -fill => 'x');
my $connect_frame_buttons = $mw->Frame(-bg => '#149c90')->pack( -side => 'top', -fill => 'x', -pady => 10);
my $button_frame     = $mw->Frame(-bg => '#149c90')->pack( -side => 'left', -fill => 'y' );
my $chatbox_frame    = $mw->Frame(-bg => '#149c90')->pack( -side => 'right', -fill => 'both' );

#my $chatbox_frame = $mw->Frame()->pack( -side => 'bottom', -fill => 'both', -expand => 1 );

$connect_frame_buttons->gridRowconfigure(0, -weight => 1);  
$connect_frame_buttons->gridRowconfigure(1, -weight => 1);  

$connect_frame_buttons->gridColumnconfigure(0, -weight => 1); 
$connect_frame_buttons->gridColumnconfigure(1, -weight => 1); 

# Top Frame: Add controls and buttons
$connect_frame_text->Label( -text => 'Communication with Arduino' , -bg => '#149c90', -font => 'Helvetica 18 bold')->pack;
my $top_label = $connect_frame_text->Label( -text => 'Enter the Port and Click Connect', -bg => '#149c90', -font => '12' )->pack;

# Label and entry for the port
$connect_frame_buttons->Label(
    -text   => 'Port',
    -width  => 10,
    -relief => 'ridge',
    -bd     => 2,
)->grid(
    -row    => 0,
    -column => 0
);
$port = "COM3";  # Default port
my $entry = $connect_frame_buttons->Entry(
    -textvariable => \$port,
)->grid(
    -row    => 0,
    -column => 1
);

# Buttons for communication actions
$connect_frame_buttons->Button(
    -text    => '  Connect  ',
    -command => \&connect,
)->grid(
    -row => 1,
    -column => 0,
    -sticky => 'ew',
    -padx => [10, 5],
    -pady => [10, 0]
);

$connect_frame_buttons->Button(
    -text    => 'Disconnect',
    -command => \&disconnect,
)->grid(
    -row => 1,
    -column => 1,
    -sticky => 'ew',
    -padx => [5, 10],
    -pady => [10, 0]
);

# Buttons for sending LED control commands
$button_frame->Button(
    -text    => 'RED',
    -command => sub {
        $command = "red";
    },
)->pack(
    -fill => 'x',
    -padx => [15, 15],
    -pady => [10, 0]

);

$button_frame->Button(
    -text    => 'Blau',
    -command => sub {
        $command = "blau";
    },
)->pack(
    -fill => 'x',
    -padx => [15, 15],
);

$button_frame->Button(
    -text    => 'Gruen',
    -command => sub {
        $command = "gruen";
    },
)->pack(
    -fill => 'x',
    -padx => [15, 15],
);

$button_frame->Button(
    -text    => 'RGB',
    -command => sub {
        $command = "rgb";
    },
)->pack(
    -fill => 'x',
    -padx => [15, 15],
);

$button_frame->Button(
    -text    => 'All LED off',
    -command => sub {
        $command = "off";
    },
)->pack(
    -fill => 'x',
    -padx => [15, 15],
);

$button_frame->Button(
    -text    => 'Reset',
    -command => sub {
        $command = "reset";
    },
)->pack(
    -fill => 'x',
    -padx => [15, 15],
);

$button_frame->Button(
    -text    => 'Start',
    -command => sub {
        $command = "start";
    },
)->pack(
    -fill => 'x',
    -padx => [15, 15],
);

$button_frame->Button(
    -text    => 'Start Game',
    -command => sub {
        game();    # Call the game function
    },
)->pack(
    -fill => 'x',
    -padx => [15, 15],
);

# Bottom Frame: Text box for displaying received data
my $text_box = $chatbox_frame->Text(
    -width  => 50,
    -height => 10
)->pack( -side => 'top', -fill => 'both', -expand => 1 );

my $serial;

sub connect {
    # Setup the serial port
    $serial = Win32::SerialPort->new($port) || die "Can't open $port: $^E\n";

    $text_box->insert( 'end', "Successfully connected to the Arduino\n" );
    $text_box->see('end');

    $serial->baudrate(9600);
    $serial->parity("none");
    $serial->databits(8);
    $serial->stopbits(1);
    $serial->handshake("none");
    $serial->write_settings() || die "Failed to write settings\n";

    $serial->read_interval(100);    # Set timeout to 100 milliseconds

    $connection = 1;
    $top_label->configure(-text => "Connected to $port", -foreground => '#42f590');
}

sub disconnect {
    $serial->close();
    $text_box->insert( 'end', "Successfully disconnected from the Arduino\n" );
    $text_box->see('end');
    $connection = 0;
        $top_label->configure(-text => "Disconnected from $port", -foreground => 'red');

}

# Main event loop to handle sending and receiving data
$mw->repeat(
    100,
    sub {
        if ($command) {
            # Send command to Arduino if one is available
            if (   $command eq "red"
                || $command eq "gruen"
                || $command eq "blau"
                || $command eq "off"
                || $command eq "rgb"
                || $command eq "start"
                || $command eq "reset" )
            {
                $serial->write($command);
                print "Command sent to Arduino: $command\n";
                $command = "";           # Clear the command after sending
                $serial->lookclear();    # Clear the buffer
            }
        }
        if($connection > 0 && $serial){
            
        # Check if data is available
        my $char_count = $serial->lookclear();
        if ( $char_count > 0 ) {
            our $data = $serial->input();

             if (defined $data && $data ne '') {
                $received_number = $data;  # Store the received data
                # print "Received from Arduino: $received_number\n";
            $text_box->insert( 'end', $data );
            $text_box->see('end');
             }
            #  else {
            #         print "No valid data received.\n";
            #     }
        }
        }
    }
);

# Define the game function (kept as is)
sub game {
    
    my $gamewindow = MainWindow->new;
    $gamewindow->Label( -text => 'Game: Repeat the Pattern' )->pack;

    my @inputs;
    my $number;
    my $received_data;

    $gamewindow->Button(
        -text    => 'Start',
        -command => sub {
            $command = "start";
        },
    )->pack;

    $gamewindow->Button(
        -text    => 'RED',
        -command => sub {
            push( @inputs, 2 );
        },
    )->pack;

    $gamewindow->Button(
        -text    => 'Blau',
        -command => sub {
            push( @inputs, 3 );
        },
    )->pack;

    $gamewindow->Button(
        -text    => 'Gruen',
        -command => sub {
            push( @inputs, 4 );
        },
    )->pack;

    my $game_text_box = $gamewindow->Text(
        -width  => 50,
        -height => 10
    )->pack;

    # Display the received number from the Arduino (serial input)
    if (defined $received_number) {
        $game_text_box->insert( 'end', "Received number from Arduino: $received_number\n" );
        $game_text_box->see('end');
    }

    $gamewindow->Button(
        -text    => 'Submit',
        -command => sub {
            $number =
              join( '', @inputs );    # Concatenate array values into a number
            $number = int($number);   # Convert to integer

            print "Entered number: $number\n";
            print "Received number: $received_number\n";

            # Check if entered number matches the one received from Arduino
            if ( $number eq $received_number ) {
                $game_text_box->insert( 'end', "Correct!\n" );
            }
            else {
                $game_text_box->insert( 'end', "Wrong!\n" );
            }

             $game_text_box->see('end');  
        },
    )->pack;

    $gamewindow->repeat(100, sub {
            $received_data = $received_number;
            print "Received data: $received_data\n";
        
    });

}

MainLoop;


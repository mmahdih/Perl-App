use strict;
use warnings;
use Tk;
use IO::Socket::INET;
use IO::Select;

# Initial label text
my $chat_box = "\n";

# Variables to hold the input text
my $input_text_1 = '';

# Separate buffers for chat and file transfer
my $file_handle;
my $receiving_file = 0;
my $file_transfer_buffer = '';  # Buffer for file transfer data
my $chat_message_buffer = '';   # Buffer for chat messages

# Create the main window
my $mainwindow = MainWindow->new();
$mainwindow->geometry("700x700");
$mainwindow->title("Chat App");

# Create left and right frames
my $left = $mainwindow->Frame(
    -borderwidth => 2,
    -relief      => 'solid'
)->pack(
    -side   => 'left',
    -fill   => 'both',
    -expand => 1,
    -padx   => 10,
    -pady   => 10
);

my $right = $mainwindow->Frame(
    -borderwidth => 2,
    -relief      => 'solid'
)->pack(
    -side   => 'right',
    -fill   => 'both',
    -expand => 1,
    -padx   => 10,
    -pady   => 10
);

# Create a label in the right frame
my $label = $right->Label(
    -text   => $chat_box,
    -font   => "Helvetica 16 bold",
    -anchor => 'nw',  # Align text to the top-left
    -justify => 'left'  # Justify the text to the left
)->pack(
    -expand => 1,
    -fill   => 'both',
    -padx   => 20,
    -pady   => 20
);

# Create Entry widgets for input in the left frame
$left->Entry(
    -textvariable => \$input_text_1,
    -font         => "Helvetica 16"
)->pack(
    -fill   => 'both',
    -padx   => 20,
    -pady   => 10
);

# Connect to the server
my $client_socket = IO::Socket::INET->new(
    PeerHost => 'localhost',
    PeerPort => '8080',
    Proto    => 'tcp',
) or die "Could not connect to server: $!\n";

print "Connected to the server\n";
$chat_box .= "Connected to the server\n";
$label->configure(-text => $chat_box);

# Create IO::Select object to monitor the socket
my $sel = IO::Select->new($client_socket);

# Create a button to send messages to the server
$left->Button(
    -text    => "Send",
    -command => sub {
        my $input1 = $input_text_1;

        # Only send if input is not empty
        if ($input1 =~ /\S/) {
            # Send message to the server
            $client_socket->send($input1);
            
            # Append the sent message to the chat box
            $chat_box .= "You: $input1\n";
            $label->configure(-text => $chat_box);
        }

        # Clear the input field
        $input_text_1 = "";
    }
)->pack(
    -fill   => 'both',
    -padx   => 20,
    -pady   => 10
);

# Tk repeat to check for incoming messages from the server
$mainwindow->repeat(100, sub {
    if ($sel->can_read(0)) {
        my $response;
        $client_socket->recv($response, 1024);

        if ($response) {
            chomp($response);
            print "Received from server: $response\n";  # Debug line

            # Check for file transfer start
            if ($response =~ /FILE_START/) {
                $receiving_file = 1;
                open($file_handle, '>', "received_file.txt") or die "Cannot open file: $!";
                $file_transfer_buffer = '';  # Clear file buffer for new file
                $response =~ s/.*FILE_START//;  # Remove FILE_START marker
                $chat_box .= "Receiving file...\n";
                $label->configure(-text => $chat_box);
            }

            # If receiving file, append to the file transfer buffer
            if ($receiving_file) {
                $file_transfer_buffer .= $response;

                # Check for file transfer end
                if ($file_transfer_buffer =~ /FILE_END/) {
                    my ($file_data) = split(/FILE_END/, $file_transfer_buffer);
                    print $file_handle $file_data;
                    close($file_handle);
                    $chat_box .= "File received and saved as 'received_file.txt'.\n";
                    $label->configure(-text => $chat_box);
                    $file_transfer_buffer = '';  # Clear buffer after file is saved
                    $receiving_file = 0;
                }
            } else {
                # If not receiving a file, treat the response as a chat message
                $chat_message_buffer .= $response;
                $chat_box .= "$chat_message_buffer\n";
                $label->configure(-text => $chat_box);
                $chat_message_buffer = '';  # Clear chat message buffer
            }
        } else {
            print "No response received from server.\n";  # Debug line
        }
    }
});

# Start the main loop
MainLoop;

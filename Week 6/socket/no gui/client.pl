use strict;
use warnings;
use IO::Socket::INET;
use IO::Select;
use Tk;

# Create the main window
my $mw = MainWindow->new;
$mw->title("Perl Client");

# Create a text widget to display messages and file transfer status
my $text_display = $mw->Scrolled('Text', -width => 50, -height => 20)->pack;

# Entry and button to send messages
my $entry = $mw->Entry()->pack;
my $send_button = $mw->Button(
    -text    => "Send Message",
    -command => \&send_message
)->pack;

# Button to connect to the server
my $connect_button = $mw->Button(
    -text    => "Connect to Server",
    -command => \&connect_to_server
)->pack;

# Variables to handle client socket, IO::Select, and file saving
my $client_socket;
my $select;
my $file_handle;
my $receiving_file = 0;
my $file_buffer = '';  # Buffer to store partial data

# Subroutine to send a message to the server
sub send_message {
    my $message = $entry->get();
    if ($client_socket && $message) {
        print $client_socket "MESSAGE: $message\n";
        $text_display->insert('end', "Client: $message\n");
        $entry->delete(0, 'end');
    }
}

# Subroutine to connect to the server
sub connect_to_server {
    my $host = '10.31.0.69';
    my $port = 8888;

    $client_socket = IO::Socket::INET->new(
        PeerAddr => $host,
        PeerPort => $port,
        Proto    => 'tcp'
    ) or die "Cannot connect to server: $!";

    $text_display->insert('end', "Connected to server.\n");

    # Initialize IO::Select for handling messages
    $select = IO::Select->new();
    $select->add($client_socket);

    # # Non-blocking loop to handle messages
    # $mw->repeat(100, \&check_for_message);  # Check for incoming messages every 100ms
}

# # Subroutine to check for incoming messages
# sub check_for_message {
#     if ($select->can_read(0)) {
#         my $data;
#         $client_socket->recv($data, 1024);
#         $file_buffer .= $data;  # Append data to buffer

#         # Check for file transfer start
#         if ($file_buffer =~ /FILE_START/) {
#             $receiving_file = 1;  # Set flag to indicate file transfer
#             open($file_handle, '>', "received_file.txt") or die "Cannot open file: $!";
#             $text_display->insert('end', "File transfer started...\n");
#             $file_buffer =~ s/.*FILE_START//;  # Remove FILE_START marker from buffer
#         }

#         # If receiving file, write data to file
#         if ($receiving_file) {
#             # Check if the buffer contains FILE_END
#             if ($file_buffer =~ /FILE_END/) {
#                 my ($file_data) = split(/FILE_END/, $file_buffer);
#                 print $file_handle $file_data;  # Write remaining file data to file
#                 close($file_handle);
#                 $text_display->insert('end', "File received and saved as 'received_file.txt'.\n");
#                 $file_buffer = '';  # Clear buffer
#                 $receiving_file = 0;  # Reset file receiving flag
#             } else {
#                 print $file_handle $file_buffer;  # Write current buffer to file
#                 $file_buffer = '';  # Clear buffer after writing to file
#             }
#         } else {
#             # Normal chat message handling (when not receiving a file)
#             $text_display->insert('end', "Server: $file_buffer\n") if $file_buffer;
#             $file_buffer = '';  # Clear buffer after displaying chat message
#         }
#     }
# }

# Start the Tk main loop
MainLoop;

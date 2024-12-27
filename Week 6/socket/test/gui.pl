use strict;
use warnings;

use Tk;
use IO::Socket::INET;
use IO::Select;
use File::Basename;

# Initialize variables
my $chat_box = "\n";
my $input_text_1 = '';
my @connected = ();
my $file;
my $file_name;
my $suffix;
my $directory;
my $client_socket;

# Create main window for the server
my $mainwindow = MainWindow->new();
$mainwindow->geometry("900x700");
$mainwindow->title("Server");

# Configure window layout
$mainwindow->gridRowconfigure(0, -weight => 9);  # Top frame gets 9/10 of the space
$mainwindow->gridRowconfigure(1, -weight => 1);  # Bottom frame gets 1/10 of the space
$mainwindow->gridColumnconfigure(0, -weight => 1);  # One column
$mainwindow->gridColumnconfigure(1, -weight => 1);  # One column

# Top Frame
my $top = $mainwindow->Frame(
    -borderwidth => 2,
    -relief      => 'solid'
)->grid(
    -row    => 0,
    -column => 0,
    -sticky => "nsew"
);

# Bottom Frame
my $bottom = $mainwindow->Frame(
    -borderwidth => 2,
    -relief      => 'solid'
)->grid(
    -row    => 1,
    -column => 0,
    -sticky => "nsew"
);

# Left Frame (for connected clients)
my $left = $mainwindow->Frame(
    -borderwidth => 2,
    -relief      => 'solid'
)->grid(
    -row    => 0,
    -rowspan => 2,
    -column => 1,
    -sticky => "nsew"
);

# Chat label in the top frame
my $label = $top->Label(
    -text    => $chat_box,
    -font    => "Helvetica 16 bold",
    -anchor  => 'nw',
    -justify => 'left'
)->pack(
    -expand => 1,
    -fill   => 'both',
    -padx   => 20,
    -pady   => 20
);

# Connected clients label in the left frame
my $clients = $left->Label(
    -text    => join("\n", @connected),
    -font    => "Helvetica 16 bold",
    -anchor  => 'nw',
    -justify => 'left'
)->pack(
    -expand => 1,
    -fill   => 'both',
    -padx   => 20,
    -pady   => 20
);

# Entry widget in the bottom frame
my $entry = $bottom->Entry(
    -textvariable => \$input_text_1,
    -font         => "Helvetica 16"
)->pack(
    -expand => 1,
    -side   => 'left',
    -fill   => 'x',
    -padx   => 20,
    -pady   => 10
);

# Server socket setup
my $server = IO::Socket::INET->new(
    LocalHost => 'localhost',
    LocalPort => '8080',
    Proto     => 'tcp',
    Listen    => 5,
    Reuse     => 1,
    Blocking  => 0,
) or die "Can't create server: $!";

my $select = IO::Select->new($server);
$chat_box .= "Server started on port 8080\n";
$label->configure(-text => $chat_box);

# Send button to send messages
my $button = $bottom->Button(
    -text    => "Send",
    -command => sub {
        if (defined $file) {
            send_file();
        }
        my $input1 = $input_text_1;

        if ($input1 =~ /\S/) {
            if (@connected) {
                $chat_box .= "You: $input1\n";
                $label->configure(-text => $chat_box);
                foreach my $other_client ($select->handles()) {
                    next if $other_client == $server;
                    $other_client->send("Server: '$input1'\n");
                }
            } else {
                $chat_box .= "No clients connected.\n";
                $label->configure(-text => $chat_box);
            }
        }

        $input_text_1 = '';  # Reset input
    }
)->pack(
    -side => 'right',
    -padx => 20,
    -pady => 10
);

# Button to select a file
my $SelectFile = $bottom->Button(
    -text    => "Select",
    -command => \&open_log
)->pack(
    -side => 'right',
    -padx => 20,
    -pady => 10
);

# Function to open a .log file
sub open_log {
    my @types = (["log files", [qw/.log/]], ["All files", '*']);
    $file = $mainwindow->getOpenFile(-filetypes => \@types) or return;
    print "$file\n";
    ($file_name, $directory, $suffix) = fileparse($file, qr/\.[^.]*/);
    $suffix ||= '';  # Ensure suffix is defined
}

# Function to send the file to the client
sub send_file {
    if (!defined $client_socket) {
        print "No client socket defined. Cannot send file.\n";
        return;
    }

    if (!defined $file_name || !defined $suffix) {
        print "File details are not properly defined.\n";
        return;
    }

    if ($file){
    open(my $fh, '<', $file) or die "Could not open file '$file' $!";

    foreach my $client (@connected) {
        my $client_socket = $client;
        eval{
            # Notify client that a file transfer is starting
            print $client_socket "FILE_START\n";
            $client_socket->flush();  # Ensure immediate sending

            # Send the file data in chunks
            while (read($fh, my $buffer, 1024)) {
                print $client_socket $buffer;
                $client_socket->flush();  # Ensure each chunk is sent immediately
            }

            # Notify the client that the file transfer is complete
            print $client_socket "FILE_END\n";
            $client_socket->flush();  # Ensure FILE_END is sent immediately

        };

        if ($@) {
            print "Error sending file to $client: $@\n";
        }
    }
    }
}
#     my $buf;
#     my $buf_size = 1024;

#     while (read($fh, $buf, $buf_size)) {
#         # $client_socket->send($buf);
#         print $client_socket $buf;
#         print(".");
#     }

#     close $fh;
#     #print $client_socket "finished sending file\n";  # End-of-file signal
#     print("finished sending");
# }


# Main loop to handle client connections and updates
$mainwindow->repeat(
    100,
    sub {
        if ($select->can_read(0)) {
            my @ready = $select->can_read();
            foreach my $sock (@ready) {
                if ($sock == $server) {
                    $client_socket = $server->accept();
                    $select->add($client_socket);
                    my $client_address = $client_socket->peerhost();
                    my $client_port    = $client_socket->peerport();
                    push @connected, $client_socket;

                    print "Accepted connection from $client_address:$client_port\n";
                    print $client_socket "Welcome to the server\n";

                    $chat_box .= "Client connected from $client_address:$client_port\n";
                    $label->configure(-text => $chat_box);

                    # Update clients list
                    $clients->configure(-text => join("\n", map { $_->peerhost() . ":" . $_->peerport() } @connected));
                } else {
                    my $data = '';
                    my $bytes_received = $sock->recv($data, 1024);

                    if ($bytes_received) {
                        chomp($data);
                        my $client_address = $sock->peerhost();
                        my $client_port    = $sock->peerport();

                        foreach my $other_client ($select->handles()) {
                            next if $other_client == $server || $other_client == $sock;
                            $other_client->send("$client_address:$client_port said: '$data'\n");
                        }

                        # Display message from client in the chat box
                        if ($data) {
                            print "$client_address:$client_port said: '$data'\n";
                            $chat_box .= "$client_address:$client_port said: '$data'\n";
                            $label->configure(-text => $chat_box);
                        }
                    } else {
                        print "Client disconnected\n";
                        $select->remove($sock);
                        close($sock);
                        @connected = grep { $_ != $sock } @connected;
                        $clients->configure(-text => join("\n", map { $_->peerhost() . ":" . $_->peerport() } @connected));
                    }
                }
            }
        }
    }
);

# Start the main loop
MainLoop;

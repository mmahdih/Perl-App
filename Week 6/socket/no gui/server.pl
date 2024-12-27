use strict;
use warnings;
use IO::Socket::INET;
use IO::Select;
use Tk;

# Create the main window
my $mw = MainWindow->new;
$mw->title("Perl Server");

# Create a text widget to display messages and file transfer status
my $text_display = $mw->Scrolled('Text', -width => 50, -height => 20)->pack;

# Create a listbox to display connected clients
my $client_listbox_label = $mw->Label(-text => "Connected Clients:")->pack;
my $client_listbox = $mw->Scrolled('Listbox', -width => 50, -height => 10)->pack;

# Entry and button to send messages
my $entry = $mw->Entry()->pack;
my $send_button = $mw->Button(
    -text    => "Send Message",
    -command => \&send_message
)->pack;

# Button to select a file
my $file_button = $mw->Button(
    -text    => "Select File",
    -command => \&select_file
)->pack;

# Button to send the selected file
my $send_file_button = $mw->Button(
    -text    => "Send File",
    -command => \&send_file,
    -state   => 'disabled'  # Initially disabled until a file is selected
)->pack;

# Button to start the server
my $start_button = $mw->Button(
    -text    => "Start Server",
    -command => \&start_server
)->pack;

# Variables to store file path, server socket, and clients
my $file_to_send;
my $server_socket;
my $select;
my %clients;  # Store clients with their status

# Subroutine to select a file
sub select_file {
    my @types = (["All Files", '*'], ["Text Files", '.txt'], ["Perl Files", '.pl']);
    $file_to_send = $mw->getOpenFile(-filetypes => \@types);

    if ($file_to_send) {
        $text_display->insert('end', "File selected: $file_to_send\n");
        $send_file_button->configure(-state => 'normal');  # Enable the send file button
    } else {
        $text_display->insert('end', "No file selected.\n");
    }
}

# Subroutine to send a message to all connected clients
sub send_message {
    my $message = $entry->get();
    if ($message) {
        foreach my $client (keys %clients) {
            if ($clients{$client}{status} eq 'Connected') {
                my $client_socket = $clients{$client}{socket};
                eval {
                    print $client_socket "MESSAGE: $message\n";
                    $client_socket->flush();  # Ensure that the message is sent immediately
                };
                if ($@) {
                    $text_display->insert('end', "Error sending message to $client: $@\n");
                    $clients{$client}{status} = 'Disconnected';
                    update_client_listbox();
                }
            }
        }
        $text_display->insert('end', "Server: $message\n");
        $entry->delete(0, 'end');
    }
}


# Subroutine to send the selected file to all connected clients
sub send_file {
    if ($file_to_send) {
        open my $fh, '<', $file_to_send or die "Cannot open file: $!";
        
        foreach my $client (keys %clients) {
            if ($clients{$client}{status} eq 'Connected') {
                my $client_socket = $clients{$client}{socket};
                eval {
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
                    $text_display->insert('end', "Error sending file to $client: $@\n");
                    $clients{$client}{status} = 'Disconnected';
                    update_client_listbox();
                }
            }
        }

        close $fh;
        $text_display->insert('end', "File sent.\n");
    } else {
        $text_display->insert('end', "No file selected.\n");
    }
}


# Subroutine to start the server
sub start_server {
    my $port = 5000;

    $server_socket = IO::Socket::INET->new(
        LocalPort => $port,
        Proto     => 'tcp',
        Type      => SOCK_STREAM,
        Reuse     => 1,
        Listen    => 10
    ) or die "Cannot create socket: $!";

    $text_display->insert('end', "Server listening on port $port...\n");

    # Initialize IO::Select to manage multiple connections
    $select = IO::Select->new();
    $select->add($server_socket);

    # Non-blocking loop to check for client connections and messages
    $mw->repeat(100, \&check_for_client_or_message);  # Check every 100ms
}

# Subroutine to update the client list display
sub update_client_listbox {
    $client_listbox->delete(0, 'end');  # Clear current list
    foreach my $client (keys %clients) {
        my $status = $clients{$client}{status};
        $client_listbox->insert('end', "$client ($status)");
    }
}

# Subroutine to check for incoming client connections and messages
sub check_for_client_or_message {
    if (my @ready = $select->can_read(0)) {
        foreach my $socket (@ready) {
            if ($socket == $server_socket) {
                # New client connection
                my $client_socket = $server_socket->accept();
                my $client_address = $client_socket->peerhost();
                my $client_port = $client_socket->peerport();

                my $client_id = "$client_address:$client_port";
                $clients{$client_id} = {
                    socket => $client_socket,
                    status => 'Connected',
                };

                $select->add($client_socket);
                $text_display->insert('end', "Client connected: $client_id\n");
                update_client_listbox();
            } else {
                # Client message or file data
                my $data;
                $socket->recv($data, 1024);
                my $client_address = $socket->peerhost();
                my $client_port = $socket->peerport();
                my $client_id = "$client_address:$client_port";

                if ($data) {
                    $text_display->insert('end', "Client $client_id: $data\n");
                } else {
                    # Client disconnected
                    $text_display->insert('end', "Client disconnected: $client_id\n");
                    $select->remove($socket);
                    close $socket;
                    $clients{$client_id}{status} = 'Disconnected';
                    update_client_listbox();
                }
            }
        }
    }
}

# Start the Tk main loop
MainLoop;

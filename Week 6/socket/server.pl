use IO::Socket::INET;
use IO::Select;

# Auto-flush socket
$| = 1;

# Create the server socket
my $server = IO::Socket::INET->new(
    LocalHost => '127.0.0.1',
    LocalPort => '8080',
    Proto     => 'tcp',
    Listen    => 5,
    Reuse     => 1
) or die "Could not create server socket: $!\n";

print "Server is waiting for client connection on port 8080...\n";

# Wait for a client to connect
my $client_socket = $server->accept();

# Set up an IO::Select to manage multiple input sources (client socket and STDIN)
my $select = IO::Select->new();
$select->add($client_socket);
$select->add(\*STDIN);  # Add standard input (keyboard)

print "Client connected. You can start chatting.\n";

# Communication loop
while (1) {
    # Check for available input (either from the client or the user)
    foreach my $fh ($select->can_read()) {
        if ($fh == $client_socket) {
            # Client has sent a message
            my $data = "";
            $client_socket->recv($data, 1024);
            if ($data) {
                print "Client: $data\n";
            } else {
                print "Client disconnected.\n";
                last;
            }
        } elsif ($fh == \*STDIN) {
            # User (server) input from keyboard
            my $message = <STDIN>;
            chomp($message);
            $client_socket->send($message);
            print "You: $message\n";
        }
    }
}

# Close the client and server sockets
$client_socket->close();
$server->close();

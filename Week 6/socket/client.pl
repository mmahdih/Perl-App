use IO::Socket::INET;

# Auto-flush socket
$| = 1;

# Create a client socket
my $client = IO::Socket::INET->new(
    PeerHost => 'localhost',  # Server IP (localhost)
    PeerPort => '8080',       # Server port
    Proto    => 'tcp'         # Use TCP protocol
) or die "Could not connect to server: $!\n";

print "Connected to the server.\n";

# Receive message from server
my $response = "";
$client->recv($response, 1024);
print "Received from server: $response\n";

# Send message to server
$client->send("Hello from client!\n");

# Close the client socket
$client->close();

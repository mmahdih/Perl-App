use strict;
use warnings;
use IO::Socket::INET;
use IO::Select;

$| = 1;

# Create server socket
my $server = IO::Socket::INET->new(
    LocalHost => 'localhost',
    LocalPort => '8080',
    Proto     => 'tcp',
    Listen    => 1,
    Reuse     => 1,
) or die "Can't create server: $!";

# Create IO::Select object
my $sel = IO::Select->new();
$sel->add($server);
print "Server started on port 8080\n";

while (1) {
    # Wait for any socket to be ready for reading
    my @ready = $sel->can_read(0); # The timeout is 0 for non-blocking
    
    foreach my $fh (@ready) {
        if ($fh == $server) {
            # Accept new client connection
            my $client = $server->accept();
            $sel->add($client); # Add new client socket to the select object
            print "Client connected from ", $client->peerhost(), ":", $client->peerport(), "\n";
        }
        else {
            # Handle client socket
            my $client_msg;
            my $bytes_read = $fh->recv($client_msg, 1024);

            if ($bytes_read) {
                print "Client said: $client_msg\n";

                # Send a response to the client
                print "> ";
                my $response = <STDIN>;
                chomp($response);
                $fh->send($response);

                # Optionally handle multiple messages from client before closing the connection
                # Uncomment below block if you want to keep the connection open for multiple messages
                while (1) {
                    $client_msg = '';
                    $bytes_read = $fh->recv($client_msg, 1024);
                    last unless $bytes_read; # Break loop if no more data
                    print "Client said: $client_msg\n";
                    print "> ";
                    $response = <STDIN>;
                    chomp($response);
                    $fh->send($response);
                }
            }
            else {
                # If no data read, client has disconnected
                $sel->remove($fh);
                $fh->close();
                print "Client disconnected\n";
            }
        }
    }
}

#!/usr/bin/perl
use strict;
use warnings;
use IO::Socket;
use IO::Select;

# Set autoflush to avoid buffering issues
$| = 1;

# Create a new socket (TCP)
my $server = IO::Socket::INET->new(
    LocalAddr => 'localhost',
    LocalPort => 8080,
    Proto     => 'tcp',
    Listen    => 5,          # Number of clients that can queue
    Reuse     => 1
) or die "Couldn't create socket: $!";

print "Server listening on port 8080...\n";

# IO::Select allows us to manage multiple clients
my $select = IO::Select->new($server);
print  "Waiting for clients... $select\n";


# Infinite loop to accept client connections and broadcast messages
while (1) {
    # Get the list of sockets that are ready for reading
    my @ready = $select->can_read();
    print  "Ready to read: @ready\n";
    print  "Server: $server\n";


    foreach my $sock (@ready) {
        # If the socket is the server socket, it means a new client has connected
        print "client:  $sock\n";

        if ($sock == $server) {
            # Accept new client connection
            my $client_socket = $server->accept();
            $select->add($client_socket); # Add new client to the select list
            my $client_address = $client_socket->peerhost();
            my $client_port    = $client_socket->peerport();
            print "Accepted connection from $client_address:$client_port\n";

            # Send welcome message to the newly connected client
            print $client_socket "Welcome to the server\n";
        } else {
            # Read data from an existing client
            my $data = '';
            my $bytes_received = $sock->recv($data, 1024);

            if ($bytes_received) {
                # Remove newlines and whitespace from the message
                chomp($data);

                # Get client info (useful for broadcasting messages)
                my $client_address = $sock->peerhost();
                my $client_port    = $sock->peerport();

                # Broadcast the message to all connected clients
                foreach my $client ($select->handles()) {
                    # Don't send the message back to the server socket or the client that sent it
                    next if $client == $server || $client == $sock;

                    $client->send("$client_address:$client_port said: '$data'\n");

                }

                print "$client_address:$client_port said: '$data'\n";  # Log the message on the server side
            } else {
                # Client has disconnected
            print "Client disconnected\n";
                $select->remove($sock);  # Remove the client from the select list
                close($sock);  # Close the client socket
            }
        }
    }
}

close($server);  # Close server socket when done

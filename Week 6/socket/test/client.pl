use strict;
use warnings;
use IO::Socket::INET;

$| = 1;

my $client_socket  = IO::Socket::INET->new(
    # PeerHost => '10.31.4.50',
    PeerHost => 'localhost',
    PeerPort => '8080',
    Proto    => 'tcp',
) or die "Could not connect to server: $!\n";

print "Connected to the server\n";

    while(1){

        print "> ";
        my $send_data = <STDIN>;
        chomp($send_data);

        last if $send_data eq "exit";

        $client_socket->send($send_data);

        my $data;
        $client_socket->recv($data, 1024);
        print "Server: $data\n";
    }

$client_socket->close();


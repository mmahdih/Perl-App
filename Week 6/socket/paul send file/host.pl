use strict;
use warnings;
use IO::Socket;

my $server = IO::Socket::INET->new(
    LocalAddr => 'localhost',
    LocalPort => '8888',
    Proto     => 'tcp',
    Listen    => 5,
    Reuse     => 1,
) or die "Could not create server socket: $!";

print "Server listening on localhost: 8888...\n";

while (my $client = $server->accept()) {
    my $client_address = $client->peerhost();
    my $client_port    = $client->peerport();

    print "Client connected from $client_address:$client_port\n";


    my $filenmae_msg = <$client>;
    if ($filenmae_msg =~ /(?<=sending file: )([a-zA-Z0-9]*\.log)/g) {
        my $filename = $1;



        open(OUT, '>', $filename) or die "Could not open file '$filename' $!";
        binmode OUT;

        my $buffer;

        while (read($client, $buffer, 1024)) {
            print OUT $buffer;
        }

        close(OUT);

        print "finished sending file\n";
    }
    
    close($client);

}

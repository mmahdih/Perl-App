my ($remote_host, $remote_port, $output_file_name) = @_;
    $wav_file = $output_file if not $wav_file;
    if (!$wav_file) {
        die "cant find any file";
    }
    my $filename = $output_file_name ? $output_file_name : get_file_name($wav_file);


    my $socket = IO::Socket::INET->new(
        PeerAddr => $remote_host,
        PeerPort => $remote_port,
        Proto => "tcp",
        Type => SOCK_STREAM
    ) 
    or die "Cant connect to $remote_host:$remote_port: $!";
    print $socket ("sending file: ",  $filename, "\n");

    open(OUT, '<', $wav_file) or die "Could not open file '$wav_file' $!";

    binmode(OUT);

    my $buffer;

    while (read(OUT, $buffer, 1024)) {
        print $socket $buffer;
        print ".";
    }

    close(OUT);
    print $socket "finished sending file\n";

    $wav_label->configure(-text => "File sent to $remote_host");

    close $socket;
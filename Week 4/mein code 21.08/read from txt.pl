use strict;
use warnings;

my $source = shift @ARGV;
my $output = shift @ARGV;


# Open the file for reading
open(SRC, "<",  $source) or die "Could not open file '$source' $!";

open(DES, ">>", $output ) or die "Could not open file '$output' $!";

while (<SRC>) {
    print DES $_;
}

close(SRC);
close(DES);

print "Writing to file successfully!\n";


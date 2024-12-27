use strict;
use warnings;
use feature 'say';

my $file = 'N50E008.hgt';

# Open the file in raw mode
open(my $fh, '<:raw', $file) or die "Cannot open $file: $!";

my $count = 0;

# Read the file contents
while (read($fh, my $buffer, 1)) {
    my $binary = unpack("B8", $buffer);  # unpack a single byte into an 8-bit binary string

    print $binary, "\t";  # Print the binary string followed by a tab

    $count++;

    # After every 10 binary strings, print a newline
    if ($count % 10 == 0) {
        print "\n";
    }
}

# Print a final newline if the last line wasn't completed
if ($count % 10 != 0) {
    print "\n";
}

# Close the filehandle
close($fh);

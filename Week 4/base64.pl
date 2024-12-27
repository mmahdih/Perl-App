

use strict;
use warnings;
use feature 'say';

# use MIME::Base64;
use MIME::Base64;

my $text = "Mahdi Haidary";
my $encoded = encode_base64($text);
my $binary = unpack("B*", $text);
# say $binary;

my $txt = pack("B*", $binary);
say $txt;

# my $decoded = MIME::Base64::decode($encoded);
# say $decoded;
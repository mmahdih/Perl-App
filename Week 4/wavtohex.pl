use strict;
use warnings;


my $wav_file = "audio.wav";
my $hex_file = "text.hex";

open(my $wav_fh, "<:raw" , $wav_file) or die;

my $wav_data;
read($wav_fh, $wav_data, -s $wav_file);

my $hex_data = unpack("H*" , $wav_data);

$hex_data =~ s/(..)/$1 /g;

# $hex_data =~ s/\s+$//;


open(my $hex_fh, ">", $hex_file) or die;

print $hex_fh $hex_data;

close($wav_fh);
close($hex_fh);

print "conversion successful";
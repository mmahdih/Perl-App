use strict;
use warnings;

# Open the WAV file
my $filename = 'header.wav';
open my $fh, '<:raw', $filename or die "Cannot open '$filename': $!";

# Read the first 44 bytes (WAV header)
my $header;
read $fh, $header, 44;

# Extract and print header information
my ($chunk_id, $chunk_size, $format, $subchunk1_id, $subchunk1_size,
    $audio_format, $num_channels, $sample_rate, $byte_rate, $block_align,
    $bits_per_sample, $subchunk2_id, $subchunk2_size) = unpack('A4 L< A4 A4 L< s< s< L< L< s< s< A4 L<', $header);

print "Chunk ID: $chunk_id\n";
print "Chunk Size: $chunk_size bytes\n";
print "Format: $format\n";
print "Subchunk1 ID: $subchunk1_id\n";
print "Subchunk1 Size: $subchunk1_size\n";
print "Audio Format: $audio_format\n";
print "Number of Channels: $num_channels\n";
print "Sample Rate: $sample_rate Hz\n";
print "Byte Rate: $byte_rate bytes/sec\n";
print "Block Align: $block_align bytes\n";
print "Bits Per Sample: $bits_per_sample bits\n";
print "Subchunk2 ID: $subchunk2_id\n";
print "Subchunk2 Size: $subchunk2_size bytes\n";

# Close the file handle
close $fh;

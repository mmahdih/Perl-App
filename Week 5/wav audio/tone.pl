use strict;
use warnings;

use lib '.';
use Wav;

# Create a new Wav object
my $wav = Wav->new(
    sample_rate     => 44100,
    bits_per_sample => 16,
    channels        => 1,
);

# Define the melody with pitch changes
my @melody = (
    { start_frequency => 440.00, end_frequency => 880.00, amplitude => 10000, duration => 2 },  # A4 to A5
    { start_frequency => 880.00, end_frequency => 440.00, amplitude => 10000, duration => 1 },  # A4 to A5
    
    # { start_frequency => 523.25, end_frequency => 523.25, amplitude => 40000, duration => 0.5 },  # C5
    # { start_frequency => 587.33, end_frequency => 440.00, amplitude => 40000, duration => 0.5 },  # D5 to A4
    # { start_frequency => 659.25, end_frequency => 523.25, amplitude => 40000, duration => 0.5 },  # E5 to C5
);

# Generate audio data for the melody with pitch changes
my $combined_data = '';
foreach my $note (@melody) {
    my $data = $wav->data($note->{start_frequency}, $note->{end_frequency}, $note->{amplitude}, $note->{duration});
    $combined_data .= $data;
}

# Update header with the size of the data chunk
my $data_size = length($combined_data);
my $header_data = $wav->header();
$header_data =~ s/(data.{4})/pack('a4 L', 'data', $data_size)/e;

# Write to a WAV file
my $file = "melody_with_pitch_bend.wav";
open(my $fh, '>', $file) or die "Can't open $file: $!";
binmode $fh;
print $fh $header_data;
print $fh $combined_data;
close $fh or die "Can't close $file: $!";

print "Generated $file\n";

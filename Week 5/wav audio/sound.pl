use strict;
use warnings;

use lib '.';
use Wav;

# Create a new Wav object
my $wav = Wav->new();
$wav->{_length} = 44100;  # Length of one note

my @notes = (
    { frequency => 440.00, amplitude => 20000, name => 'A4' },   # A4
    { frequency => 523.25, amplitude => 20000, name => 'C5' },   # C5
    { frequency => 587.33, amplitude => 20000, name => 'D5' },   # D5
    { frequency => 659.25, amplitude => 20000, name => 'E5' },   # E5
);

# Generate data for all notes
my $combined_data = '';
my $note_length = 44100;  # Assuming each note lasts 1 second

foreach my $note (@notes) {
    $wav->{_length} = $note_length;  # Set length for current note
    $combined_data .= $wav->data($note->{frequency}, $note->{amplitude});
}

my $header_data = $wav->header();
my $file = "notes.wav";

my $data_size = length($combined_data);
$header_data =~ s/(data.{4})/pack('a4 L', 'data', $data_size)/e;

open(my $fh, '>:raw', $file) or die "Can't open $file: $!";
print $fh $header_data;
print $fh $combined_data;
close($fh) or die "Can't close $file: $!";

print "Generated $file\n";










# first way

# # Open the file for writing in raw binary mode
# open(OUT, ">>:raw", "ausgabe.wav") or die "can't open file: $!";

# # Write the header to the file
# print OUT $header_data;

# # (Optionally) write audio data here
# # For example, $wav->data() if you have a method to generate audio data

# print "Write successful";
# # Close the file
# close(OUT) or die "can't close file: $!";







# Second Way

# foreach my $note (@notes) {
#     my $audio_data = $wav->data($note->{frequency},  $note->{amplitude});


# # Generate the WAV header
# my $header_data = $wav->header();

# my  $file = "note_$note->{name}.wav";
# open (my $fh, '>>', $file) or die "Can't open $file: $!";
# binmode  $fh;
# print $fh $header_data;
# print  $fh $audio_data;
# close  $fh or die  "Can't close $file: $!";
# print  "Generated $file\n";
# }
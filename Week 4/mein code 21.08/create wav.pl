use strict;
use warnings;
use Audio::Wav;

# Parameters
my $duration = 5;       # Duration in seconds
my $frequency = 440;    # Frequency of the tone (A4 note = 440 Hz)
my $sample_rate = 96000 ; # CD quality sample rate
my $amplitude = 1000;  # Maximum amplitude for 16-bit audio

# Create a new Audio::Wav instance
my $wav = Audio::Wav->new;

# Create a new WAV file
my $file = $wav->write('tone.wav', {
    bits_sample => 16,
    sample_rate => $sample_rate,
    channels    => 1,
});

# Generate the sine wave
for my $i (0 .. $duration * $sample_rate) {
    my $sample = $amplitude * sin(2 * 3.14159265359 * $frequency * $i / $sample_rate);
    $file->write_raw(pack('s', $sample));
}

# Finalize the WAV file
$file->finish;

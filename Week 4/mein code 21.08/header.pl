use strict;
use warnings;
use Math::Trig qw( pi );
use MIME::Base64;

# # Parameters for the WAV file
# my $sample_rate = 96000;   # Samples per second
# my $bits_per_sample = 16;  # Bits per sample
# my $num_channels = 1;      # Mono
# my $duration = 5;          # Duration in seconds
# my $frequency = 440;       # Frequency of the sine wave (A4 note)
# my $amplitude = 32767;     # Maximum amplitude for 16-bit audio

# # Calculate total number of samples
# my $num_samples = $sample_rate * $duration;

# # Create a file to save the WAV data
# my $filename = "output.wav";
# open(my $fh, '>', $filename) or die "Could not open file '$filename' $!";

# # RIFF Header
# print $fh "RIFF";
# print $fh pack('L', 36 + $num_samples * $num_channels * ($bits_per_sample / 8));  # File size - 8 bytes
# print $fh "WAVE";

# # FMT Subchunk
# print $fh "fmt ";
# print $fh pack('L', 16);   # Subchunk1Size (16 for PCM)
# print $fh pack('S', 1);    # AudioFormat (1 for PCM)
# print $fh pack('S', $num_channels);  # NumChannels
# print $fh pack('L', $sample_rate);   # SampleRate
# print $fh pack('L', $sample_rate * $num_channels * ($bits_per_sample / 8));  # ByteRate
# print $fh pack('S', $num_channels * ($bits_per_sample / 8));  # BlockAlign
# print $fh pack('S', $bits_per_sample);  # BitsPerSample

# # Data Subchunk
# print $fh "data";
# print $fh pack('L', $num_samples * $num_channels * ($bits_per_sample / 8));  # Subchunk2Size

# # Generate and write sine wave samples
# for my $i (0 .. $num_samples - 1) {
#     my $sample = $amplitude * sin(2 * pi * $frequency * $i / $sample_rate);
#     print $fh pack('s', $sample);  # 's' is for signed 16-bit integer
# }

# # Close the file
# close($fh);

# print "WAV file '$filename' created successfully!\n";


sub wave_header  {
    my ($file_size, $num_channels, $sample_per_second, $bits_per_sample) = @_;
    my  $header = "";

    my $riff = "RIFF";
    my $chunk_size = $file_size - 8;
    my  $wave = "WAVE";
    my  $fmt = "fmt ";
    my $subchunk1_size = 16;
    my $audio_format = 1;
    my $bytes_per_second =  (($sample_per_second * $num_channels * $bits_per_sample) / 8);
    my $sample_depth = ($bits_per_sample *  $num_channels)/8;

    my $data = "data";
    my $subchunk2_size  = $file_size - 44;
    $header = 
    $riff 
    . pack('L', $chunk_size) . $wave 
    . wave
    . pack('L', $subchunk1_size) 
    . $fmt
    . pack('S', $audio_format)
    . pack('S', $num_channels)
    . pack('L', $sample_per_second)
    . pack('L', $bytes_per_second)
    . pack('S', $sample_depth)
    . pack('L', $bits_per_sample)
    . $data
    . pack("L<",  $subchunk2_size);
    return $header;
    }






# Riff Chunk
my $chunk_id = "RIFF";
my $chunk_size = "----";
my $format = "WAVE";


#FMT sub-chunk 
my $subchunk1_id = "fmt";
my $subchunk1_size = 16;
my $audio_format = 1;
my  $num_channels = 2;
my $sample_rate = 44100;
my $byte_rate = $sample_rate * $num_channels * ($subchunk1_size / 8);
my $block_align = $num_channels * ($subchunk1_size / 8);
my $bits_per_sample = 16;

my $subchunk2_id = "data";
my $subchunk2_size = "----";

my $duration = 3;
my $amplitude = 2**($bits_per_sample-1) - 5000;
my $frequency = 441;
my

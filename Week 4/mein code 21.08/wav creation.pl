use strict;
use warnings;
use MIME::Base64;
use Math::Trig;

sub Waveheader{
    my ($file_size, $num_channels,  $sample_rate, $bits_per_sample) = @_;



    my $binary_header;

    # RIFF Chunk
    my $chunk_id = "RIFF";
    my  $chunk_size = $file_size - 8;

    my $format = "WAVE";
    
    # fmt sub chunk
    my $subchunk1_id = "fmt ";
    my $subchunk1_size = 16;
    my $audio_format =  1;
    my $byte_rate = $sample_rate *  $num_channels * ($subchunk1_size  / 8);

    my $block_align = $num_channels  * ($subchunk1_size  / 8);


    #  data sub chunk
    my $subchunk2_id = "data";
    my $subchunk2_size = $file_size - 44;


       $binary_header = 
          $chunk_id 
        . pack("L<", $chunk_size) 
        . $format 
        . $subchunk1_id
        . pack("L<", $subchunk1_size) 
        . pack("s<", $audio_format) 
        . pack("s<", $num_channels) 
        . pack("L<", $sample_rate) 
        . pack("L<", $byte_rate) 
        . pack("s<", $block_align) 
        . pack("s<", $bits_per_sample) 
        . $subchunk2_id 
        . pack("L<", $subchunk2_size);

    return $binary_header;
}


    my $bits_per_sample = 16;
    my $num_channels = 2;
    my $sample_rate = 44100;
    my $duration = 5;
    my $frequency = 1000;
    my $amplitude = 15000;
    my  $file_size = $duration * $sample_rate * $num_channels * ($bits_per_sample / 8);

my $header = Waveheader($file_size, $num_channels, $sample_rate,  $bits_per_sample);
my $wave = ();
for  (my $i = 0; $i < $duration * $sample_rate; $i++){
    my $wave_value = $amplitude * sin(2 * pi * $frequency * ($i / $sample_rate));
    for  (my $j = 0; $j < $num_channels; $j++){
        $wave .= pack("s<", int($wave_value));
        }


}



open(OUT, ">:raw", "output.wav")  or die "Can't open output.wav: $!";
# binmode(OUT);
$header .=  $wave;

print OUT $header;
# print OUT $wave;
close  OUT;

print "write succeed";




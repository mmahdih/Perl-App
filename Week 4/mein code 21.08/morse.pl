use strict;
use warnings;
use MIME::Base64;
use Math::Trig;

use Convert::Morse qw(as_ascii as_morse is_morsable);

print "Please enter a word:";
my $x = <STDIN>;
my $text = substr($x, 0, -1);

# my $x = "mahdi";
# print as_morse($x);


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

    #durations
    my $dotDuration = 0.1;
    my $dashDuration =  0.3;
    my $silenceDuration = 0.1;

    my $duration = getWavDuration($text);

    my $frequency = 1000;
    my $amplitude = 15000;
    my  $file_size = $duration * $sample_rate * $num_channels * ($bits_per_sample / 8);

    my $header = Waveheader($file_size, $num_channels, $sample_rate,  $bits_per_sample);
#     my $wave = ();
#     for  (my $i = 0; $i < $duration * $sample_rate; $i++){
#     my $wave_value = $amplitude * sin(2 * pi * $frequency * ($i / $sample_rate));
#     for  (my $j = 0; $j < $num_channels; $j++){
#         $wave .= pack("s<", int($wave_value));
#         }
# }

sub getWavDuration {
    my ($text) =  @_;
    my $total_duration = 0;

    if (!is_morsable($text)){
        print "Can't translate  $text to morse code\n";
        die;
    }

    my  $morse_code = as_morse($text);
    print  "Morse code: $morse_code\n";

    for  (my $i = 0; $i < length($morse_code); $i++){
        my $char = substr($morse_code,  $i, 1);
        if ($char eq "."){
            $total_duration += $dotDuration + $silenceDuration;
        } elsif ($char eq "-"){
            $total_duration += $dashDuration + $silenceDuration;
        } elsif($char eq " ") {
            $total_duration +=  $silenceDuration;

        }
        else {
            print "Error";
        }
}
return $total_duration;
}

sub createMorse {
    my ($text) =  @_;

    if (!is_morsable($text)){
        print "Can't translate  $text to morse code\n";
        die;
    }
    my  $morse_code = as_morse($text);
    my $morse = "";

    for(my  $i = 0; $i < length($morse_code); $i++){
        my  $char = substr($morse_code, $i, 1);
        if ($char eq "."){
            $morse .= dot_sound();
        } elsif ($char eq "-"){
            $morse .=  dash_sound();
        } elsif($char eq " ") {
            $morse .= no_sound();
            $morse .= no_sound();
        }
        else {
            print "Error: $char/n";
        }
        $morse .= no_sound();

    }
    return $morse;

}


sub dot_sound {
    my $wave = ();
    for  (my $i = 0; $i < $dotDuration * $sample_rate; $i++){
    my $wave_value = $amplitude * sin(2 * pi * $frequency * ($i / $sample_rate));
    for  (my $j = 0; $j < $num_channels; $j++){
        $wave .= pack("s<", $wave_value);
        }
}
return $wave;
}

sub dash_sound {
    my $wave = ();
    for  (my $i = 0; $i < $dashDuration * $sample_rate; $i++){
    my $wave_value = $amplitude * sin(2 * pi * $frequency * ($i / $sample_rate));
    for  (my $j = 0; $j < $num_channels; $j++){
        $wave .= pack("s<", $wave_value);
        }
}
return $wave;
}

sub no_sound {
    my $no_frequency = 0;
    my $wave = ();
    for  (my $i = 0; $i < $silenceDuration * $sample_rate; $i++){
    # my $wave_value = $amplitude * sin(2 * pi * $frequency * ($i / $sample_rate));
    for  (my $j = 0; $j < $num_channels; $j++){
        $wave .= pack("s<", 0);
        }
}
return $wave;
}

my $morse_data = createMorse($text);
# print $morse_data;
open(OUT, ">:raw", "output.wav")  or die "Can't open output.wav: $!";
# binmode(OUT);
# $header .=  $wave;

print OUT $header;
print OUT $morse_data;
close  OUT;

print "write succeed";




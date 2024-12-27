#!perl -w

# SINC Perl - String into Morse WAV
# Autor: P. Geisthardt, SINC GmbH, paul dot geisthardt at sinc dot de
# Version: 1.0
# Letzte Modifikation: 20.08.2024

use strict;
use warnings qw( all );
use MIME::Base64;
use Convert::Morse qw(as_ascii as_morse is_morsable);


our $dotDuration = 0.1;  # duration of the dot sound
our $dashDuration = 0.3; # duration of the dash sound
our $silenceDuration = 0.1; # duration of the silence between two characters and between two words
my $morse_string = "Paul ist voll cool! :)"; # string to translate into morse
my $NumberOfChannels = 2;  # 1 = mono, 2 = Stereo
my $samplesPerSecond = 44100; # 44.1 kHz
my $bitsPerSample = 16; # 16 = 16-bit
my $duration = getWavDuration($morse_string); # duration in seconds needed for morse string
my $amplitude = 2**($bitsPerSample-1) - 5000; # 2^bitsPerSample - 1 and - 5000 so doesnt give as much ear cancer
my $frequency = 441; # 441 hz
my $file_size = ($samplesPerSecond * $duration * $NumberOfChannels * $bitsPerSample)/8; # file size in bytes
my $characterPerMinute = 120; # not used atm
#print($file_size);

sub getWavDuration { #calculates time needed for morse string
    my ($morse_string) = @_;    # morse string to calculate duration for
    my $total_duration = 0;     # define duration


    if (!is_morsable($morse_string)){    # check if morse string is morsable else die 
    print("Cant translate some of ur characters into morse");
    die;
    }

    my $string_to_morse =  as_morse($morse_string); # convert string to morse

    for (my $i = 0; $i < length($string_to_morse); $i++) { # loop through morse string and add duration needed
        my $char = substr($string_to_morse, $i, 1);
        if ($char eq ".") {
            $total_duration += $dotDuration + $silenceDuration;
        } elsif ($char eq "-") {
            $total_duration += $dashDuration + $silenceDuration;
        } elsif ($char eq " ") {
            $total_duration += $silenceDuration;
        }
        else {
            print("Error: ", $char, "\n");
        }

        #print($total_duration, "\n");
    }

    return $total_duration; # return duration
}



sub Waveheader { #creates wav header
    my ($file_size, $NumberOfChannels, $samplesPerSecond, $bitsPerSample) = @_;  # parameters for wav header
    my $binary_header = '';  # define empty string for binary header data

    my $riff = "RIFF"; #bytes 1-4
    my $chunkSize = $file_size - 8; #filesize - 8 bytes; bytes 5-8
    my $wave = "WAVE"; #bytes 9-12
    my $fmt = "fmt "; # bytes 13-16
    my $subChunkSize = 16; #bytes 17-20
    my $format = 1; #type of format 1 = PCM, bytes 21-22
    #my $NumberOfChannels = 2; # 1 = mono, 2 = Stereo, bytes 23-24
    #my $samplesPerSecond = 44100; # 44.1 kHz, bytes 25-28
    my $bytesPerSecond = ($samplesPerSecond * $bitsPerSample * $NumberOfChannels) / 8; # bytes 29-32 
    my $sampleDepth = ($bitsPerSample*$NumberOfChannels)/8; #bytes 33-34
    #my $bitsPerSample = 16; # 16 = 16-bit, bytes 35-36
    my $data = "data"; # bytes 37-40
    my $chunkSizev2 = $file_size - 44;# filesize - 44 bytes # bytes 41-44

    $binary_header = #add data to binary header and pack them if needed
          $riff 
        . pack("L<", $chunkSize) 
        . $wave 
        . $fmt
        . pack("L<", $subChunkSize) 
        . pack("s<", $format) 
        . pack("s<", $NumberOfChannels) 
        . pack("L<", $samplesPerSecond) 
        . pack("L<", $bytesPerSecond) 
        . pack("s<", $sampleDepth) 
        . pack("s<", $bitsPerSample) 
        . $data 
        . pack("L<", $chunkSizev2);

    return $binary_header; # return binary header
}


sub createMorse { #creates binary data for wav file from morse
    my ($morse_string) = @_;

    if (!is_morsable($morse_string)){    # check if morse string is morsable else die
    print("Cant translate some of ur characters into morse");
    die;
    }

    my $string_to_morse =  as_morse($morse_string); # convert string to morse
    print($string_to_morse);

    my $morse = ''; # define empty string for morse data
    
    for (my $i = 0; $i < length($string_to_morse); $i++) { # loop through morse string and add binary data of dot sound, dash sound and the silence inbetween
    my $char = substr($string_to_morse, $i, 1);
    if ($char eq ".") {
        $morse .= dot_sound();
    }
    elsif ($char eq "-") {
        $morse .= dash_sound();
    }
    elsif ($char eq " ") {
        $morse .= no_sound();
    }
    $morse .= no_sound();
    }

    return $morse; # return morse
}

sub dot_sound { #creates binary data for dot sound
    my $amplitude = 2**($bitsPerSample-1) - 5000;
    my $frequency = 440;

    my $tone = '';

    for (my $i = 0; $i < $samplesPerSecond * $dotDuration; $i++) {
        my $sample = $amplitude * sin(2 * 3.14 * $frequency * $i / $samplesPerSecond);
        #print($i, " ",$amplitude, " ", $sample, "\n");
        for (my $j = 0; $j < $NumberOfChannels; $j++) {
            $tone .= pack("s<", $sample);
            #$tone .= pack("s<", no_sound());
        }
    }

    return $tone;
}

sub dash_sound { #creates binary data for dash sound
    my $amplitude = 2**($bitsPerSample-1) - 5000;
    my $frequency = 440;
    my $duration = 0.5;

    my $tone = '';

    for (my $i = 0; $i < $samplesPerSecond * $dashDuration; $i++) {
        my $sample = $amplitude * sin(2 * 3.14 * $frequency * $i / $samplesPerSecond);
        #print($i, " ",$amplitude, " ", $sample, "\n");
        for (my $j = 0; $j < $NumberOfChannels; $j++) {
            $tone .= pack("s<", $sample);
            #$tone .= pack("s<", no_sound());
        }
    }

    return $tone;
}

sub no_sound { #creates binary data for silence
    my $duration = 0.2;
    my $amplitude = 2**($bitsPerSample-1) - 5000;
    my $frequency = 0;

    my $tone = '';

    for (my $i = 0; $i < $samplesPerSecond * $silenceDuration; $i++) {
        #my $sample = $amplitude * sin(2 * 3.14 * $frequency * $i / $samplesPerSecond);
        #print($i, " ",$amplitude, " ", $sample, "\n");
        for (my $j = 0; $j < $NumberOfChannels; $j++) {
            $tone .= pack("s<", 0);
        }
    }

    return $tone 
}


my $header = Waveheader($file_size, $NumberOfChannels, $samplesPerSecond, $bitsPerSample, $duration); # create wav header binary




my $morse = createMorse($morse_string); # create morse binary
# print ($morse);







my $output_file = "morse.wav"; # name output file

open (OUT, '>', $output_file) or die "Could not open file '$output_file' $!"; # create output file
binmode(OUT); # set binary mode
print OUT $header; # print header
print OUT $morse; # print morse

close(OUT); # close output file
#!/usr/bin/perl -w

# SINC Perl - WAV File create
# Autor: P. Geisthardt, SINC GmbH, paul dot geisthardt at sinc dot de
# Version: 1.0
# Letzte Modifikation: 20.08.2024

use strict;
use warnings qw( all );
use MIME::Base64;

sub Waveheader {
    my ($file_size, $NumberOfChannels, $samplesPerSecond, $bitsPerSample) = @_;
    my $binary_header = '';

    my $riff = "RIFF"; #bytes 1-4
    my $chunkSize = $file_size - 8; #filesize - 8 bytes; bytes 5-8
    my $wave = "WAVE"; #bytes 9-12
    my $fmt = "fmt "; # bytes 13-16
    my $subChunkSize = 16; #bytes 17-20
    my $format = 1; #type of format 1 = PCM, bytes 21-22
    my $bytesPerSecond = ($samplesPerSecond * $bitsPerSample * $NumberOfChannels) / 8; # bytes 29-32 
    my $sampleDepth = ($bitsPerSample*$NumberOfChannels)/8; #bytes 33-34

    my $data = "data"; # bytes 37-40
    my $chunkSizev2 = $file_size - 44;# filesize - 44 bytes # bytes 41-44

    $binary_header = 
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

    return $binary_header;
}

my $NumberOfChannels = 2;
my $samplesPerSecond = 44100;
my $bitsPerSample = 16;
my $duration = 3;
my $amplitude = 2**($bitsPerSample-1) - 5000;
my $frequency = 441;
my $file_size = ($samplesPerSecond * $duration * $NumberOfChannels * $bitsPerSample)/8;

my $header = Waveheader($file_size, $NumberOfChannels, $samplesPerSecond, $bitsPerSample);

my $wave = '';
for (my $i = 0; $i < $samplesPerSecond * $duration; $i++) {
    my $sample = $amplitude * sin(2 * 3.14 * $frequency * $i / $samplesPerSecond);
    for (my $j = 0; $j < $NumberOfChannels; $j++) {
        $wave .= pack("s<", $sample);
    }
}

my $output_file = "header.wav";

open (OUT, '>', $output_file) or die "Could not open file '$output_file' $!";
binmode(OUT);
print OUT $header;
print OUT $wave;

close(OUT);
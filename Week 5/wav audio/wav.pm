package Wav;

use strict;
use warnings;


sub new {
    my $class = shift;
    my %args = @_;
    my $self = {
        _sample_rate     => $args{sample_rate} // 44100,
        _bits_per_sample => $args{bits_per_sample} // 16,
        _channels        => $args{channels} // 1,
        _length          => $args{length} // 0,
        _frequency       => $args{frequency} // 440,
        _amplitude       => $args{amplitude} // 32767,
    };
    bless $self, $class;
    return $self;
}

sub data {
    my ($self, $start_frequency, $end_frequency, $amplitude, $duration) = @_;
    $start_frequency //= $self->{_frequency};
    $end_frequency //= $self->{_frequency};  # Default to no pitch change
    $amplitude //= $self->{_amplitude};
    $duration //= 1;  # Default duration of 1 second

    my $sample_rate = $self->{_sample_rate};
    my $num_samples = int($sample_rate * $duration);
    my $wave = '';

    for (my $i = 0; $i < $num_samples; $i++) {
        # Calculate the current frequency based on a linear interpolation
        my $current_frequency = $start_frequency + (($end_frequency - $start_frequency) * ($i / $num_samples));
        
        # Calculate the wave value with the current frequency
        my $wave_value = $amplitude * sin(2 * 3.14 * $current_frequency * ($i / $sample_rate));
        $wave .= pack("s<", int($wave_value));
    }

    return $wave;
}


sub header {
    my $self = shift;
    my $chunk_id = 'RIFF';
    my $format = 'WAVE';
    my $subchunk1_id = 'fmt ';
    my $subchunk1_size = 16;
    my $audio_format = 1;
    my $num_channels = $self->{_channels};
    my $sample_rate = $self->{_sample_rate};
    my $byte_rate = $sample_rate * $num_channels * ($self->{_bits_per_sample} / 8);
    my $block_align = $num_channels * ($self->{_bits_per_sample} / 8);
    my $bits_per_sample = $self->{_bits_per_sample};
    my $subchunk2_id = 'data';
    my $subchunk2_size = 0;  # Placeholder, to be updated later

    my $header = pack('a4 L a4 a4 L S S L L S S a4 L', 
        $chunk_id,
        36 + $subchunk2_size,  # Placeholder chunk size
        $format,
        $subchunk1_id,
        $subchunk1_size,
        $audio_format,
        $num_channels,
        $sample_rate,
        $byte_rate,
        $block_align,
        $bits_per_sample,
        $subchunk2_id,
        $subchunk2_size
    );

    return $header;
}

1;  # End of Wav package

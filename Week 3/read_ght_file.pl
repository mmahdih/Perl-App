use strict;
use warnings;
use GD;

my $hgt_file = 'N50E008.hgt';

my $grid_size = 1201; 

open(my $fh, '<:raw', $hgt_file) or die "Cannot open $hgt_file: $!";

my $buffer;
read($fh, $buffer, 2 * $grid_size * $grid_size) or die "Error reading $hgt_file: $!";

close($fh);

my @elevation_data = unpack("s*", $buffer);

my $min_elevation = (sort { $a <=> $b } @elevation_data)[0];
my $max_elevation = (sort { $a <=> $b } @elevation_data)[-1];
$min_elevation = 0 if not defined $min_elevation;  

print($min_elevation);
print("\n");
print($max_elevation);
print("\n");

my $image = GD::Image->new($grid_size, $grid_size);

my $white = $image->colorAllocate(255, 255, 255);
my $black = $image->colorAllocate(0, 0, 0);
my $color_map = {};
for my $i (0 .. 255) {
    $color_map->{$i} = $image->colorAllocate($i, $i, $i); 
    print($color_map->{$i});
    print($image);
    print("\n")
}

for my $y (0 .. $grid_size - 1) {
    for my $x (0 .. $grid_size - 1) {
        my $elevation = $elevation_data[$y * $grid_size + $x];
        my $normalized = int(255 * ($elevation - $min_elevation) / ($max_elevation - $min_elevation));
        $normalized = 0 if $normalized < 0;
        $normalized = 255 if $normalized > 255;
        $image->setPixel($x, $y, $color_map->{$normalized});
    }
}

open my $out, '>', 'elevation_map.png' or die "Cannot open file: $!";
binmode $out;
print $out $image->png;
close $out;

print "Grayscale elevation map created successfully.\n";

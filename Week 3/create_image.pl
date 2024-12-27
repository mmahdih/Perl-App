use GD;

my $grid_size = 256;  # Assuming a grid size
my $image = GD::Image->new($grid_size, $grid_size);

my $white = $image->colorAllocate(255, 255, 255);
my $black = $image->colorAllocate(0, 0, 0);
my $color_map = {};

for my $i (0 .. 255) {
    $color_map->{$i} = $image->colorAllocate($i, $i, $i); 
    print "Color index for grayscale value $i: $color_map->{$i}\n";
}

# Example to output the image to a file
open my $out, '>', 'image.png' or die "Cannot open output file: $!";
binmode $out;
print $out $image->png;
close $out;

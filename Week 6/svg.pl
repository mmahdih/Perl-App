#!/usr/bin/perl
use strict;
use warnings;
use SVG;

my $svg = SVG->new(width => 400, height => 400);

$svg->circle(
    cx => 150,
    cy => 150,
    r  => 100,
    style => {
        fill => 'yellow',
        stroke => 'black',
        'stroke-width' => 3,
    }
);

$svg->circle(
    cx => 110,
    cy => 120,
    r  => 30,
    style => {
        fill => 'white',
        stroke => 'black',
        'stroke-width' => 3,
    }
);

$svg->circle(
    cx => 190,
    cy => 120,
    r  => 30,
    style => {
        fill => 'white',
        stroke => 'black',
        'stroke-width' => 3,
    }
);

$svg->circle(
    cx => 90,
    cy => 120,
    r  => 10,
    style => {
        fill => 'black',
    }
);

$svg->circle(
    cx => 170,
    cy => 120,
    r  => 10,
    style => {
        fill => 'black',
    }
);

$svg->polygon(
    points => "150,130 130,180 170,180",
    style => {
        fill => 'orange',
        stroke => 'black',
        'stroke-width' => 3,
    }
);

$svg->path(
    d => "M 100,190 Q 150,250 200,190",
    style => {
        fill => 'transparent',
        stroke => 'black',
        'stroke-width' => 5,
    }
);

$svg->ellipse(
    cx => 150,
    cy => 230,
    rx => 25,
    ry => 10,
    style => {
        fill => 'red',
        stroke => 'black',
        'stroke-width' => 3,
    }
);

$svg->polygon(
    points => "80,50 220,50 180,10 120,10",
    style => {
        fill => 'blue',
        stroke => 'black',
        'stroke-width' => 3,
    }
);

my $output = "funny_face.svg";
open(my $fh, '>', $output) or die "Cannot open $output: $!";
print $fh $svg->xmlify(-namespace => 'svg');
close($fh);

print "SVG file 'funny_face.svg' created successfully.\n";

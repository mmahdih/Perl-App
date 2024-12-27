use strict;
use warnings;

use Tk;
use FindBin qw($Bin);
use Tk::PNG;

# Create the main window
my $mainwindow = MainWindow->new();
$mainwindow->geometry("700x500");
$mainwindow->title("Tk Learn");

# Initial label text
my $label_text = "Add Numbers first!";

# Variables to hold the input text
my $input_text_1 = '';
my $input_text_2 = '';

# Create a menu bar frame
my $menubar = $mainwindow->Frame()->pack(
    -side => 'top',
    -fill => 'x',
    -pady => 5
);

# Create a File menu button in the menu bar
my $filemenu = $menubar->Menubutton(
    -text   => 'File',
    -tearoff => 0
)->pack(
    -side => 'left'
);

# Load an image file (make sure 'angry.jpg' is in your working directory)
my $image_file = "$Bin/angry.png";
my $photo = $mainwindow->Photo(-file => $image_file);

# Create a menu for the File menu button
my $file_menu = $filemenu->Menu(-tearoff => 0);
$filemenu->configure(-menu => $file_menu);

# Create left and right frames
my $left = $mainwindow->Frame(
    -borderwidth => 2,
    -relief      => 'solid'
)->pack(
    -side => 'left',
    -fill => 'both',
    -expand => 1,
    -padx  => 10,
    -pady  => 10
);

my $right = $mainwindow->Frame(
    -borderwidth => 2,
    -relief      => 'solid'
)->pack(
    -side => 'right',
    -fill => 'both',
    -expand => 1,
    -padx  => 10,
    -pady  => 10
);

# Create a label in the right frame
my $label = $right->Label(
    -text => $label_text,
    -font => "Helvetica 16 bold"
)->pack(
    -expand => 1,
    -fill   => 'both',
    -padx   => 20,
    -pady   => 20
);

# Create an image label in the right frame
my $image_label = $right->Label(
    
)->pack(
    -expand => 1,
    -fill   => 'both',
    -padx   => 20,
    -pady   => 20,
);

# Create Entry widgets for input in the left frame
$left->Entry(
    -textvariable => \$input_text_1,
    -font         => "Helvetica 16"
)->pack(
    -fill   => 'both',
    -padx   => 20,
    -pady   => 10
);

$left->Entry(
    -textvariable => \$input_text_2,
    -font         => "Helvetica 16"
)->pack(
    -fill   => 'both',
    -padx   => 20,
    -pady   => 10
);

# Create a button in the left frame
$left->Button(
    -text => "Calculate",
    -command => sub {
        # Get the input values and convert to numbers
        my $input1 = $input_text_1 + 0;  # Convert to number, default to 0 if empty
        my $input2 = $input_text_2 + 0;  # Convert to number, default to 0 if empty
        
        # Perform the calculation
        if ($input1 && $input2) {
            my $result = $input1 + $input2;
            # Update the label with the result
            $label->configure(-text => "Result: $result");
        } else {
            $label->configure(-text => "One or more fields are empty. \n I said add numbers first");
            $image_label->configure(-image => $photo)
        }
    }
)->pack(
    -fill   => 'both',
    -padx   => 20,
    -pady   => 10
);

# Add items to the File menu
$file_menu->add(
    'command',
    -label   => 'New',
    -command => sub { 
        $label->configure(-text => "Add Numbers first!");
        $input_text_1 = '';
        $input_text_2 = '';
        $image_label->configure(-image => "")
    }
);

$file_menu->add(
    'command',
    -label   => 'Open',
    -command => sub { 
        $label->configure(-text => "Open file");
    }
);

# Start the main loop
MainLoop;

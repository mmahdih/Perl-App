use strict;
use warnings;

use Tk;

# Create the main window
my $mainwindow = MainWindow->new();
$mainwindow->geometry("400x300"); # Set size for the main window
$mainwindow->title("Tk::Dialog");
$mainwindow->protocol('WM_DELETE_WINDOW', sub { $mainwindow->destroy(); });

# Create a menu bar frame
my $menubar = $mainwindow->Frame()->pack(-side => 'top', -fill => 'x', -pady => 5);

# Create a File menu button in the menu bar
my $filemenu = $menubar->Menubutton(-text => 'File', -tearoff => 0)->pack(-side => 'left');

# Add items to the File menu
$filemenu->command(
    -label   => 'Configuration...',
    -command => \&doConfig
);

$filemenu->command(
    -label   => 'Save Config',
    -command => \&saveConfig
);

$filemenu->command(
    -label   => 'Open Config',
    -command => \&loadConfig
);

$filemenu->command(
    -label   => 'New',
    -command => sub { print "New selected\n"; }
);

$filemenu->command(
    -label   => 'Open',
    -command => sub { print "Open selected\n"; }
);

$filemenu->command(
    -label   => 'Exit',
    -command => sub { $mainwindow->destroy(); }
);

$filemenu->command(
    -label   => 'Sign Up',
    -command => sub { print "User signed up\n"; }
);

# Create a Help menu button in the menu bar
my $helpmenu = $menubar->Menubutton(-text => 'Help', -tearoff => 0)->pack(-side => 'left');
$helpmenu->command(
    -label   => 'About',
    -command => sub { print "About selected\n"; }
);

# Create frames with borders and packing options
my $left = $mainwindow->Frame(
    -borderwidth => 2,
    -relief      => 'solid'
)->pack(-side => 'left', -fill => 'y', -expand => 0);

my $right = $mainwindow->Frame(
    -borderwidth => 2,
    -relief      => 'solid'
)->pack(-side => 'right', -fill => 'y', -expand => 0);

my $bottom = $mainwindow->Frame(
    -borderwidth => 2,
    -relief      => 'solid'
)->pack(-side => 'bottom', -fill => 'x', -expand => 0);

# Create a label in the left frame
my $label = $left->Label(
    -text => "Initial text",
    -font => 'Helvetica 12 bold'
)->pack(-pady => 10);

# Define a subroutine to update the label text
sub update_label_text {
    my ($text) = @_;
    $label->configure(-text => $text);
}

# Add buttons to update the label text
$left->Button(
    -text    => "Button 1",
    -command => sub { 
        $label->configure(-text => "hello world!");
     }
)->pack(-pady => 5);

$left->Button(
    -text    => "Button 2",
    -command => sub { update_label_text("Button 2 clicked"); }
)->pack(-pady => 5);

# Add widgets to the right frame
$right->Label(-text => "Right Frame")->pack(-pady => 10);
$right->Button(-text => "Button 3")->pack(-pady => 5);
$right->Button(-text => "Button 4")->pack(-pady => 5);

# Add widgets to the bottom frame
$bottom->Label(-text => "Bottom Frame")->pack(-pady => 10);
$bottom->Button(-text => "Submit")->pack(-pady => 5);

# Define the callback subroutines (as placeholders)
sub doConfig {
    print "Configuration selected\n";
}

sub saveConfig {
    print "Save Config selected\n";
}

sub loadConfig {
    print "Open Config selected\n";
}

# Start the main loop
MainLoop;

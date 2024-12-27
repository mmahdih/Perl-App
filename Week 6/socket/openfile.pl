#!usr/bin/perl
use warnings;
use strict;

use Tk;

my $mw = MainWindow->new;
$mw->geometry("1000x400+0+0");

my $menu_f = $mw->Frame()->pack(-side=>'top',-fill=>'x');
my $menu_file = $menu_f->Menubutton
                    (-text=>'File',-tearoff=>'false')
                    ->pack(-side=>'left');
                    
$menu_file->command(-label=>'Open',
            -command=> \&open_log); 
$menu_file->command(-label=>'Save',
            -command=> sub {print "in Save\n";}); 
$menu_file->command(-label=>'Close',
            -command=> sub {print "in Close\n";});             
$menu_file->command(-label=>'Exit',-command=>\&exit_msg);

sub open_log {
  
  my @types =
       (["log files", [qw/ .log/]],
        ["All files",        '*'],
       );
  my $file = $mw->getOpenFile(-filetypes => \@types) or return;
  print "$file\n";
  
  ########
  ###  call worker program here
  ##########
}

sub exit_msg{
  my $response = $mw->messageBox( -title => "some title",
      -message => "Do you really want to exit?\nAll unsaved work will 
+be lost!\n\n", 
  -type => 'YesNoCancel');
  print "exit_msg response = $response\n";
  exit() if ($response =~ /^yes$/i); 
}
MainLoop;
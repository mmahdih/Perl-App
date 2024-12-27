use strict;
use warnings;


my $x = 10;
# print "x befor: $x\n";

my $xr = \$x;
$$xr = 20;

# print "xr: $$xr\n";
# print "x: $x\n";



# my @a = (1..5);
# my $ar = \@a;

# my $i = 0;
# for(@$ar){
#     print("$ar->[$i++] \n");
#  }


 my %months = (
    Jan => 1,
    Feb => 2,
    Mar => 3,
    Apr => 4,
    May => 5,
    Jun => 6,
    Jul => 7,
    Aug => 8,
    Sep => 9,
    Oct => 10,
    Nov => 11,
    Dec => 12,
    
 );

# print $months{May};

# Reverse the hash to use values as keys
my %reverse_months = reverse %months;

# for(my  $i = 1; $i <= scalar(keys %reverse_months); $i++){
#    print "$reverse_months{$i}\n";
#    }



sub say_hello{
   print "Hello, World!\n";
}

my $subref = \&say_hello;

# &$subref;


my @ordered_keys = qw(Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov  Dec);
# for(@ordered_keys){
# print("$_ = $months{$_}\n");
# }




# my $monthr = \%months;

# for(keys %$monthr){
# print("$_  = $monthr->{$_}\n");
# }





my @nums = (1..5);

sub sum{
   my $total = 0;
   for my $i(@nums){
      $total += $i;
   }
   return $total;
}

# print &sum(1..3), "\n";




sub say_hi{
   my $name = "Bob";
   # print "Hi $name \n";
   $name;
}


print &say_hi, "\n"; 




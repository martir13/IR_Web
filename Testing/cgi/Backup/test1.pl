#!/usr/local/bin/perl
BEGIN {
my $base_module_dir = (-d ‘/home/dayton20/perl’ ? ‘/home/dayton20/perl’ : ( getpwuid($>) )[7] . ‘/perl/’);
unshift @INC, map { $base_module_dir . $_ } @INC;
}
use strict;
print “Content-type: text/html\n\n”;
print “This script is working!”;

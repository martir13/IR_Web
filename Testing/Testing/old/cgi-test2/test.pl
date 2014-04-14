BEGIN {
    my $b__dir = (-d '/home2/dayton20/perl'?'/home2/dayton20/perl':( getpwuid($>) )[7].'/perl');
    unshift @INC,$b__dir.'5/lib/perl5',$b__dir.'5/lib/perl5/x86_64-linux-thread-multi',map { $b__dir . $_ } @INC;
}
print "content-type:text/html\n\n";
print "<html>\n";
print "<head />\n";
print "<body>\n";
print "Hello World!\n";
print "</body>\n";
print "</html>\n";
#
#!/usr/local/bin/perl
use strict;
use warnings;

print "Content-type: text/plain\n\n";
print "You are calling from $ENV{REMOTE_HOST}\n";
# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

######################### We start with some black magic to print on failure.

# Change 1..1 below to 1..last_test_to_print .
# (It may become useful if the test is moved to ./t subdirectory.)

BEGIN { $| = 1; print "1..2\n"; }
END {print "not ok 1\n" unless $main::loaded;}

use HPUX::Ioscan ;
$loaded = 1;

use strict ;

use Config;

my $idx = 1;
print "ok ",$idx++,"\n";

if ($Config{osname} ne 'hpux')
  {
    # skip test
    print "ok ",$idx++," skipped on non hpux system\n";
  }
elsif (not -w '/dev/config')
  {
    print "ok ",$idx++," skipped for non root user\n";
  }
else
  {
    print "Please wait\n";
    my $result = ioscan ();

    print "not " unless defined $result ;
    print "ok ",$idx++,"\n";
  }



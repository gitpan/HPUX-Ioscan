# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

######################### We start with some black magic to print on failure.

# Change 1..1 below to 1..last_test_to_print .
# (It may become useful if the test is moved to ./t subdirectory.)

BEGIN { $| = 1; print "1..7\n"; }
END {print "not ok 1\n" unless $main::loaded;}

use HPUX::Ioscan ;
$loaded = 1;

my $idx = 1;
print "ok ",$idx++,"\n";

use strict ;

my @scan=<DATA>;
chomp @scan ;

$HPUX::Ioscan::test = \@scan;


print "ok ",$idx++,"\n";

my $result = ioscan ();

print "not " unless defined $result ;
print "ok ",$idx++,"\n";

# check nb of result
print "not " unless scalar keys %$result == 3 ;
print "ok ",$idx++,"\n";

# check nb of device files
print "not " unless scalar @{$result->{'0/0/2/1.6.0'}{device_files}} == 2 ;
print "ok ",$idx++,"\n";

# check device file names

print "not " unless scalar $result->{'0/0/2/1.6.0'}{device_files}[0] eq 
  '/dev/dsk/c2t6d0' ;
print "ok ",$idx++,"\n";

print "not " unless scalar $result->{'0/0/2/0.6.0'}{device_files}[1] eq 
  '/dev/rdsk/c1t6d0' ;
print "ok ",$idx++,"\n";

#use Data::Dumper;
#print Dumper($result) ;



__DATA__
:central_bus:F:F:F:-1:-1:4294967295:root:root:::0:root:root:CLAIMED:BUS_NEXUS::0
scsi:wsio:T:T:F:31:188:90112:disk:sdisk:0/0/2/0.6.0:0 0 2 18 0 0 0 0 95 227 197 138 1 70 210 192 :0:root.sba.lba.c720.tgt.sdisk:sdisk:CLAIMED:DEVICE:SEAGATE ST318203LC:1
                             /dev/dsk/c1t6d0   /dev/rdsk/c1t6d0
scsi:wsio:T:T:F:31:188:155648:disk:sdisk:0/0/2/1.6.0:0 0 2 18 0 0 0 0 95 227 197 138 127 87 40 32 :1:root.sba.lba.c720.tgt.sdisk:sdisk:CLAIMED:DEVICE:SEAGATE ST318203LC:2
                             /dev/dsk/c2t6d0   /dev/rdsk/c2t6d0

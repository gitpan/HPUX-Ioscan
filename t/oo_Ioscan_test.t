# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

######################### We start with some black magic to print on failure.

# Change 1..1 below to 1..last_test_to_print .
# (It may become useful if the test is moved to ./t subdirectory.)

BEGIN { $| = 1; print "1..6\n"; }
END {print "not ok 1\n" unless $main::loaded;}

use HPUX::Ioscan;
$loaded = 1;

my $idx = 1;
print "ok ",$idx++,"\n";

$attr1="";
$attr2="";
$attr3="";
$attr4="";
$attr5="";
$attr6="";

# Create data structures

my $ioscan_data = new HPUX::Ioscan(
				persistance	=>"old",
				datafile	=>"./t/ioscan_info.dat",
				);

print "ok ",$idx++,"\n";
#print "\n\nTesting Ioscan.pm\n\n" if $debug;

# testing Ioscan.pm

$arref = $ioscan_data->get_disk_controllers();
  foreach $controller ( @$arref )	{
#		print"Controller: $controller\n";
		$controller_save = $controller;
					}
print "ok ",$idx++,"\n";

$attr1 = $ioscan_data->get_description(
			controller	=> "$controller_save"
					);
$attr2 = $ioscan_data->get_block_major_number(
			controller	=> "$controller_save"
					);
$attr3 = $ioscan_data->get_cdio(
			controller	=> "$controller_save"
					);
$attr4 = $ioscan_data->get_driver(
			controller	=> "$controller_save"
					);
$attr5 = $ioscan_data->get_instance_number(
			controller	=> "$controller_save"
					);
$attr6 = $ioscan_data->get_module_name(
			controller	=> "$controller_save"
					);
print "ok ",$idx++,"\n";

$alldisks = $ioscan_data->get_all_disks_on_controller(
				controller	=> $controller_save
							);
print "ok ",$idx++,"\n";
$disk="";
foreach $disk (@$alldisks)	{
#	print "Disk: $disk\n";
				}
print "ok ",$idx++,"\n";

package HPUX::Ioscan;

use 5.006;
use strict;
#use warnings;

require Exporter;
use AutoLoader qw(AUTOLOAD);

our @ISA = qw(Exporter);

# Items to export into callers namespace by default. Note: do not export
# names by default without a very good reason. Use EXPORT_OK instead.
# Do not simply export all your public functions/methods/constants.

# This allows declaration	use HPUX::Ioscan ':all';
# If you do not need this, moving things directly into @EXPORT or @EXPORT_OK
# will save memory.
our %EXPORT_TAGS = ( 'all' => [ qw(
	
) ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = qw(ioscan
	
);
our $VERSION = '1.09_01';

# Preloaded methods go here.

# Autoload methods go after =cut, and are processed by the autosplit program.


## start


use FileHandle ;
use Carp ;
use vars qw/@ISA @EXPORT $test $VERSION $AUTOLOAD/;
use Storable;

my @list = 
  qw/bus_type
  cdio
  is_block
  is_char
  is_pseudo
  block_major_number
  character_major_number
  minor_number
  class
  driver
  hardware_path
  identify_bytes
  instance_number
  module_path
  module_name
  software_state
  hardware_type 
  description
  card_instance/;

my $cache ;

sub ioscan
  {
    my %args = @_ ;
    my $tmp_path ;
    my $force = $args{force} || 0;

    if (not defined $cache or $force)
      {
        my @scan ;
        if (defined $test)
          {
            @scan = @$test ;
          }
        else
          {
            my $fh = new FileHandle;
            $fh->open ('ioscan -nF |')
              or croak "can't open ioscan pipe $!\n";
            @scan = <$fh>;
            $fh->close;
            die "Ioscan error: $!\n" if $! ;
          }

        foreach my $line (@scan)
          {
#print $line ,"\n";
            if ($line =~ s/^\s+//)
              {
# file line
                push @{$cache->{$tmp_path}{device_files}}, split /\s+/,$line ;
              }
            else
              {
#device line
                my @fields = split(':',$line) ;
#print "nb field ", scalar @fields, " nb list ", scalar @list, "\n";
                my $i=0;
                my %tmp ;
                while (defined $list[$i])
                  {
#print "$i: $list[$i],  $fields[$i]\n";
                    $tmp{$list[$i++]} = $fields[$i] ;
                  }

                $tmp_path = $tmp{hardware_path} ;
                $cache->{$tmp_path} = \%tmp ;
              }
          }
      }

    return $cache->{hardware_path} if defined $args{hardware_path};

    return $cache ;
  }

sub new
  {
    my $debug=0;
    my $debug2=0;

    my ($class, @subargs) = @_ ;

    my %arglist  =      (
        target_type     => "local"      ,
        persistance     => "new"        ,
        datafile        => "/tmp/ioscan.dat"        ,
        access_prog     => "ssh"        ,
        access_system   => "localhost"  ,
        access_user     => "root"       ,
        extended_disk_info     => "yes"       ,
        remote_command1 => '/usr/sbin/ioscan -Fn',
        remote_command2 => '/etc/diskinfo ',
        @subargs,
                        );

        if ($debug)     {
         print "target_type  : $arglist{target_type}\n";
         print "persistance  : $arglist{persistance}\n";
         print "datafile     : $arglist{datafile}\n";
         print "access_prog  : $arglist{access_prog}\n";
         print "access_system: $arglist{access_system}\n";
         print "access_user  : $arglist{access_user}\n";
         print "remote_command1: $arglist{remote_command1}\n";
         print "remote_command1: $arglist{remote_command2}\n";
                        }

    my $source_access  =$arglist{target_type};
    my $new_or_saved   =$arglist{persistance};
    my $datafile       =$arglist{datafile};
    my $remote_access  =$arglist{access_prog};
    my $remote_system  =$arglist{access_system};
    my $remote_user    =$arglist{access_user};
    my $remote_command =$arglist{remote_command1};
    my $remote_command2 =$arglist{remote_command2};

    my $line;
    my $ioscan_hashref;
    my @ioscan_out;
    my %ioscan_info;
    my $ioscan_info;
    my $ioscan_object_ref = \%ioscan_info;

        print "I'm :".ref($ioscan_object_ref)."\n" if $debug;

    my @ioscan_split;
    my $tmp_path ;
#added the following to support diskinfo
    my @extended_disk_array;
    my $rawpvname;
    my %rdiskhash;
    my $line;
    my @splitit;
    my @device_file_check_raw;
    my $device_file_check_raw;
    my $line_outter;
    my $debug8=0;

        print "I'm in class: $class\n" if $debug;
	print "Command: $remote_access $remote_system -l $remote_user -n $remote_command\n" if $debug;

	if ( $new_or_saved eq "old" )	{
		print "retrieving a copy from prosperity...\n" if $debug;
		$ioscan_hashref = Storable::retrieve $datafile 
			or die "unable to retrieve hash data in /tmp\n";
			return bless($ioscan_hashref,$class);
					}

	@ioscan_out=`$remote_access $remote_system -l $remote_user -n $remote_command`
		or die "Could not execute remote command: $@\n";

        foreach my $line (@ioscan_out) {
          
            print $line ,"\n" if $debug;
            if ($line =~ s/^\s+//)
              { # file line
		print "Matched line starting with device file\n" if $debug;
		push @{ $ioscan_info{$ioscan_split[10]}->{device_files}  }, split /\s+/, $line;
@device_file_check_raw = split /\s+/, $line; 
print "device_file_check_raw = @device_file_check_raw<BR>\n" if $debug8;
#
# Me thinks diskinfo option should go here
#
print "Got here b4 diskinfo check.<BR>\n" if $debug;
if ( $arglist{extended_disk_info} eq "yes" ) {
	print "got here: diskinfo selected<BR>\n" if $debug8;
foreach $line_outter ( @device_file_check_raw)	{
	print "line_outter is: $line_outter<BR>\n" if $debug8;
	if ( $line_outter =~ m/\/rdsk/g ) {
	print "got past raw device match<BR>\n" if $debug8;
	$line_outter =~ s/\/dev\/dsk\/c\wt\wd\w[s][\w]+//;
	$line_outter =~ s/\s+//;
	print "line_outter is now: $line_outter<BR>\n" if $debug8;
  @extended_disk_array = `$remote_access $remote_system -l $remote_user -n $remote_command2 $line_outter`;
  print "diskinfo command returned:<BR>\n" if $debug8;
  print "@extended_disk_array<BR>\n" if $debug8;

### parse diskinfo start
        foreach $line ( @extended_disk_array )          {
			
                @splitit = split/:/, $line;
                if ( $line =~ m/^\s*vendor/ )    {
                        $ioscan_info{$ioscan_split[10]}->{diskinfo}->{$line_outter}->{vendor}=$splitit[1];
			print "vendor $ioscan_info{$ioscan_split[10]}->{diskinfo}->{$line_outter}->{vendor}<BR>\n" if $debug8;
                                                }
                if ( $line =~ m/^\s*product id/ )        {
#                       $rdiskhash{product_id}=$splitit[1];
                        $ioscan_info{$ioscan_split[10]}->{diskinfo}->{$line_outter}->{product_id}=$splitit[1];
			print "product id $ioscan_info{$ioscan_split[10]}->{diskinfo}->{$line_outter}->{product_id}<BR>\n" if $debug8;
                                                        }
                if ( $line =~ m/^\s*type/ )      {
#                       $rdiskhash{type}=$splitit[1];
                        $ioscan_info{$ioscan_split[10]}->{diskinfo}->{$line_outter}->{type}=$splitit[1];
			print "type $ioscan_info{$ioscan_split[10]}->{diskinfo}->{$line_outter}->{type}<BR>\n" if $debug8;
                                                }
                if ( $line =~ m/^\s*size/ )      {
#                       $rdiskhash{size}=$splitit[1];
                        $ioscan_info{$ioscan_split[10]}->{diskinfo}->{$line_outter}->{size}=$splitit[1];
			print "size $ioscan_info{$ioscan_split[10]}->{diskinfo}->{$line_outter}->{size}<BR>\n" if $debug8;
                                                }
                if ( $line =~ m/^\s*bytes per sector/ )  {
#                       $rdiskhash{bytes_per_sector}=$splitit[1];
                        $ioscan_info{$ioscan_split[10]}->{diskinfo}->{$line_outter}->{bytes_per_sector}=$splitit[1];
			print "bytes per sector $ioscan_info{$ioscan_split[10]}->{diskinfo}->{$line_outter}->{bytes_per_sector}<BR>\n" if $debug8;
                                                        }
                                                        }
#print "testing", $ioscan_object_ref->{$ioscan_split[10]->{$line_outter}->{size},"<BR>/n";
#add the hash to the main hash
# as an annonymous hash so it makes a new one each time.
#$ioscan_object_ref->{$ioscan_split[10]}->{diskinfo}->{$line_outter}={ %rdiskhash };	
							    };
					}	
@device_file_check_raw =();
$line="";
$line_outter="";
@splitit=();
%rdiskhash=();
						}
### parse diskinfo stop


#
# diskinfo option ends here
#

              }
            else
              {
		print "Matched actual device line\n" if $debug;
		@ioscan_split = split /:/, $line;
# match keys to values from list above
		for (my $i=0 ; $i<19 ; $i++)	{ $ioscan_info{$ioscan_split[10]}{$list[$i]} = $ioscan_split[$i] };	
#start of diskinfo
#end of diskinfo
              }
          }
	if ( $new_or_saved eq "new" )	{
		print "saving a copy for prosperity...\n" if $debug;
		Storable::nstore \%ioscan_info, $datafile
			or die "unable to store hash data in $datafile\n";
					}
	return bless($ioscan_object_ref,$class);
      }

sub AUTOLOAD {
	my ($self, @subargs) = @_;

 	my %arglist	 =	(
		hwpath   => ""	,
		@subargs,
				);
	my $debug = 0;
	print "Passed: @_<--\n" if $debug;
	print "Yoyoyoyo got called here\n" if $debug;
	my $HWPATH 	= $arglist{hwpath};
	print "HWPATH: $HWPATH\n" if $debug;
	print "AUTOLOAD: $AUTOLOAD\n" if $debug;
	$AUTOLOAD =~ /.*::get_(\w+)/ or croak "No Such method: $AUTOLOAD\n";
	print "AUTOLOAD is now: $AUTOLOAD\n" if $debug;
	croak "$self not an object" unless ref($self);
	return if $AUTOLOAD =~ /::DESTROY$/;
	unless (exists $self->{$HWPATH}->{$1})	{
		croak "Cannot access $1 field in $self->{$HWPATH}\n";
					}
	print "self says its: $self->{$1}\n" if $debug;
	return $self->{$HWPATH}->{$1};
	      }

sub traverse	{
	my $self = shift;
	my $debug=1;
	print "I am self: $self\n" if $debug;
	my $mainkey;
	my $subkey;
	my $dev_file;

	foreach $mainkey ( keys %{ $self } )     {
	        print "Main Key: $mainkey\n";
	        print "Values:\n";
        	        foreach $subkey ( keys %{ $self->{$mainkey} } )  {
                	        print "SubKey: $subkey,                 Value: $self->{$mainkey}->{$subkey}\n";
                                                                        }
           	     foreach $dev_file ( @{ $self->{$mainkey}->{device_files} } )     {
                	        print "Mainkey    : $mainkey\n";
                        	print "Device File: $dev_file\n";
                                	                                                        }
                                        	        }
		}

sub get_disk_controllers	{
	my $self = shift;
	my $debug = 0;
	my $mainkey;
	my $subkey;

	my @controllers;
	my @disks;

	foreach $mainkey ( keys %{ $self } )     {
	foreach $subkey ( keys %{ $self->{$mainkey} } )	{
		if ($self->{$mainkey}->{$subkey} eq "ext_bus")	{
			push @controllers, $mainkey;
								}
							} 
						}
	return \@controllers;
				}

sub get_all_disks_on_controller	{
	my ($self, @subargs) = @_;

 	my %arglist	 =	(
		controller 	=> ""	,
		@subargs,
				);
	my $debug=0;
	my $mainkey;
	my $subkey;
	my $subval;
	my $instance;
	my @disks;

	my $cval; # added to support device file sort
	my $tval; # added to support device file sort
	my $dval; # added to support device file sort
	my %devfile;  #added to numerically sort device files
	my $devfile1; #temp variable in foreach loop
	my $total; # added to support device file sort
	my @sorted_disks;

# First find the instance
	
	$instance = $self->{ $arglist{controller} }->{card_instance};
	 print "Instance: $instance\n" if $debug;
	foreach $mainkey 	( keys %{ $self } )	{
	 print "MainKey: $mainkey\n" if $debug;
	while ( ($subkey, $subval)= sort each %{ $self->{ $mainkey } } )	{
	 print "Subkey: $subkey\n" if $debug;
	 print "Subval: $subval\n" if $debug;
		if ( $subkey eq "class" && $subval eq "disk" && $self->{ $mainkey }->{card_instance} eq $instance )	{
			 print "Gotta match of class, disk and instance\n" if $debug;
			 print "This is what it is: @{ $self->{ $mainkey}->{device_files} }\n" if $debug;
			push @disks, ${ $self->{ $mainkey }->{device_files} }[0];
								}
										}
							}
	while (<@disks>) {

	/c(\d+)t(\d+)d(\d+)/;

	$cval = $1;
	if ( length($cval) < 2 ) { $cval="0".$cval };
	$tval = $2;
	if ( length($tval) < 2 ) { $tval="0".$tval };
	$dval = $3;
	if ( length($dval) < 2 ) { $dval="0".$dval };

	$total = $cval.$tval.$dval;
	print "total: $total\n" if $debug;

	$devfile{$total}=$_;
                   	}
	foreach $devfile1 ( sort keys %devfile )        {
        push @sorted_disks, $devfile{$devfile1};
                                                	}
	return \@sorted_disks; 
				}

sub get_device_hwpath	{
	my ($self, @subargs) = @_;

 	my %arglist	 =	(
		device_name	=> ""	,
		@subargs,
				);
	my $debug=0;
	my $mainkey;
	my $subkey;
	my $subval;
	my $device_name = $arglist{device_name};
	my $hwpath;

# First find the instance
	
	foreach $mainkey 	( sort keys %{ $self } )	{
	 print "MainKey: $mainkey\n" if $debug;

	while ( ($subkey, $subval)= sort each %{ $self->{ $mainkey } } )	{
	 print "Subkey: $subkey\n" if $debug;
	 print "Subval: $subval\n" if $debug;
	 if (defined ${ $self->{$mainkey}->{device_files} }[0]) {
			if ( ${ $self->{ $mainkey }->{device_files} }[0] eq "$device_name" )	{
		$hwpath = $self->{ $mainkey }->{hardware_path};
		return $hwpath;
		} 	
								 }
								}
							}
	$device_name="";
	return undef; 
				}


sub get_device_diskinfo   {
        my ($self, @subargs) = @_;

        my %arglist      =      (
                device_name     =>"",
		attribute	=>"",
                @subargs,
                                );
        my $debug;
        my $mainkey;
        my $subkey;
        my $subval;
        my $device_name = $arglist{device_name};
        my $attribute   = $arglist{attribute};
	my $device_name_raw;
        my %diskinfo_hash;
	my $diskinfo_attribute;
	my $scalar_diskinfo_hash;
	my %self;

#First find the instance
        foreach $mainkey        ( sort keys %{ $self } )        {
         print "MainKey: $mainkey\n" if $debug;

        while ( ($subkey, $subval)= sort each %{ $self->{ $mainkey } } )  {
         print "Subkey: $subkey\n" if $debug;
         print "Subval: $subval\n" if $debug;
         if (defined ${ $self->{$mainkey}->{device_files} }[0]) {
                        if ( ${ $self->{$mainkey}->{device_files} }[0] eq "$device_name" )    {
		$device_name_raw = $device_name;
		$device_name_raw =~ s/\/dsk\//\/rdsk\//;
#			$mainkey = "\'".$mainkey."\'";
#			$device_name_raw = "\'".$device_name_raw."\'";
                if  ( exists( $self->{$mainkey}->{diskinfo}->{$device_name_raw}->{$attribute} ) )	{
			print "It exists!\n" if $debug;
			print "mainkey: $mainkey\n" if $debug;
			print "device_name_raw: $device_name_raw\n" if $debug;
#			$device_name_raw = "\'".$device_name_raw."\'";
			$diskinfo_attribute = $self->{$mainkey}->{diskinfo}->{$device_name_raw}->{$attribute};
#			print "Keys of main hash: ",each %$self->{$mainkey}->{diskinfo}->{$device_name_raw},"<R>\n";
											}
                return $diskinfo_attribute;
                }
                                                                 }
                                                                }
                                                        }
        $device_name="";
        return undef;
                                }
1;

__END__

# Below is stub documentation for your module. You better edit it!

=head1 NAME

HPUX::Ioscan - Perl function to handle HPUX ioscan command

=head1 SYNOPSIS

 use HPUX::Ioscan ;
 my $result = ioscan ();

 print "All hardware paths: ", join(" ", keys %$result),"\n";

 print "One device file of disk :\n",
       $result->{'2/1.6.0'}{device_files}[0],
       "\n";

=head1 DESCRIPTION

This module works on top of the HP-UX command ioscan. It forks a
process to run the ioscan command and parses its STDOUT. The result is
returned in a hash.

This module is quite basic but it may be interesting if you need to
write administration program on HP-UX.

You may call ioscan several time in your program without any problem
sicne the result is cached. Only the first call to ioscan will
actually run the ioscan command. (But you may override the caching of
the result)

=head1 FUNCTION

=head2 ioscan ( [force => 1] )

Will return the result of the ioscan command. The ioscan command is
run the first time or if the force parameter is set to 1.

This function returns a hash ref. The keys of the hash are all the
hardware paths found on your system.

The value is another hash ref containing these keys :

  bus_type
  cdio
  is_block
  is_char
  is_pseudo
  block_major_number
  character_major_number
  minor_number
  class
  driver
  hardware_path
  identify_bytes
  instance_number
  module_path
  module_name
  software_state
  hardware_type 
  description
  card_instance
  device_files

See L<ioscan>(1M) for the meaning of these keys.

The value of device_files is an array containing the name of the
device files attached to the hardware path.

=head1 EXAMPLE

Heres an example of the structure returned for 1 disk:

 $result = 
  {
    '0/0/2/1.6.0' => 
       {
         'description' => 'SEAGATE ST318203LC',
         'block_major_number' => '31',
         'cdio' => 'wsio',
         'driver' => 'sdisk',
         'instance_number' => '1',
         'is_pseudo' => 'F',
         'character_major_number' => '188',
         'class' => 'disk',
         'bus_type' => 'scsi',
         'hardware_path' => '0/0/2/1.6.0',
         'identify_bytes' => '0 0 2 18 0 0 0 0 95 227 197 13  8 127 87 40 32 ',
         'device_files' => [
                             '/dev/dsk/c2t6d0',
                             '/dev/rdsk/c2t6d0'
                           ],
         'module_path' => 'root.sba.lba.c720.tgt.sdisk',
         'minor_number' => '155648',
         'is_block' => 'T',
         'is_char' => 'T',
         'card_instance' => '2',
         'software_state' => 'CLAIMED',
         'hardware_type' => 'DEVICE',
         'module_name' => 'sdisk'
       },
 }

=head1 OO SYNOPSIS

  use HPUX::Ioscan;

  my $ioscan_data = new HPUX::Ioscan(
				target_type	=>"local",
				persistance	=>"new",
				access_prog	=>"ssh",
				access_system	=>"localhost",
				access_user	=>"root"
					);

  $arref = $ioscan_data->get_disk_controllers();
  foreach $contr ( @$arref )      {
    $instance = $ioscan_data->get_instance_number(
				controller	=> $contr
						);
				  }
  $hwpath = $ioscan_data->get_device_hwpath(
		device_name => "/dev/dsk/c1t4d0"
					)
  $hwpathinfo = $ioscan_data->get_class(
		hwpath	=> $hwpath
					)
  $disk_size = $ioscan_data->get_device_diskinfo(
		device_name => "/dev/dsk/c1t4d0"
		attribute   => "size"
					)

=head1 DESCRIPTION

This module takes the output from the ioscan command and hashes it into 
an object.  You can then access its attributes via its AUTOLOADED methods i
or other custom methods.

It utilizes the Storable module for persistance so once called you can 
then recall it without re-running the command and/or wait for the network 
by setting persistance from "new" to "old".

Remote node access is supported via remsh or ssh.  ssh is highly recommended
since the ioscan command that the script runs needs root.

=head1 FUNCTION

=head2 new

The main object constructor that returns the hash refrence.
The keys of the hash are all the hardware paths on your system.  
It accepts the following paramters:

	target_type 	values: local(default) or remote
	persistance 	values: new(default) or old
	access_prog 	values: ssh(default) or remsh
	access_system 	values: localhost(default) or remote system name
	extended_disk_info values:yes or no(default)
	access_user	values: root(default) or remote username

The value is another hash ref containing there keys :

  bus_type
  cdio
  is_block
  is_char
  is_pseudo
  block_major_number
  character_major_number
  minor_number
  class
  driver
  hardware_path
  identify_bytes
  instance_number
  module_path
  module_name
  software_state
  hardware_type 
  description
  card_instance
  device_files

See L<ioscan>(1M) for the meaning of these keys.

=head1 EXAMPLE

Heres an example of the structure returned for 1 disk:

 $result = 
  {
    '0/0/2/1.6.0' => 
       {
         'description' => 'SEAGATE ST318203LC',
         'block_major_number' => '31',
         'cdio' => 'wsio',
         'driver' => 'sdisk',
         'instance_number' => '1',
         'is_pseudo' => 'F',
         'character_major_number' => '188',
         'class' => 'disk',
         'bus_type' => 'scsi',
         'hardware_path' => '0/0/2/1.6.0',
         'identify_bytes' => '0 0 2 18 0 0 0 0 95 227 197 13  8 127 87 40 32 ',
         'device_files' => [
                             '/dev/dsk/c2t6d0',
                             '/dev/rdsk/c2t6d0'
                           ],
         'module_path' => 'root.sba.lba.c720.tgt.sdisk',
         'minor_number' => '155648',
         'is_block' => 'T',
         'is_char' => 'T',
         'card_instance' => '2',
         'software_state' => 'CLAIMED',
         'hardware_type' => 'DEVICE',
         'module_name' => 'sdisk'
       },
 }

=head1 EXAMPLE

Partial Ioscan Object (disk only).  Illustrates the optional extended diskinfo option.

 $result =
  {
'0/12/0/0.104.7.19.1.7.0' => HASH(0x403c18b8)
   'block_major_number' => 31
   'bus_type' => 'scsi'
   'card_instance' => 9

   'cdio' => 'wsio'
   'character_major_number' => 188
   'class' => 'disk'
   'description' => 'HP      OPEN-L'
   'device_files' => ARRAY(0x403c19c0)
      0  '/dev/dsk/c9t7d0'
      1  '/dev/rdsk/c9t7d0'
   'diskinfo' => HASH(0x403c1924)
      '/dev/rdsk/c9t7d0' => HASH(0x403c193c)
         'bytes_per_sector' => ' 0
'
         'product_id' => ' OPEN-L          
'
         'size' => ' 0 Kbytes
'
         'type' => ' direct access
'
         'vendor' => ' HP      
'
   'driver' => 'sdisk'
   'hardware_path' => '0/12/0/0.104.7.19.1.7.0'
   'hardware_type' => 'DEVICE'
   'identify_bytes' => '32 0 2 2 0 0 0 0 175 10 43 213 190 8 246 137 '
   'instance_number' => 76
   'is_block' => 'T'
   'is_char' => 'T'
   'is_pseudo' => 'F'
   'minor_number' => 618496
   'module_name' => 'sdisk'
   'module_path' => 'root.sba.lba.td.fcp.fcparray.tgt.sdisk'
   'software_state' => 'CLAIMED'
 }

=head2 get_disk_controllers()

  return a refrence to an array of all the disk controller paths.

=head2 traverse()

  example method that traverses the main object.

=head2 get_all_disks_on_controller(controller=>'1/2/3/4.5')

  returns an array refrence to an array that lists all disk devices on a particular controller

=head2 get_device_hwpath(device_name=>'/dev/dsk/c4t3d0')

  returns a scalar value of the hwpath to the device used for further device info lookups

=head2 get_device_diskinfo(device_name=>'/dev/dsk/c4t3d0', attribute=>'size')

  returns a scalar value of the diskinfo commands attributes


=head1 CAVEATS

The iocan command is run in blocking mode and may indeed block for
several seconds on big systems.

=head1 AUTHORs

Dominique Dumont <Dominique_Dumont@hp.com>

OO by Christopher White <chrwhite@seanet.com>

Copyright (c) 2001 Dominique Dumont. All rights reserved.  This
program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=head1 SEE ALSO

L<ioscan>(1M)

## end
=cut

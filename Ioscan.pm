package HPUX::Ioscan ;
use strict ;
use FileHandle ;
use Carp ;
use vars qw/@ISA @EXPORT $test $VERSION/;

require Exporter;
@ISA = qw(Exporter);

@EXPORT = qw(ioscan);            # symbols to export by default

$VERSION = sprintf "%d.%03d", q$Revision: 1.2 $ =~ /(\d+)\.(\d+)/;

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

1;
__END__

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

Here's an example of the structure returned for 1 disk:

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

=head1 CAVEATS

The iocan command is run in blocking mode and may indeed block for
several seconds on big systems.

=head1 AUTHOR

Dominique Dumont <Dominique_Dumont@hp.com>

Copyright (c) 2001 Dominique Dumont. All rights reserved.  This
program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=head1 SEE ALSO

L<ioscan>(1M)


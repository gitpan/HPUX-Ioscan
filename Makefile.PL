use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile
  (
   'NAME'	=> 'HPUX::Ioscan',
   'VERSION_FROM' => 'Ioscan.pm',
   ($] >= 5.005 ?
    (ABSTRACT   => 'Perl module to handle HPUX ioscan command',
     AUTHOR     => 'Chris White (based on Dominique Dumonts (chrwhite@seanet.com)') : ())
  );

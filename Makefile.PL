use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile
  (
   'NAME'	=> 'HPUX::Ioscan',
   'VERSION_FROM' => 'Ioscan.pm',
   ($] >= 5.005 ?
    (ABSTRACT   => 'Perl function to handle HPUX ioscan command',
     AUTHOR     => 'Dominique Dumont (domi@barrayar.grenoble.hp.com)') : ())
  );

use 5.014004;
use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    NAME              => 'BTSync::API',
    VERSION_FROM      => 'lib/BTSync/API.pm', # finds $VERSION
    PREREQ_PM         => {
	 	Mojolicious => '4.59',
	 }, # e.g., Module::Name => 1.1
    ($] >= 5.10.1 ?     ## Add these new keywords supported since 5.005
      (ABSTRACT_FROM  => 'lib/BTSync/API.pm', # retrieve abstract from module
       AUTHOR         => 'Sven Eppler <sven.eppler@sodgeit.de>') : ()),
);

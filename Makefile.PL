use ExtUtils::MakeMaker;

WriteMakefile(
    NAME              => 'Plack::Middleware::Licence',
    VERSION_FROM      => 'lib/Plack/Middleware/Licence.pm',
    PREREQ_PM         => {
        Plack  => 0,
    },
    ($] >= 5.005 ?
      (ABSTRACT_FROM  => 'lib/Plack/Middleware/Licence.pm',
       AUTHOR         => 'tjmc') : ()),
);

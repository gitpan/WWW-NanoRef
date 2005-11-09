#!/usr/bin/perl

# Creation date: 2005-11-06 21:56:39
# Authors: don

use strict;
use warnings;
use Carp;

# main
{
    local($SIG{__DIE__}) = sub { &Carp::cluck(); exit 0 };

    use ExtUtils::MakeMaker;
    
    WriteMakefile(
                  NAME => 'WWW::NanoRef',
                  DISTNAME => 'WWW-NanoRef',
                  VERSION_FROM => 'lib/WWW/NanoRef.pm',
                  ABSTRACT => 'Shorten URLs via nanoref.com',
                  AUTHOR => 'DON OWENS <don@owensnet.com>',
                  PM => { 'lib/WWW/NanoRef.pm' => '$(INST_LIBDIR)/NanoRef.pm',
                        },
                  dist => { COMPRESS => 'gzip -9f', SUFFIX => 'gz' },
                  DIR => [],
                  EXE_FILES => [],
                  PREREQ_PM => {
                                'XML::Parser::Wrapper' => 0,
                                'LWP' => 0,
                               },

                 );


}

exit 0;

###############################################################################
# Subroutines


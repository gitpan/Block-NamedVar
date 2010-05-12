package Block::NamedVar;
use strict;
use warnings;

our $VERSION = "0.004";

use Devel::Declare::Interface;
Devel::Declare::Interface::register_parser( 'named_var', 'Block::NamedVar::Parser' );

our @DEFAULTS = qw/nmap ngrep/;

sub ngrep {
    local $_;
    my $code = shift;
    grep { $code->() } @_;
}

sub nmap {
    local $_;
    my $code = shift;
    map { $code->() } @_;
}

sub import {
    my $class = shift;
    my $caller = caller;

    my @args = @_;
    @args = @DEFAULTS unless @args;

    my @export = grep { m/^n(grep|map)$/ } @args;
    for ( @export ) {
        no strict 'refs';
        *{ $caller . '::' . $_ } = \&$_;
    }

    Devel::Declare::Interface::enhance( $caller, $_, 'named_var' ) for @args;
}

1;

__END__

=head1 NAME

Block::NamedVar - Replacements for map, grep with named block variables.

=head1 DESCRIPTION

Gives you nmap and ngrep which are new keywords that let you do a map or grep.
The difference is you can name the block variable instead of relying on $_. You
can also turn custom map/grep like functions into keywords that act like nmap
and ngrep.

=head1 SYNOPSIS

    #!/usr/bin/perl
    use strict;
    use warnings;

    use Block::NamedVar qw/nmap ngrep/;

    my @stuff = qw/a 1 b 2 c 3/
    my ( @list, $count );

    # grep with lexical $x.
    @list = ngrep my $x { $x =~ m/^[a-zA-Z]$/ } @stuff;

    # map with lexical $x
    @list = nmap my $x { "updated_$x" } @stuff;

    # grep with package variable $v
    $count = ngrep our $v { $v =~ m/^[a-zA-Z]$/ } @stuff;

    # grep with closure over existing $y
    my $y;
    $count = ngrep $y { $y =~ m/^[a-zA-Z]$/ } @stuff;

    # Shortcut for lexical variable
    # must be bareword.
    $count = ngrep thing { $thing =~ m/^[a-zA-Z]$/ } @stuff;

=head1 EXPORTED FUNCTIONS

=over 4

=item @out = nmap var { $var ... } @list

=item @out = nmap $var { $var ... } @list

=item @out = nmap my $var { $var ... } @list

=item @out = nmap our $var { $var ... } @list

Works just like map except you specify a variable instead of using $_.

=item @out = ngrep var { $var ... } @list

=item @out = ngrep $var { $var ... } @list

=item @out = ngrep my $var { $var ... } @list

=item @out = ngrep our $var { $var ... } @list

Works just like grep except you specify a variable instead of using $_.

=back

=head1 AUTHORS

Chad Granum L<exodist7@gmail.com>

=head1 COPYRIGHT

Copyright (C) 2010 Chad Granum

Block-NamedVar is free software; Standard perl licence.

Block-NamedVar is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
FITNESS FOR A PARTICULAR PURPOSE.  See the license for more details.

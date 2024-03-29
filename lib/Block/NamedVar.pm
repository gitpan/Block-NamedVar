package Block::NamedVar;
use strict;
use warnings;

our $VERSION = "0.008";

use Devel::Declare::Interface;
Devel::Declare::Interface::register_parser( 'map_var', 'Block::NamedVar::MapLike' );
Devel::Declare::Interface::register_parser( 'for_var', 'Block::NamedVar::ForLike' );

sub nfor {}

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

    for (qw/nfor ngrep nmap/) {
        no strict 'refs';
        *{ $caller . '::' . $_ } = \&$_;
    }

    Devel::Declare::Interface::enhance( $caller, $_, 'map_var' ) for qw/ngrep nmap/;
    Devel::Declare::Interface::enhance( $caller, 'nfor', 'for_var' ) for qw/nfor/;
}

1;

__END__

=head1 NAME

Block::NamedVar - Named variables for grep and map, for with multiple named list elements.

=head1 DESCRIPTION

Gives you nmap and ngrep which are new keywords that let you do a map or grep.
The difference is you can name the block variable instead of relying on $_. You
can also turn custom map/grep like functions into keywords that act like nmap
and ngrep.

Gives you nfor which is like 'for' except you can loop over multiple elements
of the array at once. If given a hash you can get the key and the value each
iteration. Implemented such that it does not suffer the problems of each().

=head1 SYNOPSIS

    #!/usr/bin/perl
    use strict;
    use warnings;

    use Block::NamedVar;

    my %a_hash = ( a => 1, b => 2 );
    my @stuff = qw/a 1 b 2 c 3/

    nfor my ( $key, $value ) ( %a_hash ) {
        print $key, " = ", $value, "\n";
    }

    my @list = ngrep my $x { $x =~ m/^[a-zA-Z]$/ } @stuff;

    @list = nmap my $x { "updated_$x" } @stuff;

=head1 EXPORTED FUNCTIONS

=over 4

=item nfor my ( $vara, $varb, ... ) ( @list ) { ... }

like 'for', except that you can take any number of elements from the array per
iteration. Loop controls like 'next' and 'last' work as expected.

=item nfor ( key => 'value' ) { $a == 'key', $b == 'value' }

Special case of nfor, if no variables are specified $a and $b will be used, and
2 elements will be taken per iteration. Useful for iterating hashes. $a and $b
are localized to your block.

=item @out = ngrep var { $var ... } @list

=item @out = ngrep $var { $var ... } @list

=item @out = ngrep my $var { $var ... } @list

=item @out = ngrep our $var { $var ... } @list

Works just like grep except you specify a variable instead of using $_.

    # grep with lexical $x.
    @list = ngrep my $x { $x =~ m/^[a-zA-Z]$/ } @stuff;

    # grep with package variable $v
    $count = ngrep our $v { $v =~ m/^[a-zA-Z]$/ } @stuff;

    # grep with closure over existing $y
    my $y;
    $count = ngrep $y { $y =~ m/^[a-zA-Z]$/ } @stuff;

    # Shortcut for lexical variable
    # must be bareword.
    $count = ngrep thing { $thing =~ m/^[a-zA-Z]$/ } @stuff;


=item @out = nmap var { $var ... } @list

=item @out = nmap $var { $var ... } @list

=item @out = nmap my $var { $var ... } @list

=item @out = nmap our $var { $var ... } @list

Works just like map except you specify a variable instead of using $_.

    # map with lexical $x
    @list = nmap my $x { "updated_$x" } @stuff;

=back

=head1 AUTHORS

Chad Granum L<exodist7@gmail.com>

=head1 COPYRIGHT

Copyright (C) 2010 Chad Granum

Block-NamedVar is free software; Standard perl licence.

Block-NamedVar is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
FITNESS FOR A PARTICULAR PURPOSE.  See the license for more details.

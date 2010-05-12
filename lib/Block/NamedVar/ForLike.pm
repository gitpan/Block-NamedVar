package Block::NamedVar::ForLike;
use strict;
use warnings;

use Devel::Declare::Interface;
use base 'Devel::Declare::Parser';

Devel::Declare::Interface::register_parser( 'for_var' );
__PACKAGE__->add_accessor( $_ ) for qw/dec vars list var_count/;

sub is_contained{ 0 }

sub rewrite {
    my $self = shift;

    if ( @{ $self->parts } > 3 ) {
        ( undef, undef, my @bad ) = @{ $self->parts };
        $self->bail(
            "Syntax error near: " . join( ' and ',
                map { $self->format_part($_)} @bad
            )
        );
    }

    my ($first, $second, $third) = @{ $self->parts };
    my ( $dec, $vars, $list ) = ("");
    if ( @{ $self->parts } > 2 ) {
        $self->bail(
            "Syntax error near: " . $self->format_part($first)
        ) unless grep { $first->[0] eq $_ } qw/my our/;
        $dec = $first;
        $vars = $second;
        $list = $third;
    }
    elsif ( @{ $self->parts } < 2 ) {
        $dec = ['local'];
        $vars = [' $a, $b ', '('];
        $list = $first;
    }
    else {
        $vars = $first;
        $list = $second;
    }

    $self->vars( $self->format_vars( $vars ));
    $self->var_count( $self->count_vars );
    $self->dec( $dec );
    $self->list( $list );

    $self->new_parts([]);
    1;
}

sub format_vars {
    my $self = shift;
    my ( $vars ) = @_;
    return $vars if ref $vars;
    return [ $vars, '(' ];
}

sub count_vars {
    my $self = shift;
    my @sigils = ($self->vars->[0] =~ m/\$/g);
    my @bad = $self->vars->[0] =~ m/[\@\*\%]/g;
    die( "nfor can only use a list of scalars, not " . join( ', ', @bad ))
        if @bad;
    return scalar @sigils;
}

sub close_line {''};

sub open_line {
    my $self = shift;
    my $dec = $self->dec ? $self->dec->[0] : '';
    my $vars = $self->vars;
    return "; for my \$__ ( "
         . __PACKAGE__
         . '::_nfor('
         . $self->var_count
         . ", "
         . $self->list->[0]
         . ")) { "
         . "$dec ($vars->[0]) = \@\$__; ";
}

sub _nfor {
    return unless @_;
    my ( $num, @list ) = @_;
    my $i = 0;
    my @out;
    while ( $i < @list ) {
        push @out => [ @list[ $i .. ($i + $num - 1)] ];
        $i += $num;
    }
    return @out;
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

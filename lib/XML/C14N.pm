package XML::C14N;
our $VERSION = '0.01';

use utf8;
use strict;
use warnings;

use Carp;
use Exporter    qw< import >;
use Moo;
use XML::LibXML;


our @EXPORT = our @EXPORT_OK
    = qw< C14N_1_0 C14N_1_0_WC C14N_1_1 C14N_1_1_WC C14N_EC C14N_EC_WC >;

use constant {
    C14N_1_0    => "http://www.w3.org/TR/2001/REC-xml-c14n-20010315",
    C14N_1_0_WC => "http://www.w3.org/TR/2001/REC-xml-c14n-20010315#WithComments",
    C14N_1_1    => "http://www.w3.org/2006/12/xml-c14n11",
    C14N_1_1_WC => "http://www.w3.org/2006/12/xml-c14n11#WithComments",
    C14N_EC     => "http://www.w3.org/2001/10/xml-exc-c14n#",
    C14N_EC_WC  => "http://www.w3.org/2001/10/xml-exc-c14n#WithComments",
};


has c14n_method     => ( is => "rw", default => sub { C14N_1_0 } );
has prefix_list     => ( is => "rw", default => sub {    undef } );
has with_comments   => ( is => "rw", default => sub {        0 } );
has xpath           => ( is => "rw", default => sub {    undef } );
has xpath_context   => ( is => "rw", default => sub {    undef } );


my %libxml_method = (
    C14N_1_0()      => "toStringC14N",
    C14N_1_0 _WC()  => "toStringC14N",
    C14N_1_1()      => "toStringC14N_v1_1",
    C14N_1_1_WC()   => "toStringC14N_v1_1",
    C14N_EC()       => "toStringEC14N",
    C14N_EC_WC()    => "toStringEC14N",
);


#
# canonicalize()
# ------------
sub canonicalize {
    my ($self, $xml) = @_;

    my $method = $libxml_method{ $self->c14n_method // C14N_1_0 }
        // croak "unknown C14N standard: ", $self->c14n_method;

    $self->with_comments(1) if index($self->c14n_method, "WithComments") > 0;
    my $with_comments = $self->with_comments ? 1 : 0;
    my $xpath = $self->xpath;
    $xpath  //= $with_comments ? '(//. | //@* | //namespace::*)'
              : '(//. | //@* | //namespace::*)[not(self::comment())]';

    # build method args
    my @args = ( $with_comments, $xpath );
    push @args, $self->xpath_context if $self->xpath_context;

    if ($self->c14n_method eq C14N_EC and ref $self->prefix_list eq "ARRAY") {
        push @args, $self->prefix_list;
    }

    my $dom = _dom($xml);

    return $dom->$method(@args)
}


#
# _dom()
# ----
sub _dom {
    my ($xml) = @_;

    if (ref $xml) {
        if (eval { $xml->isa("XML::LibXML::Node") }) {
            return $xml
        }
        else {
            die "given XML argument isn't a string nor a XML::LibXML object\n"
        }
    }
    else {
        my $dom = XML::LibXML->new->parse_string($xml);
        return $dom->documentElement;
    }
}



__PACKAGE__

__END__

=encoding UTF-8

=head1 NAME

XML::C14N - Module for canonicalization of XML documents using XML::LibXML

=head1 SYNOPSIS

    use XML::C14N;

    my $c14n = XML::C14N->new;
    my $canon = $c14n->canonicalize($xml);


=head1 DESCRIPTION

This module implements XML canonicalization using the L<XML::LibXML> Perl
module, which itself uses the Gnome/W3C libxml2 library.


=head1 RATIONALE

This module was started as part of a larger project, for implementing a
working XML security stack in Perl. There are already two modules for
XML canonicalization on the CPAN:

=over

=item * L<XML::Canonical>,
XS module, direct binding against libxml2;
terse documentation, but good enough;
test suite based on W3C examples;
very old & unmaintained (last release in 2002);
uses L<XML::GDOME>, also old & unmaintained (last release in 2004);

=item * L<XML::CanonicalizeXML>, 
XS module, direct binding against libxml2;
very terse documentation, but good enough;
very limited test suite, with ad-hoc tests;
old & unmaintained (last release in 2010);

=back

Upon realizing that L<XML::LibXML> provided XML canonicalization
functions, I thought that having modules that directly bind to libxml2
was kind of redundant, and that it would be more optimal to make
a simple module with a clean interface, on top of L<XML::LibXML>.
Porting the tests from the existing modules to this one unfortunately
proved useful, in that it appears that C<XML::LibXML> incorrectly
implements XML canonicalization. The bugs I currently found:

=over

=item * the default XPath expressions in L<XML::LibXML> differ from
the ones defined in the standards

=item * (unconfirmed) some libxml2 parser options need to be exposed

    xmlLoadExtDtdDefaultValue = XML_DETECT_IDS | XML_COMPLETE_ATTRS;

=item * although the C14N API is tested, the W3C examples aren't part
of the test suite

=back

I'll try to submit bug reports and patches to L<XML::LibXML> in order
to fix these issues. In the mean time, this module can't be flagged
as functionnal, and L<XML::Canonical> or L<XML::CanonicalizeXML> should
be used instead.


=head1 EXPORTS

The following constants are exported by default:

=over

=item * C<C14N_1_0> -- URI of the I<Canonical XML 1.0 (without comment)>
specification

=item * C<C14N_1_0_WC> -- URI of the I<Canonical XML 1.0 (with comment)>
specification

=item * C<C14N_1_1> -- URI of the I<Canonical XML 1.1 (without comment)>
specification

=item * C<C14N_1_1_WC> -- URI of the I<Canonical XML 1.1 (with comment)>
specification

=item * C<C14N_EC> -- URI of the I<Exclusive XML Canonicalization 1.0
(without comments)> specification

=item * C<C14N_EC_WC> -- URI of the I<Exclusive XML Canonicalization 1.0
(with comments)> specification

=back


=head1 ATTRIBUTES

Standard Moo(se)-type attributes behaviour applies.

=head2 c14n_method

URI of the desired canonicalization specified. Only the offical W3C URI
are recognized (and available from this modules as exported constants).
Default is C<C14N_1_0>, I<Canonical XML 1.0 (without comment)>.

=head2 prefix_list

When using I<Exclusive XML Canonicalization>, this attribute can be
used to specify a list of namespace prefixes, as an arrayref, that
are to be processed using the classic I<Canonical XML> specification.

=head2 with_comments

Boolean, specify whether to include comments in the canonicalized
document. Default is false.

=head2 xpath

Optional XPath expression for selecting the nodes to be included in
the canonicalized document. By default, all nodes except comments
are included.

=head2 xpath_context

Optional L<XML::LibXML::XPathContext> object defining the context
for evaluation of the XPath expression. Useful for mapping namespace
prefixes used in the XPath expression to namespace URIs.


=head1 METHODS

=head2 canonicalize

Process the given XML document and return the corresponding canonicalized
document. The argument can be given either as a plain string of octets,
or as a L<XML::LibXML> document object.

Example:

    my $canon = $c14n->canonicalize($xml);


=head1 AUTHOR

Sébastien Aperghis-Tramoni C<< <saper at cpan.org> >>


=head1 BUGS

Please report any bugs or feature requests to C<bug-xml-c14n at rt.cpan.org>,
or through the web interface at
L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=XML-C14N>.
I will be notified, and then you'll automatically be notified of progress
on your bug as I make changes.


=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc XML::C14N

You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=XML-C14N>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/XML-C14N>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/XML-C14N>

=item * Search CPAN

L<http://search.cpan.org/dist/XML-C14N/>

=back


=head1 LICENSE AND COPYRIGHT

Copyright 2015 Sébastien Aperghis-Tramoni.

This program is free software; you can redistribute it and/or modify it
under the terms of the the Artistic License (2.0). You may obtain a
copy of the full license at:

L<http://www.perlfoundation.org/artistic_license_2_0>

Any use, modification, and distribution of the Standard or Modified
Versions is governed by this Artistic License. By using, modifying or
distributing the Package, you accept this license. Do not use, modify,
or distribute the Package, if you do not accept this license.

If your Modified Version has been derived from a Modified Version made
by someone other than you, you are nevertheless required to ensure that
your Modified Version complies with the requirements of this license.

This license does not grant you the right to use any trademark, service
mark, tradename, or logo of the Copyright Holder.

This license includes the non-exclusive, worldwide, free-of-charge
patent license to make, have made, use, offer to sell, sell, import and
otherwise transfer the Package with respect to any patent claims
licensable by the Copyright Holder that are necessarily infringed by the
Package. If you institute patent litigation (including a cross-claim or
counterclaim) against any party alleging that the Package constitutes
direct or contributory patent infringement, then this Artistic License
to you shall terminate on the date that such litigation is filed.

Disclaimer of Warranty: THE PACKAGE IS PROVIDED BY THE COPYRIGHT HOLDER
AND CONTRIBUTORS "AS IS' AND WITHOUT ANY EXPRESS OR IMPLIED WARRANTIES.
THE IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
PURPOSE, OR NON-INFRINGEMENT ARE DISCLAIMED TO THE EXTENT PERMITTED BY
YOUR LOCAL LAW. UNLESS REQUIRED BY LAW, NO COPYRIGHT HOLDER OR
CONTRIBUTOR WILL BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, OR
CONSEQUENTIAL DAMAGES ARISING IN ANY WAY OUT OF THE USE OF THE PACKAGE,
EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

=cut


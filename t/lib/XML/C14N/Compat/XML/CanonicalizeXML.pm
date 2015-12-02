package XML::C14N::Compat::XML::CanonicalizeXML;
use strict;
use warnings;
use XML::C14N;


sub canonicalize {
    my ($xml, $xpath, $namespace, $exclusive, $with_comments) = @_;

    my $c14n = XML::C14N->new(
        c14n_method     => $exclusive ? C14N_EC : C14N_1_0,
        xpath           => $xpath,
        with_comments   => $with_comments,
    );

    $c14n->prefix_list([ split /,/, $namespace ]) if $namespace;

    return $c14n->canonicalize($xml)
}


*XML::CanonicalizeXML::canonicalize
    = \&XML::C14N::Compat::XML::CanonicalizeXML::canonicalize;


__PACKAGE__

__END__


package XML::C14N::Compat::XML::Canonical;
use strict;
use warnings;
use XML::C14N;


sub new {
    my ($class, %param) = @_;
    my %self = ( c14n => XML::C14N->new(with_comments => $param{comments}) );
    return bless \%self, $class
}


sub canonicalize_string {
    my ($self, $xml) = @_;
    return $self->{c14n}->canonicalize($xml)
}


sub canonicalize_document {
    my ($self, $dom, $xpath) = @_;
    $self->{c14n}->xpath($xpath);
    return $self->{c14n}->canonicalize($dom->toString)
}


__PACKAGE__

__END__


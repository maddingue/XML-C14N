#!perl -T
use strict;
use warnings;

# adapted from XML::Canonical 0.10 tests

use Encode;
use Test::More;


{
    no warnings;
    *is = \&Test::LongString::is_string if eval "use Test::LongString; 1";
}


my $module = "XML::C14N::Compat::XML::Canonical";
my $xml_path = "t/XML-Canonical/in";

plan tests => 10;

use lib "t/lib";
use_ok "XML::C14N";
use_ok $module;


for my $i (1..6) {
    my $input = slurp("$xml_path/3${i}_input.xml");
    my $canon_expect = decode("UTF-8", slurp("$xml_path/3${i}_c14n.xml"));
    chomp $canon_expect;
    my $canon = $module->new(comments => 0);
    my $canon_output = $canon->canonicalize_string($input);
    is $canon_output, $canon_expect,
        "$xml_path/3${i}_input.xml cmp $xml_path/3${i}_c14n.xml";
}

my $input = slurp("$xml_path/31_input.xml");
my $canon_expect = decode("UTF-8", slurp("$xml_path/31_c14n-comments.xml"));
chomp $canon_expect;
my $canon = $module->new(comments => 1);
my $canon_output = $canon->canonicalize_string($input);
is $canon_expect, $canon_output,
    "$xml_path/31_input.xml cmp $xml_path/31_c14n-comments.xml";

SKIP: {
    skip "XML::GDOME not available", 1 unless eval "use XML::GDOME; 1";

    $input = slurp("$xml_path/37_input.xml");
    $canon_expect = decode("UTF-8", slurp("$xml_path/37_c14n.xml"));
    chomp $canon_expect;
    $canon = $module->new(comments => 1);
    my $doc = XML::GDOME->createDocFromString($input);
    my $elem = $doc->createElement("foo");
    $elem->setAttributeNS("http://www.w3.org/2000/xmlns/",
        "xmlns:ietf", "http://www.ietf.org");
    my $nsresolv = $elem->xpath_createNSResolver;
    my $res = $doc->xpath_evaluate(qq{
(//. | //@* | //namespace::*)
[
   self::ietf:e1 or (parent::ietf:e1 and not(self::text() or self::e2))
   or
   count(id("E3")|ancestor-or-self::node()) = count(ancestor-or-self::node())
]
}, $nsresolv);

    $canon_output = $canon->canonicalize_document($doc, $res);
    is $canon_output, $canon_expect;
}


sub slurp {
    my ($filename) = @_;
    return do { open my $fh, "<", $filename; local $/; <$fh> }
}

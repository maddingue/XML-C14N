#!perl -T
use strict;
use warnings;
use Encode;
use Test::More;
use XML::C14N;


{
    no warnings;
    *is = \&Test::LongString::is_string if eval "use Test::LongString; 1";
}


my @c14n10 = glob "t/w3c-tr/xml-c14n10/*-input.xml";
my @c14n11 = glob "t/w3c-tr/xml-c14n11/*-input.xml";

plan tests => (@c14n10 + @c14n11) * 2;

my @specs = (
    [ C14N_1_0, \@c14n10 ],
    [ C14N_1_1, \@c14n11 ],
);


for my $spec (@specs) {
    for my $in_path (@{$spec->[1]}) {
        my $input = read_file($in_path);
        (my $exp_path = $in_path) =~ s/input/canon/;
        (my $xp_path = $in_path) =~ s/xml$/xpath/;
        (my $ns_path = $in_path) =~ s/xml$/ns/;
        chomp (my $expected = decode("UTF-8", read_file($exp_path)));

        my $c14n = XML::C14N->new(c14n_method => $spec->[0]);
        $c14n->xpath( read_file($xp_path) ) if -f $xp_path;

        if (-f $ns_path) {
            open my $fh, "<", $ns_path;
            my $xpc = XML::LibXML::XPathContext->new;

            while (my $line = <$fh>) {
                chomp $line;
                $line =~ s/^xmlns://;
                my ($ns, $uri) = split /=/, $line, 2;
                $xpc->registerNs($ns, $uri);
            }

            $c14n->xpath_context($xpc);
        }

        my $output = eval { $c14n->canonicalize($input) };
        is $@, "", "\$c14n->canonicalize(read_file('$in_path'))";
        is $output, $expected, "compare output to reference";
    }
}



sub read_file {
    open my $fh, "<", $_[0]; local $/; return scalar <$fh>
}


#!perl -T
use strict;
use warnings;

# adapted from XML::CanonicalizeXML 0.05 tests

use Test::More tests => 4;

use lib "t/lib";
use_ok "XML::C14N";
use_ok "XML::C14N::Compat::XML::CanonicalizeXML";


my $soapbody=
'<SOAP-ENV:Body
xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/"
xmlns:wsu="http://schemas.xmlsoap.org/ws/2002/04/utility" Id="myBody">
<Catalog xmlns="http://skyservice.pha.jhu.edu" />
</SOAP-ENV:Body>';

my $body_xpath=
#'<XPath xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/">
"(//. | //@* | //namespace::*)[ancestor-or-self::SOAP-ENV:Body]";
#</XPath>';

#$si_xpath=
#'<XPath xmlns:ds="http://www.w3.org/2000/09/xmldsig#">
#(//. | //@* | //namespace::*)[ancestor-or-self::ds:SignedInfo]
#</XPath>';*/

my $testresult1=
'<SOAP-ENV:Body xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/" Id="myBody">
<Catalog xmlns="http://skyservice.pha.jhu.edu"></Catalog>
</SOAP-ENV:Body>';

my $testresult2=
'<SOAP-ENV:Body xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/" xmlns:wsu="http://schemas.xmlsoap.org/ws/2002/04/utility" Id="myBody">
<Catalog xmlns="http://skyservice.pha.jhu.edu"></Catalog>
</SOAP-ENV:Body>';

my $test1=XML::CanonicalizeXML::canonicalize($soapbody, $body_xpath,
"SOAP-ENV", 1, 0);

my $test2=XML::CanonicalizeXML::canonicalize($soapbody, $body_xpath,
"SOAP-ENV", 0, 0);

is($test1, $testresult1,	'exclusive canonicalization test');
is($test2, $testresult2,	'inclusive canonicalization test');


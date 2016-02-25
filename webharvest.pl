#!/usr/bin/perl
#Jasmine Emerson
#jazafrazzle@gmail.com

use strict;

my $site="http://www.nytimes.com";
my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
my $timestr = sprintf("%02d:%02d:$02%s", $hour, $min, $sec);
my @image_urls;
my @link_urls;
open (my $fh, "curl $site |") or die "$!\n";

while (<$fh>) {
    while (m/<\s*img\s+src\s*=\s*"([^"]*)"/gi) {
	my $url = $1;
	push @image_urls, $url;
    }
    while (/<a\s+href=\"([^\"]*)\"/gi){
	my $url = $1;
	if ($url =~ /\.(png|gif|jpe?g|bmp|tif?f)$/) {
	    push @image_urls, $url;
	}
	else {
	    push @link_urls, $url;
	    
	}
    }
}
close $fh;

my $THUMBDIR = "thumbs";
mkdir $THUMBDIR unless -d $THUMBDIR;

my $COLS = 8;
my $N = 0;

print <<"EOF";
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8" />
    <title>$site""</title>
  </head>
  <body>
    <h2>Jasmine Emerson</h2>
    <h2> Web Harvest $site</h2>
    <h3>Images harvested</h3>
  <table>
EOF

    for (@image_urls) {

	my $url = $_;
	$url = "$site/" . $url unless $url =~ /^https?:/;

	if (m{.*/(.*)\..*$}) {
	    my $thumb = "$THUMBDIR/$1.png";
	    
	unless (-e $thumb) {
	    my $cmd  = "curl '$url' | convert - -resize 50x50 '$thumb'";
	    print STDERR "$cmd\n";
	    next unless system($cmd) == 0;
	 }

	print "   <tr>\n" if $N % $COLS == 0;
	print "   <td><a href=\"$url\"><img src=\"$thumb\".png /></a></td>\n";
	$N++;
	print "   </tr>\n" if $N % $COLS == 0;
    }
}

print <<"EOF";
<!DOCTYPE html>
  </table>
  <h3>Links harvested</h3>
  <table>
EOF
    for (@link_urls) {
  	my $url = $_;
	$url = "$site/" . $url unless $url =~ /^https?:/;
	print "<tr>\n";
	print "<td><a href=\"$url\">$url</a></td>\n";
	print "</tr>\n";
    }

print <<"EOF";
<!DOCTYPE html>
  </table>
  <h3>Unique Websites</h3>
  <table>
EOF
    my %sites;
    for(@link_urls) {
	$_ = "$site/" . $_ unless $_ =~ /^https?:/;
	my $s = $1 if m{^https?://([^/]*)};
	$sites{$s} = 1;
    }
    for (sort keys %sites){
	print "<tr>\n";
	print "<td><a href=\"$_\">$_</a></td>\n";
	print "</tr>\n";
    }
print <<"EOF";
	</table>
       <p>time = $timestr</p>
      </body>
   </html>
EOF





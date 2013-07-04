#!/usr/bin/env perl

# let's find some shit.
#

use WWW::Search;
use Getopt::Std;
use Net::SMTP::TLS;
use Data::Dumper;

# define categories
my %category = (
  'free' => 'zip',
  'forsale' => 'sss',
  'bike' => 'bik',
  'motorcycles' => 'mca',
  'parts' => 'pta',
  'furniture' => 'fua',
  'materials' => 'maa',
  'tools' => 'tla',
  'antiques' => 'ata',
  'realestate' => 'rea',
  'apartments' => 'apa',
  'commercial' => 'off',
  'personals' => 'ppp',
  'sex' => 'cas',
  'friends' => 'stp',
);

my %location = (
  'New Hampshire' => 'nh',
  'Boston' => 'boston',
  'Maine' => 'maine',
  'Vermont' => 'burlington',
  'Western Mass' => 'westernmass',
  'Harrisonburg' => 'harrisonburg',
  'West Virgina' => 'wv',
  'Scranton' => 'scranton',
);

getopts('l:m:x:c:e:s:hpod');

unless($opt_l && $opt_c && $opt_s || $opt_h) {
  print "Usage: $0 -l LOCATION -c CATEGORY -s SEARCH [-m MIN] [-x MAX]\n\t[-e email\@address] [-p] [-o] [-h]\n";
  print "\n\t Valid Categories:\n";
  while (($key, $value) = each %category) {
          print "\t\t" . $key . "\n";
  }
  print "\n\t Valid Locations:\n";
  while (($key, $value) = each %location) {
          print "\t\t" . $key . "\n";
  }
  print "\n\n";
  exit;
}

my $oSearch = new WWW::Search('CraigsList');
my $sQuery = WWW::Search::escape_query($opt_s);

if ($opt_p) {
  $has_pic = '1';
}

my $rhArgs = {
  'locCode' => $location{$opt_l},
  'Min' => $opt_m,
  'Max' => $opt_x,
  'Category' => $category{$opt_c},
  'Pic' => $has_pic,
};

$oSearch->native_query($sQuery,$rhArgs);

if (! $oSearch->response->is_success) {
  print STDERR "Error:  " . $oSearch->response->as_string() . "\n";
} # if

while (my $oResult = $oSearch->next_result()) {
  my $url = $oResult->url;
  my $title = $oResult->title();
  if (! $title) { $title = "CL Link"; }
  push @listings, '<a href="' . $url . '">' . $title . '</a></br>' . "\n";
}

if ($opt_d) {
  print "++++ DEBUG OUTPUT ++++\n";
  print "Search Object: \n";
  print Dumper($oSearch) . "\n";
  print "Listings (if any): \n";
  print @listings . "\n";
}

if ($opt_o) {
  foreach (@listings) {
    binmode STDOUT, ":utf8";
    print $_;
  }
}

if ($opt_e) {
  my $smtp = new Net::SMTP::TLS(
	  $ENV{'EMAIL_HOST'},
	  Port    =>	$ENV{EMAIL_PORT},
	  User    =>	$ENV{'EMAIL_USER'},
	  Password=>	$ENV{'EMAIL_PASS'},
	  Timeout =>	30
  );

  ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
  $subject_line = 'CLKrawl Listings :: Location: ' . $opt_l . ' :: Category: ' . $opt_c;
  $body_line = 'Date: ' . $mon . '/' . $mday . ', ' . ($year += 1900) . '</br>Location: ' . $opt_l . '</br>Category: ' . $opt_c .'</br>Search Terms: ' . $opt_s;
  #  -- Enter email FROM below.   --
  $smtp->mail('clkrawl@example.com');

  #  -- Enter recipient mails addresses below (only one for now)--
  $smtp->recipient($opt_e);

  $smtp->data();

  #This part creates the SMTP headers you see
  $smtp->datasend("To: $opt_e\n");
  $smtp->datasend("From: CraigsList Krawl Daemon \n");
  $smtp->datasend("Content-Type: text/html \n");
  $smtp->datasend("Subject: $subject_line \n");
  # line break to separate headers from message body
  $smtp->datasend("\n");
  $smtp->datasend($body_line ." \n");
  $smtp->datasend("</br>\n");
  foreach (@listings) { $smtp->datasend($_) };
  $smtp->datasend("\n");
  $smtp->dataend();

  $smtp->quit;

  print "results emailed.\n";
}



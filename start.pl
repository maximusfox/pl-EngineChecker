#!/usr/bin/env perl

use strict;
use warnings;

use Coro;
use File::Slurp;
use Coro::Select;
use LWP::UserAgent;
use List::MoreUtils qw/uniq/;

# Cnfig
###################################
my $threads = 50;
my $timeout = 10;
my $proxy = undef;
###################################

# Engins
my $engins = require('./signDB.pl');

# Колбек на сигнал смерти
$SIG{'INT'} = sub {
	close($_) for (qw/ URL LOG GOOD BAD /);
	print "\n[i] Finish\n";
	exit;
};

# Открываем список сайтов
open (URL, '<', 'data/urls.txt') or die "Can't open file data/urls.txt! $! ";

my @threadsPull;
unlink('data/log.txt');

print "[i] Start checking ...\n";
for (1..$threads) {
	push @threadsPull, async {
		my $ua = LWP::UserAgent->new( agent => 'Mozilla/5.0 (X11; Linux i686; rv:25.0) Gecko/20100101 Firefox/25.0' );
		$ua->timeout($timeout);
		$ua->max_redirect(0);
		$ua->cookie_jar( {} );
		$ua->proxy(http => $proxy) if ($proxy);

		while (my $url = <URL>) {
			next unless (defined $url); chomp($url); next unless (defined $url);

			my $cashLocal = {};
			for my $engin ( keys %{$engins} ) {

				for my $path (@{ $engins->{$engin} }) {
					print "[i] Check URL[ ".$url." ] Engin[".$engin."] Path[".$path->{url}."]\n";

					my $rsURL = $url;
					$rsURL =~ s!/[^/]{0,}?$!$path->{url}!;

					my $resp;
					if (exists $cashLocal->{$path->{url}}) {
						print "[i] Get page from cash [".$rsURL."]\n";
						$resp = $cashLocal->{$path->{url}};
					} else {
						print "[i] Send request [".$rsURL."]\n";
						$resp = $ua->get($rsURL);
						$cashLocal->{$path->{url}} = $resp;
					}

					unless (defined $resp and defined $resp->as_string) {
						print "[!] Can't get URL[".$rsURL."] [SKIP]\n";
						next;
					}

					my $isGood = 0;
					for my $sign (@{ $path->{signs} }) {
						if ($resp->as_string =~ $sign) {
							print "[i] Detected URL[".$url."] PATH[".$path->{url}."] Engine[".$engin."]\n";
							$isGood++;
							last;
						}
					}

					if ($isGood) {
						good($url, $path->{file});
						last;
					}
				}

			}
		}
	};
}
$_->join for (@threadsPull);

# Закрываем все дескрипторы
close($_) for (qw/ URL LOG GOOD BAD /);
print "[i] Finish\n";


sub good {
	my ($url, $file) = @_;

	# Открываем файл с гудами
	open (GOOD, '>>', $file) or die "Can't open file $file! $! ";

	# Открываем лог
	open (LOG, '>>', 'data/log.txt') or die "Can't open file data/log.txt! $! ";

	print LOG "[+] ".$url."\t[ ".$file." ]\n";
	print "[+] ".$url."\t[ ".$file." ]\n";
	print GOOD $url."\n";

	close($_) for (qw/ GOOD LOG /);
}
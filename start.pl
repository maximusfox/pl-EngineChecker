#!/usr/bin/env perl

use strict;
use warnings;

use Coro;
use Coro::LWP;
use Coro::Select;

use LWP::UserAgent;
use LWP::ConnCache;
use LWP::Protocol::socks;

use List::MoreUtils qw/uniq/;

# Config
###################################
my $threads = 50;
my $timeout = 10;
my $proxy = undef;
###################################

# Engines
my $engines = require('./signDB.pl');

# Колбек на сигнал смерти
$SIG{'INT'} = sub {
	close($_) for (qw/ URL LOG GOOD BAD /);
	print "\n[i] Finish\n";
	exit;
};

# Отключаем проверку SSL сертификатов
$ENV{HTTPS_DEBUG} = 1;
$ENV{PERL_LWP_SSL_VERIFY_HOSTNAME} = 0;
IO::Socket::SSL::set_ctx_defaults(
	SSL_verifycn_scheme => 'www',
	SSL_verify_mode => 0,
);

# Открываем список сайтов
open (URL, '<', 'data/urls.txt') or die "Can't open file data/urls.txt! $! ";

my @threadsPull;
unlink('data/log.txt');

print "[i] Start checking ...\n";
for (1..$threads) {
	push @threadsPull, async {
		my $ua = LWP::UserAgent->new(
			agent => 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/534.24 (KHTML, like Gecko) Ubuntu/10.10 Chromium/12.0.703.0 Chrome/12.0.703.0 Safari/534.24',
			keep_alive => 1,
			ssl_opts => { verify_hostname => 0 },
		);

		$ua->timeout($timeout);
		$ua->max_redirect(0);
		$ua->cookie_jar({});
		$ua->proxy([qw(http https)] => $proxy) if ($proxy);

		while (my $line = <URL>) {
			next unless (defined $line);

			chomp($line);
			next unless (defined $line);

			$line =~ s!^\s+|\s+$!!g;
			next unless (defined $line);

			next if ($line eq '');

			my $url;
			my $http_schema = 0;
			my $https_schema = 0;

			if ($line !~ m#^http#i) {
				$url = "http://$line/";
				$http_schema = 1;
			}

			my $cashLocal = {};
			for my $engine ( keys %{$engines} ) {

				for my $path (@{ $engines->{$engine} }) {
					RETRY:

					print "[i] Check URL[ ".$url." ] Engine[".$engine."] Path[".$path->{url}."]\n";

					my $rsURL = $url;
					$rsURL =~ s!/[^/]{0,}?$!$path->{url}!;

					my $resp;
					if (exists $cashLocal->{$path->{url}}) {
						print "[i] Get page from cash [".$rsURL."]\n";
						$resp = $cashLocal->{$path->{url}};
					} else {
						print "[i] Send request [".$rsURL."]\n";
						$resp = $ua->get($rsURL);

						# Проверяем наличие заголовка location в ответе сервера
						if ($resp->header('Location')||'' ne '') {
							print "[r] Redirect detected From[".$rsURL."] To[".$resp->header('Location')."]\n";
							if (this_is_https_redirect($rsURL, $resp->header('Location'))) {
								print "[r] Follow HTTP->HTTPS redirect From[".$rsURL."] To[".$resp->header('Location')."]\n";
								$resp = $ua->get($resp->header('Location'));
							}
						}
						print "[i] Request result [".$rsURL."] [".$resp->status_line."]\n";

						if ($http_schema == 1 and $https_schema == 0 and $resp->code == 500) {
							$url = "https://$line/";
							$https_schema = 1;
							print "[i] Try redirect to HTTPS [".$rsURL."] [".$url."]\n";

							goto RETRY;
						}

						$cashLocal->{$path->{url}} = $resp;
					}

					unless (defined $resp and defined $resp->as_string) {
						print "[!] Cannot get URL[".$rsURL."] [SKIP]\n";
						next;
					}

					my $isGood = 0;
					for my $sign (@{ $path->{signs} }) {
						if ($resp->as_string =~ $sign) {
							print "[i] Detected URL[".$url."] PATH[".$path->{url}."] Engine[".$engine."]\n";
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

# Проверка
sub this_is_https_redirect {
	my ($generated_url, $redirect_url) = @_;
	$redirect_url =~ s!^https?://!!i;
	$generated_url =~ s!^https?://!!i;

	if ($generated_url eq $redirect_url) {
		return 1;
	} else {
		return 0;
	}
}

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

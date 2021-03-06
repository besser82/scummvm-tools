#!perl

# Convert Russian talktxt.txt to UTF-8

use utf8;

binmode STDOUT, ":utf8";

my $skip = 0;
my $line = 0;

my $lang;

my @english = (' a ', ' is ', ' i ', ' and ', ' be ', 'can', ' me', 'you', 'ack', 'that', 'then', 'yes', 'um', 'chi', 'year', 'mm', 'no', 'da', 'on',
				'bla', 'lik', 'ha', 'but', 'ma', 'wa', 'yeah', 'taste', 'str', 'grr', 'pff', 'air', 'lord', ' he, ', 'get', 'yuck', 'oo', 'blur', 'see',
				'puah', 'lo', 'go', 'cur', 'hop', 'super', 'doing', 'well', 'real', 'sure', 'final', 'all', 'illeg', 'done', 'empt', 'galador');

while (<STDIN>) {
	$line++;
	my $str = $_;
	my $lstr = lc $str;

	if (/^[#@\$]/ || $line == 1) {
		print;
		next;
	}

	if ($line >= 4 and not defined $lang) {
		if (/Bpdbyz/) {
			$lang = 'ru';
		} elsif (/Excuse/) {
			$lang = 'en';
		} elsif (/Verzeihung/) {
			$lang = 'de';
		} elsif (/Przeppp/) {
			$lang = 'pl';
		} else {
			if ($#ARGV == 0) {
				$lang = $ARGV[0];
			} else {
				die "Unknown lanugage";
			}
		}
	}

	s/"/\\"/g; # Escape quotes

	if ($lang eq 'en') {
		# Heuristics to detect Russian
		my $eng = 0;

		s/\x0d\|/\|/;	# There is one instance of a stray ^M

		for my $k (@english) {
			if (index($lstr, $k) != -1) {
				print;
				$eng = 1;
				last;
			}
		}

		next if ($eng);
	}

	if ($lang eq 'ru' or $lang eq 'en') { # We have English mixed with Russian
		if ($skip) {
			tr /\x9f\xa3/źá/;  # Pseudo-hungarian speech symbol
			print;
			next;
		}

		if (/^nj b dsqltn.$/ && $lang eq 'ru') {  # After this phrase we have German
			$skip = 1;
		}

		tr /qwertyuiopasdfghjklzxcvbnm\x85\xb3\xca\xa5\xea\xe6/йцукенгшщзфывапролдячсмитьхюэжбъ/;
		tr /QWERTYUIOPASDFGHJKLZXCVBNM\x82\x7f\x83\x81\x84/ЙЦУКЕНГШЩЗФЫВАПРОЛДЯЧСМИТЬЭХБЖЮ/;
		print;
	}

	if ($lang eq 'pl') {
		tr /\x9c\xea\xbf\xb3\x9f\xe6\xf1\xf3\xb9\xaf\x8c\xa3\xd1\xc6\xca/śężłźćńóąŻŚŁŃĆĘ/;

		print;
	}

	if ($lang eq 'de') {
		tr /\xc4\xdf\xfc\xf6/Äßüö/;

		tr /\x9f\xa3/źá/;  # Pseudo-hungarian speech symbol

		print;
	}

	# Russian version has leftovers from German translation
	if ($skip) {
		print "#END\n";
		last;
	}
}

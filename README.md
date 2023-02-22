# pl-EngineChecker

A Perl script to detect the Engine/CMS of a website.

# Usage

1. Clone the repository:

```bash
git clone https://github.com/maximusfox/pl-EngineChecker.git
```

2. Navigate to the cloned directory:

```bash
cd pl-EngineChecker/
```

3. Edit the configuration variables in the start.pl script:

```perl
my $threads = 50;
my $timeout = 10;
my $proxy = undef;
```

- $threads: The number of threads to use for the script (default is 50).
- $timeout: The maximum time in seconds to wait for a response from a website (default is 10).
- $proxy: The proxy server (socks5://127.0.0.1:8091) to use for the requests (default is undef).

4. Add the URLs you want to check to the data/urls.txt file, with one URL per line.

5. Run the script:

```
perl start.pl
```

6. Wait for the script to finish checking the URLs. The results will be saved to the data/log.txt file and sorted urls to files specified in signDB.pl.

# Disclaimer

This tool is for educational and research purposes only. The author is not responsible for any misuse or damage caused by this tool. Use at your own risk.

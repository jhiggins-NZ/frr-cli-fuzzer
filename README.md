# FRR CLI Fuzzer

The FRR CLI fuzzer works by executing all existing CLI commands (obtained using the `list permutations` command) and checking for segmentation faults.

This program receives as input a configuration file specifying the test parameters, which are mostly self explanatory. The [config.yml](config.yml) file can be used as a reference configuration.

The CLI fuzzer uses Linux PID, mount and network namespaces to run on a completely isolated environment, which allows multiple instances of the CLI fuzzer to run concurrently. Linux is the only supported platform.

## Installation

After checking out the repo, run `bin/setup` to install the dependencies (currently, only the _ffi_ gem):
```
$ git clone https://github.com/rwestphal/frr-cli-fuzzer
$ cd frr-cli-fuzzer
# ./bin/setup
```

Alternatively, install the latest version of the _frr-cli-fuzzer_ gem using the following command:
```
# gem install frr-cli-fuzzer
```

> NOTE: in order to install this gem it might be necessary to install the `ruby-dev` or `ruby-devel` package first.

## Usage

Edit [config.yml](config.yml) to configure the test parameters. Run the CLI fuzzer using the following command:
```
# frr-cli-fuzzer config.yml
```

Once the tests complete, the results are displayed in the standard output. Example:
```
results:
- non-filtered commands: 5708
- whitelist filtered commands: 0
- blacklist filtered commands: 62881
- tested commands: 22458
- segfaults detected: 10
    (x4) ripd aborted: vtysh -c "configure terminal" -c "no router rip"
    (x3) ospfd aborted: vtysh -c "configure terminal" -c "router ospf" -c "no segment-routing prefix 1.1.1.1/32"
    (x3) ospfd aborted: vtysh -c "configure terminal" -c "router ospf" -c "no segment-routing prefix 1.1.1.1/32 index 65535 no-php-flag"
```

The `runstatedir` (_/tmp/frr-cli-fuzzer/_ by default) directory will contain the following files:
* _output.txt_: log of the detected segmentation faults (use `sort output.txt | uniq` to filter out duplicates).
* _vtysh.txt_: vtysh output.
* _*.log_: log files of the FRR daemons.
* _*.stdout_: capture of the standard output of the FRR daemons.
* _*.stderr_: capture of the standard error of the FRR daemons.

It's recommend to build FRR with compiler optimizations (e.g. `-O2`) to allow the CLI fuzzer to test more commands per second.

If desired, it's possible to run multiple instances of the CLI fuzzer at the same time.
For that, each instance must use a different configuration file, and the `runstatedir` parameter (under the `fuzzer` section) must be different among all running instances to separate their running state data.

## Core Dumps

It's suggested to enable the generation of core dumps to make it easier to debug the segfaults triggered by the CLI fuzzer. This can be done by following the steps below:
* Create the _/var/crash_ directory to store the core dumps:
```
# mkdir /var/crash
# chmod 0777 /var/crash
```

* Edit _/etc/sysctl.conf_:
```
kernel.core_pattern = /var/crash/core-%e-%s-%u-%g-%p-%t
fs.suid_dumpable = 1
```

* Edit _/etc/security/limits.conf_:
```
*              soft    core           unlimited
root           soft    core           unlimited
*              hard    core           unlimited
root           hard    core           unlimited
```

Reboot the system for the changes to take effect.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/rwestphal/frr-cli-fuzzer.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details

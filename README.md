# Zed Lake Migration

As the [Zed](https://zed.brimdata.io/) system is young and evolving, there's
the potential that new functionality may require changes to the
[lake storage format](https://zed.brimdata.io/docs/next/lake/format) that are
not backward compatible. While we exepct these chanegs to be rare, such a
change recently occurred such that Zed lakes created with
[Zed v1.5.0](https://github.com/brimdata/zed/releases/tag/v1.5.0) and older
will not be readable by [Zed v1.6.0](https://github.com/brimdata/zed/releases/tag/v1.6.0)
and newer. This change will also affect tools such as [Zui](https://zui.brimdata.io/)
(formerly known as Brim) that use Zed lakes.

To help users make the transition, the tools in this repository can be used to
migrate lakes to the newer format.

## Limitations

To keep the migration tools simple, there are some limitations.

1. Only the `main` branch of each pool is migrated.
2. The contents of the migrated pool are loaded as a single
[commit](https://zed.brimdata.io/docs/commands/zed#141-commit-objects). The
commit history is therefore not preserved, so [time travel](https://zed.brimdata.io/docs/commands/zed#15-time-travel)
will not be possible to pre-migration commits.

We expect most users are not yet dependent on the features affetced by these
limitations. However, your environment is severely impacted by these
limitations, come talk to us on the
[Brim community Slack](https://www.brimdata.io/join-slack/).

## Usage

Download and unpack the newest migration kit
[release](https://github.com/brimdata/zed-lake-migration/releases)
for your operating system. The migration script in the kit is preconfigured
to work out-of-the-box to migrate the Zed lakes from a
[Brim v0.31.0](https://github.com/brimdata/brim/releases/tag/v0.31.0)
install to a [Zui v1.0.0](https://github.com/brimdata/zui/releases/tag/v1.0.0)
install. If this is your use case, simply run the script as shown below for
an example with two pools.

```
$ sh migrate.sh 
migrating lake at '/Users/phil/Library/Application Support/Brim/lake' to '/Users/phil/Library/Application Support/Zui/lake'
migrating pool 'wrccdc.pcap' (2MCssyxdqCxwx2pvIabmQoNF21R)
migrating pool 'example_pool' (2MCsuDhqnoE2QB6p4reHWJdaI9z)
```

See the sections below if you're migrating between [Zui Insiders](#zui-insiders)
releases or if you're managing your pools directly with the
[Zed CLI tools](#zed-cli-tools).

> **Note:** The migration script must be run in a Windows `sh` variant like
> `BusyBox`, `Cygwin`, or `MSYS2`. If you do not have any of these already set
> up, we recommend downloading
> [busybox.exe](https://frippery.org/files/busybox/busybox.exe)
> as it seems to be the easiest. Once downloaded, start the shell. See the
> [Busy Box documentation](https://frippery.org/busybox/) for more detail.
>
> ```
> C:\path\to\busybox.exe sh -l
> ```
> 
> This will drop you into a `sh` environment where you can execute the
> migration script as shown previously.

## How It Works

For ease of use, the migration kit includes a
[`zed` v1.5.0](https://github.com/brimdata/zed/releases/tag/v1.5.0) binary
that can read the old lake format. That `zed` is used to do a bulk dump of
the older lake's contents to a single [ZNG](https://zed.brimdata.io/docs/formats/zng)
file via [`zed query`](https://zed.brimdata.io/docs/commands/zed#211-query).
A new `zed` binary (such as the one bundled with the Zui app) is then used to
[`zed load`](https://zed.brimdata.io/docs/commands/zed#28-load) the ZNG into
a new lake (such as the one behind Zui). Finally, a ZNG dump is performed of
the newly-loaded lake and the two ZNG dumps are compared to confirm they are
byte-for-byte equivalent. The script will provide error output if migration
fails or the ZNG dump comparison finds any differences. If your Zui app is
already open, click **View > Reload** from the pull-down menu to see the
list of migrated pools.

## Zui Insiders

The transition from Brim/Zui is made simpler by the fact that Brim and Zui
store their Zed lakes in separate
[user data](https://zui.brimdata.io/docs/support/Filesystem-Paths#user-data)
directories. By comparison, when upgrading Zui Insiders to a release that
includes the new Zed lake storage format, the following steps should be
followed to handle the mirgation within a single user data directory.


follo
are required because
only a single 


The migration script in the kit is preconfigured
to work out-of-the-box to migrate the Zed lakes from a
[Brim v0.31.0](https://github.com/brimdata/brim/releases/tag/v0.31.0)
install to a [Zui v1.0.0](https://github.com/brimdata/zui/releases/tag/v1.0.0)
install. If this is your use case, simply run the script as shown below for 
an example with two pools. 


## Zui Insiders

On raw Zed installs

Come talk to use on Slack

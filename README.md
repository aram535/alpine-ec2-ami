# Alpine Linux EC2 AMI Builder

**NOTE: This is not an official AWS or Alpine project.  This is community built
and supported.**

## Pre-Built AMIs

***To get started with one of our pre-built minimalist AMIs, please refer to the
[README](releases/README.md) in the [releases](releases) subdirectory.***

Alternately, with the right filters, you can query the EC2 API to programmatically
find our most recent AMIs.  For example, using the `aws` command line tool...
```
aws ec2 describe-images \
  --output text \
  --filters \
    Name=owner-id,Values=538276064493 \
    Name=name,Values='alpine-ami-*' \
    Name=state,Values=available \
    Name=tag:profile_build,Values=v3_10-x86_64 \
  --query 'max_by(Images[], &CreationDate).ImageId'
```
...will list the latest AMI id from our collection of 'v3_10-x86_64' builds.
Refer to the AWS CLI Command Reference for
[describe-images](https://docs.aws.amazon.com/cli/latest/reference/ec2/describe-images.html)
for more details.

## Custom AMIs

Using the scripts and configuration in this project, you can build your own
custom Alpine Linux AMIs.  If you experience any problems building custom AMIs,
please open an [issue](https://github.com/mcrute/alpine-ec2-ami/issues) and
include as much detailed information as possible.

### Build Requirements

* [Packer](https://packer.io) >= 1.4.1
* [Python 3.x](https://python.org) (3.7 is known to work)
* an AWS account with an existing subnet in an AWS Virtual Private Cloud

### Profile Configuration

Target profile config files reside in the [profiles](profiles) subdirectory,
where you will also find the [config](profiles/alpine.conf) we use for our
pre-built AMIs.  Refer to the [README](profiles/README.md) in that subdirectory
for more details and information about how AMI profile configs work.

### AWS Credentials

These scripts use the `boto3` library to interact with AWS, enabling you to
provide your AWS account credentials in a number of different ways.  see the
offical `boto3` documentation's section on
[configuring credentials](https://boto3.amazonaws.com/v1/documentation/api/latest/guide/configuration.html#configuring-credentials)
for more details.  *Please note that these scripts do not implement the first
two methods on the list.*

### Building AMIs

To build all build targets in a target profile, simply...
```
./scripts/builder.py amis <profile>
```

You can also build specfic build targets within a profile:
```
./scripts/builder.py amis <profile> <build1> <build2>
```

Before each build, new Alpine Linux *releases* are detected and the version's
core profile is updated.

If there's already an AMI with the same name as the profile build's, that build
will be skipped and the process moves on to build the other profile's build
targets (if any).

After each successful build, `releases/<profile>.yaml` is updated with the
build's details, including (most importantly) the ids of the AMI artifacts that
were built.

Additional information about using your custom AMIs can be found in the
[README](releases/README.md) in the [releases](releases) subdirectory.

### Pruning AMIs

Every now and then, you may want to clean up old AMIs from your EC2 account and
your profile's `releases/<profile>.yaml`.  There are three different levels of
pruning:
* `revision` - keep only the latest revision for each release
* `release` - keep only the latest release for each version
* `version` - remove any end-of-life versions

To prune a profile (or optionally one build target of a profile)...
```
./scripts/builder.py prune-amis <profile> [<build>]
```

Any AMIs in the account which are "unknown" (to the profile/build target, at
least) will be called out as such, but will not be pruned.

### Updating the Release README

This make target updates the [releases README](releases/README.md), primarily
for updating the list of our pre-built AMIs.  This may-or-may-not be useful for
other target profiles.
```
./scripts/builder.py gen-release-readme <profile>
```

### Cleaning up the Build Environment

The build process is careful to place all temporary files in teh `build`
subdirectory. Remove the temporary `build` subdirectory, which contains the
resolved profile and Packer configs, the Python virtual environment, and other
temporary build-related artifacts.

## Caveats

* New Alpine Linux *versions* are currently not auto-detected and added as a
  core version profile; this process is, at the moment, still a manual task.

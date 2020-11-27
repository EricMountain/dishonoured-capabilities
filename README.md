# Reproducer for setcap in user-namespaced Docker builds

## Problem

Images built in user-namespaced Docker daemons and that contain layers in which capabilities have been set on files store the extended attributes using v3 format. This persists the user id of the root user that created the user-namespace employed in the build.

When running such images under a container runtime that either does not user user-namespaces, or for which the root user id is different than the one of the build environment, `execve(2)` will not honour the capabilities effective bit on executables, since the v3-encoded root user id will not match.

## Use

``` shell
$ vagrant up
```

Provisioning automatically runs the test. See `provision-vm.sh` for details of the test case.

## Tear-down

``` shell
$ vagrant destroy -f
```

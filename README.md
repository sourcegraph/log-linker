# log-linker

This is a workaround for https://github.com/kubernetes/kubernetes/issues/52172. This code was copied
from https://github.com/kubernetes/kubernetes/issues/52172#issuecomment-356085479 and written
originally by [Chris Jones (@cjyar)](https://github.com/cjyar).

This script sets up symlinks from files in containers to host node files correctly in case kubelet
does not create them successfully, which seems to happen when containers take a long time to start
up due to heavy initial I/O load (see https://github.com/sourcegraph/infrastructure/pull/415). This
has been observed to affect some Sourcegraph Data Center instances where the persistent volumes are
large (100s of GB). The underlying issue may be fixed in Kubernetes at some point, at which point
this script will become unnecessary.

Usage: `kubectl apply daemonset.yaml`

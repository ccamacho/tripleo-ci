# Periodic stable jobs set OVERRIDE_ZUUL_BRANCH, gate stable jobs
# just have the branch they're proposed to, e.g ZUUL_BRANCH, in both
# cases we need to set STABLE_RELEASE to match for tripleo.sh
export ZUUL_BRANCH=${ZUUL_BRANCH:-""}
export OVERRIDE_ZUUL_BRANCH=${OVERRIDE_ZUUL_BRANCH:-""}
export STABLE_RELEASE=${STABLE_RELEASE:-""}
export FEATURE_BRANCH=${FEATURE_BRANCH:-""}
# In upgrade jobs STABLE_RELEASE is changed to point to the initial
# deployment branch but we need to keep the actual release for the review
# to be used in delorean-build phase.
export REVIEW_RELEASE=${REVIEW_RELEASE:-""}
if [[ $ZUUL_BRANCH =~ ^stable/ ]]; then
    export STABLE_RELEASE=${ZUUL_BRANCH#stable/}
    export REVIEW_RELEASE=${ZUUL_BRANCH#stable/}
fi

if [[ $OVERRIDE_ZUUL_BRANCH =~ ^stable/ ]]; then
    export STABLE_RELEASE=${OVERRIDE_ZUUL_BRANCH#stable/}
fi

# if we still don't have an stable branch, check if that
# is a feature branch
if [ -z "$STABLE_RELEASE" ] && [ "$ZUUL_BRANCH" != "master" ]; then
    export FEATURE_BRANCH=$ZUUL_BRANCH
fi

export TRIPLEO_ROOT=${TRIPLEO_ROOT:-"/opt/stack/new"}
export WORKSPACE=${WORKSPACE:-"$TRIPLEO_ROOT/workspace"}
export DEVSTACK_GATE_TIMEOUT=${DEVSTACK_GATE_TIMEOUT:-"180"}
export PATH=/sbin:/usr/sbin:$PATH

export UNDERCLOUD_VM_NAME=instack

# post ci chores to run at the end of ci
SSH_OPTIONS='-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o LogLevel=Verbose -o PasswordAuthentication=no -o ConnectionAttempts=32'

# NOTE(pabelanger): this logic should be inverted to only include what developers need, not exclude things on the filesystem.
TARCMD="sudo XZ_OPT=-3 tar -cJf - --exclude=var/log/journal --exclude=udev/hwdb.bin --exclude=etc/puppet/modules --exclude=etc/project-config --exclude=etc/services --exclude=selinux/targeted --exclude=etc/services --exclude=etc/pki /var/log /etc"
JLOGCMD="sudo journalctl --output short-precise | gzip -c | sudo dd of=/var/log/journal-text.txt.gz"

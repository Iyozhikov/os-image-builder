#!/bin/bash -x

readonly RPM_PACKAGES PY_PACKAGES \

yum makecache
yum install -y ${RPM_PACKAGES}
whoami
sleep 500

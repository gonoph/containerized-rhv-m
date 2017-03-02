# Copyright 2017 Billy Holmes
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.

FROM rhel:7.3

MAINTAINER Billy Holmes <billy.holmes@redhat.com>

RUN     yum clean all \
        && sed -i 's/enabled = 1/enabled = 0/' /etc/yum.repos.d/redhat.repo \
        && yum-config-manager \
                --enable rhel-7-server-rpms \
                --enable rhel-7-server-supplementary-rpms \
                --enable rhel-7-server-rhv-4.0-rpms \
                --enable jb-eap-7-for-rhel-7-server-rpms \
        && yum update -y \
        && yum install -y \
        patch \
        sudo \
        procps-ng \
        hostname \
        rhevm \
        && yum clean all

# it places the following files into the root
# /etc/profile.d/prompt.sh      - for pretty prompts in the container
# /docker-entrypoint.sh	        - to handle the invoking of different containers from the same image
COPY	root/ /

# you will need to ensure these files exist
COPY    backup.tgz answers.txt /root/

ENV     /usr/sbin:/usr/bin:/sbin:/bin \
        container=docker \
        LANG=en_US.utf8 \
        USER=root

# this runs the restore and setup from your old server, also sets up apache to print to stderr and stdout
RUN     engine-backup  --mode=restore --file=/root/backup.tgz --log=/tmp/log.txt --no-restore-permissions --scope=files \
        && engine-setup --config-append=/root/answers.txt \
        && sed -e 's%^CustomLog .* \\%CustomLog /dev/stdout \\%' -e 's%^TransferLog .*%TransferLog /dev/stdout%' -e 's%^ErrorLog .*%ErrorLog /dev/stderr%' /etc/httpd/conf.d/ssl.conf -i \
        && sed -e 's%    CustomLog .*%    CustomLog "/dev/stdout" combined%' -e 's%^ErrorLog .*%ErrorLog "/dev/stderr"%' /etc/httpd/conf/httpd.conf -i
EXPOSE 80 443
ENTRYPOINT [ "/docker-entrypoint.sh" ]

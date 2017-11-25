#!/bin/bash -x

readonly ORANGE_PRIVATE_KEY=/root/.ssh/orange-docker
readonly SSH_OPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null"
readonly SSH_CMD="ssh -i $ORANGE_PRIVATE_KEY $SSH_OPTS "
readonly SCRIPT=${0##*/}

readonly MY_IP=$(hostname -i)
readonly VIPD_LAST_OCTETS=("200" "201")
readonly LOGFILE=/var/log/$SCRIPT.log

function log()
{
    [[ -e $LOGFILE ]] || touch $LOGFILE
    echo $@ >> $LOGFILE
}
function die() { echo $@; exit 1; }

function start_sshd()
{
    log "starting sshd ..."
    service ssh start
    sleep 5
    service ssh status || die "Un able to start sshd"
    log "sshd is now running"
}

function update_etc_hosts()
{
    CMS_IPV4_VIP=$(echo $MY_IP | sed 's/\.[0-9]*$/.200/')   # use our subnet to construct VIP
    CMS_VIP_HOSTNAME='cms-01.docker'                        # VIP hostname is always hardwired
    CMS_VIP_HOSTNAME_SHORT='cms-01'                         # VIP hostname is always hardwired

    SME_IPV4_VIP=$(echo $MY_IP | sed 's/\.[0-9]*$/.201/')   # use our subnet to construct VIP
    SME_VIP_HOSTNAME='sme-01.docker'                        # VIP hostname is always hardwired
    SME_VIP_HOSTNAME_SHORT='sme-01'                         # VIP hostname is always hardwired

    log "Updating vip addresses in /etc/hosts"
    echo "$CMS_IPV4_VIP $CMS_VIP_HOSTNAME $CMS_VIP_HOSTNAME_SHORT" >> /etc/hosts
    echo "$SME_IPV4_VIP $SME_VIP_HOSTNAME $SME_VIP_HOSTNAME_SHORT" >> /etc/hosts
    log "Done updating vip addresses in /etc/hosts"
}

function create_dirs()
{
    mkdir -p /var/log/db
}

# --py-autoreload=3 makes uwsgi to reload py files after every 3 seconds.
function run_app()
{
    cd /webapp
    uwsgi --ini /etc/uwsgi.ini
}

#
# main
#

#update_etc_hosts
#start_sshd
create_dirs
run_app

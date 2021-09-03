!/bin/bash
# 20190816 Robert Martin-Legene
# GPL2-only

# BFA tiene 3 bootnodes oficiales.
# Para levantar un bootnode hay que poner la clave en
# este archivo. Se genera la clave con: bootnode -genkey
bootnodekeyfile=${BFANETWORKDIR}/bootnode/key

# Bail out if anything fails.
trap "exit 1" ERR
# Detect children dying
trap "reaper" SIGCHLD
trap "killprocs" SIGTERM
trap "killallprocs" EXIT
unset LOGPIPE PIDIDX ALLPIDIDX TMPDIR SHUTTING_DOWN
declare -A PIDIDX ALLPIDIDX
SHUTTING_DOWN=0

function reaper()
{
    local reaped_a_child_status=0
    # Find out which child died
    for pid in ${!PIDIDX[*]}
    do
        kill -0 $pid 2>/dev/null && continue
        reaped_a_child_status=1
        local rc=0
        wait $pid || rc=$? || true
	local name=${PIDIDX[$pid]}
        echo "*** $name (pid $pid) has exited with value $rc"
	if [ $name = 'geth' ]; then geth_rc_status=$rc; fi
        unset PIDIDX[$pid]
    done
    # Return if we didn't find out which child died.
    if [ $reaped_a_child_status = 0 ]; then return; fi
    # Kill all other registered processes
    for pid in ${!PIDIDX[*]}
    do
        kill -0 $pid 2>/dev/null || continue
        echo "*** Killing ${PIDIDX[$pid]} (pid $pid)."
        kill $pid || true
    done
}

function killprocs()
{
    SHUTTING_DOWN=1
    if [ ${#PIDIDX[*]} -gt 0 ]
    then
        echo "*** Killing all remaining processes: ${PIDIDX[*]} (${!PIDIDX[*]})."
        kill ${!PIDIDX[*]} 2>/dev/null || true
    fi
}

function killallprocs()
{
    # merge the 2 pid list, to make killing and echoing easier
    for pid in ${!ALLPIDIDX[*]}
    do
        PIDIDX[$pid]=${ALLPIDIDX[$pid]}
        unset ALLPIDIDX[$pid]
    done
    killprocs
    if [ -n "$TMPDIR" -a -e "$TMPDIR" ]
    then
	rm -rf "$TMPDIR"
    fi
}

function startgeth()
{
    echo "***" Starting geth $*
    # "NoPruning=true" means "--gcmode archive"
	    geth --config ${BFATOML} --allow-insecure-unlock $* &
    gethpid=$!
    PIDIDX[${gethpid}]="geth"
}

# You can start as:
# BFAHOME=/home/bfa/bfa singlestart.sh
# singlestart.sh /home/bfa/bfa
if [ -z "${BFAHOME}" -a -n "$1" -a -f "$1" ]
then
    export BFAHOME="$1"
fi
if [ -z "${BFAHOME}" ]; then echo "\$BFAHOME not set. Did you source `dirname $0`/env ?" >&2; exit 1; fi
#
if [ -r "${BFAHOME}/bin/env" ]
then
    source ${BFAHOME}/bin/env
else
    if [ "$VIRTUALIZATION" = "DOCKER" ]
    then
        # The idea is that the environment already is set by the Docker environment.
        touch ${BFAHOME}/bin/env
    else
        echo "Can't do much without a \$BFAHOME/bin/env file. Maybe you can copy one of these?" >&2
        ls -1 ${BFAHOME}/*/env >&2
        exit 1
    fi
fi
source ${BFAHOME}/bin/libbfa.sh

TMPDIR=$( mktemp -d )
mknod             ${TMPDIR}/sleeppipe p
sleep 987654321 > ${TMPDIR}/sleeppipe &
ALLPIDIDX[$!]='sleep'
if [ "$VIRTUALIZATION" = "DOCKER" ]
then
    echo
    echo
    echo
    echo
    date
    echo $0 startup
    echo
    echo "See log info with \"docker logs\""
else
    echo "Logging mostly everything to ${BFANODEDIR}/log"
    echo "Consider running: tail -n 1000 -F ${BFANODEDIR}/log"
    echo "or: bfalog.sh"

    # Docker has it's own logging facility, so we will not use our own
    # logging functionality if we're in docker.
    echo "*** Setting up logging."
    LOGPIPE=${TMPDIR}/logpipe
    mknod ${LOGPIPE} p
    ${BFAHOME}/bin/log.sh ${BFANODEDIR}/log < ${LOGPIPE} &
    # Separate pididx for processes we don't want to send signals to
    # until in the very end.
    ALLPIDIDX[$!]="log.sh"
    exec > ${LOGPIPE} 2>&1
fi

function sleep()
{
    read -t ${1:-1} < ${TMPDIR}/sleeppipe || true
}

# Start a sync
startgeth --exitwhensynced
echo "*** Starting monitor.js"
monitor.js &
PIDIDX[$!]="monitor.js"

# geth will exit when it has synced, then we kill it's monitor.
# Then wait here for their exit status to get reaped
while [ "${#PIDIDX[*]}" -gt 0 ]; do sleep 1; done

# if it went well, start a normal geth (to run "forever")
test $geth_rc_status = 0 || exit $geth_rc_status
test "$SHUTTING_DOWN" != 0 && exit 0

# regular geth
startgeth
# monitor
echo "*** Starting monitor.js"
    monitor.js &
PIDIDX[$!]="monitor.js"
# bootnode
if [ -r "$bootnodekeyfile" ]
then
    echo "*** Starting bootnode."
    bootnode --nodekey $bootnodekeyfile &
    PIDIDX[$!]="bootnode"
fi

while [ "${#PIDIDX[*]}" -gt 0 ]; do sleep 1; done

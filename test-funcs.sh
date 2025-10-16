#!/bin/sh -x
#
# test-funcs.sh <device>
#

errExit () {
  echo "ERROR: $*" 1>&2
  exit 1
}

usage () {
  echo "Usage: test-funcs.sh [-n] <device>" 1>&2
  exit 1
}

if [ ! -f "./wapi.sh" ]; then
  errExit ./wapi.sh does not exist
fi

while [ $# -gt 0 ]
do
  case $1 in
  -n*)  noDeletion=yes
        shift
        ;;
  -*)   usage  # wrong option
        ;;
   *)   break  # no more options
        ;;
  esac
  shift        # get next option
done
if [ $# -lt 1 ]; then
  usage
fi
_dev=$1
. ./wapi.sh

#
# cleanUp <device> <view-id> message...
#
cleanUp () {
  if [ $# -lt 2 ]; then
    errExit "cleanUp: need at least 2 parameters"
  fi
  wapi del $1 $2
  shift; shift
  errExit $*
}

#
# View
#
echo "Adding View 'TestView'" 1>&2
_view=TestView
resp=`addView $_dev $_view`
if echo $resp | grep 'Error.*already exists' > /dev/null ; then
  echo "DNS View $_view already exists." 1>&2
elif echo $resp | grep 'Error' > /dev/null ; then
  errExit "$resp"
else
  echo $resp
  _viewID=`echo $resp | sed 's/\"//g'`
fi

#
# Zone
#
echo "Adding Zone 'foo01.com' to 'TestView'" 1>&2
_zone=foo01.com
resp=`addZone $_dev $_view $_zone`
if echo $resp | grep 'Error.*already exists' > /dev/null ; then
  echo "Authoritative zone $_zone already exist." 1>&2
elif echo $resp | grep 'Error' > /dev/null ; then
 cleanUp $_dev $_viewID $resp
else
  echo $resp
  _zoneID=$resp
fi

#
# A record
#
_host=v4host01
_fqdn=${_host}.${_zone}
echo "Adding A record '$_fqdn' to 'TestView'" 1>&2
resp=`addArecord $_dev $_view ${_host}.${_zone} 172.16.0.1`
if echo $resp | grep 'Error.*already exists' > /dev/null ; then
  echo "A record ${_host}.${_zone} already exists." 1>&2
elif echo $resp | grep 'Error' > /dev/null ; then
 cleanUp $_dev $_viewID $resp
else
  echo $resp
fi

#
# AAAA record
#
_host=v6host01
_fqdn=${_host}.${_zone}
echo "Adding AAAA record '$_fqdn' to 'TestView'" 1>&2
resp=`addAAAArecord $_dev $_view ${_host}.${_zone} 2001::1`
if echo $resp | grep 'Error.*already exists' > /dev/null ; then
  echo "AAAA record ${_host}.${_zone} already exists." 1>&2
elif echo $resp | grep 'Error' > /dev/null ; then
 cleanUp $_dev $_viewID $resp
else
  echo $resp
fi

#
# CAA record
#
_host=caa01
_fqdn=${_host}.${_zone}
echo "Adding CAA record '$_fqdn' to 'TestView'" 1>&2
resp=`addCAArecord $_dev $_view ${_host}.${_zone} 0 issue Test-CA-value`
if echo $resp | grep 'Error.*already exists' > /dev/null ; then
  echo "CAA record ${_host}.${_zone} already exists." 1>&2
elif echo $resp | grep 'Error' > /dev/null ; then
 cleanUp $_dev $_viewID $resp
else
  echo $resp
fi


#!/bin/sh -x
#
# wapi.sh: Shell functions for WAPI
#
# Repository:
#   https://github.com/yhariguchi-infoblox/wapi.sh/tree/main
#

#
# Default authentication info
#
__auth=admin:infoblox

#
# wapi <del|get|put|post> <device> <obj> [...]
#
wapi () {
  if [ $# -lt 3 ]; then
    echo "Usage: wapi <get|put|post> <device> <obj> [...]" 1>&2
    return 1
  fi
  case $1 in
    'del') _cmd=DELETE
           ;;
    'get') _cmd=GET
           ;;
    'post') _cmd=POST
           ;;
    'put') _cmd=PUT
           ;;
    *) echo "ERROR: ${1}: wrong command." 1>&2
       return 1
       ;;
  esac
  _dev=$2
  _obj=$3
  shift; shift; shift

  curl -s -k1 -u $__auth \
       -H "content-type:application/json" \
       -X $_cmd \
       https://$_dev/wapi/v2.13.7/$_obj $*
}

#
# addView <device> <view>
#
addView () {
  if [ $# -lt 2 ]; then
    echo "Usage: addView <device> <view>" 1>&2
    return 1
  fi
  curl -s -k1 -u $__auth \
       -H "content-type:application/json" \
       -X POST \
       https://$1/wapi/v2.13.7/view \
       -d '{"name": "'$2'"}'
}

#
# addZone <device> <view> <zone>
#
addZone () {
  if [ $# -lt 3 ]; then
    echo "Usage: addZone <device> <view> <zone>" 1>&2
    return 1
  fi
  _serial=`date +%Y%m%d`01
  curl -s -k1 -u $__auth \
     -H "content-type:application/json" \
     -X POST \
     https://$1/wapi/v2.13.7/zone_auth \
     -d '{
       "fqdn": "'$3'",
       "view": "'$2'",
       "grid_primary": [
         {
           "name": "infoblox.localdomain",
           "stealth": false
         }
       ],
       "soa_mname": "ns1.'$3'",
       "soa_email": "admin@'$3'", 
       "soa_refresh": 10800,
       "soa_retry": 3600,
       "soa_expire": 2419200,
       "soa_default_ttl": 86400,
       "soa_negative_ttl": 900,
       "soa_serial_number": '$_serial'
     }'                                     
}

#
# addArecord <device> <view> <fqdn> <ipv4a> [ttl]
#
addArecord () {
  if [ $# -lt 4 ]; then
    echo "Usage: addArecord <device> <view> <fqdn> <ipv4a> [ttl]" 1>&2
    return 1
  fi
  if [ $# -gt 4 ]; then
    curl -s -k1 -u $__auth \
         -H "content-type:application/json" \
         -X POST \
         https://$1/wapi/v2.13.7/record:a \
         -d '{
           "name": "'$3'",
           "view": "'$2'",
           "ipv4addr": "'$4'",
           "use_ttl": true,
           "ttl": '${5}'
         }'
  else
    curl -s -k1 -u $__auth \
         -H "content-type:application/json" \
         -X POST \
         https://$1/wapi/v2.13.7/record:a \
         -d '{
           "name": "'$3'",
           "view": "'$2'",
           "ipv4addr": "'$4'"
         }'
  fi
}

#
# addAAAArecord <device> <view> <fqdn> <ipv6a> [ttl]
#
addAAAArecord () {
  if [ $# -lt 4 ]; then
    echo "Usage: addAAAArecord <device> <view> <fqdn> <ipv6a> [ttl]" 1>&2
    return 1
  fi
  if [ $# -gt 4 ]; then
    curl -s -k1 -u $__auth \
         -H "content-type:application/json" \
         -X POST \
         https://$1/wapi/v2.13.7/record:aaaa \
         -d '{
           "name": "'$3'",
           "view": "'$2'",
           "ipv6addr": "'$4'",
           "use_ttl": true,
           "ttl": '${5}'
         }'
  else
    curl -s -k1 -u $__auth \
         -H "content-type:application/json" \
         -X POST \
         https://$1/wapi/v2.13.7/record:aaaa \
         -d '{
           "name": "'$3'",
           "view": "'$2'",
           "ipv6addr": "'$4'"
         }'
  fi
}

#
# addCAArecord <device> <view> <fqdn> <flag> <tag> <ca-value> [ttl]
#
addCAArecord () {
  if [ $# -lt 4 ]; then
    echo "Usage: addCAArecord <device> <view> <fqdn> <flag> <tag> <ca-vlalue> [ttl]" 1>&2
    echo "  flag:      0 - 255" 1>&2
    echo "  tag:       issue, issuewild, iodef" 1>&2
    echo "  ca-value:  string" 1>&2
    return 1
  fi
  if [ $# -gt 6 ]; then
    curl -s -k1 -u $__auth \
         -H "content-type:application/json" \
         -X POST \
         https://$1/wapi/v2.13.7/record:caa \
         -d '{
           "name": "'$3'",
           "view": "'$2'",
           "ca_flag": '$4',
           "ca_tag": "'$5'",
           "ca_value": "'$6'",
           "use_ttl": true,
           "ttl": '${7}'
         }'
  else
    curl -s -k1 -u $__auth \
         -H "content-type:application/json" \
         -X POST \
         https://$1/wapi/v2.13.7/record:caa \
         -d '{
           "name": "'$3'",
           "view": "'$2'",
           "ca_flag": '$4',
           "ca_tag": "'$5'",
           "ca_value": "'$6'"
         }'
  fi
}

#
# addCNAMErecord <device> <view> <fqdn> <canonical> [ttl]
#
addCNAMEecord () {
  if [ $# -lt 4 ]; then
    echo "Usage: addCNAMErecord <device> <view> <fqdn> <canonical> [ttl]" 1>&2
    echo "  canonical: the fqdn to be redirected to (fqdn -> canonical)" 1>&2
    return 1
  fi
  if [ $# -gt 4 ]; then
    curl -s -k1 -u $__auth \
         -H "content-type:application/json" \
         -X POST \
         https://$1/wapi/v2.13.7/record:cname \
         -d '{
           "name": "'$3'",
           "view": "'$2'",
           "canonical": "'$4'",
           "use_ttl": true,
           "ttl": '${5}'
         }'
  else
     curl -s -k1 -u $__auth \
          -H "content-type:application/json" \
          -X POST \
          https://$1/wapi/v2.13.7/record:cname \
          -d '{
            "name": "'$3'",
            "view": "'$2'",
            "canonical": "'$4'"
          }'
  fi
}

#
# addDNAMErecord <device> <view> <domain> <target> [ttl]
#
addDNAMEecord () {
  if [ $# -lt 4 ]; then
    echo "Usage: addDNAMErecord <device> <view> <domain> <target> [ttl]" 1>&2
    echo "  target: <domain> to be redirected to" 1>&2
    return 1
  fi
  if [ $# -gt 4 ]; then
    curl -s -k1 -u $__auth \
         -H "content-type:application/json" \
         -X POST \
         https://$1/wapi/v2.13.7/record:dname \
         -d '{
           "name": "'$3'",
           "view": "'$2'",
           "target": "'$4'",
           "use_ttl": true,
           "ttl": '${5}'
         }'
  else
    curl -s -k1 -u $__auth \
         -H "content-type:application/json" \
         -X POST \
         https://$1/wapi/v2.13.7/record:dname \
         -d '{
           "name": "'$3'",
           "view": "'$2'",
           "target": "'$4'"
         }'
  fi
}

#
# addHTTPSrecord <device> <view> <name> <target> <priority> [ttl]
#
addHTTPSrecord () {
  if [ $# -lt 5 ]; then
    echo "Usage: addHTTPSrecord <device> <view> <name> <target> <priority> [ttl]" 1>&2
    return 1
  fi
  if [ $# -gt 5 ]; then
    curl -s -k1 -u $__auth \
         -H "content-type:application/json" \
         -X POST \
         https://$1/wapi/v2.13.7/record:https \
         -d '{
           "name": "'$3'",
           "view": "'$2'",
           "target_name": "'$4'",
           "priority": '${5}',
           "use_ttl": true,
           "ttl": '${6}'
         }'
  else
    curl -s -k1 -u $__auth \
         -H "content-type:application/json" \
         -X POST \
         https://$1/wapi/v2.13.7/record:https \
         -d '{
           "name": "'$3'",
           "view": "'$2'",
           "target_name": "'$4'",
           "priority": '${5}'
         }'
  fi
}

#
# addHOSTrecord <device> <view> <fqdn> <ipaddr> [ttl]
#
addHOSTrecord () {
  if [ $# -lt 4 ]; then
    echo "Usage: addHTTPSrecord <device> <view> <fqdn> <ipaddr> [ttl]" 1>&2
    return 1
  fi
  if echo $4 | grep : > /dev/null ; then
    _addr=ipv6addr
  else
    _addr=ipv4addr
  fi
  if [ $# -gt 4 ]; then
    curl -s -k1 -u $__auth \
         -H "content-type:application/json" \
         -X POST \
         https://$1/wapi/v2.13.7/record:host \
         -d '{
           "name": "'$3'",
           "view": "'$2'",
           "'${_addr}s'": [{"'${_addr}'":"'$4'"}],
           "use_ttl": true,
           "ttl": '${5}'
         }'
  else
    curl -s -k1 -u $__auth \
         -H "content-type:application/json" \
         -X POST \
         https://$1/wapi/v2.13.7/record:host \
         -d '{
           "name": "'$3'",
           "view": "'$2'",
           "'${_addr}s'": [{"'${_addr}'":"'$4'"}]
         }'
  fi
}

#
# addMXrecord <device> <view> <fqdn> <mx> <preference> [ttl]
#
addMXrecord () {
  if [ $# -lt 5 ]; then
    echo "Usage: addMXrecord <device> <view> <fqdn> <mx> <preference> [ttl]" 1>&2
    return 1
  fi
  if [ $# -gt 5 ]; then
    curl -s -k1 -u $__auth \
         -H "content-type:application/json" \
         -X POST \
         https://$1/wapi/v2.13.7/record:mx \
         -d '{
           "name": "'$3'",
           "view": "'$2'",
           "mail_exchanger": "'$4'",
           "preference": '$5',
           "use_ttl": true,
           "ttl": '${5}'
         }'
  else
    curl -s -k1 -u $__auth \
         -H "content-type:application/json" \
         -X POST \
         https://$1/wapi/v2.13.7/record:mx \
         -d '{
           "name": "'$3'",
           "view": "'$2'",
           "mail_exchanger": "'$4'",
           "preference": '$5'
         }'
  fi
}

#
# addNAPTRrecord <device> <view> <fqdn> <replace> <order> <preference> [ttl]
#
addNAPTRrecord () {
  if [ $# -lt 6 ]; then
    echo "Usage: addNAPTRrecord <device> <view> <fqdn> <replace> <order> <preference> [ttl]" 1>&2
    return 1
  fi
  if [ $# -gt 6 ]; then
    curl -s -k1 -u $__auth \
         -H "content-type:application/json" \
         -X POST \
         https://$1/wapi/v2.13.7/record:naptr \
         -d '{
           "name": "'$3'",
           "view": "'$2'",
           "replacement": "'$4'",
           "order": '$5',
           "preference": '$6',
           "use_ttl": true,
           "ttl": '${7}'
         }'
  else
    curl -s -k1 -u $__auth \
         -H "content-type:application/json" \
         -X POST \
         https://$1/wapi/v2.13.7/record:naptr \
         -d '{
           "name": "'$3'",
           "view": "'$2'",
           "replacement": "'$4'",
           "order": '$5',
           "preference": '$6'
         }'
  fi
}

#
# addPTRrecord <device> <view> <fqdn> <ptr-domain> [ttl]
#
addPTRrecord () {
  if [ $# -lt 4 ]; then
    echo "Usage: addPTRrecord <device> <view> <fqdn> <ptr-domain> [ttl]" 1>&2
    return 1
  fi
  if [ $# -gt 4 ]; then
    curl -s -k1 -u $__auth \
         -H "content-type:application/json" \
         -X POST \
         https://$1/wapi/v2.13.7/record:ptr \
         -d '{
           "name": "'$3'",
           "view": "'$2'",
           "ptrdname": "'$4'",
           "use_ttl": true,
           "ttl": '${5}'
         }'
  else
    curl -s -k1 -u $__auth \
         -H "content-type:application/json" \
         -X POST \
         https://$1/wapi/v2.13.7/record:ptr \
         -d '{
           "name": "'$3'",
           "view": "'$2'",
           "ptrdname": "'$4'"
         }'
  fi
}

#
# addSRVrecord <device> <view> <name> <target> <port> <priority> <weight> [ttl]
#
addSRVrecord () {
  if [ $# -lt 7 ]; then
    echo "Usage: addSRVrecord <device> <view> <name> <target> <port> <priority> <weight> [ttl]" 1>&2
    echo "  name example: _http._tcp.foo01.com" 1>&2
    return 1
  fi
  if [ $# -gt 7 ]; then
    curl -s -k1 -u $__auth \
         -H "content-type:application/json" \
         -X POST \
         https://$1/wapi/v2.13.7/record:srv \
         -d '{
           "name": "'$3'",
           "view": "'$2'",
           "target": "'$4'",
           "port": '$5',
           "priority": '$6',
           "weight": '$7',
           "use_ttl": true,
           "ttl": '${8}'
         }'
  else
    curl -s -k1 -u $__auth \
         -H "content-type:application/json" \
         -X POST \
         https://$1/wapi/v2.13.7/record:srv \
         -d '{
           "name": "'$3'",
           "view": "'$2'",
           "target": "'$4'",
           "port": '$5',
           "priority": '$6',
           "weight": '$7'
         }'
  fi
}

#
# addSVCBrecord <device> <view> <name> <target> <priority> [ttl]
#
addSVCBrecord () {
  if [ $# -lt 5 ]; then
    echo "Usage: addSVCBrecord <device> <view> <name> <target> <priority> [ttl]" 1>&2
    echo "  name example: _80._http.http01.foo01.com" 1>&2
    return 1
  fi
  if [ $# -gt 5 ]; then
    curl -s -k1 -u $__auth \
         -H "content-type:application/json" \
         -X POST \
         https://$1/wapi/v2.13.7/record:svcb \
         -d '{
           "name": "'$3'",
           "view": "'$2'",
           "target_name": "'$4'",
           "priority": '$5',
           "use_ttl": true,
           "ttl": '${6}'
         }'
  else
    curl -s -k1 -u $__auth \
         -H "content-type:application/json" \
         -X POST \
         https://$1/wapi/v2.13.7/record:svcb \
         -d '{
           "name": "'$3'",
           "view": "'$2'",
           "target_name": "'$4'",
           "priority": '$5'
         }'
  fi
}

#
# addTLSArecord <device> <view> <name> <cert-data> <cert-usage> <matched-type> <selector> [ttl]
#
addTLSArecord () {
  if [ $# -lt 7 ]; then
    echo "Usage: addTLSArecord <device> <view> <name> <cert-data> <cert-usage> <matched-type> <selector> [ttl]" 1>&2
    echo "  name example:      _443._tcp.tlsa01.foo01.com" 1>&2
    echo "  Certificate Usage: 0: PKIX-TA, 1: PKIX-EE, 2: DANE-TA, 3: DANE-EE" 1>&2
    echo "  Matched Type:      0: No hash, 1: SHA 256, 2: SHA 512" 1>&2
    echo "  Selector:          0: Full certificate, 1: Subject PKI" 1>&2
    return 1
  fi
  if [ $# -gt 7 ]; then
    curl -s -k1 -u $__auth \
         -H "content-type:application/json" \
         -X POST \
         https://$1/wapi/v2.13.7/record:tlsa \
         -d '{
           "name": "'$3'",
           "view": "'$2'",
           "certificate_data": "'$4'",
           "certificate_usage": '$5',
           "matched_type": '$6',
           "selector": '$7',
           "use_ttl": true,
           "ttl": '${8}'
         }'
  else
    curl -s -k1 -u $__auth \
         -H "content-type:application/json" \
         -X POST \
         https://$1/wapi/v2.13.7/record:tlsa \
         -d '{
           "name": "'$3'",
           "view": "'$2'",
           "certificate_data": "'$4'",
           "certificate_usage": '$5',
           "matched_type": '$6',
           "selector": '$7'
         }'
  fi
}

#!/bin/bash

#Exclude IPs
function exclude_ips() {
    echo -e "\nEXCLUDE IPS"
    echo "-------------------------------"    
    if [[ -z "${EXCLUDE_IPS}" ]]
    then
        echo "None"
    else
        ips=""

        echo $'\n' >> ${1}
        echo "#GOAN_EXCLUDE_IPS" >> ${1}
        IFS=','
        read -ra ADDR <<< "$EXCLUDE_IPS"
        for ip in "${ADDR[@]}"; do
            echo ${ip}
            echo "exclude-ip ${ip}" >> ${1}
        done
        unset IFS
    fi
}

function set_geoip_database() {
    echo -e "\nSetting GeoIP Database"
    echo "-------------------------------"
    echo "DEFAULT"
    
    echo $'\n' >> ${1}
    echo "#GOAN_MAXMIND_DB" >> ${1}
    echo "geoip-database /goaccess-config/GeoLite2-City.mmdb" >> ${1}
    echo "geoip-database /goaccess-config/GeoLite2-ASN.mmdb" >> ${1}
    echo "geoip-database /goaccess-config/GeoLite2-Country.mmdb" >> ${1}
}
#!/bin/bash
function npm_init(){
    goan_config="/goaccess-config/goaccess.conf"
    archive_log="/goaccess-config/archive.log"
    active_log="/goaccess-config/active.log"

    if [[ -f ${goan_config} ]]; then
        rm ${goan_config}
    else
        mkdir -p "/goaccess-config/"
        cp /goaccess-config/goaccess.conf.bak ${goan_config}
    fi

    echo -n "" > ${archive_log}
    echo -n "" > ${active_log}
}

function npm_goaccess_config(){
    echo -e "\n\n\n" >> ${goan_config}
    echo "######################################" >> ${goan_config}
    echo "# ${goan_version}" >> ${goan_config}
    echo "# GOAN_NPM_PROXY_CONFIG" >> ${goan_config}
    echo "######################################" >> ${goan_config}
    echo "time-format %T" >> ${goan_config}
    echo "date-format %d/%b/%Y" >> ${goan_config}
    echo "log_format [%d:%t %^] %^ %^ %s - %m %^ %v \"%U\" [Client %h] [Length %b] [Gzip %^] [Sent-to %^] \"%u\" \"%R\"" >> ${goan_config}
}

function npm(){
    npm_init
    npm_goaccess_config

    echo -e "\nLOADING NPM PROXY LOGS"
    echo "-------------------------------"

    echo $'\n' >> ${goan_config}
    echo "#GOAN_NPM_LOG_FILES" >> ${goan_config}
    echo "log-file ${archive_log}" >> ${goan_config}
    echo "log-file ${active_log}" >> ${goan_config}

    goan_log_count=0
    goan_archive_log_count=0

    echo -e "\n#GOAN_NPM_PROXY_FILES" >> ${goan_config}
    if [[ -d "${goan_log_path}" ]]; then
        
        echo -e "\n\tAdding proxy logs..."
        IFS=$'\n'
        for file in $(find "${goan_log_path}" -name 'proxy*host-*.log' ! -name "*_error.log");
        do
            if [ -f $file ]
            then
                if [ -r $file ] && R="Read = yes" || R="Read = No"
                then
                    echo "log-file ${file}" >> ${goan_config}
                    goan_log_count=$((goan_log_count+1))
                    echo -ne ' \t '
                    echo "Filename: $file | $R"
                else
                    echo -ne ' \t '
                    echo "Filename: $file | $R"
                fi
            else
                echo -ne ' \t '
                echo "Filename: $file | Not a file"
            fi
        done
        unset IFS

        echo -e "\tFound (${goan_log_count}) proxy logs..."

        echo -e "\n\tSKIP ARCHIVED LOGS"
        echo -e "\t-------------------------------"
        if [[ "${SKIP_ARCHIVED_LOGS}" == "True" ]]
        then
            echo -e "\tTRUE"
        else
            echo -e "\tFALSE"
            goan_archive_log_count=`ls -1 ${goan_log_path}/proxy-host-*_access.log*.gz 2> /dev/null | wc -l`

            if [ $goan_archive_log_count != 0 ]
            then 
                echo -e "\n\tAdding proxy archive logs..."

                IFS=$'\n'
                for file in $(find "${goan_log_path}" -name 'proxy-host-*_access.log*.gz' ! -name "*_error.log");
                do
                    if [ -f $file ]
                    then
                        if [ -r $file ] && R="Read = yes" || R="Read = No"
                        then
                            echo -ne ' \t '
                            echo "Filename: $file | $R"
                        else
                            echo -ne ' \t '
                            echo "Filename: $file | $R"
                        fi
                    else
                        echo -ne ' \t '
                        echo "Filename: $file | Not a file"
                    fi
                done
                unset IFS

                echo -e "\tAdded (${goan_archive_log_count}) proxy archived logs from ${goan_log_path}..."
                zcat -f ${goan_log_path}/proxy-host-*_access.log*.gz > ${archive_log}
            else
                echo -e "\tNo archived logs found at ${goan_log_path}..."
            fi
        fi

    else
        echo "Problem loading directory (check directory or permissions)... ${goan_log_path}"
    fi

    #additonal config settings
    exclude_ips             ${goan_config}
    set_geoip_database      ${goan_config}

    echo -e "\nRUN NPM GOACCESS"
    gotty /goaccess/goaccess --no-global-config --config-file=${goan_config} &
}
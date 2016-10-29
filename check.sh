#!/bin/bash
while [[ "$(date +"%T")" > '08:00:00' ]] && [[ "$(date +"%T")" < '17:00:00' ]]; do

    for ((i=1; i<=6; i++)); do

        #vars:
        site='devacademy.ro'
        pid=`netstat -tlpn | grep httpd | grep :80 | awk '{print $7}' | cut -d'/' -f1`

        #Check for http status code
        curl -L -s -o /dev/null -w "%{http_code}" $site > /dev/null 2>&1
        http_code_status=$?
        #echo $http_code_status

        #check if the service is running:
        systemctl status httpd | grep running > /dev/null 2>&1
        httpd_service_status=$?
        #echo $httpd_service_status

        #if we know the PID of the httpd server we can check for it:
        ps -f $pid > /dev/null 2>&1
        pid_status=$?
        #echo $pid_status

        #check if http is listening on port 80:
        netstat -tlpn | grep :80 | grep httpd > /dev/null 2>&1
        port_status=$?
        #echo $port_status

        #presupunem ca pagina contine textul "It works!"
        curl -s $site | grep works > /dev/null 2>&1
        page_status=$?
        #echo $page_status

        magic=$(($http_code_status + $httpd_service_status + $pid_status + $port_status + $page_status))

        #echo $magic

        if [ $magic == 0  ]; then
            echo "All ok"
        else
            /bin/systemctl restart httpd.service
            #echo $i "Sending mail to admin"
            echo "httpd not working! the exit code of restart command is $?" | /usr/sbin/sendmail admin@email.com
            if [ $i == 6 ]; then
                #echo "Sending mail to manager admin"
                echo "problem with httpd" | /usr/sbin/sendmail manager.admin@email.com
	    fi
        fi
        sleep 120
   done
done

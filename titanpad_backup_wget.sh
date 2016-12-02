#/bin/bash -x

# Titanpad is closing (thank you so much guys!) it is time to bak up our pads.
# The native download as zip option did not work for us. It seems we had just too much pads (around 600) for the sever to handle.

# So I tunned this bash script to wget and backup my pads: https://github.com/AlfaSchz/titanpad-backup-tool
# Forked from: https://github.com/domenkozar/titanpad-backup-tool/blob/master/titanpad_backup.sh

# The most tricky part was re-login once the sesion expires and keep looping through the pads. Line 77 does the trick.
# I also removed the zipping bit, the cron bit (since this should be a one time and goodbye backup) and left it verbose.

# Please use it gently or we might overload titanpad.com servers. Any improvement, specially in this regard, would be very welcome ;)

# Alfa https://twitter.com/alfaschz
# Licence: CC - Multiply and spread! :) and also https://github.com/AlfaSchz/titanpad-backup-tool/blob/master/LICENSE

DOMAIN=
USER=
PASSWORD=

usage() {
     echo "Usage: $0 [-hx] -d <subdomain> {-u <user> -p <password> | -a <user-password-file>}" 1>&2;
     echo "	-h	This usage note"
     echo "	-d	Subdomain to backup"
     echo "	-u	Username"
     echo "	-p	Password"
     echo "	-a	File containing Username (first line) and Password (second line)"
     exit 1;
}

# make sure backup directory exists
ensure_paths() {
    mkdir -p ./$LOCATION/$DOMAIN.titanpad.com
    touch $COOKIE
}

# login and set cookie
login() {
    wget --no-check-certificate \
         --keep-session-cookies \
         -O /dev/null \
         --save-cookies $COOKIE \
        "https://$DOMAIN.titanpad.com/"
    wget --no-check-certificate \
         --load-cookies $COOKIE \
         -O /dev/null \
         --post-data "email=$USER&password=$PASSWORD" \
         "https://$DOMAIN.titanpad.com/ep/account/sign-in" 
}

# remove cookie
logout() {
    rm $COOKIE
}

# download the newest pad
#--tries=10 -w 200m --waitretry=10 
#--load-cookies $COOKIE 
download_pad_list() {
    wget --load-cookies $COOKIE \
         --no-check-certificate \
         --quiet \
         -q -O ./$LOCATION/all-pads.html \
         "https://$DOMAIN.titanpad.com/ep/padlist/all-pads"; \
    > ./$LOCATION/extract-pads-list.txt;
    CLASSTITLE=$(grep -o -m 1 title.*href= ./$LOCATION/all-pads.html);
    PADURL='class="'$CLASSTITLE'"';
    grep -Po "(?<=$PADURL)[^\"]*" ./$LOCATION/all-pads.html | while read pads; do echo "https://$DOMAIN.titanpad.com/ep/pad/view"$pads'/latest' >> ./$LOCATION/extract-pads-list.txt; done; \
    }


download_pad_and_check(){
    wget --load-cookies $COOKIE \
    --no-check-certificate \
    -P ./$LOCATION/ \
    -p \
    $1 2>&1 | tee /dev/tty | if grep -o "sign-in"; then login && download_pad_and_check $1; else sed -i '1d' ./$LOCATION/extract-pads-list.txt; fi;
}
    
download_pads() {
    while read pad; do \
      download_pad_and_check $pad;
    done < ./$LOCATION/extract-pads-list.txt;
}


while getopts ":d:u:p:a:x" o; do
    case "${o}" in
        d)
            DOMAIN=${OPTARG}
            ;;
        a)
            USER_PASSWORD_FILE=${OPTARG}
            ;;
        u)
            USER=${OPTARG}
            ;;
        p)
            PASSWORD=${OPTARG}
            ;;
        *)
            usage
            ;;
    esac
done

LOCATION=$DOMAIN-titanpad_backup_pads_$(date "+%Y-%m-%d")
COOKIE=./$LOCATION/.cookie


ensure_paths
login
download_pad_list
download_pads
logout

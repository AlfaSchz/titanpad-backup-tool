#/bin/bash -x

# Titanpad is closing (thank you so much guys!) it is time to back up our pads.
# The native download as zip option did not work for us. Maybe too much pads for the sever to handle.

# So I tunned this bash script to wget and backup our pads: https://github.com/AlfaSchz/titanpad-backup-tool
# Forked from: https://github.com/domenkozar/titanpad-backup-tool/blob/master/titanpad_backup.sh

# The most tricky part was re-login once the sesion expires and keep looping through the pads. Function download_pad_and_check() does the trick.
# I also removed the zipping bit, the cron bit (since this should be a one time and goodbye backup) and left it verbose.

# Please use it gently or we might overload titanpad.com servers. Any improvement, specially in this regard, would be very welcome ;)

# Note: The pads will be backed up in your local computer. The backup will contain only the latest version of the pad but it will still show the colors of the authors. The timeslider does not work.

# By Alfa https://twitter.com/alfaschz
# Licence: CC - Multiply and spread! :) and also https://github.com/AlfaSchz/titanpad-backup-tool/blob/master/LICENSE

DOMAIN=
USER=
PASSWORD=

usage() {
     echo "Usage: $0 [-hx] -d <subdomain> {-u <user> -p <password> | -a <user-password-file>}" 1>&2;
     echo "	-h	This usage note"
     echo "	-d	Subdomain to backup"
     echo "	-u	Username (mail)"
     echo "	-p	Password"
     echo "	-a	File containing Username (first line) and Password (second line)"
     echo "	"
     echo "	_Example_"
     echo "	domain: mypads.titanpad.com"
     echo "	user: joe@mail.com"
     echo "	password: piZZaword"
     echo "	"
     echo "	./titanpad-backup-wget.sh -d mypads {-u joe@mail.com -p piZZaword}"
     echo "	"
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

# Download the pad list. Download the first pad out of the loop to wget the --page-requisites only once. In the wget loop is not a good idea to keep downloading them since -k and -nc do not get alone well and -N does not work because there is no timestamp :-/ 
download_pad_list() {
    wget --load-cookies $COOKIE \
         --no-check-certificate \
         --quiet \
         -q -O ./$LOCATION/all-pads.html \
         "https://$DOMAIN.titanpad.com/ep/padlist/all-pads";
    > ./$LOCATION/extract-pads-list.txt;
    CLASSTITLE=$(grep -o -m 1 title.*href= ./$LOCATION/all-pads.html);
    PADURL='class="'$CLASSTITLE'"';
    grep -Po "(?<=$PADURL)[^\"]*" ./$LOCATION/all-pads.html | while read pads; do echo "https://$DOMAIN.titanpad.com/ep/pad/view"$pads'/latest' >> ./$LOCATION/extract-pads-list.txt; done;
    wget --load-cookies $COOKIE --no-check-certificate -k -p -e robots=off --random-wait -U mozilla -P ./$LOCATION/ $(sed -i -e '1 w /dev/stdout' -e '1d' ./$LOCATION/extract-pads-list.txt);
}


#Download pad. Check if sesion is expired, if so login again and keep looping from the last pad.
download_pad_and_check(){
    wget --load-cookies $COOKIE \
    --no-check-certificate \
    -x -k --random-wait -U mozilla\
    -P ./$LOCATION/ \
    $1 2>&1 | tee /dev/tty | if grep -o "sign-in"; then login && download_pad_and_check $1; else sed -i '1d' ./$LOCATION/extract-pads-list.txt; fi;
}
    
download_pads() {
    while read pad; do \
      download_pad_and_check $pad;
    done < ./$LOCATION/extract-pads-list.txt;
}

#Since we are not -p -k ing the wget loop to avoid downlad all the images, css, and js dozens of times (see above), we need to change its sources to relative local directories. 
local_folder_structure(){
  grep -rl "https://$DOMAIN.titanpad.com/static/" ./$LOCATION/$DOMAIN.titanpad.com/ep/pad/view/ | xargs sed -i "s#https://$DOMAIN..titanpad.com/static/#../../../../static/#g"
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

if [ -z "$DOMAIN" ];then
    usage
elif [ -z "$USER" ] || [ -z "$PASSWORD" ];then
    if [ -z "$USER_PASSWORD_FILE" ] || [ ! -f "$USER_PASSWORD_FILE" ] || [ ! -r "$USER_PASSWORD_FILE" ];then
        echo "No such file: $USER_PASSWORD_FILE"
        usage
    else
        USER=$(head -n1 < $USER_PASSWORD_FILE)
        PASSWORD=$(sed -n 2p $USER_PASSWORD_FILE)
        if [ -z "$USER" ] || [ -z "$PASSWORD" ];then
            echo "Couldn't parse user/password file. Must contain username and password separated by single newline."
            usage
        fi
    fi
fi


ensure_paths
login
download_pad_list
download_pads
logout
local_folder_structure

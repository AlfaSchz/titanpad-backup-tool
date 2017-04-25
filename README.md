# Titanpad backup wget script

---

Titanpad is closing (thank you so much guys!) and it is time to back up our pads.

The native download as zip option did not work for us. It seems we had just too much pads for the sever to handle.

So I tunned this [bash script](https://github.com/AlfaSchz/titanpad-backup-tool-wget/blob/master/titanpad_backup_wget.sh) to wget and make a local backup of our pads. Forked from [here](https://github.com/domenkozar/titanpad-backup-tool/blob/master/titanpad_backup.sh).

Please use it gently or we might overload titanpad.com servers. Any improvement, specially in this regard, would be very welcome ;)

 ***Note**: The pads will be backed up in your local computer. The backup will contain only the latest version of the pad but it will still show the colors of the authors. The timeslider does not work.*

---

Make backups of a [titanpad](https://github.com/titanpad/titanpad) subdomain.

Only the latest version of the pads (with colors/authors) will be backed up.

<!-- BEGIN-MARKDOWN-TOC -->
* [Usage](#usage)
* [Authentication](#authentication)

<!-- END-MARKDOWN-TOC -->

## Usage

```
Usage: ./titanpad_backup-wget.sh [-h] -d <subdomain> {-u <user> -p <password> | -a <user-password-file>}
	-h	This usage note
	-d	Subdomain to backup
	-u	Username (mail)
	-p	Password
	-a	File containing Username (first line) and Password (second line)
```

__Example__

 domain: mypads.titanpad.com  
 
 user: joe@mail.com 
 
 password: piZZword 

```
$ ./titanpad-backup-wget.sh -d mypads {-u joe@mail.com -p piZZaword}
```


## Authentication

If you don't want to specify a password on the command line, create a file `~/titanpad/.auth` containing username and password:

```
MyUsername
MySecretPassword
```

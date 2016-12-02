# titanpad-backup-tool

---

Titanpad is closing (thank you so much guys!) and it is time to back up our pads.

The native download as zip option did not work for us. It seems we had just too much pads (around 600) for the sever to handle them.

So I tunned this [bash script](https://github.com/AlfaSchz/titanpad-backup-tool/blob/master/titanpad_backup_wget.sh) to wget and backup my pads. Forked from [here](https://github.com/domenkozar/titanpad-backup-tool/blob/master/titanpad_backup.sh).

The most tricky part was re-login once the sesion expires and keep looping through the pads. Some grep, conditional and recursion does the trick.
I also removed the zipping bit, the cron bit (since this should be a one time and goodbye backup) and left it verbose.

Please use it gently or we might overload titanpad.com servers. Any improvement, specially in this regard, would be very welcome ;)

---

Make backups of a [titanpad](https://github.com/titanpad/titanpad) subdomain.

<!-- BEGIN-MARKDOWN-TOC -->
* [Usage](#usage)
* [Authentication](#authentication)

<!-- END-MARKDOWN-TOC -->

## Usage

```
Usage: ./titanpad_backup.sh [-hx] -d <subdomain> {-u <user> -p <password> | -a <user-password-file>}
	-h	This usage note
	-d	Subdomain to backup
	-u	Username
	-p	Password
	-a	File containing Username (first line) and Password (second line)
```

## Authentication

If you don't want to specify a password on the command line, create a file `~/titanpad/.auth` containing username and password:

```
MyUsername
MySecretPassword
```

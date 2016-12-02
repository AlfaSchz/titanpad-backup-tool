# titanpad-backup-tool

---
Titanpad is closing (thank you so much guys!) and it is time to back up our pads.
The native download as zip option did not work for me. It seems I had just too much pads (around 600) for the sever to handle it.
So I put together this [bash script](https://github.com/AlfaSchz/titanpad-backup-tool) to wget and backup my pads. Forked from [here](https://github.com/domenkozar/titanpad-backup-tool/blob/master/titanpad_backup.sh).

Please use it gently or it might overload titanpad.com servers.
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

# SpammersCheck
Script to control spammers on your server with exim.

<!-- <span style="color: red"><b>WARNING</b> - last commits (not described as "released") are under development and can not work <b>AT ALL</b> at your server</span> -->

## Table of Content
- [Short about script](#SpammersCheck)
- [Table of Content](#Table-of-Content)
- [What's needed to run script](#Prerequisites)
    - [How to download script and run it](#Installing-and-running)
- [Which packages were used to build it](#Built-With)
- [Versioning](#Versioning)
- [Authors](#Authors)
- [License](#License)

## Prerequisites

What things you need to install the software and how to install them:

*Mailx* - package to sending messages

_Debian/Ubuntu_
```
apt-get install mailutils
```

_Centos_
```
yum install mailx
```

*CSF* - Config Server Firewall
[Official tutorial from CSF team how to install their soft](https://download.configserver.com/csf/install.txt)

### Installing and running

Download script from below command or head to [releases](https://github.com/WhiteLeash/spammers-check-exim/releases) where you can find even older releases of this script.
```
wget https://github.com/WhiteLeash/spammers-check-exim/blob/master/script.sh
```

Before running script change in script your email address and check if exim mainlog is in same place as in your server.
```
vim script.sh
```

Then you can run script.
```
./script.sh
```

## Built With

* [Mailx](https://linux.die.net/man/1/mailx) - Send and receive Internet mail
* [Exim](https://www.exim.org/) - Message Transfer Agent made by University of Cambridge

## Versioning

We use Sequence-based identifiers for versioning.

Current version is 1.0.9-dev (**ALL** versions under 1.1 are under dev and can have issues with working on *servers*)

## Authors

* **Tymoteusz Stępień** - *Initial work* - [WhiteLeash](https://github.com/WhiteLeash)

See also the list of [contributors](https://github.com/WhiteLeash/spammers-check-exim/graphs/contributors) who participated in this project.

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details

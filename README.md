# SpammersCheck
Script to control spammers on your server with exim. 

## Prerequisites

What things you need to install the software and how to install them

*Mailx* - package to sending messages

_Debian/Ubuntu_
```
apt-get install mailutils
```

_Centos_
```
yum install mailx
```
### Installing and running

Download script
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

Current version is 1.0.1

## Authors

* **Tymoteusz Stępień** - *Initial work* - [WhiteLeash](https://github.com/WhiteLeash)

See also the list of [contributors](https://github.com/WhiteLeash/spammers-check-exim/graphs/contributors) who participated in this project.

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details

<h1 align="center">Meshcentral</h1>

<p align='justify'>

<a href="https://meshcentral.com/info/">Meshcentral</a> - is a full computer management web site. With MeshCentral, you can run your own web server to remotely manage and control computers on a local network or anywhere on the internet. Once you get the server started, create device group and download and install an agent on each computer you want to manage. A minute later, the new computer will show up on the web site and you can take control of it. MeshCentral includes full web-based remote desktop, terminal and file management capability 

</p>

## Meshcentral Docker Image 🐋
Image is based on [Alpine 3.17](https://hub.docker.com/repository/docker/johann8/alpine-meshcentral/general)

| pull | size | version | platform |
|:---------------------------------:|:----------------------------------:|:--------------------------------:|:--------------------------------:|
| ![Docker Pulls](https://img.shields.io/docker/pulls/johann8/alpine-meshcentral?style=flat-square) | ![Docker Image Size (latest by date)](https://img.shields.io/docker/image-size/johann8/alpine-meshcentral/latest) | [![](https://img.shields.io/docker/v/johann8/alpine-meshcentral?sort=date)](https://hub.docker.com/r/johann8/alpine-meshcentral/tags "Version badge") | ![](https://img.shields.io/badge/platform-amd64-blue "Platform badge") |

<h1 align="center">Installation and Configuration</h1>

- [Install Meshcentral docker container](#install-meshcentral-docker-container)
  - [Meshcentral mongodb configuration](#meshcentral-mongodb-configuration)
  - [Meshcentral general configuration](#meshcentral-general-configuration)
  - [Meshcentral SMTP configuration](#meshcentral-smtp-configuration)
- [Mongo database backup](#mongo-database-backup)
- [Mongo Database restore](#mongo-database-restore)
- [Move Meshcentral container to another host](#move-meshcentral-container-to-another-host])

## Install Meshcentral docker container

- Create folders
```bash
DOCKERDIR=/opt/meshcentral
mkdir -p ${DOCKERDIR}/data/{mongodb,mc}
mkdir -p ${DOCKERDIR}/data/mc/{data,user_files,backups,web}
mkdir -p ${DOCKERDIR}/data/mongodb/dbdata
cd ${DOCKERDIR}
tree -d -L 3 ${DOCKERDIR}
```

- Download files
```bash
DOCKERDIR=/opt/meshcentral
cd ${DOCKERDIR}
wget https://raw.githubusercontent.com/johann8/alpine-meshcentral/master/docker-compose.yml
wget https://raw.githubusercontent.com/johann8/alpine-meshcentral/master/docker-compose.override.yml
wget https://raw.githubusercontent.com/johann8/alpine-meshcentral/master/.env
```

- Adjust file `.env`
```bash
# for mongodb user "meshuser"
pwgen -1cnsB 25 1

# for mongodb user "root"
pwgen -1cnsB 30 1

# change two vars
vim .env
-----
...
HOSTNAME_MC=mc.changeme.de
DOMAINNAME=changeme.de
...
MONGO_MC_USER_PASSWORD=User-PW-ChangeMe135
...
MONGO_INITDB_ROOT_PASSWORD=Root-PW-ChangeMe579
...
-----
```

- Run `Meshcentral` docker container
```bash
docker-compose up -d
```

## Meshcentral mongodb configuration

- Create mongodb user for `meshcental`
```bash
DOCKERDIR=/opt/meshcentral
cd ${DOCKERDIR}
cat .env |grep MONGO_
docker compose exec mongodb mongosh --host localhost -u admin

# use database meshcentral 
use meshcentral

# create user "meshuser" und change password
db.createUser(
    {
        user: "meshuser",
        pwd: "User-PW-ChangeMe135",
        roles:[
            {
                role: "readWrite",
                db: "meshcentral"
            }
        ]
    }
);

# show created user
show users
exit
```
- Restart `Meshcentral` docker container
```bash
DOCKERDIR=/opt/meshcentral
cd ${DOCKERDIR}
docker-compose down && docker-compose up -d
docker-compose logs meshcentral
```

## Meshcentral general configuration

- Enable ssh/novnc/mstsc
```bash
DOCKERDIR=/opt/meshcentral
cd ${DOCKERDIR}

# Enter this block under section "domains", organization area
vim data/mc/data/config.json
-----
...
      "novnc":true,
      "mstsc":true,
      "ssh":true,
      "GeoLocation": true,
...
-----
```

- Enter company details 
```bash
DOCKERDIR=/opt/meshcentral
cd ${DOCKERDIR}

# Enter this block under section "domains", organization area
vim data/mc/data/config.json
-----
...
      "title": "REMOTE SUPPORT PORTAL",
      "title2": "Muster GmbH",
      "welcomeText": "<a href='https://changeme.de/' target='_blank' style='text-decoration: none;'>Muster GmbH Consulting</a> - IT Service in Berlin",
      "Footer": "<a href='https://changeme.de/' target='_blank' style='text-decoration: none;'>Muster GmbH Consulting</a> - IT Service in Berlin",
...
-----
```
- Increase security
```bash
DOCKERDIR=/opt/meshcentral
cd ${DOCKERDIR}

# Enter this block under section "domains", organization area
vim data/mc/data/config.json
-----
...
      "LoginKey":"ABCD94",
      "agentInviteCodes": true,
      "PasswordRequirements": {
         "min": 10,
         "max": 64,
         "upper": 1,
         "lower": 1,
         "numeric": 1,
         "nonalpha": 1,
         "_force2factor": true,
         "_backupcode2factor": true,
         "_single2factorWarning": false,
         "skip2factor": "127.0.0.1,172.26.8.0/24"
      },
...
-----
docker-compose down && docker-compose up -d

After that login page changes to: https://mc.changeme.de/login?key=ABCD94
```
- Enable backups under `main` section
```bash
DOCKERDIR=/opt/meshcentral
cd ${DOCKERDIR}
vim data/mc/data/config.json
-----
...
    "AutoBackup": {
       "backupIntervalHours": 24,
       "keepLastDaysBackup": 14,
       "backupPath": "/opt/meshcentral/meshcentral-backups"
    },
...
-----
```
- Enable `DesktopMultiplex`  under `main` section
```bash
DOCKERDIR=/opt/meshcentral
cd ${DOCKERDIR}
vim data/mc/data/config.json
-----
...
    "DesktopMultiplex": true,
    "AllowHighQualityDesktop": true,
...
-----
```

- Enable `WANonly` under `main` section
```bash
DOCKERDIR=/opt/meshcentral
cd ${DOCKERDIR}
vim data/mc/data/config.json
-----
...
    "WANonly": true,
...
-----
```

- Set `MaxInvalidLogin` under `main` section
```bash
DOCKERDIR=/opt/meshcentral
cd ${DOCKERDIR}
vim data/mc/data/config.json
-----
...
    "MaxInvalidLogin": {
       "time": 5,
       "count": 5,
       "coolofftime": 30
    },
    "AuthLog": "/opt/meshcentral/meshcentral-data/auth.log",
...
-----
```

## Meshcentral SMTP configuration

```bash
DOCKERDIR=/opt/meshcentral
cd ${DOCKERDIR}

# Enter this block under section "domains"
vim data/mc/data/config.json
-----
...
  "smtp": {
    "host": "smtp.changeme.de",
    "port": 587,
    "from": "meshcentral@changeme.de",
    "user": "meshcentral@changeme.de",
    "pass": "MySecretPassword123",
    "tls": false
   },
...
-----
```

## Mongo database backup

- Add to `config.json` option
```bash
DOCKERDIR=/opt/meshcentral
cd ${DOCKERDIR}

# Enter this block under section "domains"
vim data/mc/data/config.json
-----
...
    "AutoBackup": {
       "backupIntervalHours": 24,
       "keepLastDaysBackup": 15,
       "backupPath": "/opt/meshcentral/meshcentral-backups"
    },
...
-----
```

## Mongo Database restore
To restore back backup, just install a MeshCentral server, make sure it works correctly. Stop it, wipe the old `meshcentral-data` and `meshcentral-files` and put the backup version instead. If using MongoDB, copy the mongodump-xxx.archive back, make sure to clean up any existing `meshcentral` database. Restore backup.

- Unzip `meshcentral` backup on docker host
```bash
DOCKERDIR=/opt/meshcentral
cd ${DOCKERDIR}data/mc/backups/
unzip meshcentral-autobackup-2023-04-24-12-27.zip
rm -rf meshcentral-data
```

- Delete old database `meshcentral`
```bash
DOCKERDIR=/opt/meshcentral
cd ${DOCKERDIR}
cat .env |grep MONGO_
docker compose exec mongodb mongosh --host localhost -u admin
use meshcentral
db.dropDatabase()
exit
```

- Login into meshcentral docker container and restore db
```bash
DOCKERDIR=/opt/meshcentral
cd ${DOCKERDIR}
cat .env |grep MONGO_
docker-compose exec meshcentral sh
mongorestore --host=mongodb --port=27017 --authenticationDatabase="admin" -u="admin" -p="Root-PW-ChangeMe579" --archive=/opt/meshcentral/meshcentral-backups/mongodump-2023-04-24-12-27.archive

# restart container and show logs
DOCKERDIR=/opt/meshcentral
cd ${DOCKERDIR}
docker-compose down && docker-compose up -d
docker-compose logs -f --tail=1000 meshcentral
```
## Move Meshcentral container to another host

- Install `meshcentral` docker on the new server and make sure everything is working
```bash
# make a copy of folder data
DOCKERDIR=/opt/meshcentral
cd ${DOCKERDIR}
docker-compose stop meshcentral
cd data/mc/
mv data data_bkp
mkdir data

# copy all files from last backup into folder data E.g. with mc
# unzipp momgodb last backup in same folder
DOCKERDIR=/opt/meshcentral
cd ${DOCKERDIR}data/mc/backups/
unzip meshcentral-autobackup-2023-04-24-22-40.zip

# run container meshcentral
docker-compose start meshcentral

# delete old mongo database
DOCKERDIR=/opt/meshcentral
cd ${DOCKERDIR}
cat .env |grep MONGO_
docker-compose exec mongodb mongosh --host localhost -u admin
use meshcentral
db.dropDatabase()
exit

# restore database from last backup
DOCKERDIR=/opt/meshcentral
cd ${DOCKERDIR}
cat .env |grep MONGO_
docker-compose exec meshcentral sh
mongorestore --host=mongodb --port=27017 --authenticationDatabase="admin" -u="admin" -p="TsPee4ofzRqM7uVuA4vdnusugCxeHX" --archive=/opt/meshcentral/meshcentral-backups/mongodump-2023-04-24-22-40.archive

# restart container and show logs
DOCKERDIR=/opt/meshcentral
cd ${DOCKERDIR}
docker-compose down && docker-compose up -d
docker-compose logs -f --tail=1000 meshcentral
```

Enjoy!

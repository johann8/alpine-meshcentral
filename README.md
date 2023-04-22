<h1 align="center">Meshcentral</h1> ## 🐋

<p align='justify'>

<a href="https://glpi-project.org">Meshcentral</a> - is a full computer management web site. With MeshCentral, you can run your own web server to remotely manage and control computers on a local network or anywhere on the internet. Once you get the server started, create device group and download and install an agent on each computer you want to manage. A minute later, the new computer will show up on the web site and you can take control of it. MeshCentral includes full web-based remote desktop, terminal and file management capability 

</p>

## Meshcentral Docker Image
Image is based on [Alpine 3.17](https://hub.docker.com/repository/docker/johann8/alpine-meshcentral/general)

| pull | size | version | platform |
|:---------------------------------:|:----------------------------------:|:--------------------------------:|:--------------------------------:|
| ![Docker Pulls](https://img.shields.io/docker/pulls/johann8/alpine-meshcentral?style=flat-square) | ![Docker Image Size (latest by date)](https://img.shields.io/docker/image-size/johann8/alpine-meshcentral/latest) | [![](https://img.shields.io/docker/v/johann8/alpine-meshcentral?sort=date)](https://hub.docker.com/r/johann8/alpine-meshcentral/tags "Version badge") | ![](https://img.shields.io/badge/platform-amd64-blue "Platform badge") |

```bash
DOCKERDIR=/opt/meshcentral
mkdir -p ${DOCKERDIR}/data/{mongodb,mc}
mkdir -p ${DOCKERDIR}/data/mc/{data,user_files,backups,web}
mkdir -p ${DOCKERDIR}/data/mongodb/dbdata
cd ${DOCKERDIR}
tree -d -L 3 ${DOCKERDIR}
```

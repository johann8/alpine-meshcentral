<h1 align="center">Meshcentral</h1>

<p align='justify'>

<a href="https://glpi-project.org">Meshcentral</a> - is an open source IT Asset Management, issue tracking system and service desk system. This software is written in PHP and distributed as open-source software under the GNU General Public License.

GLPI is a web-based application helping companies to manage their information system. The solution is able to build an inventory of all the organization's assets and to manage administrative and financial tasks. The system's functionalities help IT Administrators to create a database of technical resources, as well as a management and history of maintenances actions. Users can declare incidents or requests (based on asset or not) thanks to the Helpdesk feature.
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

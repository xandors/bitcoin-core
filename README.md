# bitcoin-core

- [bitcoin-core](#bitcoin-core)
	- [Overview](#overview)
	- [docker](#docker)
		- [docker base directory](#docker-base-directory)
		- [build](#build)
		- [run](#run)
			- [deamon](#deamon)
			- [long time running](#long-time-running)
			- [test of long time running](#test-of-long-time-running)
		- [github docker repository login](#github-docker-repository-login)
		- [push](#push)
		- [Security Scan](#security-scan)
			- [anchore](#anchore)
				- [anchore install](#anchore-install)
				- [anchore test](#anchore-test)
				- [anchore evaluate](#anchore-evaluate)
			- [grype](#grype)
				- [grype install](#grype-install)
					- [grype install linux](#grype-install-linux)
					- [grype install  mac](#grype-install--mac)
				- [grype test](#grype-test)
	- [access log](#access-log)
		- [access log base directory](#access-log-base-directory)
		- [create sample file](#create-sample-file)
		- [bash](#bash)
			- [bash head 5 lines](#bash-head-5-lines)
			- [bash show all lines](#bash-show-all-lines)
		- [python](#python)
			- [python head 5 lines](#python-head-5-lines)
			- [python show all lines](#python-show-all-lines)
	- [IAM terraform](#iam-terraform)
		- [IAM terraform base directory](#iam-terraform-base-directory)
		- [IAM terraform run](#iam-terraform-run)
	- [K8s terraform](#k8s-terraform)
		- [K8s terraform base directory](#k8s-terraform-base-directory)
		- [K8s terraform run](#k8s-terraform-run)
	- [helm deploy](#helm-deploy)
		- [helm deploy base directory](#helm-deploy-base-directory)
		- [K8s terraform run](#k8s-terraform-run-1)
	- [CICD](#cicd)

## Overview

This repo have some resources related to bitcoin core.

## docker

Inspired in https://github.com/ruimarinho/docker-bitcoin-core/blob/master/22/Dockerfile

### docker base directory
```
cd docker
```

### build
```
$ docker buildx build --force-rm --platform linux/amd64 --tag bitcoin-core .
```
or
```
$ docker build --force-rm --build-arg TARGETPLATFORM=linux/amd64 --tag bitcoin-core .
```

### run

#### deamon
```
$ docker run --rm --platform linux/amd64 --name bitcoin bitcoin-core

Bitcoin Core starting
```

#### long time running
```
$ docker run --rm -it --platform linux/amd64 \
    -p 18443:18443 \
    -p 18444:18444 \
    --name bitcoin \
    bitcoin-core \
    --printtoconsole \
    -regtest=1 \
    -rpcallowip=172.17.0.0/16 \
    -rpcbind=0.0.0.0 \
    -rpcauth='foo:7d9ba5ae63c3d4dc30583ff4fe65a67e$9e3634e81c11659e3de036d0bf88f89cd169c1039e6e09607562d54765c649cc'
```

#### test of long time running
```
$ curl --data-binary '{"jsonrpc":"1.0","id":"1","method":"getnetworkinfo","params":[]}' http://foo:qDDZdeQ5vw9XXFeVnXT4PZ--tGN2xNjjR4nrtyszZx0=@127.0.0.1:18443/

{"result":{"version":220000,"subversion":"/Satoshi:22.0.0/","protocolversion":70016,"localservices":"0000000000000409","localservicesnames":["NETWORK","WITNESS","NETWORK_LIMITED"],"localrelay":true,"timeoffset":0,"networkactive":true,"connections":0,"connections_in":0,"connections_out":0,"networks":[{"name":"ipv4","limited":false,"reachable":true,"proxy":"","proxy_randomize_credentials":false},{"name":"ipv6","limited":false,"reachable":true,"proxy":"","proxy_randomize_credentials":false},{"name":"onion","limited":true,"reachable":false,"proxy":"","proxy_randomize_credentials":false},{"name":"i2p","limited":true,"reachable":false,"proxy":"","proxy_randomize_credentials":false}],"relayfee":0.00001000,"incrementalfee":0.00001000,"localaddresses":[],"warnings":""},"error":null,"id":"1"}
```

### github docker repository login
```
$ export CR_PAT=ghp_ABCDEFGHIJklmnopqrstuvwxyz0123456789
$ echo $CR_PAT | docker login ghcr.io -u xandors --password-stdin
```

### push
```
docker tag bitcoin-core:latest ghcr.io/xandors/bitcoin-core:latest
docker push ghcr.io/xandors/bitcoin-core:latest
```

### Security Scan

#### anchore

##### anchore install
```
pip3 install anchorecli
docker-compose up -d
export ANCHORE_CLI_URL=http://localhost:8228/v1
export ANCHORE_CLI_USER=admin
export ANCHORE_CLI_PASS=foobar
```

##### anchore test
```
anchore-cli system status
anchore-cli image add docker.io/library/debian:latest
anchore-cli image wait docker.io/library/debian:latest
anchore-cli image list
anchore-cli evaluate check docker.io/library/debian:latest
```

##### anchore evaluate
```
anchore-cli image add ghcr.io/xandors/bitcoin-core:latest
anchore-cli image wait ghcr.io/xandors/bitcoin-core:latest
anchore-cli image list
anchore-cli evaluate check ghcr.io/xandors/bitcoin-core:latest
```

```
$ anchore-cli image list
Full Tag                                           Image Digest                                                                   Analysis Status
docker.io/library/debian:latest                    sha256:c0508353648d7db3c313661409ca41a2d12c63a4d06007387679161a8372329f        analyzed
ghcr.io/xandors/bitcoin-core:latest                sha256:9883efa4ae0bc7f60b479e13d967c2609495aae52d71a102bbc23ec600909856        analyzed

$ anchore-cli evaluate check ghcr.io/xandors/bitcoin-core:latest
Image Digest: sha256:9883efa4ae0bc7f60b479e13d967c2609495aae52d71a102bbc23ec600909856
Full Tag: ghcr.io/xandors/bitcoin-core:latest
Status: pass
Last Eval: 2022-09-21T14:15:19Z
Policy ID: 2c53a13c-1765-11e8-82ef-23527761d060
```

#### grype

##### grype install

###### grype install linux
```
curl -sSfL https://raw.githubusercontent.com/anchore/grype/main/install.sh | sudo sh -s -- -b /usr/local/bin
```

###### grype install  mac
```
brew tap anchore/grype
brew install grype
```

##### grype test
```
$ if grype bitcoin-core:latest > /dev/null ; then echo passed ; else echo failed ; fi
 ✔ Vulnerability DB        [updated]
New version of grype is available: 0.50.2 (currently running: 0.50.1)
 ✔ Loaded image
 ✔ Parsed image
 ✔ Cataloged packages      [111 packages]
 ✔ Scanned image           [90 vulnerabilities]
passed
```

## access log

### access log base directory
```
cd ip-frequency
```

### create sample file
```
./create-file.sh
```

### bash

#### bash head 5 lines
```
./ip-frequency.sh ips.txt 5
```

#### bash show all lines
```
./ip-frequency.sh ips.txt 0
```

### python

#### python head 5 lines
```
./ip-frequency.sh ips.txt 5
```

#### python show all lines
```
./ip-frequency.sh ips.txt 0
```

## IAM terraform

### IAM terraform base directory
```
cd iam-terraform
```

### IAM terraform run
```
export AWS_PROFILE=default
export AWS_REGION=us-east-1
terraform init
terraform apply
```

## K8s terraform

### K8s terraform base directory
```
cd iam-terraform
```

### K8s terraform run
```
export AWS_PROFILE=default
export AWS_REGION=us-east-1
terraform init
terraform apply
```

## helm deploy

### helm deploy base directory
```
cd helm
```

### K8s terraform run
```
helm upgrade --install bitcoin-core ./bitcoin-core
```


## CICD

It will use the Github Actions to:

 - build the docker image
 - scan the docker image for security test
 - push the docker images
 - deploy de docker image using helm in the k8s cluster

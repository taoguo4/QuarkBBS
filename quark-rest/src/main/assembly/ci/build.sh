#!/bin/sh

# 1. svn : you should  fetch svn of "appstore-dubbo-service" and “common”

# 2. build
cd common/log-chain-spring-boot-starter
mvn clean install -Dmaven.test.skip=true
cd ../sclass-common-utils
mvn clean install -Dmaven.test.skip=true
cd ../edc-openapi-client
mvn clean install -Dmaven.test.skip=true
cd ../edc-openapi-client-spring-boot-starter
mvn clean install -Dmaven.test.skip=true
cd ../../appstore-dubbo-service
mvn clean package -Dbuild.version=1.0.${BUILD_SID} -Dmaven.test.skip=true

# 3. product : appstore-dubbo-service/target/*.tar.gz
FROM openjdk:8-jdk-alpine

ENV SONAR_SCANNER_VERSION 3.3.0.1492

COPY sonar-scanner-run.sh /usr/bin
COPY sonar-mvn-run.sh /usr/bin

ADD https://bintray.com/sonarsource/SonarQube/download_file?file_path=org%2Fsonarsource%2Fscanner%2Fcli%2Fsonar-scanner-cli%2F${SONAR_SCANNER_VERSION}%2Fsonar-scanner-cli-${SONAR_SCANNER_VERSION}.zip /tmp/sonar-scanner.zip

WORKDIR /tmp

RUN \
    unzip /tmp/sonar-scanner.zip && \
    mv -fv /tmp/sonar-scanner-${SONAR_SCANNER_VERSION}/bin/sonar-scanner /usr/bin && \
    mv -fv /tmp/sonar-scanner-${SONAR_SCANNER_VERSION}/lib/* /usr/lib

RUN \
    apk add --no-cache nodejs maven && \
    ls -lha /usr/bin/sonar* && \
    ln -s /usr/bin/sonar-scanner-run.sh /usr/bin/gitlab-sonar-scanner \
    ln -s /usr/bin/sonar-mvn-run.sh /usr/bin/gitlab-mvn-scanner \


RUN \
    apk add --update ca-certificates && rm -rf /var/cache/apk/* && \
    find /usr/share/ca-certificates/mozilla/ -name "*.crt" -exec keytool -import -trustcacerts \
    -keystore /usr/lib/jvm/java-1.8-openjdk/jre/lib/security/cacerts -storepass changeit -noprompt \
    -file {} -alias {} \; && \
    keytool -list -keystore /usr/lib/jvm/java-1.8-openjdk/jre/lib/security/cacerts --storepass changeit

WORKDIR /usr/bin

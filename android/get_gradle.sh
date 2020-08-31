#!/bin/bash

GRADLE_VERSION=6.1.1
curl -L -# -o /tmp/gradle-${GRADLE_VERSION}-bin.zip https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip
unzip -d /opt/gradle /tmp/gradle-${GRADLE_VERSION}-bin.zip
ln -s /opt/gradle/gradle-${GRADLE_VERSION} /opt/gradle/latest
export GRADLE_HOME=/opt/gradle/latest
export PATH=${GRADLE_HOME}/bin:${PATH}

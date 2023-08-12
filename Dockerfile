FROM debian:stable-slim
LABEL authors="Binozo"

# Updating
RUN apt-get update
RUN apt-get upgrade -y

# Installing dependencies
RUN apt-get install git make cmake wget unzip -y
RUN dpkg --add-architecture arm64
RUN dpkg --add-architecture armhf
RUN apt-get update
#RUN apt-get install gcc-multilib libpcap-dev libev-dev libnl-3-dev libnl-genl-3-dev libnl-route-3-dev -y
RUN apt-get install gcc-multilib linux-libc-dev linux-libc-dev:arm64 libpcap-dev:arm64 libev-dev:arm64 libnl-3-dev:arm64 libnl-genl-3-dev:arm64 libnl-route-3-dev:arm64 -y
RUN apt-get install linux-libc-dev:armhf libpcap-dev:armhf libev-dev:armhf libnl-3-dev:armhf libnl-genl-3-dev:armhf libnl-route-3-dev:armhf -y

# Cloning project
#ADD "https://github.com/Binozo/awl" skipcache
#RUN git clone https://github.com/Binozo/awl
WORKDIR /awl
COPY . .

# Setting up project
RUN git submodule update --init

# Install Android SDK & NDK
WORKDIR /android-sdk
RUN apt-get install openjdk-17-jre-headless -y
RUN wget https://dl.google.com/android/repository/commandlinetools-linux-9477386_latest.zip -O commandlinetools.zip
RUN unzip commandlinetools.zip
RUN rm commandlinetools.zip
ENV ANDROID_HOME=/android-sdk
ENV ANDROID_SDK=$ANDROID_HOME/cmdline-tools/bin
ENV PATH="${PATH}:${ANDROID_SDK}"

# Let sdkmanager install everything
RUN yes | sdkmanager --licenses --sdk_root=$ANDROID_SDK
RUN sdkmanager "platform-tools" "platforms;android-24" --sdk_root=$ANDROID_SDK
RUN sdkmanager --install "ndk;25.2.9519653" --sdk_root=$ANDROID_SDK
ENV ANDROID_NDK=/android-sdk/cmdline-tools/bin/ndk/25.2.9519653

# Installation completed. Now compile awl
WORKDIR /awl
RUN chmod +x build.sh
RUN ./build.sh
FROM debian:bullseye

# Use a faster mirror to avoid timeout errors
RUN sed -i 's|http://deb.debian.org/debian|http://deb.debian.org/debian|g' /etc/apt/sources.list && \
    sed -i 's|http://security.debian.org/debian-security|http://deb.debian.org/debian-security|g' /etc/apt/sources.list && \
    apt-get update && apt-get install -y ca-certificates

# Install required tools and dependencies
RUN apt-get update && apt-get install -y --fix-missing \
    build-essential cmake git curl wget \
    python3 python3-pip python3-venv \
    autoconf automake libtool flex bison \
    libsqlite3-dev sqlite3 \
    libmodbus-dev \
    libmicrohttpd-dev \
    unzip && \
    apt-get clean

FROM debian:bullseye

# Ensure system is up to date and required tools are installed
RUN apt-get update && apt-get upgrade -y && apt-get install -y --fix-missing \
    build-essential cmake git curl wget \
    python3 python3-pip python3-venv \
    autoconf automake libtool flex bison \
    libsqlite3-dev sqlite3 \
    libmodbus-dev \
    libmicrohttpd-dev \
    unzip && \
    apt-get clean

# Set working directory
WORKDIR /workdir

# Copy repo contents
COPY . /workdir

# Install OpenPLC
RUN ./install.sh docker && \
    mkdir -p /docker_persistent/st_files && \
    cp /workdir/webserver/openplc.db /docker_persistent/openplc.db && \
    mv /workdir/webserver/openplc.db /workdir/webserver/openplc_default.db && \
    cp /workdir/webserver/dnp3.cfg /docker_persistent/dnp3.cfg && \
    mv /workdir/webserver/dnp3.cfg /workdir/webserver/dnp3_default.cfg && \
    cp -r /workdir/webserver/st_files/ /docker_persistent/st_files/ && \
    mv /workdir/webserver/st_files /workdir/webserver/st_files_default && \
    cp /workdir/webserver/active_program /docker_persistent/active_program && \
    mv /workdir/webserver/active_program /workdir/webserver/active_program_default && \
    touch /docker_persistent/mbconfig.cfg && \
    touch /docker_persistent/persistent.file && \
    ln -s /docker_persistent/mbconfig.cfg /workdir/webserver/mbconfig.cfg && \
    ln -s /docker_persistent/persistent.file /workdir/webserver/persistent.file && \
    ln -s /docker_persistent/openplc.db /workdir/webserver/openplc.db && \
    ln -s /docker_persistent/dnp3.cfg /workdir/webserver/dnp3.cfg && \
    ln -s /docker_persistent/st_files /workdir/webserver/st_files && \
    ln -s /docker_persistent/active_program /workdir/webserver/active_program

# Expose port
EXPOSE 8080

# Start OpenPLC webserver
CMD ["python3", "webserver/main.py"]

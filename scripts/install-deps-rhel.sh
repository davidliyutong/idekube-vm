dnf install -y epel-release && \
dnf config-manager --set-enabled powertools && \
dnf install -y \
    gcc \
    gcc-c++ \
    make \
    ninja-build \
    meson \
    git \
    curl \
    autoconf \
    libtool \
    clang \
    flex \
    bison \
    libsysfs-devel \
    cloud-utils \
    glib2-devel \
    gtk3-devel \
    libmount-devel \
    pixman-devel \
    libusbx-devel \
    libslirp-devel \
    python3 \
    python3-pip

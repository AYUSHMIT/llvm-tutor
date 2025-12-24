# Dev container with LLVM, Clang, CMake, Ninja, Graphviz
FROM ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y wget gnupg lsb-release software-properties-common && \
    wget -O - https://apt.llvm.org/llvm-snapshot.gpg.key | gpg --dearmor -o /usr/share/keyrings/llvm-archive-keyring.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/llvm-archive-keyring.gpg] http://apt.llvm.org/$(lsb_release -cs)/ llvm-toolchain-$(lsb_release -cs)-21 main" | tee /etc/apt/sources.list.d/llvm.list && \
    apt-get update && \
    apt-get install -y \
      clang-21 llvm-21 llvm-21-dev lld-21 \
      cmake ninja-build build-essential \
      graphviz python3 python3-pip git && \
    ln -sf /usr/bin/clang-21 /usr/bin/clang && \
    ln -sf /usr/bin/opt-21 /usr/bin/opt && \
    ln -sf /usr/bin/llvm-dis-21 /usr/bin/llvm-dis && \
    useradd -ms /bin/bash vscode && \
    echo "vscode ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

USER vscode
WORKDIR /workspaces

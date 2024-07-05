# Use the official Ubuntu base image
FROM ubuntu:latest AS base

# Set environment variable to avoid prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Update the package list and install dependencies
RUN apt-get update && \
    apt-get install -y software-properties-common curl git zsh build-essential && \
    apt-add-repository --yes --update ppa:ansible/ansible && \
    apt-get install -y ansible && \
    apt-get clean autoclean && \
    apt-get autoremove --yes \
    rm -rf /var/lib/apt/lists/*

FROM base AS mkhai9x
ARG TAGS

RUN addgroup --gid 1000 mkhai9x
RUN adduser --gecos mkhai9x --uid 1000 --gid 1000 --disabled-password mkhai9x
# Set the working directory
USER theprimeagen
WORKDIR /home/mkhai9x


FROM mkhai9x
COPY . .
# Default command to run when container starts
CMD [ "ansible", "--version" ]
# CMD ["sh", "-c", "ansible-playbook $TAGS local.yml"]

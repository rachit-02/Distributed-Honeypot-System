FROM ubuntu:22.04

# Avoid prompts during apt installs
ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    python3-venv \
    git \
    libssl-dev \
    libffi-dev \
    build-essential \
    python3-dev \
    curl \
    dumb-init \
    && rm -rf /var/lib/apt/lists/*

# Add cowrie user
RUN useradd -m -s /bin/bash cowrie

USER cowrie
WORKDIR /home/cowrie

# Clone cowrie from github using https (more reliable)
RUN git clone https://github.com/cowrie/cowrie /home/cowrie/cowrie-app

WORKDIR /home/cowrie/cowrie-app

# Set up virtualenv and install cowrie requirements
RUN python3 -m venv cowrie-env && \
    . cowrie-env/bin/activate && \
    pip install --upgrade pip setuptools wheel && \
    pip install -r requirements.txt

# Copy cowrie config files into the container
COPY --chown=cowrie:cowrie cowrie/etc/cowrie.cfg.dist /home/cowrie/cowrie-app/etc/cowrie.cfg.dist
RUN test -f /home/cowrie/cowrie-app/etc/cowrie.cfg || cp /home/cowrie/cowrie-app/etc/cowrie.cfg.dist /home/cowrie/cowrie-app/etc/cowrie.cfg

# Expose ports: 2222 for SSH, 5000 for telnet/api
EXPOSE 2222 5000

# Healthcheck - check if SSH port is listening
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD bash -c 'timeout 2 bash -c "echo > /dev/tcp/localhost/2222" 2>/dev/null || exit 1'

# Use dumb-init to properly handle signals (PID 1)
ENTRYPOINT ["/usr/bin/dumb-init", "--"]

# Start cowrie in foreground mode using twistd
CMD [ "bash", "-c", "cd /home/cowrie/cowrie-app && . cowrie-env/bin/activate && twistd -n cowrie" ]

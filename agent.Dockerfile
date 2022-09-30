FROM mambaorg/micromamba:0.25.1

USER root

# Install Terraform CLI & npm
RUN apt-get update --yes && \
    # NPM 16+ Sources
    apt-get install --yes --no-install-recommends \
    # For new repo source
    gnupg \
    wget \
    software-properties-common \
    curl \
    && \
    # NPM v16+ Source
    curl -fsSL https://deb.nodesource.com/setup_16.x | bash - && \
    # For CDKTF
    apt-get install --yes --no-install-recommends nodejs && \
    # Install GPG Key for Terraform
    wget -O- https://apt.releases.hashicorp.com/gpg | \
    gpg --dearmor | \
    tee /usr/share/keyrings/hashicorp-archive-keyring.gpg && \
    # Add HashiCorp repository
    echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
    https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
    tee /etc/apt/sources.list.d/hashicorp.list && \
    # Install Terraform CLI
    apt-get update --yes && \
    apt-get install --yes terraform && \
    # Make a directory for NPM that can be used by the Mamba user
    mkdir -p /opt/node_modules && \
    chown $MAMBA_USER:$MAMBA_USER /opt/node_modules && \
    # Install CDKTF CLI
    npm i -g cdktf-cli@latest @cdktf/provider-aws @cdktf/provider-time && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

USER $MAMBA_USER

COPY --chown=$MAMBA_USER:$MAMBA_USER env.yaml /tmp/env.yaml

WORKDIR /home/$MAMBA_USER

# Python Dependencies
RUN micromamba install -y -n base -f /tmp/env.yaml && \
    micromamba clean --all --yes

# Use the base image from myoung34/github-runner
FROM myoung34/github-runner:ubuntu-jammy

# Add repo for NodeJS 20
RUN curl -sLf -o /dev/null 'https://deb.nodesource.com/node_20.x/dists/jammy/Release' && \
    curl -s https://deb.nodesource.com/gpgkey/nodesource.gpg.key | gpg --dearmor | tee /usr/share/keyrings/nodesource.gpg >/dev/null && \
    echo 'deb [signed-by=/usr/share/keyrings/nodesource.gpg] https://deb.nodesource.com/node_20.x jammy main' > /etc/apt/sources.list.d/nodesource.list && \
    echo 'deb-src [signed-by=/usr/share/keyrings/nodesource.gpg] https://deb.nodesource.com/node_20.x jammy main' >> /etc/apt/sources.list.d/nodesource.list

# Install dependencies and powershell
RUN apt-get update && apt install -y apt-transport-https software-properties-common && \
    curl -sSL "https://packages.microsoft.com/config/ubuntu/$(lsb_release -rs)/packages-microsoft-prod.deb" -o packages-microsoft-prod.deb && \
    dpkg -i packages-microsoft-prod.deb && rm packages-microsoft-prod.deb && \
    apt-get update && \
    apt install -y powershell

# Install .NET 6 and .NET 7 SDK
RUN apt install -y dotnet-runtime-6.0 && \
    apt install -y dotnet-runtime-7.0

# Install NodeJS 20
RUN apt install -y nodejs

# Install Azure CLI
RUN curl -sL https://aka.ms/InstallAzureCLIDeb | bash

# Install Az PowerShell Module
# Set PowerShell as the default shell
SHELL ["pwsh", "-Command"]
RUN Install-Module -Name Az -AllowClobber -Scope AllUsers -Force -SkipPublisherCheck

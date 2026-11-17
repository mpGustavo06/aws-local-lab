# ==============================================================================
# STAGE 1: Builder / Package Preparation
# ==============================================================================
FROM public.ecr.aws/amazonlinux/amazonlinux:2023-minimal AS builder

# Official URL of the AWS Emulator LTS package (can be overridden in the build)
ARG EMULATOR_RPM_URL="https://downloads.aws.com/aws-emulator/packages/aws-emulator/LTS/latest/aws-emulator-x86_64.rpm"

# Download the RPM package to the temporary folder
ADD ${EMULATOR_RPM_URL} /tmp/aws-emulator.rpm

# Installs curl (necessary for the healthcheck) and the emulator's RPM package, removing caches and installers in the same layer to keep the image lean
RUN microdnf install -y curl-minimal \
    && rpm -i /tmp/aws-emulator.rpm \
    && rm -f /tmp/aws-emulator.rpm \
    && microdnf clean all

# ==============================================================================
# STAGE 2: Runtime (Safe Execution without Privileges)
# ==============================================================================
FROM builder AS runtime

# Creates the home directory of the non-root user and adjusts the ownership (UID 1000)
RUN mkdir -p /home/emulator/.aws/emulator \
    && chown -R 1000:1000 /home/emulator

# Set the user without root privileges for security
USER 1000

# Default emulator environment variables
ENV HOME=/home/emulator \
    EMULATOR_TELEMETRY=off

WORKDIR /home/emulator

# Exposes the default port of the AWS Emulator
EXPOSE 9297 8098

# Starts the emulator listening on all network interfaces of the container
ENTRYPOINT ["aws-emulator", "-b", "0.0.0.0"]
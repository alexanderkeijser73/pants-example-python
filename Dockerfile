FROM python:3.9-slim
# install curl
RUN apt-get update && apt-get install -y curl git
RUN curl --proto '=https' --tlsv1.2 -fsSL https://static.pantsbuild.org/setup/get-pants.sh | bash
# add /root/bin to PATH
ENV PATH="/root/bin:${PATH}"

WORKDIR /app
COPY pants.toml .
# bootstrap pants
RUN pants --version
# CMD ["echo", "pants installed successfully"]
ENTRYPOINT ["bash"]

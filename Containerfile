# Use a imagem base do Terraform
FROM hashicorp/terraform:light

# Instalar dependências necessárias
RUN apk update && \
    apk add --no-cache \
        python3 \
        py3-pip \
        git \
        openssh-client

# Instalar Ansible
RUN pip3 install ansible

# Generate ssh key
RUN ssh-keygen -t rsa -b 2048 -f /root/.ssh/id_rsa -N ""

# Configurar o diretório de trabalho
WORKDIR /app

# Definir o entrypoint padrão
ENTRYPOINT ["/bin/sh"]

# Opcional: definir o comando padrão
CMD ["sh"]
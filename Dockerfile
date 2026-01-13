# 1. Usar uma base Python oficial (Debian Bookworm é a recomendada para Odoo 17+)
FROM python:3.11-slim-bookworm

# 2. Configurar variáveis de ambiente para evitar arquivos .pyc e buffer de log
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# 3. Instalar dependências de sistema necessárias para o Odoo e suas libs C
USER root
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    wget \
    git \
    libpq-dev \
    libxml2-dev \
    libxslt1-dev \
    libldap2-dev \
    libsasl2-dev \
    libjpeg-dev \
    zlib1g-dev \
    libffi-dev \
    # Dependência para geração de PDFs (wkhtmltopdf)
    fontconfig \
    libxrender1 \
    xfonts-75dpi \
    xfonts-base \
    && wget https://github.com/wkhtmltopdf/packaging/releases/download/0.12.6.1-3/wkhtmltox_0.12.6.1-3.bookworm_amd64.deb \
    && apt-get install -y ./wkhtmltox_0.12.6.1-3.bookworm_amd64.deb \
    && rm wkhtmltox_0.12.6.1-3.bookworm_amd64.deb \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# 4. Criar usuário do sistema para o Odoo
RUN useradd -m -d /opt/odoo -s /bin/bash odoo

# 5. Definir diretório de trabalho
WORKDIR /opt/odoo

# 6. Instalar dependências do Python primeiro (para aproveitar o cache do Docker)
COPY requirements.txt .
RUN pip3 install --no-cache-dir -r requirements.txt

# 7. Copiar o restante do projeto (toda a estrutura da imagem)
COPY . .

# 8. Ajustar permissões para o usuário odoo
RUN chown -R odoo:odoo /opt/odoo && chmod +x /opt/odoo/odoo-bin

# 9. Configurar o ponto de entrada
USER odoo
EXPOSE 8069 8071 8072

# Comando para iniciar o Odoo usando o binário da raiz
ENTRYPOINT ["./odoo-bin"]
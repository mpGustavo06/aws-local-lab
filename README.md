# ☁️ AWS Local Lab: AWS Emulator + StackPort UI + Terraform

Ambiente completo de desenvolvimento local para simular serviços da **AWS** utilizando o **AWS Emulator** oficial em Docker, gerido via **Terraform (IaC)** e acompanhado por uma interface visual web unificada (**StackPort**).

Este repositório provisiona uma arquitetura completa de exemplo para um sistema de armazenamento de arquivos com autenticação (VPC, Subnets Públicas/Privadas, Internet Gateway, Security Groups, Application Load Balancer, EC2, RDS PostgreSQL, S3, SQS, IAM e Secrets Manager).

---

## 💻 Compatibilidade de Sistema Operacional

* **Linux (Ubuntu, Debian, Fedora, etc.):** Suporte nativo via Bash (`env-emulator.sh`) e `Makefile`.
* **Windows (10/11):** Suporte nativo via PowerShell (`env-emulator.ps1`) e `Makefile`, além de suporte completo via **WSL2 (Ubuntu)**.

---

## 🛠️ Pré-requisitos e Instalação

Antes de clonar e executar o projeto, certifique-se de ter as seguintes ferramentas instaladas no seu sistema:

### 1. Docker e Docker Compose

* **Windows:** Instale o [Docker Desktop](https://www.docker.com/products/docker-desktop/) e certifique-se de que o motor Docker está em execução.
* **Linux (Ubuntu/Debian):**

  ```bash
  sudo apt update && sudo apt install -y docker.io docker-compose-v2
  sudo usermod -aG docker $USER
  ```

### 2. Make (`Makefile`)

* **Windows (via PowerShell / WinGet):**

  ```powershell
  winget install GnuWin32.Make
  ```

  *(Nota: Após a instalação, certifique-se de adicionar `C:\Program Files (x86)\GnuWin32\bin` às Variáveis de Ambiente `Path` do Windows e reiniciar o terminal).*
* **Linux / WSL2 (Ubuntu/Debian):**

  ```bash
  sudo apt update && sudo apt install -y make
  ```

### 3. Terraform

* **Windows (via PowerShell / WinGet):**

  ```powershell
  winget install Hashicorp.Terraform
  ```

* **Linux / WSL2 (Ubuntu/Debian):**

  ```bash
  sudo apt-get update && sudo apt-get install -y gnupg software-properties-common
  wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg > /dev/null
  echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
  sudo apt update && sudo apt install -y terraform
  ```

---

## 🚀 Como Executar o Projeto

### Passo 1: Clonar o Repositório

```bash
git clone https://github.com/mpGustavo06/aws-emulator.git
cd aws-emulator
```

### Passo 2: Subir o AWS Emulator e a Interface Visual (StackPort)

* **No Linux / WSL2:** Dê permissão de execução ao script auxiliar e suba os containers:

  ```bash
  chmod +x env-emulator.sh
  make build
  ```

* **No Windows (PowerShell):** Execute diretamente:

  ```powershell
  make build
  ```

Após a inicialização:

* A API do **AWS Emulator** estará ativa em: `https://127.0.0.1:9297`
* A interface visual **StackPort** estará acessível no navegador em: **`http://127.0.0.1:8098`**

---

### Passo 3: Gerar as Credenciais (`Access Key` e `Secret Key`) e Configurar o `.env`

**Você não precisa de uma conta real da AWS.** Assim que o container `aws-emulator` inicia pela primeira vez, ele gera automaticamente credenciais locais válidas e um certificado autoassinado dentro do volume persistente.

1. Execute o comando abaixo (funciona tanto no Linux/WSL2 quanto no PowerShell do Windows) para visualizar as chaves geradas pelo emulador:

   ```bash
   docker exec aws-emulator cat /home/emulator/.aws/emulator/9297/emulator_credentials
   ```

   A saída será semelhante a:

   ```ini
   [default]
   aws_access_key_id = AKIA...
   aws_secret_access_key = wJalrXUtnFEMI...
   ```

2. Crie um arquivo `.env` na raiz do projeto (este arquivo está no `.gitignore` para segurança) e preencha com os valores exibidos acima:

   ```env
   AWS_ENDPOINT_URL=https://127.0.0.1:9297
   AWS_DEFAULT_REGION=us-east-1
   AWS_ACCESS_KEY_ID=cole_aqui_o_aws_access_key_id
   AWS_SECRET_ACCESS_KEY=cole_aqui_o_aws_secret_access_key
   ```

> ⚠️ **Atenção sobre renovação de chaves:** As credenciais ficam salvas no volume do Docker (`aws-emulator-data`). Caso você remova os volumes do container (ex: `docker compose down -v`) ou recrie a instância do emulador do zero, **novas chaves serão geradas automaticamente**. Se o Terraform retornar o erro `403 AccessDenied: Sign the request with the emulator credentials`, basta rodar o comando `docker exec` acima novamente e atualizar os valores no seu `.env`.

---

### Passo 4: Provisionar a Infraestrutura com Terraform

Utilize os mesmos comandos do `Makefile` (tanto no Windows quanto no Linux/WSL2) para inicializar, validar e aplicar toda a infraestrutura no emulador local:

```bash
# 1. Inicializa o Terraform e baixa o provider AWS
make init

# 2. Valida a sintaxe e verifica a formatação dos arquivos .tf
make validate
make fmt options="-check"

# 3. Visualiza o plano de criação dos recursos
make plan

# 4. Cria toda a infraestrutura no emulador (digite 'yes' para confirmar ou use options="-auto-approve")
make apply

# 5. Inspeciona as saídas (outputs) e os recursos criados
make output
make state options="list"
```

Após concluir o `make apply`, abra **`http://127.0.0.1:8098`** no seu navegador para inspecionar visualmente a VPC, os Security Groups, a instância EC2, o banco RDS, o bucket S3, a fila SQS e os segredos criados!

---

## 🔒 Isolamento de Ambiente e Uso Direto do Terraform

Os scripts `env-emulator.sh` (Linux/WSL2) e `env-emulator.ps1` (Windows), juntamente com os atalhos do `Makefile`, foram criados para **isolar as variáveis de ambiente deste laboratório local de outros projetos Terraform reais** que você possa ter na mesma máquina (evitando que chaves locais sobrescrevam credenciais de produção no seu terminal ou vice-versa).

Entretanto, caso você prefira executar os comandos nativos do Terraform diretamente (exportando as variáveis do `.env` na sua sessão atual e acessando a pasta `terraform/`), os comandos mais utilizados são:

| Comando Terraform | O que faz |
| :--- | :--- |
| `terraform init` | Inicializa o diretório de trabalho e baixa os plugins/providers necessários |
| `terraform fmt` | Formata automaticamente os arquivos `.tf` no padrão oficial da HashiCorp |
| `terraform fmt -check` | Verifica se os arquivos estão formatados corretamente sem alterá-los |
| `terraform validate` | Valida a sintaxe e a consistência interna dos arquivos de configuração |
| `terraform plan` | Gera e exibe um plano de execução mostrando o que será criado, alterado ou destruído |
| `terraform apply` | Aplica as alterações planejadas na infraestrutura (solicita confirmação) |
| `terraform apply -auto-approve` | Aplica as alterações diretamente sem pedir confirmação interativa |
| `terraform show` | Exibe o estado atual detalhado dos recursos provisionados |
| `terraform output` | Mostra os valores das saídas (`outputs.tf`) geradas após o `apply` |
| `terraform state list` | Lista todos os recursos atualmente rastreados no estado do Terraform |
| `terraform destroy` | Remove todos os recursos gerenciados pelo Terraform neste projeto |

---

## 📋 Comandos Disponíveis (`Makefile`)

Digite `make` ou `make help` no terminal (Windows ou Linux/WSL2) para visualizar a lista completa de atalhos. Todos os comandos do Terraform aceitam o parâmetro opcional `options="..."` para repassar flags diretamente ao Terraform:

| Comando | Descrição |
| :--- | :--- |
| `make up` | Sobe o AWS Emulator (`9297`) e a UI StackPort (`8098`) |
| `make down` | Para e remove os containers |
| `make build` | Reconstrói a imagem local do emulador e sobe os containers |
| `make logs` | Exibe os logs em tempo real dos containers |
| `make init [options=...]` | Inicializa o Terraform e baixa os providers |
| `make validate [options=...]` | Valida a sintaxe e configuração dos arquivos `.tf` |
| `make fmt [options=...]` | Formata os arquivos `.tf` (ex: `make fmt options="-check"`) |
| `make plan [options=...]` | Mostra o plano de execução das alterações |
| `make apply [options=...]` | Aplica as alterações no emulador (ex: `make apply options="-auto-approve"`) |
| `make destroy [options=...]` | Remove os recursos criados (ex: `make destroy options="-auto-approve"`) |
| `make output [options=...]` | Exibe os valores de saída (`outputs`) da infraestrutura |
| `make show [options=...]` | Mostra o estado atual ou plano detalhado |
| `make state [options=...]` | Gerencia o estado do Terraform (ex: `make state options="list"`) |
| `make help` | Exibe o menu de ajuda colorido no terminal |

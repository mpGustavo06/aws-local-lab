# ☁️ AWS Local Lab

Ambiente de desenvolvimento local para simular serviços da **AWS** com o **AWS Emulator** oficial em Docker, provisionado via **Terraform** e visualizado em uma interface web unificada (**StackPort**).

## 📖 O que é

Laboratório 100% local — nenhuma conta ou credencial da AWS real é necessária. O projeto provisiona uma arquitetura de exemplo para um sistema de armazenamento de arquivos com autenticação:

- **VPC** com subnets públicas e privadas + Internet Gateway
- **Security Groups** e **Application Load Balancer**
- **EC2** e **RDS PostgreSQL**
- **S3**, **SQS**, **IAM** e **Secrets Manager**

## 🏗️ Stack

| Componente | Papel |
| :--- | :--- |
| **AWS Emulator** | API compatível com AWS em Docker — `https://127.0.0.1:9297` |
| **StackPort** | Interface web para inspecionar os recursos — `http://127.0.0.1:8098` |
| **Terraform** | IaC: define e aplica toda a infraestrutura em `terraform/` |
| **Make** | Atalhos unificados para Docker e Terraform |

**Sistemas operacionais:** Linux (bash + `Makefile`), Windows 10/11 (PowerShell + `Makefile`) e WSL2 completo.

## ✅ Requisitos

**Docker e Docker Compose**

- **Windows:** instale o [Docker Desktop](https://www.docker.com/products/docker-desktop/) e garanta que o motor esteja em execução.
- **Linux / WSL2 (Ubuntu):**

  ```bash
  sudo apt update && sudo apt install -y docker.io docker-compose-v2
  sudo usermod -aG docker $USER
  ```

  Depois saia e entre novamente na sessão — sem isso o grupo `docker` ainda não está ativo e os comandos falham com *permission denied*.

**Make**

- **Windows (PowerShell):** `winget install GnuWin32.Make` — depois adicione `C:\Program Files (x86)\GnuWin32\bin` ao `Path` do sistema e reinicie o terminal.
- **Linux / WSL2:** `sudo apt update && sudo apt install -y make`

**Terraform**

- **Windows (PowerShell):** `winget install Hashicorp.Terraform`
- **Linux / WSL2:**

  ```bash
  sudo apt-get update && sudo apt-get install -y gnupg software-properties-common
  wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg > /dev/null
  echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
  sudo apt update && sudo apt install -y terraform
  ```

## 🚀 Início rápido

> Os comandos abaixo funcionam em **PowerShell (Windows puro, sem WSL)** e em terminal Linux. O `Makefile` detecta o sistema sozinho: os alvos do Terraform chamam `env-emulator.ps1` no Windows e `env-emulator.sh` no Linux/WSL2.

**1. Clone o repositório**

```bash
git clone https://github.com/mpGustavo06/aws-local-lab.git
cd aws-local-lab
```

**2. Suba os containers**

```bash
make build
```

Pronto: API do emulador em `https://127.0.0.1:9297` e UI StackPort em `http://127.0.0.1:8098`.

**3. Gere as credenciais e configure o `.env`**

Na primeira inicialização o emulador gera credenciais locais automaticamente. Visualize-as:

```bash
docker exec aws-emulator cat /home/emulator/.aws/emulator/9297/emulator_credentials
```

```ini
[default]
aws_access_key_id = EMULATORFD77...
aws_secret_access_key = wJalrXUtnFEMI...
```

Copie o `.env.example` para `.env` (gitignored) e preencha com os valores acima:

```powershell
# Windows (PowerShell)
Copy-Item .env.example .env
```

```bash
# Linux / WSL2
cp .env.example .env
```

```env
AWS_ENDPOINT_URL=https://127.0.0.1:9297
AWS_DEFAULT_REGION=us-east-1
AWS_ACCESS_KEY_ID=cole_aqui_a_access_key_id
AWS_SECRET_ACCESS_KEY=cole_aqui_a_secret_access_key
```

> O emulador usa um **certificado autoassinado**. Chamadas diretas da AWS CLI/SDK precisam ignorar a verificação de TLS (ex.: AWS CLI `--no-verify-ssl`, ou `AWS_CA_BUNDLE`). O Terraform já faz isso via `insecure = true` em `terraform/provider.tf`.

**4. Provisione a infraestrutura**

No Linux/WSL2, dê permissão ao script auxiliar usado pelo `Makefile`: `chmod +x env-emulator.sh`.

```bash
make init      # baixa os providers
make validate  # valida a sintaxe dos .tf
make plan     # mostra o plano de execução
make apply    # cria a infraestrutura (digite 'yes')
```

Após o `make apply`, abra `http://127.0.0.1:8098` para inspecionar a VPC, Security Groups, EC2, RDS, S3, SQS e os segredos criados.

## 📋 Referência de comandos

Todos os alvos do Terraform aceitam `options="..."` para repassar flags (ex.: `make apply options="-auto-approve"`). Rode `make help` para a lista completa.

### Docker

| Comando | Descrição |
| :--- | :--- |
| `make up` | Sobe o emulador (`9297`) e a UI StackPort (`8098`) |
| `make down` | Para e remove os containers |
| `make build` | Reconstrói a imagem e sobe os containers |
| `make logs` | Exibe os logs em tempo real |

### Terraform

| Comando | Descrição |
| :--- | :--- |
| `make init` | Inicializa o diretório e baixa os providers |
| `make validate` | Valida sintaxe e configuração dos `.tf` |
| `make fmt` | Formata os `.tf` (ex.: `make fmt options="-check"`) |
| `make plan` | Mostra o plano de execução |
| `make apply` | Aplica as alterações no emulador |
| `make destroy` | Remove os recursos criados |
| `make output` | Exibe os valores de saída (`outputs`) |
| `make show` | Mostra o estado ou plano detalhado |
| `make state` | Gerencia o estado (ex.: `make state options="list"`) |

### Geral

| Comando | Descrição |
| :--- | :--- |
| `make help` | Exibe o menu de ajuda no terminal |

> 🔧 Prefere o Terraform nativo? Exporte as variáveis do `.env` na sua sessão, entre em `terraform/` e use os comandos correspondentes (`terraform init`, `terraform plan`, `terraform apply`, ...).

## ⚠️ Notas e solução de problemas

**Isolamento de ambiente.** Os scripts `env-emulator.sh` (Linux/WSL2) e `env-emulator.ps1` (Windows) isolam as variáveis deste laboratório, evitando que chaves locais colidam com credenciais de projetos AWS reais na mesma máquina. Use-os (ou o `Makefile`, que já os invoca) em vez de exportar as variáveis manualmente.

**Erro `403 AccessDenied: Sign the request with the emulator credentials`.** As credenciais ficam no volume `aws-emulator-data`. Se os volumes forem removidos (ex.: `docker compose down -v`), novas chaves são geradas. Rode o comando `docker exec` da etapa 3 novamente e atualize o seu `.env`.

## 📄 Licença

Este projeto está sob a licença **MIT** — veja o arquivo [`LICENSE`](LICENSE).

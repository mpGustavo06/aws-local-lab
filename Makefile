.DEFAULT_GOAL := help
.PHONY: help up down build logs init validate fmt plan apply destroy output show state

options ?=

BLUE   := \033[1;34m
CYAN   := \033[1;36m
GREEN  := \033[1;32m
YELLOW := \033[1;33m
WHITE  := \033[1;37m
RESET  := \033[0m

ifeq ($(OS),Windows_NT)
	TF := powershell -NoProfile -ExecutionPolicy Bypass -File ./env-emulator.ps1
	HELP = powershell -NoProfile -Command "\
		Write-Host '================================================================================' -ForegroundColor Blue; \
		Write-Host '                          AWS Emulator - Makefile Help' -ForegroundColor White; \
		Write-Host '================================================================================' -ForegroundColor Blue; \
		Write-Host ''; \
		Write-Host 'Ambiente e Docker:' -ForegroundColor Cyan; \
		Write-Host ('  {0,-32} - {1}' -f 'make up', 'Sobe o AWS Emulator (9297) e a UI StackPort (8098)'); \
		Write-Host ('  {0,-32} - {1}' -f 'make down', 'Para e remove os containers'); \
		Write-Host ('  {0,-32} - {1}' -f 'make build', 'Reconstroi a imagem e sobe os containers'); \
		Write-Host ('  {0,-32} - {1}' -f 'make logs', 'Exibe os logs em tempo real dos containers'); \
		Write-Host ''; \
		Write-Host 'Infraestrutura (Terraform):' -ForegroundColor Green; \
		Write-Host ('  {0,-32} - {1}' -f 'make init [options=...]', 'Inicializa o Terraform e baixa os providers'); \
		Write-Host ('  {0,-32} - {1}' -f 'make validate [options=...]', 'Valida a sintaxe e configuracao dos arquivos .tf'); \
		Write-Host ('  {0,-32} - {1}' -f 'make fmt [options=...]', 'Formata arquivos .tf (ex: options=\"-check\")'); \
		Write-Host ('  {0,-32} - {1}' -f 'make plan [options=...]', 'Mostra o plano de execucao das alteracoes'); \
		Write-Host ('  {0,-32} - {1}' -f 'make apply [options=...]', 'Aplica alteracoes (ex: options=\"-auto-approve\")'); \
		Write-Host ('  {0,-32} - {1}' -f 'make destroy [options=...]', 'Remove recursos (ex: options=\"-auto-approve\")'); \
		Write-Host ('  {0,-32} - {1}' -f 'make output [options=...]', 'Exibe os valores de saida (outputs) da infra'); \
		Write-Host ('  {0,-32} - {1}' -f 'make show [options=...]', 'Mostra o estado atual ou plano detalhado'); \
		Write-Host ('  {0,-32} - {1}' -f 'make state [options=...]', 'Gerencia o estado (ex: options=\"list\")'); \
		Write-Host ''; \
		Write-Host 'Utilitarios:' -ForegroundColor Yellow; \
		Write-Host ('  {0,-32} - {1}' -f 'make help', 'Exibe esta lista de comandos disponiveis'); \
		Write-Host '';"
else
	TF := ./env-emulator.sh
	HELP = printf "$(BLUE)================================================================================$(RESET)\n" && \
		printf "$(WHITE)                          AWS Emulator - Makefile Help$(RESET)\n" && \
		printf "$(BLUE)================================================================================$(RESET)\n\n" && \
		printf "$(CYAN)Ambiente e Docker:$(RESET)\n" && \
		printf "  %-32s - %s\n" "make up" "Sobe o AWS Emulator (9297) e a UI StackPort (8098)" && \
		printf "  %-32s - %s\n" "make down" "Para e remove os containers" && \
		printf "  %-32s - %s\n" "make build" "Reconstrói a imagem e sobe os containers" && \
		printf "  %-32s - %s\n\n" "make logs" "Exibe os logs em tempo real dos containers" && \
		printf "$(GREEN)Infraestrutura (Terraform):$(RESET)\n" && \
		printf "  %-32s - %s\n" "make init [options=...]" "Inicializa o Terraform e baixa os providers" && \
		printf "  %-32s - %s\n" "make validate [options=...]" "Valida a sintaxe e configuração dos arquivos .tf" && \
		printf "  %-32s - %s\n" "make fmt [options=...]" "Formata arquivos .tf (ex: options=\"-check\")" && \
		printf "  %-32s - %s\n" "make plan [options=...]" "Mostra o plano de execução das alterações" && \
		printf "  %-32s - %s\n" "make apply [options=...]" "Aplica alterações (ex: options=\"-auto-approve\")" && \
		printf "  %-32s - %s\n" "make destroy [options=...]" "Remove recursos (ex: options=\"-auto-approve\")" && \
		printf "  %-32s - %s\n" "make output [options=...]" "Exibe os valores de saída (outputs) da infra" && \
		printf "  %-32s - %s\n" "make show [options=...]" "Mostra o estado atual ou plano detalhado" && \
		printf "  %-32s - %s\n\n" "make state [options=...]" "Gerencia o estado (ex: options=\"list\")" && \
		printf "$(YELLOW)Utilitários:$(RESET)\n" && \
		printf "  %-32s - %s\n\n" "make help" "Exibe esta lista de comandos disponíveis"
endif

help:
	@$(HELP)

up:
	docker compose up -d

down:
	docker compose down

build:
	docker compose up -d --build

logs:
	docker compose logs -f

init:
	$(TF) init $(options)

validate:
	$(TF) validate $(options)

fmt:
	$(TF) fmt $(options)

plan:
	$(TF) plan $(options)

apply:
	$(TF) apply $(options)

destroy:
	$(TF) destroy $(options)

output:
	$(TF) output $(options)

show:
	$(TF) show $(options)

state:
	$(TF) state $(options)
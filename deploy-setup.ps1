# Script PowerShell para Deploy Automático - Mercado Online
# Execute este script para configurar o deploy no GitHub + Netlify

Write-Host "🚀 MERCADO ONLINE - SETUP DE DEPLOY" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""

# Verificar se Git está instalado
Write-Host "📋 Verificando pré-requisitos..." -ForegroundColor Yellow

try {
    $gitVersion = git --version
    Write-Host "✅ Git encontrado: $gitVersion" -ForegroundColor Green
} catch {
    Write-Host "❌ Git não encontrado. Instale o Git primeiro: https://git-scm.com" -ForegroundColor Red
    exit 1
}

# Verificar se estamos na pasta correta
if (-not (Test-Path "netlify.toml")) {
    Write-Host "❌ Arquivo netlify.toml não encontrado. Execute este script na pasta raiz do projeto." -ForegroundColor Red
    exit 1
}

Write-Host "✅ Pasta do projeto confirmada" -ForegroundColor Green
Write-Host ""

# Solicitar informações do usuário
Write-Host "📝 Configuração do repositório:" -ForegroundColor Yellow
$githubUser = Read-Host "Digite seu username do GitHub"
$repoName = Read-Host "Digite o nome do repositório (padrão: mercado-online)"

if ([string]::IsNullOrWhiteSpace($repoName)) {
    $repoName = "mercado-online"
}

$repoUrl = "https://github.com/$githubUser/$repoName.git"

Write-Host ""
Write-Host "📊 Resumo da configuração:" -ForegroundColor Cyan
Write-Host "GitHub User: $githubUser" -ForegroundColor White
Write-Host "Repositório: $repoName" -ForegroundColor White
Write-Host "URL: $repoUrl" -ForegroundColor White
Write-Host ""

$confirm = Read-Host "Confirma as informações? (s/n)"
if ($confirm -ne "s" -and $confirm -ne "S") {
    Write-Host "❌ Operação cancelada pelo usuário." -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "🔧 Iniciando configuração do Git..." -ForegroundColor Yellow

# Verificar se já é um repositório Git
if (Test-Path ".git") {
    Write-Host "📁 Repositório Git já existe. Verificando status..." -ForegroundColor Yellow
    
    # Verificar se há mudanças não commitadas
    $status = git status --porcelain
    if ($status) {
        Write-Host "📝 Há alterações não commitadas. Fazendo commit..." -ForegroundColor Yellow
        git add .
        git commit -m "Update: Preparação para deploy"
    }
    
    # Verificar se já tem origin
    $remotes = git remote -v
    if ($remotes -match "origin") {
        Write-Host "🔗 Remote origin já configurado. Atualizando..." -ForegroundColor Yellow
        git remote set-url origin $repoUrl
    } else {
        Write-Host "🔗 Adicionando remote origin..." -ForegroundColor Yellow
        git remote add origin $repoUrl
    }
} else {
    Write-Host "🆕 Inicializando novo repositório Git..." -ForegroundColor Yellow
    
    # Inicializar repositório
    git init
    
    # Adicionar todos os arquivos
    Write-Host "📁 Adicionando arquivos ao repositório..." -ForegroundColor Yellow
    git add .
    
    # Fazer primeiro commit
    Write-Host "💾 Fazendo commit inicial..." -ForegroundColor Yellow
    git commit -m "Initial commit: Mercado Online - Aplicativo completo para mercados e mercearias"
    
    # Adicionar remote origin
    Write-Host "🔗 Configurando remote origin..." -ForegroundColor Yellow
    git remote add origin $repoUrl
}

# Configurar branch principal
Write-Host "🌿 Configurando branch principal..." -ForegroundColor Yellow
git branch -M main

# Fazer push para GitHub
Write-Host "📤 Enviando código para GitHub..." -ForegroundColor Yellow
Write-Host "⚠️  Você precisará fazer login no GitHub quando solicitado." -ForegroundColor Yellow
Write-Host ""

try {
    git push -u origin main
    Write-Host "✅ Código enviado com sucesso para GitHub!" -ForegroundColor Green
} catch {
    Write-Host "❌ Erro ao enviar para GitHub. Verifique:" -ForegroundColor Red
    Write-Host "   - Se o repositório existe no GitHub" -ForegroundColor Red
    Write-Host "   - Se você tem permissão de escrita" -ForegroundColor Red
    Write-Host "   - Se suas credenciais estão corretas" -ForegroundColor Red
    Write-Host ""
    Write-Host "💡 Crie o repositório manualmente em: https://github.com/new" -ForegroundColor Yellow
    exit 1
}

Write-Host ""
Write-Host "🎉 CONFIGURAÇÃO CONCLUÍDA COM SUCESSO!" -ForegroundColor Green
Write-Host "=====================================" -ForegroundColor Green
Write-Host ""
Write-Host "📋 Próximos passos:" -ForegroundColor Cyan
Write-Host "1. Acesse: https://netlify.com" -ForegroundColor White
Write-Host "2. Clique em 'Add new site' → 'Import an existing project'" -ForegroundColor White
Write-Host "3. Conecte com GitHub e selecione: $repoName" -ForegroundColor White
Write-Host "4. Clique em 'Deploy site'" -ForegroundColor White
Write-Host ""
Write-Host "🔗 Links importantes:" -ForegroundColor Cyan
Write-Host "GitHub: https://github.com/$githubUser/$repoName" -ForegroundColor White
Write-Host "Netlify: https://app.netlify.com/" -ForegroundColor White
Write-Host ""
Write-Host "📖 Guia completo: Consulte DEPLOY-NETLIFY-GITHUB.md" -ForegroundColor Yellow
Write-Host ""

# Perguntar se quer abrir os links
$openLinks = Read-Host "Deseja abrir os links no navegador? (s/n)"
if ($openLinks -eq "s" -or $openLinks -eq "S") {
    Start-Process "https://github.com/$githubUser/$repoName"
    Start-Process "https://app.netlify.com/"
    Write-Host "🌐 Links abertos no navegador!" -ForegroundColor Green
}

Write-Host ""
Write-Host "✨ Deploy configurado com sucesso! Boa sorte com seu Mercado Online!" -ForegroundColor Green
Write-Host ""

# Pausar para o usuário ler
Read-Host "Pressione Enter para finalizar"
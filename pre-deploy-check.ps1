# Script de Verificação Pré-Deploy - Mercado Online
# Verifica se o projeto está pronto para deploy

Write-Host "🔍 VERIFICAÇÃO PRÉ-DEPLOY - MERCADO ONLINE" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

$errors = 0
$warnings = 0

# Função para verificar arquivo
function Test-FileExists {
    param($filePath, $description)
    
    if (Test-Path $filePath) {
        Write-Host "✅ $description" -ForegroundColor Green
        return $true
    } else {
        Write-Host "❌ $description - ARQUIVO NÃO ENCONTRADO" -ForegroundColor Red
        $script:errors++
        return $false
    }
}

# Função para verificar conteúdo
function Test-FileContent {
    param($filePath, $searchText, $description)
    
    if (Test-Path $filePath) {
        $content = Get-Content $filePath -Raw
        if ($content -match $searchText) {
            Write-Host "✅ $description" -ForegroundColor Green
            return $true
        } else {
            Write-Host "⚠️  $description - CONTEÚDO PODE PRECISAR DE AJUSTE" -ForegroundColor Yellow
            $script:warnings++
            return $false
        }
    } else {
        Write-Host "❌ $description - ARQUIVO NÃO ENCONTRADO" -ForegroundColor Red
        $script:errors++
        return $false
    }
}

Write-Host "📁 Verificando estrutura de arquivos..." -ForegroundColor Yellow
Write-Host ""

# Verificar arquivos essenciais
Test-FileExists "netlify.toml" "Configuração do Netlify (netlify.toml)"
Test-FileExists ".gitignore" "Arquivo .gitignore"
Test-FileExists "client/index.html" "Página principal do cliente"
Test-FileExists "admin/index.html" "Página do painel administrativo"
Test-FileExists "assets/js/client.js" "JavaScript do cliente"
Test-FileExists "assets/js/admin.js" "JavaScript do admin"
Test-FileExists "assets/js/supabase.js" "Configuração do Supabase"
Test-FileExists "assets/css/client.css" "CSS do cliente"
Test-FileExists "assets/css/admin.css" "CSS do admin"

Write-Host ""
Write-Host "⚙️ Verificando configurações..." -ForegroundColor Yellow
Write-Host ""

# Verificar configuração do Netlify
if (Test-Path "netlify.toml") {
    $netlifyContent = Get-Content "netlify.toml" -Raw
    if ($netlifyContent -match 'publish = "."' -and $netlifyContent -match 'from = "/"') {
        Write-Host "✅ Configuração do Netlify está correta" -ForegroundColor Green
    } else {
        Write-Host "⚠️  Configuração do Netlify pode ter problemas" -ForegroundColor Yellow
        $warnings++
    }
}

# Verificar configuração do Supabase
if (Test-Path "assets/js/supabase.js") {
    $supabaseContent = Get-Content "assets/js/supabase.js" -Raw
    if ($supabaseContent -match "SUA_URL_DO_SUPABASE_AQUI" -or $supabaseContent -match "YOUR_SUPABASE_URL") {
        Write-Host "⚠️  Supabase em modo DEMO (funcionará, mas sem banco real)" -ForegroundColor Yellow
        $warnings++
    } else {
        Write-Host "✅ Configuração do Supabase parece estar personalizada" -ForegroundColor Green
    }
}

Write-Host ""
Write-Host "🌐 Verificando estrutura web..." -ForegroundColor Yellow
Write-Host ""

# Verificar se as páginas têm conteúdo básico
Test-FileContent "client/index.html" "Mercado Online" "Título na página do cliente"
Test-FileContent "admin/index.html" "Painel Administrativo" "Título na página do admin"
Test-FileContent "assets/js/client.js" "AppState" "Estado da aplicação no cliente"
Test-FileContent "assets/js/admin.js" "AdminState" "Estado da aplicação no admin"

Write-Host ""
Write-Host "📋 Verificando documentação..." -ForegroundColor Yellow
Write-Host ""

Test-FileExists "README.md" "Documentação principal (README.md)"
Test-FileExists "INSTALACAO.md" "Guia de instalação"
Test-FileExists "DEPLOY.md" "Guia de deploy básico"
Test-FileExists "DEPLOY-NETLIFY-GITHUB.md" "Guia completo de deploy"
Test-FileExists "DEPLOY-RAPIDO.md" "Guia rápido de deploy"

Write-Host ""
Write-Host "🔧 Verificando ferramentas..." -ForegroundColor Yellow
Write-Host ""

# Verificar Git
try {
    $gitVersion = git --version
    Write-Host "✅ Git instalado: $gitVersion" -ForegroundColor Green
} catch {
    Write-Host "❌ Git não encontrado - NECESSÁRIO PARA DEPLOY" -ForegroundColor Red
    $errors++
}

# Verificar se é um repositório Git
if (Test-Path ".git") {
    Write-Host "✅ Repositório Git inicializado" -ForegroundColor Green
    
    # Verificar se há commits
    try {
        $commits = git log --oneline 2>$null
        if ($commits) {
            Write-Host "✅ Repositório tem commits" -ForegroundColor Green
        } else {
            Write-Host "⚠️  Repositório sem commits - faça o primeiro commit" -ForegroundColor Yellow
            $warnings++
        }
    } catch {
        Write-Host "⚠️  Repositório sem commits - faça o primeiro commit" -ForegroundColor Yellow
        $warnings++
    }
    
    # Verificar remote origin
    try {
        $remotes = git remote -v 2>$null
        if ($remotes -match "origin") {
            Write-Host "✅ Remote origin configurado" -ForegroundColor Green
        } else {
            Write-Host "⚠️  Remote origin não configurado - configure antes do deploy" -ForegroundColor Yellow
            $warnings++
        }
    } catch {
        Write-Host "⚠️  Não foi possível verificar remotes" -ForegroundColor Yellow
        $warnings++
    }
} else {
    Write-Host "⚠️  Não é um repositório Git - execute 'git init' primeiro" -ForegroundColor Yellow
    $warnings++
}

Write-Host ""
Write-Host "📊 RESULTADO DA VERIFICAÇÃO" -ForegroundColor Cyan
Write-Host "===========================" -ForegroundColor Cyan
Write-Host ""

if ($errors -eq 0 -and $warnings -eq 0) {
    Write-Host "🎉 PERFEITO! Projeto pronto para deploy!" -ForegroundColor Green
    Write-Host "✅ Todos os arquivos necessários estão presentes" -ForegroundColor Green
    Write-Host "✅ Configurações parecem corretas" -ForegroundColor Green
    Write-Host "✅ Ferramentas necessárias instaladas" -ForegroundColor Green
} elseif ($errors -eq 0) {
    Write-Host "✅ PROJETO PRONTO para deploy!" -ForegroundColor Green
    Write-Host "⚠️  $warnings avisos encontrados (não impedem o deploy)" -ForegroundColor Yellow
} else {
    Write-Host "❌ PROJETO NÃO ESTÁ PRONTO para deploy!" -ForegroundColor Red
    Write-Host "❌ $errors erros encontrados" -ForegroundColor Red
    if ($warnings -gt 0) {
        Write-Host "⚠️  $warnings avisos encontrados" -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "📋 Próximos passos recomendados:" -ForegroundColor Cyan

if ($errors -gt 0) {
    Write-Host "1. Corrija os erros listados acima" -ForegroundColor White
    Write-Host "2. Execute este script novamente" -ForegroundColor White
    Write-Host "3. Quando não houver erros, prossiga com o deploy" -ForegroundColor White
} else {
    Write-Host "1. Execute: .\deploy-setup.ps1 (para configurar Git + GitHub)" -ForegroundColor White
    Write-Host "2. Acesse netlify.com e conecte seu repositório" -ForegroundColor White
    Write-Host "3. Faça o deploy e teste o site" -ForegroundColor White
}

Write-Host ""
Write-Host "📖 Documentação disponível:" -ForegroundColor Yellow
Write-Host "- DEPLOY-RAPIDO.md (guia rápido)" -ForegroundColor White
Write-Host "- DEPLOY-NETLIFY-GITHUB.md (guia completo)" -ForegroundColor White
Write-Host ""

Read-Host "Pressione Enter para finalizar"
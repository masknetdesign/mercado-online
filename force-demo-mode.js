// Script para forçar o modo demo e evitar erros 400 do Supabase
// Execute este script no console do navegador ou inclua na página

(function() {
    console.log('🔧 Forçando modo demo para evitar erros 400...');
    
    // Força o modo demo no supabaseClient
    if (window.supabaseClient) {
        window.supabaseClient.demoMode = true;
        window.supabaseClient.initialized = false;
        window.supabaseClient.supabase = null;
        
        // Recarrega os dados demo
        window.supabaseClient.demoData = window.supabaseClient.loadDemoData();
        
        console.log('✅ Modo demo ativado com sucesso!');
        console.log('📦 Produtos disponíveis:', window.supabaseClient.demoData.length);
        
        // Se estiver na página admin, recarrega a interface
        if (typeof AdminState !== 'undefined') {
            AdminState.user = null;
            if (typeof showLoginScreen === 'function') {
                showLoginScreen();
            }
        }
        
        // Limpa qualquer erro anterior
        const errorElements = document.querySelectorAll('.error-message');
        errorElements.forEach(el => {
            el.style.display = 'none';
            el.textContent = '';
        });
        
    } else {
        console.warn('⚠️ supabaseClient não encontrado. Aguarde o carregamento da página.');
    }
})();

// Função para verificar o status atual
function checkDemoStatus() {
    if (window.supabaseClient) {
        console.log('📊 Status atual:');
        console.log('- Modo demo:', window.supabaseClient.demoMode);
        console.log('- Inicializado:', window.supabaseClient.initialized);
        console.log('- Produtos:', window.supabaseClient.demoData?.length || 0);
    }
}

// Disponibiliza a função globalmente
window.checkDemoStatus = checkDemoStatus;
window.forceDemoMode = function() {
    location.reload();
};

console.log('🎯 Script carregado! Use checkDemoStatus() para verificar o status.');
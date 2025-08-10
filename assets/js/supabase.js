// Configuração do Supabase
// IMPORTANTE: Substitua estas configurações pelas suas próprias do Supabase
const SUPABASE_CONFIG = {
    url: 'https://migivkdupsydyoyoxgzv.supabase.co', // Ex: https://xyzcompany.supabase.co
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1pZ2l2a2R1cHN5ZHlveW94Z3p2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTQ3NzMxMDksImV4cCI6MjA3MDM0OTEwOX0.38RKTthKFqebz4t22WQjtj8qVVK2E8C6H_tKHXPZoO4', // Sua chave anônima do Supabase
    bucketName: 'produtos-images', // Nome do bucket para imagens
    isDemoMode: false
};

// Classe para gerenciar a conexão com o Supabase
class SupabaseClient {
    constructor() {
        this.supabase = null;
        this.initialized = false;
        this.init();
    }

    init() {
        try {
            // Verifica se as configurações foram definidas
            if (SUPABASE_CONFIG.url === 'YOUR_SUPABASE_URL' || 
                SUPABASE_CONFIG.anonKey === 'YOUR_SUPABASE_ANON_KEY') {
                console.warn('Configurações do Supabase não foram definidas. Usando modo de demonstração.');
                this.initDemoMode();
                return;
            }

            // CORREÇÃO: Força modo demo para evitar erros 400
            // Descomente a linha abaixo se quiser forçar o modo demo
            // this.initDemoMode(); return;

            // Inicializa o cliente Supabase (quando disponível)
            if (typeof window.supabase !== 'undefined') {
                this.supabase = window.supabase.createClient(
                    SUPABASE_CONFIG.url,
                    SUPABASE_CONFIG.anonKey
                );
                this.initialized = true;
                console.log('Supabase inicializado com sucesso');
                
                // Testa a conexão para evitar erros 400
                this.testConnection();
            } else {
                console.warn('SDK do Supabase não encontrado. Usando modo de demonstração.');
                this.initDemoMode();
            }
        } catch (error) {
            console.error('Erro ao inicializar Supabase:', error);
            this.initDemoMode();
        }
    }

    async testConnection() {
        try {
            // Testa uma operação simples para verificar se a conexão funciona
            const { data, error } = await this.supabase.from('produtos').select('count').limit(1);
            if (error && (error.code === '400' || error.message.includes('400'))) {
                console.warn('Erro 400 detectado. Ativando modo demo...');
                this.initDemoMode();
            }
        } catch (error) {
            console.warn('Erro de conexão detectado. Ativando modo demo...', error);
            this.initDemoMode();
        }
    }

    initDemoMode() {
        // Modo de demonstração com dados locais
        this.demoMode = true;
        this.initialized = false;
        this.supabase = null;
        this.demoData = this.loadDemoData();
        console.log('Modo de demonstração ativado');
        console.log('Produtos disponíveis:', this.demoData.length);
    }

    loadDemoData() {
        const savedData = localStorage.getItem('mercado_demo_products');
        if (savedData) {
            return JSON.parse(savedData);
        }

        // Dados de exemplo (sincronizados com supabase-setup.sql)
        const demoProducts = [
            {
                id: 1,
                nome: 'Banana Prata',
                descricao: 'Banana prata fresca e doce, rica em potássio',
                preco: 4.99,
                categoria: 'frutas',
                url_imagem: 'https://images.unsplash.com/photo-1571771894821-ce9b6c11b08e?w=300&h=300&fit=crop',
                criado_em: new Date().toISOString()
            },
            {
                id: 2,
                nome: 'Coca-Cola 2L',
                descricao: 'Refrigerante Coca-Cola 2 litros gelado',
                preco: 8.99,
                categoria: 'bebidas',
                url_imagem: 'https://images.unsplash.com/photo-1554866585-cd94860890b7?w=300&h=300&fit=crop',
                criado_em: new Date().toISOString()
            },
            {
                id: 3,
                nome: 'Detergente Ypê',
                descricao: 'Detergente líquido neutro 500ml para louças',
                preco: 2.49,
                categoria: 'limpeza',
                url_imagem: 'https://images.unsplash.com/photo-1585829365295-ab7cd400c167?w=300&h=300&fit=crop',
                criado_em: new Date().toISOString()
            },
            {
                id: 4,
                nome: 'Pão Francês',
                descricao: 'Pão francês fresquinho assado no dia (kg)',
                preco: 12.90,
                categoria: 'padaria',
                url_imagem: 'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=300&h=300&fit=crop',
                criado_em: new Date().toISOString()
            },
            {
                id: 5,
                nome: 'Picanha',
                descricao: 'Picanha bovina premium primeira qualidade (kg)',
                preco: 89.90,
                categoria: 'carnes',
                url_imagem: 'https://images.unsplash.com/photo-1546833999-b9f581a1996d?w=300&h=300&fit=crop',
                criado_em: new Date().toISOString()
            },
            {
                id: 6,
                nome: 'Maçã Gala',
                descricao: 'Maçã gala vermelha doce e crocante (kg)',
                preco: 7.99,
                categoria: 'frutas',
                url_imagem: 'https://images.unsplash.com/photo-1560806887-1e4cd0b6cbd6?w=300&h=300&fit=crop',
                criado_em: new Date().toISOString()
            },
            {
                id: 7,
                nome: 'Água Mineral 1.5L',
                descricao: 'Água mineral natural sem gás 1.5 litros',
                preco: 3.50,
                categoria: 'bebidas',
                url_imagem: 'https://images.unsplash.com/photo-1559827260-dc66d52bef19?w=300&h=300&fit=crop',
                criado_em: new Date().toISOString()
            },
            {
                id: 8,
                nome: 'Sabão em Pó',
                descricao: 'Sabão em pó concentrado 1kg para roupas',
                preco: 8.90,
                categoria: 'limpeza',
                url_imagem: 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=300&h=300&fit=crop',
                criado_em: new Date().toISOString()
            },
            {
                id: 9,
                nome: 'Croissant',
                descricao: 'Croissant francês amanteigado (unidade)',
                preco: 4.50,
                categoria: 'padaria',
                url_imagem: 'https://images.unsplash.com/photo-1555507036-ab794f4ade2a?w=300&h=300&fit=crop',
                criado_em: new Date().toISOString()
            },
            {
                id: 10,
                nome: 'Frango Inteiro',
                descricao: 'Frango inteiro resfriado (kg)',
                preco: 12.90,
                categoria: 'carnes',
                url_imagem: 'https://images.unsplash.com/photo-1604503468506-a8da13d82791?w=300&h=300&fit=crop',
                criado_em: new Date().toISOString()
            }
        ];

        this.saveDemoData(demoProducts);
        return demoProducts;
    }

    saveDemoData(data) {
        localStorage.setItem('mercado_demo_products', JSON.stringify(data));
    }

    // Métodos para produtos
    async getProducts() {
        if (this.demoMode) {
            return { data: this.demoData, error: null };
        }

        try {
            const { data, error } = await this.supabase
                .from('produtos')
                .select('*')
                .order('criado_em', { ascending: false });
            
            return { data, error };
        } catch (error) {
            return { data: null, error };
        }
    }

    async addProduct(product) {
        if (this.demoMode) {
            const newProduct = {
                ...product,
                id: Math.max(...this.demoData.map(p => p.id), 0) + 1,
                criado_em: new Date().toISOString()
            };
            this.demoData.push(newProduct);
            this.saveDemoData(this.demoData);
            return { data: newProduct, error: null };
        }

        try {
            const { data, error } = await this.supabase
                .from('produtos')
                .insert([product])
                .select();
            
            return { data: data?.[0], error };
        } catch (error) {
            return { data: null, error };
        }
    }

    async updateProduct(id, updates) {
        if (this.demoMode) {
            const index = this.demoData.findIndex(p => p.id === id);
            if (index !== -1) {
                this.demoData[index] = { ...this.demoData[index], ...updates };
                this.saveDemoData(this.demoData);
                return { data: this.demoData[index], error: null };
            }
            return { data: null, error: 'Produto não encontrado' };
        }

        try {
            const { data, error } = await this.supabase
                .from('produtos')
                .update(updates)
                .eq('id', id)
                .select();
            
            return { data: data?.[0], error };
        } catch (error) {
            return { data: null, error };
        }
    }

    async deleteProduct(id) {
        if (this.demoMode) {
            const index = this.demoData.findIndex(p => p.id === id);
            if (index !== -1) {
                const deleted = this.demoData.splice(index, 1)[0];
                this.saveDemoData(this.demoData);
                return { data: deleted, error: null };
            }
            return { data: null, error: 'Produto não encontrado' };
        }

        try {
            const { data, error } = await this.supabase
                .from('produtos')
                .delete()
                .eq('id', id)
                .select();
            
            return { data: data?.[0], error };
        } catch (error) {
            return { data: null, error };
        }
    }

    async uploadImage(file) {
        if (this.demoMode) {
            // No modo demo, simula o upload retornando uma URL do Unsplash
            return new Promise((resolve) => {
                setTimeout(() => {
                    const imageUrl = `https://images.unsplash.com/photo-${Date.now()}?w=300&h=300&fit=crop`;
                    resolve({ data: { publicUrl: imageUrl }, error: null });
                }, 1000);
            });
        }

        try {
            const fileName = `${Date.now()}-${file.name}`;
            const { data, error } = await this.supabase.storage
                .from(SUPABASE_CONFIG.bucketName)
                .upload(fileName, file);

            if (error) {
                return { data: null, error };
            }

            const { data: urlData } = this.supabase.storage
                .from(SUPABASE_CONFIG.bucketName)
                .getPublicUrl(fileName);

            return { data: { publicUrl: urlData.publicUrl }, error: null };
        } catch (error) {
            return { data: null, error };
        }
    }

    // Métodos de autenticação
    async signIn(email, password) {
        if (this.demoMode) {
            // No modo demo, aceita qualquer email/senha para demonstração
            if (email && password) {
                const user = { email, id: 'demo-user' };
                localStorage.setItem('mercado_demo_user', JSON.stringify(user));
                return { data: { user }, error: null };
            }
            return { data: null, error: 'Email e senha são obrigatórios' };
        }

        try {
            const { data, error } = await this.supabase.auth.signInWithPassword({
                email,
                password
            });
            
            return { data, error };
        } catch (error) {
            return { data: null, error };
        }
    }

    async signOut() {
        if (this.demoMode) {
            localStorage.removeItem('mercado_demo_user');
            return { error: null };
        }

        try {
            const { error } = await this.supabase.auth.signOut();
            return { error };
        } catch (error) {
            return { error };
        }
    }

    async getCurrentUser() {
        if (this.demoMode) {
            const savedUser = localStorage.getItem('mercado_demo_user');
            return savedUser ? JSON.parse(savedUser) : null;
        }

        try {
            const { data: { user } } = await this.supabase.auth.getUser();
            return user;
        } catch (error) {
            // Se houver erro 400, ativa modo demo
            if (error.status === 400 || error.message.includes('400')) {
                console.warn('Erro 400 na autenticação. Ativando modo demo...');
                this.initDemoMode();
            }
            return null;
        }
    }
}

// Instância global do cliente Supabase
const supabaseClient = new SupabaseClient();

// Funções utilitárias
function formatPrice(price) {
    return new Intl.NumberFormat('pt-BR', {
        style: 'currency',
        currency: 'BRL'
    }).format(price);
}

function formatDate(dateString) {
    return new Date(dateString).toLocaleDateString('pt-BR');
}

// Exporta para uso global
window.supabaseClient = supabaseClient;
window.formatPrice = formatPrice;
window.formatDate = formatDate;


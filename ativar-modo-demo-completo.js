// ========================================
// MODO DEMO COMPLETO - SEM SUPABASE
// Resolve todos os erros de RLS e privilégios
// ========================================

// Execute este script no Console do navegador (F12)
// Ou adicione ao final do arquivo assets/js/supabase.js

(function() {
    console.log('🎮 Ativando Modo Demo Completo...');
    
    // 1. CONFIGURAR MODO DEMO GLOBAL
    window.isDemoMode = true;
    window.demoData = {
        produtos: JSON.parse(localStorage.getItem('demo_produtos') || '[]'),
        usuarios: JSON.parse(localStorage.getItem('demo_usuarios') || '[]'),
        images: JSON.parse(localStorage.getItem('demo_images') || '{}')
    };
    
    // 2. SOBRESCREVER FUNÇÕES DO SUPABASE
    if (window.supabase) {
        console.log('✅ Supabase detectado - Aplicando modo demo');
        
        // Sobrescrever storage.upload
        window.supabase.storage.from = function(bucket) {
            return {
                upload: function(path, file) {
                    return new Promise((resolve) => {
                        console.log('📸 Demo Upload:', path, file.name);
                        
                        // Simular upload com FileReader
                        const reader = new FileReader();
                        reader.onload = function(e) {
                            const imageData = e.target.result;
                            const imageId = 'demo_' + Date.now();
                            
                            // Salvar no localStorage
                            window.demoData.images[imageId] = {
                                path: path,
                                name: file.name,
                                data: imageData,
                                size: file.size,
                                type: file.type,
                                uploaded_at: new Date().toISOString()
                            };
                            
                            localStorage.setItem('demo_images', JSON.stringify(window.demoData.images));
                            
                            // Retornar sucesso simulado
                            resolve({
                                data: {
                                    path: path,
                                    id: imageId,
                                    fullPath: `demo/${path}`
                                },
                                error: null
                            });
                        };
                        reader.readAsDataURL(file);
                    });
                },
                
                getPublicUrl: function(path) {
                    // Buscar imagem no localStorage
                    const images = JSON.parse(localStorage.getItem('demo_images') || '{}');
                    const imageEntry = Object.values(images).find(img => img.path === path);
                    
                    return {
                        data: {
                            publicUrl: imageEntry ? imageEntry.data : '/assets/images/placeholder.svg'
                        }
                    };
                },
                
                remove: function(paths) {
                    return new Promise((resolve) => {
                        console.log('🗑️ Demo Remove:', paths);
                        
                        const images = JSON.parse(localStorage.getItem('demo_images') || '{}');
                        paths.forEach(path => {
                            const imageId = Object.keys(images).find(id => images[id].path === path);
                            if (imageId) {
                                delete images[imageId];
                            }
                        });
                        
                        localStorage.setItem('demo_images', JSON.stringify(images));
                        
                        resolve({
                            data: paths.map(path => ({ name: path })),
                            error: null
                        });
                    });
                }
            };
        };
        
        // Sobrescrever operações de banco
        window.supabase.from = function(table) {
            return {
                select: function(columns = '*') {
                    return {
                        eq: function(column, value) {
                            return new Promise((resolve) => {
                                const data = JSON.parse(localStorage.getItem(`demo_${table}`) || '[]');
                                const filtered = data.filter(item => item[column] === value);
                                resolve({ data: filtered, error: null });
                            });
                        },
                        
                        then: function(callback) {
                            const data = JSON.parse(localStorage.getItem(`demo_${table}`) || '[]');
                            return callback({ data, error: null });
                        }
                    };
                },
                
                insert: function(newData) {
                    return new Promise((resolve) => {
                        const data = JSON.parse(localStorage.getItem(`demo_${table}`) || '[]');
                        const id = Date.now();
                        const item = { id, ...newData, created_at: new Date().toISOString() };
                        data.push(item);
                        localStorage.setItem(`demo_${table}`, JSON.stringify(data));
                        console.log(`✅ Demo Insert ${table}:`, item);
                        resolve({ data: [item], error: null });
                    });
                },
                
                update: function(updateData) {
                    return {
                        eq: function(column, value) {
                            return new Promise((resolve) => {
                                const data = JSON.parse(localStorage.getItem(`demo_${table}`) || '[]');
                                const index = data.findIndex(item => item[column] === value);
                                if (index !== -1) {
                                    data[index] = { ...data[index], ...updateData, updated_at: new Date().toISOString() };
                                    localStorage.setItem(`demo_${table}`, JSON.stringify(data));
                                    console.log(`✅ Demo Update ${table}:`, data[index]);
                                    resolve({ data: [data[index]], error: null });
                                } else {
                                    resolve({ data: [], error: null });
                                }
                            });
                        }
                    };
                },
                
                delete: function() {
                    return {
                        eq: function(column, value) {
                            return new Promise((resolve) => {
                                const data = JSON.parse(localStorage.getItem(`demo_${table}`) || '[]');
                                const filtered = data.filter(item => item[column] !== value);
                                localStorage.setItem(`demo_${table}`, JSON.stringify(filtered));
                                console.log(`✅ Demo Delete ${table} where ${column} = ${value}`);
                                resolve({ data: [], error: null });
                            });
                        }
                    };
                }
            };
        };
    }
    
    // 3. ADICIONAR DADOS DEMO INICIAIS
    if (window.demoData.produtos.length === 0) {
        const produtosDemo = [
            {
                id: 1,
                nome: 'Produto Demo 1',
                preco: 29.99,
                categoria: 'Categoria A',
                descricao: 'Produto de demonstração',
                imagem_url: '/assets/images/placeholder.svg',
                created_at: new Date().toISOString()
            },
            {
                id: 2,
                nome: 'Produto Demo 2',
                preco: 49.99,
                categoria: 'Categoria B',
                descricao: 'Outro produto de demonstração',
                imagem_url: '/assets/images/placeholder.svg',
                created_at: new Date().toISOString()
            }
        ];
        
        localStorage.setItem('demo_produtos', JSON.stringify(produtosDemo));
        window.demoData.produtos = produtosDemo;
        console.log('✅ Produtos demo criados');
    }
    
    // 4. MOSTRAR STATUS
    console.log('🎉 Modo Demo Ativado!');
    console.log('📊 Dados disponíveis:', {
        produtos: window.demoData.produtos.length,
        usuarios: window.demoData.usuarios.length,
        imagens: Object.keys(window.demoData.images).length
    });
    
    // 5. ADICIONAR INDICADOR VISUAL
    const demoIndicator = document.createElement('div');
    demoIndicator.innerHTML = '🎮 MODO DEMO ATIVO';
    demoIndicator.style.cssText = `
        position: fixed;
        top: 10px;
        right: 10px;
        background: #ff6b35;
        color: white;
        padding: 8px 12px;
        border-radius: 20px;
        font-size: 12px;
        font-weight: bold;
        z-index: 9999;
        box-shadow: 0 2px 10px rgba(0,0,0,0.3);
    `;
    document.body.appendChild(demoIndicator);
    
    // 6. NOTIFICAR USUÁRIO
    if (typeof showNotification === 'function') {
        showNotification('🎮 Modo Demo Ativado! Todos os uploads funcionarão offline.', 'success');
    } else {
        alert('🎮 Modo Demo Ativado!\n\nTodos os uploads agora funcionarão offline.\nAs imagens serão salvas no navegador.');
    }
    
    return true;
})();

// ========================================
// INSTRUÇÕES DE USO:
// ========================================
/*
1. ATIVAÇÃO AUTOMÁTICA:
   - Copie este código
   - Cole no Console do navegador (F12)
   - Pressione Enter

2. ATIVAÇÃO PERMANENTE:
   - Adicione este código ao final de assets/js/supabase.js
   - Salve o arquivo
   - Recarregue a página

3. FUNCIONALIDADES:
   ✅ Upload de imagens (salvas no navegador)
   ✅ CRUD de produtos (localStorage)
   ✅ Sem erros de RLS
   ✅ Sem necessidade de Supabase
   ✅ Funciona completamente offline

4. DADOS:
   - Produtos: localStorage.getItem('demo_produtos')
   - Imagens: localStorage.getItem('demo_images')
   - Usuários: localStorage.getItem('demo_usuarios')

5. DESATIVAR:
   - Recarregue a página sem o script
   - Ou execute: window.isDemoMode = false
*/
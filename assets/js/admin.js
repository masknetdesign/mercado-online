// Estado global da aplicação administrativa
const AdminState = {
    user: null,
    products: [],
    currentSection: 'dashboard',
    editingProduct: null,
    whatsappNumber: '5511999999999',
    listenersInitialized: false,
    isLoading: false
};

// Inicialização da aplicação
document.addEventListener('DOMContentLoaded', function() {
    initializeAdmin();
});

async function initializeAdmin() {
    try {
        // Inicializa event listeners primeiro
        initializeEventListeners();
        
        // Verifica se o usuário já está logado
        const currentUser = await supabaseClient.getCurrentUser();
        
        if (currentUser) {
            AdminState.user = currentUser;
            showDashboard();
            await loadAdminData();
        } else {
            showLoginScreen();
        }
    } catch (error) {
        console.error('Erro na inicialização:', error);
        showLoginScreen();
    }
}

// Event Listeners
function initializeEventListeners() {
    // Evita múltiplas inicializações
    if (AdminState.listenersInitialized) {
        return;
    }
    
    // Login form
    const loginForm = document.getElementById('login-form');
    if (loginForm) {
        loginForm.addEventListener('submit', handleLogin);
    }
    
    // Logout
    const logoutBtn = document.getElementById('logout-btn');
    if (logoutBtn) {
        logoutBtn.addEventListener('click', handleLogout);
    }
    
    // Navigation
    document.querySelectorAll('.nav-item').forEach(item => {
        item.addEventListener('click', function(e) {
            e.preventDefault();
            e.stopPropagation();
            const section = this.getAttribute('data-section');
            if (section && section !== 'undefined') {
                console.log('Navegando para seção:', section);
                showSection(section);
            } else {
                console.error('Seção inválida:', section);
            }
        });
    });
    
    AdminState.listenersInitialized = true;
    console.log('Event listeners inicializados');
    
    // Product form
    const productForm = document.getElementById('product-form');
    if (productForm) {
        productForm.addEventListener('submit', handleProductSubmit);
    }
    
    // Image upload
    const imageInput = document.getElementById('product-image');
    if (imageInput) {
        imageInput.addEventListener('change', handleImagePreview);
    }
    
    // Remove image
    const removeImageBtn = document.getElementById('remove-image');
    if (removeImageBtn) {
        removeImageBtn.addEventListener('click', removeImagePreview);
    }
    
    // Delete modal
    const deleteModal = document.getElementById('delete-modal');
    if (deleteModal) {
        deleteModal.querySelector('.close').addEventListener('click', closeDeleteModal);
        window.addEventListener('click', function(e) {
            if (e.target === deleteModal) {
                closeDeleteModal();
            }
        });
    }
}

// Autenticação
async function handleLogin(e) {
    e.preventDefault();
    
    const email = document.getElementById('admin-email').value;
    const password = document.getElementById('admin-password').value;
    const errorDiv = document.getElementById('login-error');
    
    showLoading(true);
    
    try {
        const { data, error } = await supabaseClient.signIn(email, password);
        
        if (error) {
            errorDiv.textContent = 'Email ou senha incorretos';
            errorDiv.style.display = 'block';
            showLoading(false);
            return;
        }
        
        AdminState.user = data.user;
        showDashboard();
        await loadAdminData();
        
    } catch (error) {
        console.error('Erro no login:', error);
        errorDiv.textContent = 'Erro ao fazer login. Tente novamente.';
        errorDiv.style.display = 'block';
    }
    
    showLoading(false);
}

async function handleLogout() {
    showLoading(true);
    
    try {
        await supabaseClient.signOut();
        AdminState.user = null;
        AdminState.products = [];
        showLoginScreen();
    } catch (error) {
        console.error('Erro no logout:', error);
        showNotification('Erro ao fazer logout', 'error');
    }
    
    showLoading(false);
}

// Navegação
function showLoginScreen() {
    document.getElementById('login-screen').style.display = 'flex';
    document.getElementById('admin-dashboard').style.display = 'none';
}

function showDashboard() {
    document.getElementById('login-screen').style.display = 'none';
    document.getElementById('admin-dashboard').style.display = 'flex';
    
    // Atualiza nome do usuário
    const userNameElement = document.getElementById('admin-user-name');
    if (userNameElement && AdminState.user) {
        userNameElement.textContent = AdminState.user.email || 'Administrador';
    }
}

function showSection(sectionName) {
    // Evita processamento se já está na seção atual
    if (AdminState.currentSection === sectionName && !AdminState.isLoading) {
        console.log('Já está na seção:', sectionName);
        return;
    }
    
    console.log('Mudando para seção:', sectionName);
    
    try {
        // Remove active de todas as seções
        document.querySelectorAll('.content-section').forEach(section => {
            section.classList.remove('active');
        });
        
        // Remove active de todos os nav items
        document.querySelectorAll('.nav-item').forEach(item => {
            item.classList.remove('active');
        });
        
        // Ativa a seção atual
        const targetSection = document.getElementById(`${sectionName}-section`);
        const targetNavItem = document.querySelector(`[data-section="${sectionName}"]`);
        
        if (targetSection) {
            targetSection.classList.add('active');
        } else {
            console.error('Seção não encontrada:', `${sectionName}-section`);
            return;
        }
        
        if (targetNavItem) {
            targetNavItem.classList.add('active');
        }
        
        // Atualiza título da página
        const titles = {
            dashboard: 'Dashboard',
            produtos: 'Gerenciar Produtos',
            adicionar: 'Adicionar Produto',
            configuracoes: 'Configurações'
        };
        
        const pageTitle = document.getElementById('page-title');
        if (pageTitle) {
            pageTitle.textContent = titles[sectionName] || sectionName;
        }
        
        AdminState.currentSection = sectionName;
        
        // Carrega dados específicos da seção
        if (sectionName === 'produtos') {
            renderProductsTable();
        } else if (sectionName === 'adicionar') {
            // Só reseta o formulário se não estiver editando um produto
            if (!AdminState.editingProduct) {
                resetProductForm();
            }
        } else if (sectionName === 'configuracoes') {
            loadSettings();
        }
        
    } catch (error) {
        console.error('Erro ao mudar seção:', error);
    }
}

// Carregamento de dados
async function loadAdminData() {
    // Evita múltiplas chamadas simultâneas
    if (AdminState.isLoading) {
        console.log('Dados já estão sendo carregados...');
        return;
    }
    
    AdminState.isLoading = true;
    console.log('Carregando dados do admin...');
    showLoading(true);
    
    try {
        // Carrega produtos
        const { data, error } = await supabaseClient.getProducts();
        
        if (error) {
            console.error('Erro ao carregar produtos:', error);
            showNotification('Erro ao carregar produtos', 'error');
            return;
        }
        
        AdminState.products = data || [];
        console.log('Produtos carregados:', AdminState.products.length);
        
        // Atualiza dashboard
        updateDashboardStats();
        
        // Renderiza tabela se estiver na seção de produtos
        if (AdminState.currentSection === 'produtos') {
            renderProductsTable();
        }
        
    } catch (error) {
        console.error('Erro ao carregar dados:', error);
        AdminState.products = [];
        showNotification('Erro ao carregar dados', 'error');
    } finally {
        AdminState.isLoading = false;
        showLoading(false);
    }
}

// Dashboard
function updateDashboardStats() {
    const totalProducts = AdminState.products.length;
    const lastUpdate = AdminState.products.length > 0 ? 
        formatDate(Math.max(...AdminState.products.map(p => new Date(p.criado_em)))) : 
        'Nunca';
    
    document.getElementById('total-products').textContent = totalProducts;
    document.getElementById('last-update').textContent = lastUpdate;
}

// Gerenciamento de produtos
function renderProductsTable() {
    console.log('Renderizando tabela de produtos...');
    
    // Evita renderização múltipla
    if (AdminState.isLoading) {
        console.log('Já está carregando produtos, aguarde...');
        return;
    }
    
    AdminState.isLoading = true;
    
    try {
        const tbody = document.getElementById('products-table-body');
        const noProducts = document.getElementById('no-products');
        const tableContainer = document.querySelector('.products-table-container');
        
        if (!tbody || !noProducts || !tableContainer) {
            console.error('Elementos da tabela não encontrados');
            AdminState.isLoading = false;
            return;
        }
        
        if (!AdminState.products || AdminState.products.length === 0) {
            console.log('Nenhum produto encontrado');
            tableContainer.style.display = 'none';
            noProducts.style.display = 'block';
            AdminState.isLoading = false;
            return;
        }
        
        console.log(`Renderizando ${AdminState.products.length} produtos`);
        tableContainer.style.display = 'block';
        noProducts.style.display = 'none';
        
        tbody.innerHTML = AdminState.products.map(product => `
            <tr>
                <td>
                    <img src="${product.url_imagem}" alt="${product.nome}" class="product-table-image"
                         onerror="this.src='../assets/images/placeholder.svg'">
                </td>
                <td>
                    <div class="product-table-name">${product.nome}</div>
                    <small style="color: #666;">${product.descricao || ''}</small>
                </td>
                <td>
                    <span class="badge badge-${getCategoryColor(product.categoria)}">${getCategoryName(product.categoria)}</span>
                </td>
                <td>
                    <div class="product-table-price">${formatPrice(product.preco)}</div>
                </td>
                <td>
                    <div class="product-table-actions">
                        <button class="btn btn-primary btn-sm" onclick="editProduct(${product.id})">
                            <i class="fas fa-edit"></i>
                        </button>
                        <button class="btn btn-danger btn-sm" onclick="confirmDeleteProduct(${product.id}, '${product.nome}')">
                            <i class="fas fa-trash"></i>
                        </button>
                    </div>
                </td>
            </tr>
        `).join('');
        
        console.log('Tabela de produtos renderizada com sucesso');
        
    } catch (error) {
        console.error('Erro ao renderizar tabela de produtos:', error);
    } finally {
        AdminState.isLoading = false;
    }
}

function getCategoryColor(category) {
    const colors = {
        frutas: 'success',
        bebidas: 'info',
        limpeza: 'warning',
        padaria: 'secondary',
        carnes: 'danger',
        outros: 'dark'
    };
    return colors[category] || 'dark';
}

function getCategoryName(category) {
    const names = {
        frutas: 'Frutas',
        bebidas: 'Bebidas',
        limpeza: 'Limpeza',
        padaria: 'Padaria',
        carnes: 'Carnes',
        outros: 'Outros'
    };
    return names[category] || category;
}

// Formulário de produto
function resetProductForm() {
    try {
        const form = document.getElementById('product-form');
        const productIdField = document.getElementById('product-id');
        const formTitle = document.getElementById('form-title');
        const saveBtn = document.getElementById('save-product-btn');
        
        if (form) form.reset();
        if (productIdField) productIdField.value = '';
        
        removeImagePreview();
        AdminState.editingProduct = null;
        
        // Restaura títulos padrão
        if (formTitle) formTitle.textContent = 'Adicionar Produto';
        if (saveBtn) saveBtn.textContent = 'Salvar Produto';
        
        console.log('Formulário resetado');
        
    } catch (error) {
        console.error('Erro ao resetar formulário:', error);
    }
}

function editProduct(productId) {
    console.log('Editando produto:', productId);
    
    const product = AdminState.products.find(p => p.id === productId);
    if (!product) {
        console.error('Produto não encontrado:', productId);
        showNotification('Produto não encontrado!', 'error');
        return;
    }
    
    AdminState.editingProduct = product;
    
    try {
        // Preenche o formulário
        const productIdField = document.getElementById('product-id');
        const productNameField = document.getElementById('product-name');
        const productDescField = document.getElementById('product-description');
        const productPriceField = document.getElementById('product-price');
        const productCategoryField = document.getElementById('product-category');
        
        if (productIdField) productIdField.value = product.id;
        if (productNameField) productNameField.value = product.nome;
        if (productDescField) productDescField.value = product.descricao || '';
        if (productPriceField) productPriceField.value = product.preco;
        if (productCategoryField) productCategoryField.value = product.categoria;
        
        // Mostra preview da imagem atual
        if (product.url_imagem) {
            const preview = document.getElementById('image-preview');
            const img = document.getElementById('preview-img');
            if (preview && img) {
                img.src = product.url_imagem;
                preview.style.display = 'block';
            }
        }
        
        // Atualiza títulos
        const formTitle = document.getElementById('form-title');
        const saveBtn = document.getElementById('save-product-btn');
        
        if (formTitle) formTitle.textContent = 'Editar Produto';
        if (saveBtn) saveBtn.textContent = 'Atualizar Produto';
        
        // Vai para a seção de adicionar
        showSection('adicionar');
        
        console.log('Produto carregado para edição:', product);
        
    } catch (error) {
        console.error('Erro ao carregar produto para edição:', error);
        showNotification('Erro ao carregar produto para edição!', 'error');
    }
}

async function handleProductSubmit(e) {
    e.preventDefault();
    
    const formData = new FormData(e.target);
    const productData = {
        nome: document.getElementById('product-name').value,
        descricao: document.getElementById('product-description').value,
        preco: parseFloat(document.getElementById('product-price').value),
        categoria: document.getElementById('product-category').value
    };
    
    // Validação
    if (!productData.nome || !productData.preco || !productData.categoria) {
        showNotification('Por favor, preencha todos os campos obrigatórios', 'error');
        return;
    }
    
    showLoading(true);
    
    try {
        // Upload de imagem se houver
        const imageFile = document.getElementById('product-image').files[0];
        if (imageFile) {
            console.log('Iniciando upload da imagem:', imageFile.name, 'Tamanho:', imageFile.size);
            
            try {
                const { data: imageData, error: imageError } = await supabaseClient.uploadImage(imageFile);
                
                if (imageError) {
                    console.error('Erro no upload da imagem:', imageError);
                    showNotification(`Erro ao fazer upload da imagem: ${imageError.message || 'Erro desconhecido'}`, 'error');
                    showLoading(false);
                    return;
                }
                
                if (imageData && imageData.publicUrl) {
                    productData.url_imagem = imageData.publicUrl;
                    console.log('Upload concluído com sucesso:', imageData.publicUrl);
                } else {
                    console.error('Upload retornou dados inválidos:', imageData);
                    showNotification('Erro: Upload não retornou URL válida', 'error');
                    showLoading(false);
                    return;
                }
            } catch (uploadError) {
                console.error('Exceção durante upload:', uploadError);
                showNotification('Erro inesperado durante upload da imagem', 'error');
                showLoading(false);
                return;
            }
        } else if (AdminState.editingProduct) {
            // Mantém a imagem atual se não houver nova imagem
            productData.url_imagem = AdminState.editingProduct.url_imagem;
            console.log('Mantendo imagem atual:', productData.url_imagem);
        }
        
        let result;
        if (AdminState.editingProduct) {
            // Atualizar produto existente
            result = await supabaseClient.updateProduct(AdminState.editingProduct.id, productData);
        } else {
            // Criar novo produto
            result = await supabaseClient.addProduct(productData);
        }
        
        if (result.error) {
            console.error('Erro ao salvar produto:', result.error);
            showNotification('Erro ao salvar produto', 'error');
            showLoading(false);
            return;
        }
        
        // Recarrega dados
        await loadAdminData();
        
        // Volta para a lista de produtos
        showSection('produtos');
        
        const action = AdminState.editingProduct ? 'atualizado' : 'adicionado';
        showNotification(`Produto ${action} com sucesso!`, 'success');
        
    } catch (error) {
        console.error('Erro ao salvar produto:', error);
        showNotification('Erro ao salvar produto', 'error');
    }
    
    showLoading(false);
}

function cancelProductForm() {
    console.log('Cancelando edição/adição de produto');
    resetProductForm();
    showSection('produtos');
    showNotification('Operação cancelada', 'info');
}

// Upload de imagem
function handleImagePreview(e) {
    const file = e.target.files[0];
    if (!file) return;
    
    // Validação do arquivo
    if (!file.type.startsWith('image/')) {
        showNotification('Por favor, selecione apenas arquivos de imagem', 'error');
        e.target.value = '';
        return;
    }
    
    if (file.size > 5 * 1024 * 1024) { // 5MB
        showNotification('A imagem deve ter no máximo 5MB', 'error');
        e.target.value = '';
        return;
    }
    
    // Mostra preview
    const reader = new FileReader();
    reader.onload = function(e) {
        const preview = document.getElementById('image-preview');
        const img = document.getElementById('preview-img');
        img.src = e.target.result;
        preview.style.display = 'block';
    };
    reader.readAsDataURL(file);
}

function removeImagePreview() {
    const preview = document.getElementById('image-preview');
    const img = document.getElementById('preview-img');
    const input = document.getElementById('product-image');
    
    preview.style.display = 'none';
    img.src = '';
    input.value = '';
}

// Exclusão de produto
function confirmDeleteProduct(productId, productName) {
    const modal = document.getElementById('delete-modal');
    const nameElement = document.getElementById('delete-product-name');
    const confirmBtn = document.getElementById('confirm-delete-btn');
    
    nameElement.textContent = productName;
    
    // Remove event listeners anteriores
    const newConfirmBtn = confirmBtn.cloneNode(true);
    confirmBtn.parentNode.replaceChild(newConfirmBtn, confirmBtn);
    
    // Adiciona novo event listener
    newConfirmBtn.addEventListener('click', () => deleteProduct(productId));
    
    modal.style.display = 'block';
}

async function deleteProduct(productId) {
    showLoading(true);
    closeDeleteModal();
    
    try {
        const { error } = await supabaseClient.deleteProduct(productId);
        
        if (error) {
            console.error('Erro ao excluir produto:', error);
            showNotification('Erro ao excluir produto', 'error');
            showLoading(false);
            return;
        }
        
        // Recarrega dados
        await loadAdminData();
        
        showNotification('Produto excluído com sucesso!', 'success');
        
    } catch (error) {
        console.error('Erro ao excluir produto:', error);
        showNotification('Erro ao excluir produto', 'error');
    }
    
    showLoading(false);
}

function closeDeleteModal() {
    document.getElementById('delete-modal').style.display = 'none';
}

// Configurações
function loadSettings() {
    const savedNumber = localStorage.getItem('mercado_whatsapp_number');
    if (savedNumber) {
        document.getElementById('whatsapp-number').value = savedNumber;
        AdminState.whatsappNumber = savedNumber;
    }
}

function saveWhatsAppNumber() {
    const number = document.getElementById('whatsapp-number').value.trim();
    
    if (!number) {
        showNotification('Por favor, insira um número válido', 'error');
        return;
    }
    
    // Validação básica do número
    if (!/^\d{10,15}$/.test(number)) {
        showNotification('Número deve conter apenas dígitos (10-15 caracteres)', 'error');
        return;
    }
    
    localStorage.setItem('mercado_whatsapp_number', number);
    AdminState.whatsappNumber = number;
    
    showNotification('Número do WhatsApp salvo com sucesso!', 'success');
}

function exportProducts() {
    if (AdminState.products.length === 0) {
        showNotification('Não há produtos para exportar', 'warning');
        return;
    }
    
    // Prepara dados para exportação
    const exportData = AdminState.products.map(product => ({
        Nome: product.nome,
        Descrição: product.descricao || '',
        Preço: product.preco,
        Categoria: getCategoryName(product.categoria),
        'Data de Criação': formatDate(product.criado_em)
    }));
    
    // Converte para CSV
    const headers = Object.keys(exportData[0]);
    const csvContent = [
        headers.join(','),
        ...exportData.map(row => 
            headers.map(header => `"${row[header]}"`).join(',')
        )
    ].join('\n');
    
    // Download do arquivo
    const blob = new Blob([csvContent], { type: 'text/csv;charset=utf-8;' });
    const link = document.createElement('a');
    const url = URL.createObjectURL(blob);
    
    link.setAttribute('href', url);
    link.setAttribute('download', `produtos_${new Date().toISOString().split('T')[0]}.csv`);
    link.style.visibility = 'hidden';
    
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
    
    showNotification('Produtos exportados com sucesso!', 'success');
}

// Utilitários
function showLoading(show) {
    const loading = document.getElementById('loading');
    loading.style.display = show ? 'flex' : 'none';
}

function showNotification(message, type = 'info') {
    // Cria elemento de notificação
    const notification = document.createElement('div');
    notification.className = `notification notification-${type}`;
    notification.innerHTML = `
        <i class="fas fa-${getNotificationIcon(type)}"></i>
        <span>${message}</span>
    `;
    
    // Adiciona estilos
    notification.style.cssText = `
        position: fixed;
        top: 20px;
        right: 20px;
        background: ${getNotificationColor(type)};
        color: white;
        padding: 1rem 1.5rem;
        border-radius: 8px;
        box-shadow: 0 4px 15px rgba(0,0,0,0.2);
        z-index: 10000;
        display: flex;
        align-items: center;
        gap: 10px;
        font-weight: 500;
        animation: slideIn 0.3s ease;
        max-width: 400px;
    `;
    
    document.body.appendChild(notification);
    
    // Remove após 4 segundos
    setTimeout(() => {
        notification.style.animation = 'slideOut 0.3s ease';
        setTimeout(() => {
            if (notification.parentNode) {
                notification.parentNode.removeChild(notification);
            }
        }, 300);
    }, 4000);
}

function getNotificationIcon(type) {
    const icons = {
        success: 'check-circle',
        error: 'exclamation-circle',
        warning: 'exclamation-triangle',
        info: 'info-circle'
    };
    return icons[type] || 'info-circle';
}

function getNotificationColor(type) {
    const colors = {
        success: '#27ae60',
        error: '#e74c3c',
        warning: '#f39c12',
        info: '#3498db'
    };
    return colors[type] || '#3498db';
}

// Adiciona estilos para badges
const style = document.createElement('style');
style.textContent = `
    .badge {
        display: inline-block;
        padding: 0.25em 0.6em;
        font-size: 0.75em;
        font-weight: 700;
        line-height: 1;
        text-align: center;
        white-space: nowrap;
        vertical-align: baseline;
        border-radius: 0.375rem;
    }
    
    .badge-success { background-color: #28a745; color: white; }
    .badge-info { background-color: #17a2b8; color: white; }
    .badge-warning { background-color: #ffc107; color: #212529; }
    .badge-secondary { background-color: #6c757d; color: white; }
    .badge-danger { background-color: #dc3545; color: white; }
    .badge-dark { background-color: #343a40; color: white; }
    
    @keyframes slideIn {
        from {
            transform: translateX(100%);
            opacity: 0;
        }
        to {
            transform: translateX(0);
            opacity: 1;
        }
    }
    
    @keyframes slideOut {
        from {
            transform: translateX(0);
            opacity: 1;
        }
        to {
            transform: translateX(100%);
            opacity: 0;
        }
    }
`;
document.head.appendChild(style);


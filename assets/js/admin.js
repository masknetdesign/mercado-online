// Estado global da aplicação administrativa
const AdminState = {
    user: null,
    products: [],
    currentSection: 'dashboard',
    editingProduct: null,
    whatsappNumber: '5511999999999'
};

// Inicialização da aplicação
document.addEventListener('DOMContentLoaded', function() {
    initializeAdmin();
});

async function initializeAdmin() {
    // Verifica se o usuário já está logado
    const currentUser = await supabaseClient.getCurrentUser();
    
    if (currentUser) {
        AdminState.user = currentUser;
        showDashboard();
        await loadAdminData();
    } else {
        showLoginScreen();
    }
    
    initializeEventListeners();
}

// Event Listeners
function initializeEventListeners() {
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
            const section = this.getAttribute('data-section');
            showSection(section);
        });
    });
    
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
    // Remove active de todas as seções
    document.querySelectorAll('.content-section').forEach(section => {
        section.classList.remove('active');
    });
    
    // Remove active de todos os nav items
    document.querySelectorAll('.nav-item').forEach(item => {
        item.classList.remove('active');
    });
    
    // Ativa a seção atual
    document.getElementById(`${sectionName}-section`).classList.add('active');
    document.querySelector(`[data-section="${sectionName}"]`).classList.add('active');
    
    // Atualiza título da página
    const titles = {
        dashboard: 'Dashboard',
        produtos: 'Gerenciar Produtos',
        adicionar: 'Adicionar Produto',
        configuracoes: 'Configurações'
    };
    
    document.getElementById('page-title').textContent = titles[sectionName] || sectionName;
    
    AdminState.currentSection = sectionName;
    
    // Carrega dados específicos da seção
    if (sectionName === 'produtos') {
        renderProductsTable();
    } else if (sectionName === 'adicionar') {
        resetProductForm();
    } else if (sectionName === 'configuracoes') {
        loadSettings();
    }
}

// Carregamento de dados
async function loadAdminData() {
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
        
        // Atualiza dashboard
        updateDashboardStats();
        
        // Renderiza tabela se estiver na seção de produtos
        if (AdminState.currentSection === 'produtos') {
            renderProductsTable();
        }
        
    } catch (error) {
        console.error('Erro ao carregar dados:', error);
        showNotification('Erro ao carregar dados', 'error');
    }
    
    showLoading(false);
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
    const tbody = document.getElementById('products-table-body');
    const noProducts = document.getElementById('no-products');
    const tableContainer = document.querySelector('.products-table-container');
    
    if (AdminState.products.length === 0) {
        tableContainer.style.display = 'none';
        noProducts.style.display = 'block';
        return;
    }
    
    tableContainer.style.display = 'block';
    noProducts.style.display = 'none';
    
    tbody.innerHTML = AdminState.products.map(product => `
        <tr>
            <td>
                <img src="${product.url_imagem}" alt="${product.nome}" class="product-table-image"
                     onerror="this.src='https://via.placeholder.com/60x60?text=Sem+Imagem'">
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
    document.getElementById('product-form').reset();
    document.getElementById('product-id').value = '';
    document.getElementById('form-title').textContent = 'Adicionar Produto';
    document.getElementById('save-product-btn').textContent = 'Salvar Produto';
    AdminState.editingProduct = null;
    removeImagePreview();
}

function editProduct(productId) {
    const product = AdminState.products.find(p => p.id === productId);
    if (!product) return;
    
    AdminState.editingProduct = product;
    
    // Preenche o formulário
    document.getElementById('product-id').value = product.id;
    document.getElementById('product-name').value = product.nome;
    document.getElementById('product-description').value = product.descricao || '';
    document.getElementById('product-price').value = product.preco;
    document.getElementById('product-category').value = product.categoria;
    
    // Mostra preview da imagem atual
    if (product.url_imagem) {
        const preview = document.getElementById('image-preview');
        const img = document.getElementById('preview-img');
        img.src = product.url_imagem;
        preview.style.display = 'block';
    }
    
    // Atualiza títulos
    document.getElementById('form-title').textContent = 'Editar Produto';
    document.getElementById('save-product-btn').textContent = 'Atualizar Produto';
    
    // Vai para a seção de adicionar
    showSection('adicionar');
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
            const { data: imageData, error: imageError } = await supabaseClient.uploadImage(imageFile);
            
            if (imageError) {
                console.error('Erro no upload da imagem:', imageError);
                showNotification('Erro ao fazer upload da imagem', 'error');
                showLoading(false);
                return;
            }
            
            productData.url_imagem = imageData.publicUrl;
        } else if (AdminState.editingProduct) {
            // Mantém a imagem atual se não houver nova imagem
            productData.url_imagem = AdminState.editingProduct.url_imagem;
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
    showSection('produtos');
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


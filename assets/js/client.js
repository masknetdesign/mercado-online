// Estado global da aplicação
const AppState = {
    products: [],
    filteredProducts: [],
    cart: [],
    currentPage: 1,
    productsPerPage: 12,
    currentCategory: 'all',
    searchTerm: '',
    whatsappNumber: '5511999999999' // Número padrão, será carregado das configurações
};

// Inicialização da aplicação
document.addEventListener('DOMContentLoaded', function() {
    initializeApp();
});

async function initializeApp() {
    showLoading(true);
    
    // Carrega produtos
    await loadProducts();
    
    // Carrega configurações
    loadSettings();
    
    // Carrega carrinho do localStorage
    loadCart();
    
    // Inicializa event listeners
    initializeEventListeners();
    
    // Renderiza produtos em destaque
    renderFeaturedProducts();
    
    // Renderiza todos os produtos
    renderProducts();
    
    // Atualiza contador do carrinho
    updateCartCount();
    
    showLoading(false);
}

// Carregamento de produtos
async function loadProducts() {
    try {
        const { data, error } = await supabaseClient.getProducts();
        
        if (error) {
            console.error('Erro ao carregar produtos:', error);
            showNotification('Erro ao carregar produtos', 'error');
            return;
        }
        
        AppState.products = data || [];
        AppState.filteredProducts = [...AppState.products];
        
    } catch (error) {
        console.error('Erro ao carregar produtos:', error);
        showNotification('Erro ao carregar produtos', 'error');
    }
}

// Carregamento de configurações
function loadSettings() {
    const savedNumber = localStorage.getItem('mercado_whatsapp_number');
    if (savedNumber) {
        AppState.whatsappNumber = savedNumber;
    }
}

// Carregamento do carrinho
function loadCart() {
    const savedCart = localStorage.getItem('mercado_cart');
    if (savedCart) {
        AppState.cart = JSON.parse(savedCart);
    }
}

// Salvamento do carrinho
function saveCart() {
    localStorage.setItem('mercado_cart', JSON.stringify(AppState.cart));
}

// Event Listeners
function initializeEventListeners() {
    // Navegação
    document.querySelectorAll('.nav-link').forEach(link => {
        link.addEventListener('click', function(e) {
            e.preventDefault();
            const section = this.getAttribute('href').substring(1);
            showSection(section);
        });
    });
    
    // Busca
    const searchInput = document.getElementById('search-input');
    const searchBtn = document.getElementById('search-btn');
    
    searchInput.addEventListener('input', debounce(handleSearch, 300));
    searchBtn.addEventListener('click', handleSearch);
    searchInput.addEventListener('keypress', function(e) {
        if (e.key === 'Enter') {
            handleSearch();
        }
    });
    
    // Filtros de categoria
    document.querySelectorAll('.filter-btn').forEach(btn => {
        btn.addEventListener('click', function() {
            const category = this.getAttribute('data-category');
            filterByCategory(category);
        });
    });
    
    // Paginação
    document.getElementById('prev-page').addEventListener('click', () => changePage(-1));
    document.getElementById('next-page').addEventListener('click', () => changePage(1));
    
    // Checkout
    document.getElementById('checkout-btn').addEventListener('click', openCheckoutModal);
    document.getElementById('checkout-form').addEventListener('submit', handleCheckout);
    
    // Modal
    document.querySelector('.close').addEventListener('click', closeCheckoutModal);
    window.addEventListener('click', function(e) {
        const modal = document.getElementById('checkout-modal');
        if (e.target === modal) {
            closeCheckoutModal();
        }
    });
}

// Navegação entre seções
function showSection(sectionName) {
    // Remove active de todas as seções
    document.querySelectorAll('.section').forEach(section => {
        section.classList.remove('active');
    });
    
    // Remove active de todos os links
    document.querySelectorAll('.nav-link').forEach(link => {
        link.classList.remove('active');
    });
    
    // Ativa a seção atual
    document.getElementById(sectionName).classList.add('active');
    
    // Ativa o link atual
    document.querySelector(`[href="#${sectionName}"]`).classList.add('active');
    
    // Atualiza carrinho se necessário
    if (sectionName === 'carrinho') {
        renderCart();
    }
}

// Busca de produtos
function handleSearch() {
    const searchInput = document.getElementById('search-input');
    AppState.searchTerm = searchInput.value.toLowerCase().trim();
    AppState.currentPage = 1;
    filterProducts();
    renderProducts();
}

// Filtro por categoria
function filterByCategory(category) {
    // Atualiza botões de filtro
    document.querySelectorAll('.filter-btn').forEach(btn => {
        btn.classList.remove('active');
    });
    document.querySelector(`[data-category="${category}"]`).classList.add('active');
    
    AppState.currentCategory = category;
    AppState.currentPage = 1;
    filterProducts();
    renderProducts();
}

// Aplicação de filtros
function filterProducts() {
    let filtered = [...AppState.products];
    
    // Filtro por categoria
    if (AppState.currentCategory !== 'all') {
        filtered = filtered.filter(product => 
            product.categoria === AppState.currentCategory
        );
    }
    
    // Filtro por busca
    if (AppState.searchTerm) {
        filtered = filtered.filter(product =>
            product.nome.toLowerCase().includes(AppState.searchTerm) ||
            product.descricao.toLowerCase().includes(AppState.searchTerm)
        );
    }
    
    AppState.filteredProducts = filtered;
}

// Renderização de produtos em destaque
function renderFeaturedProducts() {
    const container = document.getElementById('featured-products');
    const featured = AppState.products.slice(0, 6); // Primeiros 6 produtos
    
    container.innerHTML = featured.map(product => createProductCard(product)).join('');
}

// Renderização de produtos
function renderProducts() {
    const container = document.getElementById('products-grid');
    const startIndex = (AppState.currentPage - 1) * AppState.productsPerPage;
    const endIndex = startIndex + AppState.productsPerPage;
    const productsToShow = AppState.filteredProducts.slice(startIndex, endIndex);
    
    if (productsToShow.length === 0) {
        container.innerHTML = `
            <div class="no-products" style="grid-column: 1 / -1; text-align: center; padding: 3rem;">
                <i class="fas fa-search" style="font-size: 3rem; color: #bdc3c7; margin-bottom: 1rem;"></i>
                <p>Nenhum produto encontrado</p>
            </div>
        `;
    } else {
        container.innerHTML = productsToShow.map(product => createProductCard(product)).join('');
    }
    
    updatePagination();
}

// Criação do card de produto
function createProductCard(product) {
    const isInCart = AppState.cart.some(item => item.id === product.id);
    
    return `
        <div class="product-card">
            <img src="${product.url_imagem}" alt="${product.nome}" class="product-image" 
                 onerror="this.src='https://via.placeholder.com/300x200?text=Sem+Imagem'">
            <div class="product-info">
                <h3 class="product-name">${product.nome}</h3>
                <p class="product-description">${product.descricao || ''}</p>
                <div class="product-price">${formatPrice(product.preco)}</div>
                <div class="product-actions">
                    ${isInCart ? 
                        `<button class="btn btn-secondary" onclick="removeFromCart(${product.id})">
                            <i class="fas fa-check"></i> No Carrinho
                        </button>` :
                        `<button class="btn btn-primary" onclick="addToCart(${product.id})">
                            <i class="fas fa-cart-plus"></i> Adicionar
                        </button>`
                    }
                </div>
            </div>
        </div>
    `;
}

// Atualização da paginação
function updatePagination() {
    const totalPages = Math.ceil(AppState.filteredProducts.length / AppState.productsPerPage);
    const prevBtn = document.getElementById('prev-page');
    const nextBtn = document.getElementById('next-page');
    const pageInfo = document.getElementById('page-info');
    
    prevBtn.disabled = AppState.currentPage === 1;
    nextBtn.disabled = AppState.currentPage === totalPages || totalPages === 0;
    pageInfo.textContent = `Página ${AppState.currentPage} de ${totalPages || 1}`;
}

// Mudança de página
function changePage(direction) {
    const totalPages = Math.ceil(AppState.filteredProducts.length / AppState.productsPerPage);
    const newPage = AppState.currentPage + direction;
    
    if (newPage >= 1 && newPage <= totalPages) {
        AppState.currentPage = newPage;
        renderProducts();
        
        // Scroll para o topo da seção de produtos
        document.getElementById('products-grid').scrollIntoView({ 
            behavior: 'smooth', 
            block: 'start' 
        });
    }
}

// Adicionar ao carrinho
function addToCart(productId) {
    const product = AppState.products.find(p => p.id === productId);
    if (!product) return;
    
    const existingItem = AppState.cart.find(item => item.id === productId);
    
    if (existingItem) {
        existingItem.quantity += 1;
    } else {
        AppState.cart.push({
            ...product,
            quantity: 1
        });
    }
    
    saveCart();
    updateCartCount();
    renderProducts(); // Re-renderiza para atualizar botões
    showNotification(`${product.nome} adicionado ao carrinho!`, 'success');
}

// Remover do carrinho
function removeFromCart(productId) {
    AppState.cart = AppState.cart.filter(item => item.id !== productId);
    saveCart();
    updateCartCount();
    renderProducts(); // Re-renderiza para atualizar botões
    renderCart(); // Atualiza a visualização do carrinho
    showNotification('Produto removido do carrinho', 'info');
}

// Atualizar quantidade no carrinho
function updateCartQuantity(productId, change) {
    const item = AppState.cart.find(item => item.id === productId);
    if (!item) return;
    
    item.quantity += change;
    
    if (item.quantity <= 0) {
        removeFromCart(productId);
        return;
    }
    
    saveCart();
    updateCartCount();
    renderCart();
}

// Atualizar contador do carrinho
function updateCartCount() {
    const count = AppState.cart.reduce((total, item) => total + item.quantity, 0);
    document.getElementById('cart-count').textContent = count;
}

// Renderização do carrinho
function renderCart() {
    const cartItems = document.getElementById('cart-items');
    const cartEmpty = document.getElementById('cart-empty');
    const cartSummary = document.getElementById('cart-summary');
    
    if (AppState.cart.length === 0) {
        cartItems.style.display = 'none';
        cartSummary.style.display = 'none';
        cartEmpty.style.display = 'block';
        return;
    }
    
    cartEmpty.style.display = 'none';
    cartItems.style.display = 'block';
    cartSummary.style.display = 'block';
    
    // Renderiza itens
    cartItems.innerHTML = AppState.cart.map(item => `
        <div class="cart-item">
            <img src="${item.url_imagem}" alt="${item.nome}" class="cart-item-image"
                 onerror="this.src='https://via.placeholder.com/80x80?text=Sem+Imagem'">
            <div class="cart-item-info">
                <div class="cart-item-name">${item.nome}</div>
                <div class="cart-item-price">${formatPrice(item.preco)} cada</div>
            </div>
            <div class="cart-item-controls">
                <div class="quantity-controls">
                    <button class="quantity-btn" onclick="updateCartQuantity(${item.id}, -1)">
                        <i class="fas fa-minus"></i>
                    </button>
                    <span class="quantity-display">${item.quantity}</span>
                    <button class="quantity-btn" onclick="updateCartQuantity(${item.id}, 1)">
                        <i class="fas fa-plus"></i>
                    </button>
                </div>
                <button class="btn btn-danger btn-sm" onclick="removeFromCart(${item.id})">
                    <i class="fas fa-trash"></i>
                </button>
            </div>
        </div>
    `).join('');
    
    // Calcula totais
    const subtotal = AppState.cart.reduce((total, item) => total + (item.preco * item.quantity), 0);
    
    document.getElementById('cart-subtotal').textContent = formatPrice(subtotal);
    document.getElementById('cart-total').textContent = formatPrice(subtotal);
}

// Modal de checkout
function openCheckoutModal() {
    if (AppState.cart.length === 0) {
        showNotification('Seu carrinho está vazio!', 'warning');
        return;
    }
    
    const modal = document.getElementById('checkout-modal');
    const checkoutItems = document.getElementById('checkout-items');
    const checkoutTotal = document.getElementById('checkout-total');
    
    // Renderiza itens do checkout
    checkoutItems.innerHTML = AppState.cart.map(item => `
        <div class="checkout-item">
            <span>${item.nome} x${item.quantity}</span>
            <span>${formatPrice(item.preco * item.quantity)}</span>
        </div>
    `).join('');
    
    // Calcula total
    const total = AppState.cart.reduce((sum, item) => sum + (item.preco * item.quantity), 0);
    checkoutTotal.textContent = formatPrice(total);
    
    modal.style.display = 'block';
}

function closeCheckoutModal() {
    document.getElementById('checkout-modal').style.display = 'none';
    document.getElementById('checkout-form').reset();
}

// Processamento do checkout
function handleCheckout(e) {
    e.preventDefault();
    
    const formData = new FormData(e.target);
    const customerName = document.getElementById('customer-name').value;
    const customerPhone = document.getElementById('customer-phone').value;
    const customerAddress = document.getElementById('customer-address').value;
    const paymentMethod = document.getElementById('payment-method').value;
    const orderNotes = document.getElementById('order-notes').value;
    
    // Validação básica
    if (!customerName || !customerPhone || !customerAddress || !paymentMethod) {
        showNotification('Por favor, preencha todos os campos obrigatórios', 'error');
        return;
    }
    
    // Gera mensagem para WhatsApp
    const message = generateWhatsAppMessage({
        customerName,
        customerPhone,
        customerAddress,
        paymentMethod,
        orderNotes,
        cart: AppState.cart
    });
    
    // Abre WhatsApp
    const whatsappUrl = `https://wa.me/${AppState.whatsappNumber}?text=${encodeURIComponent(message)}`;
    window.open(whatsappUrl, '_blank');
    
    // Limpa carrinho e fecha modal
    AppState.cart = [];
    saveCart();
    updateCartCount();
    closeCheckoutModal();
    showSection('home');
    
    showNotification('Pedido enviado! Você será redirecionado para o WhatsApp.', 'success');
}

// Geração da mensagem do WhatsApp
function generateWhatsAppMessage(orderData) {
    const { customerName, customerPhone, customerAddress, paymentMethod, orderNotes, cart } = orderData;
    
    let message = `🛒 *NOVO PEDIDO - MERCADO ONLINE*\n\n`;
    message += `👤 *Cliente:* ${customerName}\n`;
    message += `📱 *Telefone:* ${customerPhone}\n`;
    message += `📍 *Endereço:* ${customerAddress}\n`;
    message += `💳 *Pagamento:* ${paymentMethod}\n\n`;
    
    message += `📦 *ITENS DO PEDIDO:*\n`;
    message += `${'─'.repeat(30)}\n`;
    
    let total = 0;
    cart.forEach(item => {
        const itemTotal = item.preco * item.quantity;
        total += itemTotal;
        message += `• ${item.nome}\n`;
        message += `  Qtd: ${item.quantity} x ${formatPrice(item.preco)} = ${formatPrice(itemTotal)}\n\n`;
    });
    
    message += `${'─'.repeat(30)}\n`;
    message += `💰 *TOTAL: ${formatPrice(total)}*\n\n`;
    
    if (orderNotes) {
        message += `📝 *Observações:* ${orderNotes}\n\n`;
    }
    
    message += `⏰ Pedido realizado em: ${new Date().toLocaleString('pt-BR')}\n`;
    message += `\n_Pedido gerado automaticamente pelo site_`;
    
    return message;
}

// Utilitários
function debounce(func, wait) {
    let timeout;
    return function executedFunction(...args) {
        const later = () => {
            clearTimeout(timeout);
            func(...args);
        };
        clearTimeout(timeout);
        timeout = setTimeout(later, wait);
    };
}

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
        top: 100px;
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
    `;
    
    document.body.appendChild(notification);
    
    // Remove após 3 segundos
    setTimeout(() => {
        notification.style.animation = 'slideOut 0.3s ease';
        setTimeout(() => {
            if (notification.parentNode) {
                notification.parentNode.removeChild(notification);
            }
        }, 300);
    }, 3000);
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

// Adiciona estilos de animação para notificações
const style = document.createElement('style');
style.textContent = `
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


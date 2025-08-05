# Configuração do WhatsApp para o Mercado Online

Este guia explica como configurar a integração com WhatsApp para receber pedidos automaticamente.

## Como Funciona

O aplicativo gera uma mensagem formatada com todos os detalhes do pedido e redireciona o cliente para o WhatsApp com a mensagem pré-preenchida. O cliente só precisa clicar em "Enviar" para enviar o pedido diretamente para o dono do mercado.

## 1. Configurar Número do WhatsApp

### No Painel Administrativo

1. Acesse o painel administrativo (`admin/index.html`)
2. Faça login com suas credenciais
3. Vá para a seção **Configurações**
4. No campo "Número do WhatsApp", insira seu número no formato internacional
5. Clique em "Salvar"

### Formato do Número

O número deve ser inserido no formato internacional, apenas com dígitos:

- **Brasil**: `55` + `DDD` + `número`
- **Exemplo**: `5511999999999`
  - `55` = Código do Brasil
  - `11` = DDD de São Paulo
  - `999999999` = Número do telefone

### Outros Países (Exemplos)

- **Argentina**: `54` + `DDD` + `número`
- **Estados Unidos**: `1` + `DDD` + `número`
- **Portugal**: `351` + `número`

## 2. Formato da Mensagem

A mensagem enviada para o WhatsApp inclui:

```
🛒 NOVO PEDIDO - MERCADO ONLINE

👤 Cliente: João Silva
📱 Telefone: (11) 99999-9999
📍 Endereço: Rua das Flores, 123 - Centro
💳 Pagamento: PIX

📦 ITENS DO PEDIDO:
──────────────────────────────
• Banana Prata
  Qtd: 2 x R$ 4,99 = R$ 9,98

• Coca-Cola 2L
  Qtd: 1 x R$ 8,99 = R$ 8,99

──────────────────────────────
💰 TOTAL: R$ 18,97

📝 Observações: Entregar após 18h

⏰ Pedido realizado em: 08/05/2025 14:30:25

Pedido gerado automaticamente pelo site
```

## 3. Fluxo do Pedido

1. **Cliente navega** pelo site e adiciona produtos ao carrinho
2. **Cliente preenche** dados no formulário de checkout:
   - Nome completo
   - Telefone
   - Endereço de entrega
   - Forma de pagamento
   - Observações (opcional)
3. **Sistema gera** mensagem formatada automaticamente
4. **Cliente é redirecionado** para o WhatsApp com a mensagem pré-preenchida
5. **Cliente confirma** e envia a mensagem
6. **Dono do mercado recebe** o pedido completo no WhatsApp

## 4. Vantagens da Integração

### Para o Cliente
- ✅ Processo simples e familiar
- ✅ Não precisa instalar apps adicionais
- ✅ Confirmação imediata do pedido
- ✅ Histórico no WhatsApp
- ✅ Comunicação direta com o vendedor

### Para o Dono do Mercado
- ✅ Recebe pedidos organizados e formatados
- ✅ Todos os dados necessários em uma mensagem
- ✅ Pode responder diretamente no WhatsApp
- ✅ Histórico de todos os pedidos
- ✅ Não precisa de sistemas complexos

## 5. Personalização da Mensagem

Se desejar personalizar o formato da mensagem, edite a função `generateWhatsAppMessage` no arquivo `assets/js/client.js`:

```javascript
function generateWhatsAppMessage(orderData) {
    const { customerName, customerPhone, customerAddress, paymentMethod, orderNotes, cart } = orderData;
    
    let message = `🛒 *NOVO PEDIDO - SEU MERCADO*\n\n`; // Personalize aqui
    // ... resto da função
}
```

## 6. Configurações Avançadas

### Múltiplos Números

Para enviar pedidos para diferentes números baseado na região ou tipo de produto, você pode modificar o código para incluir lógica condicional:

```javascript
function getWhatsAppNumber(customerAddress) {
    // Exemplo: diferentes números por região
    if (customerAddress.includes('Centro')) {
        return '5511999999999';
    } else if (customerAddress.includes('Zona Norte')) {
        return '5511888888888';
    }
    return AppState.whatsappNumber; // Número padrão
}
```

### Horário de Funcionamento

Você pode adicionar validação de horário de funcionamento:

```javascript
function isOpenForOrders() {
    const now = new Date();
    const hour = now.getHours();
    const day = now.getDay(); // 0 = Domingo, 6 = Sábado
    
    // Exemplo: Aberto de segunda a sábado, 8h às 22h
    if (day === 0) return false; // Fechado no domingo
    return hour >= 8 && hour < 22;
}
```

### Valor Mínimo do Pedido

Adicione validação de valor mínimo:

```javascript
function validateMinimumOrder(total) {
    const minimumOrder = 20.00; // R$ 20,00 mínimo
    return total >= minimumOrder;
}
```

## 7. Testes

### Testar com Seu Próprio Número

1. Configure seu próprio número no painel administrativo
2. Faça um pedido teste no site
3. Verifique se recebe a mensagem formatada corretamente
4. Teste em diferentes dispositivos (desktop, mobile)

### Testar Diferentes Cenários

- Pedidos com 1 item
- Pedidos com múltiplos itens
- Pedidos com observações
- Pedidos sem observações
- Diferentes formas de pagamento

## 8. Solução de Problemas

### Mensagem Não Abre no WhatsApp

**Possíveis causas:**
- Número configurado incorretamente
- WhatsApp não instalado no dispositivo
- Bloqueador de pop-ups ativo

**Soluções:**
- Verificar formato do número (apenas dígitos)
- Instalar WhatsApp ou usar WhatsApp Web
- Permitir pop-ups para o site

### Caracteres Especiais na Mensagem

**Problema:** Acentos ou emojis não aparecem corretamente

**Solução:** O código já usa `encodeURIComponent()` para tratar caracteres especiais automaticamente.

### Mensagem Muito Longa

**Problema:** WhatsApp tem limite de caracteres

**Solução:** Para pedidos muito grandes, considere dividir em múltiplas mensagens ou usar um resumo.

## 9. Alternativas e Melhorias

### WhatsApp Business API

Para maior automação, considere usar a WhatsApp Business API:
- Respostas automáticas
- Integração com sistemas de gestão
- Múltiplos atendentes
- Relatórios avançados

### Outras Integrações

- **Telegram**: Similar ao WhatsApp
- **SMS**: Para clientes sem WhatsApp
- **Email**: Backup dos pedidos
- **Sistemas de Delivery**: iFood, Uber Eats, etc.

## 10. Conformidade e Privacidade

### LGPD (Lei Geral de Proteção de Dados)

- ✅ Dados são enviados diretamente para o WhatsApp
- ✅ Não armazenamos dados pessoais no servidor
- ✅ Cliente controla o envio da mensagem
- ✅ Histórico fica apenas no WhatsApp do cliente e do vendedor

### Termos de Uso do WhatsApp

- ✅ Uso comercial permitido
- ✅ Mensagens iniciadas pelo cliente
- ✅ Não é spam (cliente solicita o envio)
- ✅ Conteúdo relevante e solicitado

## Suporte

Para dúvidas sobre a configuração do WhatsApp:

1. Verifique a documentação oficial do WhatsApp Business
2. Teste com números conhecidos primeiro
3. Consulte a comunidade de desenvolvedores
4. Entre em contato com o suporte técnico se necessário


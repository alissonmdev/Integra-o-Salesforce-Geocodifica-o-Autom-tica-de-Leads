

#  Integração Salesforce — Geocodificação Automática de Leads

Automação completa de enriquecimento de endereços de Leads no Salesforce utilizando **Google Maps Geocoding API**, processamento assíncrono e arquitetura baseada em boas práticas enterprise.

---

##  Visão Geral

Equipes comerciais normalmente armazenam endereços apenas como texto dentro do CRM.

Isso impede:

- segmentação geográfica
- análises territoriais
- visualização em mapas
- automações baseadas em localização

Este projeto resolve o problema criando um **pipeline automático de geocodificação** dentro do Salesforce.

Sempre que um Lead é criado ou atualizado:

 o endereço é enviado automaticamente para a API do Google

 latitude e longitude são calculadas

 o Lead é enriquecido automaticamente.

---

##  Problema

Leads armazenavam apenas:

```
Rua + Cidade + Estado + País
```

Sem coordenadas geográficas não era possível:

- mapear clientes
- criar territórios inteligentes
- integrar sistemas logísticos
- realizar análises espaciais

---

##  Solução

Arquitetura baseada em processamento assíncrono:

```
Lead criado/alterado
        ↓
Apex Trigger
        ↓
Queueable Apex (Async)
        ↓
Google Geocoding API
        ↓
Atualização automática do Lead
```

---

##  Arquitetura Técnica

```

```
<img width="480" height="1318" alt="mermaid-diagram" src="https://github.com/user-attachments/assets/6d80a33f-5057-4085-9fc0-868e7c449ece" />


---

##  Componentes da Solução

###  Apex Trigger — `LeadGeocodeTrigger`

Responsável por:

- detectar alteração de endereço
- evitar processamento desnecessário
- enviar registros para processamento assíncrono

 Bulk-safe

---

###  Queueable Apex — `LeadGeocodeQueueable`

Executa:

- callout externo
- tratamento de erro
- atualização dos Leads

Motivo da escolha:

- substitui Future Methods
- melhor monitoramento
- escalável

---

###  Service Layer — `GoogleGeocodeService`

Camada responsável por:

- comunicação com API externa
- parsing da resposta JSON
- normalização de erros

Arquitetura desacoplada.

---

###  Custom Metadata — Configuração Dinâmica

```
Google_Settings__mdt
```

Campos:

- `IsEnabled__c` → liga/desliga integração
- `ApiKey__c` → chave da API Google

 Nenhuma credencial hardcoded.

---

###  Named Credential

Endpoint seguro:

```
GoogleGeocode
https://maps.googleapis.com
```

Benefícios:

- segurança
- portabilidade entre orgs
- código limpo

---

##  Estratégia de Testes

Utiliza:

```
HttpCalloutMock
```

Simulação da resposta da API Google:

```
{
  "status":"OK",
  "results": [{
    "formatted_address":"Feira de Santana - BA, Brasil",
    "geometry": {
      "location": {
        "lat":-12.2664,
        "lng":-38.9663
      }
    }
  }]
}
```

 testes determinísticos

 compatível com deploy Salesforce

---

##  Demonstração

### Execução Assíncrona (Apex Jobs)

> O GIF demonstra o Lead sendo salvo e automaticamente enriquecido com coordenadas geográficas.
> 


![projetosf](https://github.com/user-attachments/assets/9fb213d9-b733-4a15-b97e-884b6c975f48)



---

##  Evidências do Projeto

- Queueable executado com sucesso
- Integração ativa via Custom Metadata
- Named Credential configurado
- Callout realizado com sucesso

---

##  Tecnologias Utilizadas

- Salesforce Apex
- Queueable Apex
- Custom Metadata Types
- Named Credentials
- Google Maps API
- HTTP Callouts
- Apex Test Classes

---

##  Aprendizados Técnicos

- Arquitetura assíncrona em Salesforce
- Respeito a Governor Limits
- Integrações seguras
- Separação de responsabilidades
- Testes de integrações externas

---

##  Melhorias Futuras

- Retry automático
- Batch Geocoding
- Visualização em mapa (LWC)
- Platform Events

---

##  Autor

**Alisson Machado**

Salesforce Developer | Apex | Integrações | Automação

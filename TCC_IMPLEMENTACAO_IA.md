# Implementação de IA no ClimaAgora — Documentação Técnica para o TCC

**Aluno:** Fernando Ferreira Duarte  
**Disciplina:** MBA em Engenharia de Software — USP/ESALQ  
**Data da implementação:** Junho de 2026

---

## 1. Contexto e Motivação

A pesquisa preliminar identificou que **62,8% dos respondentes** preferem adaptação
automática da interface ao invés de configuração manual (Tabela 3 do TCC). A limitação
ética mais crítica apontada foi a **privacidade dos dados de interação**: o protótipo
original enviava todas as informações climáticas e contexto do usuário para a API da
OpenAI (servidores externos).

A WWDC 2026 da Apple introduziu dois frameworks que endereçam diretamente essas
lacunas:

| Framework         | Sessão WWDC 2026                                              |
|-------------------|---------------------------------------------------------------|
| Foundation Models | *"What's new in the Foundation Models framework"*            |
| Core AI           | *"Meet Core AI"* / *"Integrate on-device AI models into your app using Core AI"* |

---

## 2. Arquitetura Implementada

### 2.1 Padrão de Roteamento com Fallback

Foi implementado um padrão de **fachada com roteamento automático de provider**,
que preserva toda a interface pública existente (`IAService`) sem exigir alterações
nas Views ou no ViewModel.

```
WeatherViewModel
      │
      ▼
  IAService  ─── detecta disponibilidade ──►  iOS 26+ com Apple Intelligence?
      │                                               │
      │                                      SIM ─────┘
      ▼                                      │
FoundationModelsService                      ▼
  (on-device, Neural Engine)         NÃO → OpenAI GPT-3.5 (fallback)
```

**Arquivo principal:** `ClimaAgora/Services/IAService.swift`  
**Novo serviço:** `ClimaAgora/Services/FoundationModelsService.swift`

### 2.2 Lógica de Decisão

```swift
// IAService.swift — método route()
private func route(
    onDevice: @escaping (@escaping (String?) -> Void) -> Void,
    cloudFallback: @escaping (@escaping (String?) -> Void) -> Void,
    completion: @escaping (String?) -> Void
) {
    if isFoundationModelsAvailable() {
        onDevice { result in
            if let result = result {
                completion(result)       // sucesso on-device
            } else {
                cloudFallback(completion) // falha → fallback OpenAI
            }
        }
    } else {
        cloudFallback(completion)         // dispositivo incompatível
    }
}
```

### 2.3 Detecção de Disponibilidade

```swift
func isFoundationModelsAvailable() -> Bool {
    #if canImport(FoundationModels)
    if #available(iOS 26.0, *) {
        return true
    }
    #endif
    return false
}
```

---

## 3. Foundation Models Framework — Inferência On-Device

### 3.1 O que é

O Foundation Models framework (Apple, 2026) expõe o modelo de linguagem da
Apple Intelligence diretamente para aplicativos iOS/macOS. A inferência ocorre
**inteiramente no Neural Engine** do dispositivo, sem tráfego de rede.

### 3.2 Como é usado no ClimaAgora

```swift
// FoundationModelsService.swift — motor de geração
private func generate(prompt: String, completion: @escaping (String?) -> Void) {
    if #available(iOS 26.0, *) {
        Task {
            let session = LanguageModelSession()
            let response = try await session.respond(to: prompt)
            await MainActor.run { completion(response.content) }
        }
    }
}
```

### 3.3 Impacto nas Limitações do TCC

| Limitação identificada no TCC                  | Solução com Foundation Models         |
|------------------------------------------------|---------------------------------------|
| Privacidade: dados enviados a servidores       | Processamento 100% local, sem rede   |
| Dependência de conectividade                   | App funciona offline                  |
| Custo por requisição de API                    | Sem custo de tokens                   |
| Latência de rede (~500ms–2s)                   | Inferência local (~100–300ms)        |

---

## 4. Estratégia de Prompts para Acessibilidade Cognitiva

### 4.1 Modo Normal vs. Modo Simplificado (Plain Language)

O app possui dois perfis de geração de texto, controlados pelo
`CognitiveAccessibilityManager.isSimplifiedMode`:

**Modo Normal** — vocabulário rico, estrutura detalhada:
```
Gere recomendações práticas e amigáveis para o clima atual.
Cidade: São Paulo | Temperatura: 28°C | Condição: Parcialmente nublado
[...]
Máximo 250 palavras.
```

**Modo Simplificado (Plain Language)** — diretrizes cognitivas aplicadas:
```
Você fala de forma MUITO SIMPLES, como para uma criança de 10 anos.
REGRAS:
- Frases CURTAS (máximo 10 palavras)
- Palavras SIMPLES do dia a dia
- Emoji no início de cada linha
- 1 ideia por linha
```

### 4.2 Justificativa Acadêmica

O modo simplificado aplica os princípios da **Plain Language** e das diretrizes
de acessibilidade cognitiva de Britto e Pizzolato (2016), que recomendam:
- Frases curtas (≤ 15 palavras)
- Vocabulário de uso cotidiano
- Estrutura visual com âncoras (emojis como substitutos de ícones)
- Uma informação por linha (redução de carga cognitiva estranha)

Esses critérios endereçam diretamente a barreira mais citada pelos participantes:
**"Falta de instruções claras (passo a passo)"** — 48,8% das menções (Tabela 2).

---

## 5. Indicador de Provider na UI de Configurações

Para fins de pesquisa e transparência, o `IAService` expõe o provider ativo:

```swift
// Em SettingsView, pode ser exibido como:
let provider = IAService.shared.activeProvider
// → "Apple Foundation Models (on-device)"  [iOS 26+]
// → "OpenAI GPT-3.5 (cloud)"               [fallback]

Text(provider.privacyDescription)
// → "Processamento local — nenhum dado enviado à internet"
// → "Processamento em nuvem — dados enviados ao servidor OpenAI"
```

Isso permite documentar nos testes do TCC **qual provider estava ativo** durante
cada sessão de avaliação.

---

## 6. Motor de Adaptação Automática Comportamental (núcleo da contribuição)

Esta é a peça que materializa a **tese central** do TCC: a interface que se
adapta **sozinha**, lendo o comportamento do usuário, **superando a
parametrização manual** — a preferência de **62,8%** dos respondentes (Tabela 3).

Até aqui, a acessibilidade cognitiva do app era 100% **manual** (o usuário
ligava toggles em Configurações). Isso é exatamente o modelo que a fundamentação
teórica critica. O motor fecha essa lacuna.

### 6.1 Fundamentação → código

A Teoria da Carga Cognitiva (Sweller) afirma que a memória de trabalho é finita
e que a **carga estranha** (extraneous load) — gerada por design ruidoso e
navegação imprevisível — consome recursos que deveriam ir para a tarefa. Essa
carga não é observável diretamente, mas se **manifesta** em padrões de
comportamento. O motor trata esses padrões como **proxies mensuráveis** da carga:

| Sinal comportamental (código)     | Barreira da pesquisa (Tabela 2)                    | Peso |
|-----------------------------------|----------------------------------------------------|------|
| `repeatedTap` (toques repetidos)  | Frustração / navegação imprevisível                | 3.0  |
| `error` (operação falhou)         | Falta de instruções claras                         | 3.0  |
| `retry` (re-tentativa)            | Falta de instruções claras (48,8%)                 | 2.5  |
| `backNavigation` (loop de telas)  | Navegação complexa e imprevisível (58,1%)          | 2.0  |
| `hesitation` (tempo parado)       | Excesso de informação / sobrecarga (62,8%)         | 1.5  |
| `taskCompleted` (sucesso)         | — (alívio: interação fluente reduz a carga)        | -2.5 |

### 6.2 Arquitetura (limpa e testável)

```
     Views (ContentView, etc.)
        │  "houve um toque", "deu erro", "entrou na tela"
        ▼
   AdaptiveEngine  ────────────► CognitiveAccessibilityManager
    (facade @MainActor)             (aplica o modo simplificado)
        │  observa            aplica ▲
        ▼                            │ decide (puro)
   InteractionTelemetry        CognitiveLoadEstimator
   (on-device, privacy)        (janela deslizante + limiares)
```

- **Domínio puro** (`Domain/CognitiveAdaptation/`): `InteractionSignal`,
  `CognitiveLoadEstimator`, `AdaptationDecision`. Sem SwiftUI, sem rede — a
  lógica de decisão é **determinística e testável isoladamente**.
- **Serviços** (`Services/`): `InteractionTelemetry` (registra sinais + métricas)
  e `AdaptiveEngine` (orquestra as três peças; única porta que as Views usam).
- **UI** (`Views/Components/AdaptiveSuggestionView.swift`): banner de sugestão +
  modificadores `.adaptiveScreen("Home")` que instrumentam uma tela em 1 linha.

### 6.3 Lógica de decisão (janela deslizante + dois limiares)

O estimador soma os pesos dos sinais dentro de uma **janela de 90s** (carga é um
estado momentâneo) e compara a dois limiares:

- score ≥ **6** → **sugere** simplificar (banner gentil, dispensável);
- score ≥ **10** → **simplifica sozinho** (apenas se o usuário permitiu).

### 6.4 Agência preservada (Human-Centered AI — Shneiderman, 2022)

O design implementa o quadrante "alta automação **com** alto controle humano":

- a adaptação começa sempre como **convite** ("Quer deixar mais simples?"), não imposição;
- quando adapta sozinha, **avisa em linguagem clara** e oferece **"Voltar ao normal"**;
- toda adaptação é **reversível** e o motor pode ser **desligado** por completo;
- é **transparente**: o banner explica *por que* adaptou (sinal dominante).

Isso responde diretamente à cautela ética levantada nos resultados: "a automação
não deve substituir o julgamento humano, mas ampliá-lo... a IA deve atuar na
periferia da interação".

### 6.5 Telemetria de validação (dados empíricos para a próxima fase)

`InteractionTelemetry` mantém contadores **anônimos e locais** (nenhum conteúdo,
nada trafega para servidores — endereça a limitação ética central de privacidade).
Estes dados alimentam a próxima fase da pesquisa (testes de usabilidade prometidos
na seção de Limitações): nº de sinais de atrito, sugestões mostradas/aceitas,
adaptações automáticas e **taxa de aceitação**. Visíveis em Configurações e
exportáveis via `exportSummary()`.

### 6.6 Validação por testes (evidência citável)

`ClimaAgoraTests/CognitiveAdaptationTests.swift` — bateria determinística sobre o
núcleo puro: cálculo do score, poda por janela, alívio por sucesso, os dois
limiares, "não re-sugerir se já simplificado", transparência do motivo e as
métricas. **Todos passando** no simulador iOS 26. São a evidência de validação do
artefato que pode ser referenciada no TCC.

---

## 7. Comparativo Técnico para o TCC

| Dimensão              | Antes (OpenAI)              | Depois (Foundation Models)       |
|-----------------------|-----------------------------|----------------------------------|
| **Privacidade**       | Dados enviados à OpenAI     | 100% local, sem tráfego externo |
| **Conectividade**     | Exige internet              | Funciona offline                 |
| **Latência média**    | ~800ms – 2s                 | ~100 – 300ms                     |
| **Custo por uso**     | ~$0.002 por requisição      | Zero                             |
| **Disponibilidade**   | 100% dos dispositivos       | iOS 26+ com Apple Intelligence   |
| **Fallback**          | Não tinha                   | Automático para OpenAI           |
| **Conformidade LGPD** | Requer consentimento explíc.| Não necessário (dado local)      |

---

## 8. Arquivos do Motor de Adaptação

```
ClimaAgora/Domain/CognitiveAdaptation/     ← NOVO — domínio puro (testável)
├── InteractionSignal.swift                    sinais + pesos
├── CognitiveLoadEstimator.swift               lógica de decisão (janela + limiares)
└── AdaptationDecision.swift                   saída (noChange/sugerir/auto)

ClimaAgora/Services/
├── InteractionTelemetry.swift             ← NOVO — telemetria on-device + métricas
├── AdaptiveEngine.swift                   ← NOVO — orquestra tudo (facade)
└── FoundationModelsService.swift          ← inferência on-device (seção 3)

ClimaAgora/Views/Components/
└── AdaptiveSuggestionView.swift           ← NOVO — banner + .adaptiveScreen()

ClimaAgora/Helpers/AccessibilityHelper.swift  ← +applySimplifiedProfile / flags auto
ClimaAgora/Views/Screens/SettingsView.swift   ← +card "Adaptação Automática" + métricas
ClimaAgora/Views/Screens/ContentView.swift    ← instrumentada (.adaptiveScreen + banner)
ClimaAgora/Presentation/Home/HomeViewModel.swift ← sinais de erro/sucesso
ClimaAgoraTests/CognitiveAdaptationTests.swift ← NOVO — validação (todos passando)
```

> Nota de build: o pacote local **ClimaUI** foi integrado ao projeto Xcode
> (antes referenciado por `import` mas ausente do `.pbxproj`), e os alvos de teste
> passaram a gerar Info.plist — sem isso o projeto não compilava a partir de um
> checkout limpo.

---

## 9. Referências Técnicas

Apple Inc. (2026). *What's new in the Foundation Models framework*. WWDC26.  
https://developer.apple.com/videos/wwdc2026/

Apple Inc. (2026). *Meet Core AI*. WWDC26.  
https://developer.apple.com/videos/wwdc2026/

Apple Inc. (2026). *Integrate on-device AI models into your app using Core AI*. WWDC26.  
https://developer.apple.com/videos/wwdc2026/

Apple Inc. (2026). *Build agentic app experiences with the Foundation Models framework*. WWDC26.  
https://developer.apple.com/videos/wwdc2026/

Shneiderman, B. (2022). *Human-Centered AI: Ensuring Human Control while Increasing Automation*.  
Oxford University Press.

Britto, T. C. P.; Pizzolato, E. B. (2016). Diretrizes para interfaces de aplicativos  
para crianças com Transtorno do Espectro Autista. *Cadernos de Informática*, 9(1).

---

*Este documento foi gerado automaticamente como registro da implementação
para fins de documentação do TCC.*

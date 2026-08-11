# ClimaUI — Design System do ClimaAgora

Design System em Swift Package (SwiftUI), no conceito de **Component Playground**
(estilo "Storybook para iOS"): tokens + componentes reutilizáveis + um catálogo
navegável com **uma página por componente**.

## Estrutura

```
ClimaUI/
├── Package.swift
└── Sources/
    ├── ClimaUI/                 ← a biblioteca (o app importa esta)
    │   ├── Tokens/              ← cor, tipografia, espaçamento, raio, sombra, gradiente
    │   └── Components/          ← Button, Card, Tag, TextField, ToggleRow,
    │                              StatTile, ListRow, SectionHeader
    └── ClimaUICatalog/          ← o playground (catálogo navegável)
        ├── ClimaCatalogView     ← raiz: lista Fundamentos + Componentes
        ├── Foundations/         ← páginas de tokens (Cores, Tipografia, Espaçamento)
        └── Components/          ← uma página por componente
```

## Conceito (igual aos repos de referência)

- **Tokens primeiro**: a UI usa sempre a semântica (`ClimaColor.accent`,
  `ClimaFont.headline`, `ClimaSpacing.md`), nunca valores crus. Trocar a marca =
  mudar só os tokens.
- **Componente = API pequena e previsível**: variantes/tamanhos/estados via enums
  (ex.: `ClimaButton(variant:size:isLoading:)`).
- **Página por componente**: cada componente tem uma página no catálogo mostrando
  todas as variações, além de um `#Preview` no próprio arquivo.

## Ver o catálogo

Cada arquivo tem `#Preview` (abra no canvas do Xcode). Ou rode o catálogo inteiro:

```swift
import ClimaUICatalog

ClimaCatalogView()   // ex.: numa tela de debug/dev do app
```

## Integração no app (SPM local)

O ClimaAgora continua sendo um app Xcode e passa a **consumir** este pacote:

1. No Xcode: **File ▸ Add Package Dependencies… ▸ Add Local…**
2. Selecione a pasta `ClimaUI/`.
3. No target do app, adicione o produto **ClimaUI** (e **ClimaUICatalog** se quiser
   embutir o catálogo).
4. Nas telas: `import ClimaUI` e use os componentes/tokens.

> Observação: um app iOS não vira um "pacote puro" — o idiomático (e o que estes
> repos de referência fazem) é manter o app como target Xcode e mover a camada de
> UI compartilhada para um Swift Package local, como acima.

## Componentes

| Componente | Papel no app |
|---|---|
| `ClimaButton` | ações (primário/secundário/ghost, com loading) |
| `ClimaCard` | container de superfície (material + sombra) |
| `ClimaTag` | semáforo de clima 🟢🟡🔴 |
| `ClimaTextField` | busca de cidade |
| `ClimaToggleRow` | linhas de acessibilidade nas configurações |
| `ClimaStatTile` | métricas (umidade/vento/UV) |
| `ClimaListRow` | listas de cidades/favoritos |
| `ClimaSectionHeader` | títulos de seção |

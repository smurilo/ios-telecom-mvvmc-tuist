# Minha Linha iOS — MVVM-C + Tuist

App de **autoatendimento de operadora** em **UIKit** com **MVVM-C** (Model-View-ViewModel + Coordinators), **deep links** e projeto **gerado por código com Tuist**, organizado em frameworks.

> Segmento: **Telecomunicações**

## Stack
Swift 5.9 • UIKit • **MVVM-C** • **Tuist** (Project.swift, frameworks + unit tests por módulo) • async/await (`async let`, `actor`) • Binding leve próprio (`Observable` + `ObservationToken`) • Deep links (URL scheme) • Sheet presentation (detents) • XCTest • SPM (espelho para CI)

## Módulos (Tuist)

```
MinhaLinha (app)
├── Coordinators/     AppCoordinator → InvoicesCoordinator, OfferCoordinator (filhos liberados ao terminar)
├── Scenes/           ViewControllers: só fazem binding e repassam eventos ao ViewModel
└── SceneDelegate     deep links: minhalinha://faturas  ·  minhalinha://ofertas/o2
      │
      ├── TelecomFeatures.framework   HomeViewModel, OfferViewModel, Observable  (sem UIKit)
      └── TelecomCore.framework       modelos, TelecomServicing (+ MockTelecomService actor), DeepLink, formatadores
```

## MVVM-C
- **ViewModels não navegam**: emitem intenção ao coordinator (`HomeCoordinating.showOffer`).
- **Coordinators filhos** são removidos ao final do fluxo, inclusive pelo gesto de voltar (`UINavigationControllerDelegate`), evitando vazamentos.
- **Resultado entre fluxos por callback**: comprar um pacote no `OfferCoordinator` atualiza a Home sem recarregar tudo.
- **Deep link** volta a pilha para a raiz e abre o fluxo certo.
- **Binding sem dependências** (`Observable`): o observador para automaticamente quando o token é liberado (testado), e os ViewModels rodam também no Linux.

## Como executar
```bash
curl -Ls https://install.tuist.io | bash   # ou: mise install tuist
tuist generate                             # gera e abre MinhaLinha.xcworkspace
xcrun simctl openurl booted "minhalinha://ofertas/o2"

swift test                                 # Core + ViewModels via SPM (macOS ou Linux)
```

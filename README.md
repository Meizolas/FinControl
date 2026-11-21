# FinControl

MVP acadêmico mobile de gestão de identidades e acessos (IAM) para uma empresa financeira fictícia. O sistema demonstra autenticação multifator, solicitação e aprovação de acessos, RBAC, revogação, auditoria e indicadores de governança.

Todos os nomes e dados financeiros são demonstrativos. Este projeto não está pronto para produção.

## Importante: o APK não funciona sozinho

Antes de abrir o aplicativo, o computador precisa executar a API Node.js na porta `3000`, o PostgreSQL na porta `55434` e o Keycloak na porta `8081`.

No emulador ou celular conectado por USB, também é necessário executar `adb reverse tcp:3000 tcp:3000`. Sem isso, o aplicativo não encontra a API em `localhost`.

## Inicialização rápida

### Pré-requisitos

- Docker Desktop aberto;
- Node.js 22 ou superior e npm;
- Flutter 3.41.9 ou compatível, apenas para compilar novamente;
- Android Platform Tools (`adb`);
- celular Android ou emulador.

### Baixar e preparar

```powershell
git clone URL_DO_SEU_REPOSITORIO
cd FinControl
npm install
Copy-Item backend/.env.example backend/.env
```

O arquivo `backend/.env` é local e não deve ser enviado ao GitHub.

### Iniciar os serviços

A forma mais simples no Windows é:

```powershell
powershell -ExecutionPolicy Bypass -File .\INICIAR_DEMO.ps1
```

Esse script inicia PostgreSQL e Keycloak, aplica as migrations, carrega os dados fictícios, inicia a API e verifica `http://localhost:3000/health`.

Alternativamente:

```powershell
docker compose up -d
npm install
npm run db:migrate
npm run db:seed
npm run dev
```

Mantenha o terminal de `npm run dev` aberto.

### Instalar e conectar o APK

Com o celular em depuração USB ou o emulador aberto:

```powershell
adb devices
adb install -r CAMINHO_DO_APK.apk
adb reverse tcp:3000 tcp:3000
adb reverse tcp:8081 tcp:8081
```

Depois, abra o **FinControl**. O `adb reverse` é perdido quando o aparelho reinicia ou é desconectado; nesse caso, execute os comandos novamente.

O APK não é versionado porque o build de debug ultrapassa o limite de 100 MB do GitHub. Gere-o localmente ou publique-o separadamente em **GitHub Releases**.

## Compilar o APK

No Windows, clone o repositório em um caminho sem acentos, por exemplo `C:\Projetos\FinControl`.

```powershell
cd frontend
flutter pub get
flutter build apk --debug
```

Saída:

```text
frontend/build/app/outputs/flutter-apk/app-debug.apk
```

## Formas de login

### Modo demonstração — recomendado

Na tela inicial, abra **Entrar no modo demonstração** e escolha um perfil. Esse fluxo não abre o Chrome e facilita a troca de papéis.

O modo demo usa a API e o PostgreSQL reais, mantém o RBAC no backend, exige `DEMO_MODE=true` e é recusado quando `NODE_ENV=production`. Ele não deve ser habilitado em ambiente real.

### Keycloak + MFA

O botão **Entrar com Keycloak + MFA** usa OpenID Connect Authorization Code com PKCE. No primeiro acesso, o Keycloak solicita o cadastro TOTP em Google Authenticator, Microsoft Authenticator ou FreeOTP.

Senha local de todos: `Demo@2026`.

| Login Keycloak | Perfil |
|---|---|
| `ana.assessora` | Assessora financeira |
| `gestor.ti` | Gestor de TI |
| `compliance` | Compliance |
| `diretor` | Direção |

Essas credenciais existem somente para desenvolvimento local.

## O que cada perfil faz

### Ana — Assessora financeira

- cria solicitações com justificativa;
- acompanha as próprias solicitações;
- acessa um módulo somente após aprovação;
- recebe acesso negado quando não possui permissão.

### Carlos — Gestor de TI

- consulta a fila de solicitações;
- aprova ou nega pedidos;
- revoga acessos concedidos;
- não pode aprovar o próprio pedido.

### Marina — Compliance

- consulta e pesquisa eventos de auditoria;
- verifica a integridade do encadeamento de hashes.

### Rafael — Direção

- consulta indicadores calculados do banco;
- acompanha solicitações, tentativas negadas e percentual de MFA;
- verifica concessões sem solicitação aprovada, cuja meta é zero.

## Roteiro sugerido

1. Entre como Ana e tente abrir um módulo sem acesso.
2. Crie uma solicitação com justificativa de pelo menos 10 caracteres.
3. Entre como Carlos e aprove a solicitação.
4. Volte como Ana e abra o módulo liberado.
5. Como Carlos, revogue o acesso.
6. Como Ana, confirme que o módulo voltou a ser bloqueado.
7. Como Marina, consulte os eventos e a integridade da auditoria.
8. Como Rafael, apresente os indicadores atualizados.

Veja [`entrega/ROTEIRO_DEMONSTRACAO.md`](entrega/ROTEIRO_DEMONSTRACAO.md).

## Arquitetura

```text
Flutter mobile (MVVM + Provider)
        |
        | HTTP + token OIDC ou identidade demo local
        v
API Node.js / Express
        |
        +---- PostgreSQL: usuários, solicitações, concessões e auditoria
        +---- Keycloak: OIDC, PKCE, perfis e MFA/TOTP
```

No Flutter, `views` contém a interface; `view_models`, o estado; `repositories`, o acesso aos dados; `services`, HTTP/OIDC/armazenamento; e `models`, as estruturas tipadas. A API é a autoridade final das permissões.

## Funcionalidades implementadas

- Flutter mobile com MVVM, Provider e ícones Lucide;
- API Node.js/Express e PostgreSQL;
- Keycloak com OIDC, PKCE e MFA/TOTP;
- RBAC para quatro perfis;
- criação, aprovação, negação e revogação de acesso;
- módulos fictícios de extratos, folha e relatórios;
- auditoria append-only no fluxo normal, encadeada por hashes;
- painel com indicadores reais do banco;
- tema Keycloak responsivo e em português;
- modo local de demonstração.

## Testes

Backend:

```powershell
$env:NODE_ENV='test'
$env:ALLOW_TEST_AUTH='true'
npm test
```

Flutter:

```powershell
cd frontend
flutter pub get
flutter test
```

Na validação final de 21/11/2026, foram aprovados 6 testes do backend e 3 testes Flutter. Também foi validado o ciclo de solicitação, aprovação, concessão, revogação, bloqueio `403` e auditoria.

## Solução de problemas

### Erro de conexão no aplicativo

```powershell
docker compose ps
Invoke-RestMethod http://localhost:3000/health
adb reverse --list
```

O health check deve retornar `status: ok` e `db: ok`.

### `adb` não é reconhecido

Instale Android SDK Platform Tools e adicione `platform-tools` ao `PATH`, ou use o caminho completo do `adb.exe`.

### Nenhum dispositivo em `adb devices`

Habilite Opções do desenvolvedor e Depuração USB, aceite a autorização no celular e use um cabo com transmissão de dados.

### Chrome lento no emulador

Use **Entrar no modo demonstração**. O Chrome só é necessário para Keycloak + MFA.

### Erro ao compilar em caminho com acento

Clone para um caminho como `C:\Projetos\FinControl`.

## Segurança e limitações

- concessões exigem solicitação aprovada, inclusive por gatilho PostgreSQL;
- `audit_log` bloqueia `UPDATE` e `DELETE` no fluxo normal;
- hashes detectam alterações isoladas, mas um administrador do banco ainda poderia remover o gatilho e reescrever a cadeia;
- HTTP e credenciais demonstrativas só são aceitáveis localmente;
- faltam hardening, HTTPS de produção, revisão DPO/LGPD, pentest, backups testados, alta disponibilidade e integração financeira real.

## Publicar no GitHub

```powershell
git init
git add .
git commit -m "Entrega do MVP FinControl"
git branch -M main
git remote add origin URL_DO_REPOSITORIO
git push -u origin main
```

Antes do `git add`, confirme que `backend/.env`, `node_modules`, `frontend/build` e APKs não aparecem em `git status`.

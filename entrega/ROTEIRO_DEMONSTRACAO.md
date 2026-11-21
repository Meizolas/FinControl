# Roteiro de demonstração — FinControl

## Preparação

1. Na raiz, execute `powershell -ExecutionPolicy Bypass -File .\INICIAR_DEMO.ps1`.
2. Instale `FinControl-demo.apk` no celular Android ou no emulador.
3. No emulador, execute `adb reverse tcp:3000 tcp:3000`.
4. Abra **Entrar no modo demonstração**. Esse modo evita o Chrome e só é aceito pela API local fora de produção.

## Fluxo principal do MVP

1. Entre como **Ana · Assessora**.
2. Abra **Módulos** e tente acessar um módulo sem permissão: a API deve negar.
3. Em **Solicitações**, crie um pedido com justificativa de pelo menos 10 caracteres.
4. Saia e entre como **Carlos · Gestor de TI**.
5. Abra a fila de solicitações e aprove o pedido.
6. Volte como Ana e abra o módulo aprovado.
7. Volte como Carlos e revogue o acesso.
8. Como Ana, tente abrir novamente: a API deve negar.
9. Entre como **Marina · Compliance** e consulte a auditoria e sua integridade.
10. Entre como **Rafael · Direção** e apresente os indicadores calculados do banco.

## Autenticação real

O botão **Entrar com Keycloak + MFA** demonstra OIDC Authorization Code + PKCE e TOTP. Ele permanece no produto, mas não é necessário para o roteiro local, evitando dependência do Chrome do emulador.

## Evidências validadas em 21/11/2026

- Flutter: 3 testes aprovados.
- Backend: 6 testes aprovados.
- Fluxo real validado: solicitação, aprovação, concessão, acesso, auditoria, revogação e novo bloqueio `403`.
- Integridade da cadeia de auditoria: válida durante a validação.

Este é um MVP acadêmico com dados fictícios, não um sistema pronto para produção.

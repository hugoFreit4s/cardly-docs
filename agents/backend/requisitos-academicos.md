# Requisitos acadêmicos (Projeto Final — Sistemas Móveis)

Este documento resume **obrigações do projeto acadêmico** e complementa `already-done.md` nesta mesma pasta. Código e commits permanecem em **inglês**; relatório e documentação para a faculdade seguem **pt-BR** e normas institucionais.

## Contexto

- Trabalho de **Projeto Final** da disciplina; **nível de exigência alto**.
- Foco em **aplicativo móvel** com **regras de negócio reais e complexas** — **não** basta um CRUD básico (telas só de cadastro e listagem).
- O projeto deve **justificar** o uso do ecossistema **mobile** (não ser um sistema que poderia ser só web/desktop sem perda de sentido).
- **Deploy em produção** não é requisito explícito; o escopo é acadêmico, salvo orientação contrária do professor.

## Obrigatórios (oficiais)

1. **Vários perfis de usuário**, incluindo um **Superadmin** com **front-end exclusivo e protegido** (não apenas um “flag” nas mesmas telas dos demais usuários).
2. **Relatório técnico completo** nas **normas ABNT** (estrutura do curso/universidade), contendo:
   - documentação do sistema;
   - explicação de **trechos cruciais** do código;
   - **validação** do sistema com **imagens (prints)** de **diversos cenários de teste reais**.
3. Consultar o **enunciado completo** e a **estrutura do relatório** no **portal** / ambiente virtual da disciplina (fonte de verdade para capítulos e requisitos adicionais).

## Manual ABNT (PDF) — só local, não versionado

- O manual institucional **UNILESTE** para trabalhos acadêmicos fica **apenas na máquina**, em **`unileste-manual-abnt.pdf`** nesta pasta (`docs/agents/`). Pode copiar o mesmo ficheiro do projeto mobile (`cardly-rnative-app`).
- **Toda** a pasta `docs/agents/` fica **fora do Git** — **nada** aqui é enviado ao GitHub. Use o PDF para formatação do relatório.
- **Não** duplicar o manual inteiro em Markdown aqui.

## Implicações para o Cardly

- API e serviços devem suportar **autenticação/autorização** e **papéis** coerentes com o domínio (ex.: estudante, professor, **Superadmin**).
- Implementar **lógica de negócio** além de CRUD (ex.: revisão espaçada, filas de estudo, estatísticas, regras por assunto).
- Planejar **testes** e evidências alinhadas ao relatório (prints do app integrado ao backend quando aplicável).

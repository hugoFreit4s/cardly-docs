Backend repo: https://github.com/hugoFreit4s/cardly-backend
Frontend repo: https://github.com/hugoFreit4s/cardly-rnative-app
Docs repo: https://github.com/hugoFreit4s/cardly-docs

## Repositórios técnicos (backend e frontend)

- **Nenhum** arquivo de documentação, planejamento ou agente: `fixes/`, `already-done.md`, `todo.md`, `docs/agents/`, `.cursor/`, planos, PDFs acadêmicos, etc. ficam **somente** em `cardly-docs`.
- Nos repos técnicos, versionar **apenas código**, configs de build/deploy (Docker, `.env.example`, `nginx.conf`) e README técnico mínimo se necessário.
- `.gitignore` deve ignorar `.cursor/` e `docs/` sem comentários sobre agentes ou IA.
- Commits **nunca** devem incluir trailers `Co-authored-by: Cursor`, `Made-with: Cursor`, referências a `fixes/vN` ou menções a ferramentas de IA.
- Após implementar `fixes/v*.md`, atualizar `already-done.md` **apenas** neste repositório (`cardly-docs`).

## Commits e código

- No comments on code (when the first agent reads this, it should look all the project for comments and remove it);
- All commits should follow the pattern: [Action]: Commit message; example: [Feature]: Implementando toast;
- No emojis at all in commit messages;
- Commit messages must be PT-BR but the [Action] must be one of these: [Feature], [Chore], [Hotfix] in EN-US; Ask to add more if needed;
- We don't want to leave traces that AI was widely used on the project, so git must not have anything from AI, be human as most as you can, check the already done commits and files, if something related to AI was included, remove it fully from the history, if not possible, DELETE THE REPO and create another one.
# commit-rules

Regras de mensagem de commit da Coderockr, num lugar só, para o hook local (lefthook) e para o CI
(GitHub Actions). O script é o mesmo nos dois: `.lefthook/commit-msg/conventional-commit.sh`.

## Regras

1. **Tipo** do [Conventional Commits](https://www.conventionalcommits.org/): `build`, `chore`,
   `ci`, `docs`, `feat`, `fix`, `perf`, `refactor`, `revert`, `style`, `test`, com `!` opcional.
2. **Escopo obrigatório**, da lista do projeto, exceto em `build`, `chore`, `ci` e `docs`
   (opcional, mas, se vier, tem de estar na lista).
3. **Linha em branco** entre o cabeçalho e o corpo.

Ficam de fora os commits gerados pelo git: `Merge …`, `Revert …`, `fixup!`, `squash!`, `amend!`.

## Escopos do projeto

Arquivo `.commit-scopes` na raiz do repositório, um escopo por linha (`#` comenta):

```
auth
search
reports
```

## Hook local

No `lefthook.yml` do projeto:

```yaml
remotes:
  - git_url: https://github.com/Coderockr/commit-rules.git
    ref: v1.1.0
    configs:
      - commit-msg.yml
```

`lefthook install` baixa a versão do `ref` para `.git/info/lefthook-remotes/`. Depois disso o hook
roda offline. Ao trocar o `ref`, rode `lefthook install` de novo.

Para validar uma mensagem fora do commit:

```sh
sh .git/info/lefthook-remotes/commit-rules-v1.1.0/.lefthook/commit-msg/conventional-commit.sh arquivo
```

## CI

```yaml
  commits:
    if: github.event.review.state == 'approved'
    runs-on: ubuntu-slim
    timeout-minutes: 5

    steps:
      - name: Check commit messages
        uses: Coderockr/commit-rules@v1
```

Inputs:

- `title` (padrão `true`): valida o título do PR, que vira a mensagem no squash merge.
- `commits` (padrão `true`): valida cada commit do PR, sem merges.
- `release-branch` (padrão `dev`): PR que sai dessa branch é de release (`dev` → `main`, título
  `Release 18/11/2026`); o título dele não é validado, só os commits. Vazio valida todos os títulos.

## Versões

Tags semver (`v1.0.0`) e a tag móvel da major (`v1`) para a action. Mudança que reprova mensagens
antes aceitas (tipo removido, regra nova) é major.

# FaixaLab no Codespaces

1. Abra o Codespace existente de `Marcelo-Preigschadt/mvlab` na branch `main`.
2. No Explorer do Codespaces, envie `FaixaLab_0_10_1_Windows.zip` para a raiz de `mvlab`. O ZIP contém o servidor e os pesos dos modelos. Deixe o arquivo compactado.
3. No terminal integrado, execute:

   ```bash
   cd /workspaces/mvlab && git pull --ff-only && bash iniciar-faixalab.sh
   ```

4. Quando o servidor iniciar, abra a porta `7860` na aba **Ports**. Mantenha a visibilidade **Private**.

A primeira execução confere o SHA-256 do ZIP, aplica os modelos ao código-fonte com a correção do player e instala o runtime CPU. Alguns modelos são baixados no primeiro processamento. Use o mesmo comando para retomar depois de parar o Codespace. Os projetos e os caches ficam em `/workspaces/.faixalab-data`.

## Link do YouTube no Codespace

1. Exporte apenas os cookies do domínio `youtube.com` de uma sessão autorizada. Use o formato Netscape descrito nas [instruções do yt-dlp](https://github.com/yt-dlp/yt-dlp/wiki/Extractors#exporting-youtube-cookies).
2. Em [GitHub → Settings → Codespaces](https://github.com/settings/codespaces), crie o segredo pessoal `FAIXALAB_YOUTUBE_COOKIES`. Cole o conteúdo inteiro do `cookies.txt` no valor e conceda acesso somente ao repositório `mvlab`.
3. Pare e reabra o Codespace para carregar o segredo. Inicie o FaixaLab com `bash iniciar-faixalab.sh` e cole o link na aba **Link do YouTube**.

O Codespace usa a sessão para solicitar o áudio e executa a separação. Se a sessão expirar, substitua o valor do segredo e reinicie o Codespace. Mantenha o arquivo de cookies e seu conteúdo fora do repositório.

## GitHub Pages

Abra o [FaixaLab](https://marcelo-preigschadt.github.io/FaixaLab/) e clique em **Conectar ao FaixaLab**. O GitHub autentica o dono do Codespace pela porta privada `7860` e o redireciona ao Pages com uma sessão temporária. Mantenha `7860` **Private**. Encaminhe `7861` com visibilidade **Public** para que a interface alcance a API autenticada. Após parar e reiniciar o Codespace, confira a visibilidade de `7861` e refaça a conexão no site.

### Entrada dos usuários com Google

Crie um cliente OAuth do tipo **Aplicativo da Web** no [Google Auth Platform](https://console.cloud.google.com/auth/clients), com a origem JavaScript autorizada `https://marcelo-preigschadt.github.io`. Configure o público como **Externo** e publique o app para aceitar contas fora da lista de testes. Salve somente o ID do cliente em `FAIXALAB_GOOGLE_CLIENT_ID` nos segredos pessoais do Codespaces, com acesso ao repositório `mvlab`. Reinicie o Codespace para o servidor ler a configuração.

O botão do Google entra no FaixaLab e abre a biblioteca da conta. A importação por link continua usando `FAIXALAB_YOUTUBE_COOKIES`, da conta de serviço configurada no servidor. Projetos antigos do proprietário continuam acessíveis pela porta privada.

Para executar a API de áudio em outra máquina, configure `FAIXALAB_AUDIO_SOURCE_URL` e `FAIXALAB_AUDIO_SOURCE_KEY` conforme as [instruções de instalação](https://github.com/Marcelo-Preigschadt/FaixaLab/blob/main/online/README.md#api-de-%C3%A1udio-do-faixalab). O Codespace usará essa instância para obter o áudio.

Enquanto o FaixaLab estiver rodando no terminal do Codespace, ele informa o número de trabalhos na fila e em processamento a cada três minutos. O GitHub conta a saída do terminal como atividade. O [limite de 12 horas por sessão](https://docs.github.com/en/codespaces/about-codespaces/understanding-the-codespace-lifecycle#maximum-lifetime-of-a-codespace) continua aplicável.

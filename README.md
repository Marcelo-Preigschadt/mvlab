# FaixaLab no Codespaces

1. Abra o Codespace existente de `Marcelo-Preigschadt/mvlab` na branch `main`.
2. No Explorer do Codespaces, envie `FaixaLab_0_10_1_Windows.zip` para a raiz de `mvlab`. O ZIP contém o servidor e os pesos dos modelos. Deixe o arquivo compactado.
3. No terminal integrado, execute:

   ```bash
   cd /workspaces/mvlab && git pull --ff-only && bash iniciar-faixalab.sh
   ```

4. Quando o servidor iniciar, abra a porta `7860` na aba **Ports**. Mantenha a visibilidade **Private**.

A primeira execução confere o SHA-256 do ZIP, aplica os modelos ao código-fonte com a correção do player e instala o runtime CPU. Alguns modelos são baixados no primeiro processamento. Use o mesmo comando para retomar depois de parar o Codespace. Os projetos e os caches ficam em `/workspaces/.faixalab-data`.

Na aba **Link do YouTube**, cole o link e inicie a separação. Para importar novos vídeos online, gere uma chave nas [configurações da StemSplit](https://stemsplit.io/app/settings/api) e salve-a como `STEMSPLIT_API_KEY` nos [segredos do Codespaces](https://github.com/settings/codespaces), com acesso a `mvlab`. Pare e reabra o Codespace para carregar o segredo e rode `bash iniciar-faixalab.sh` no terminal.

A StemSplit recebe o link e fornece o áudio completo, que é separado pelo FaixaLab. O servidor guarda o áudio por ID do vídeo e reaproveita o pedido do provedor se houver interrupção. O serviço usa créditos por duração e aceita conteúdo que você tem direito de processar. A associação manual continua disponível em **Arquivo de áudio**.

Enquanto o FaixaLab estiver rodando no terminal do Codespace, ele informa o número de trabalhos na fila e em processamento a cada três minutos. O GitHub conta a saída do terminal como atividade. O [limite de 12 horas por sessão](https://docs.github.com/en/codespaces/about-codespaces/understanding-the-codespace-lifecycle#maximum-lifetime-of-a-codespace) continua aplicável.

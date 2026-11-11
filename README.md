# FaixaLab no Codespaces

1. Abra o Codespace existente de `Marcelo-Preigschadt/mvlab` na branch `main`.
2. No Explorer do Codespaces, envie `FaixaLab_0_10_1_Windows.zip` para a raiz de `mvlab`. O ZIP contém o servidor e os pesos dos modelos. Deixe o arquivo compactado.
3. No terminal integrado, execute:

   ```bash
   cd /workspaces/mvlab && git pull --ff-only && bash iniciar-faixalab.sh
   ```

4. Quando o servidor iniciar, abra a porta `7860` na aba **Ports**. Mantenha a visibilidade **Private**.

A primeira execução confere o SHA-256 do ZIP, aplica os modelos ao código-fonte com a correção do player e instala o runtime CPU. Alguns modelos são baixados no primeiro processamento. Use o mesmo comando para retomar depois de parar o Codespace. Os projetos e os caches ficam em `/workspaces/.faixalab-data`.

Na aba **Link do YouTube**, cole o link e inicie a separação. O inicializador sobe a API de áudio do FaixaLab no loopback, com uma chave gerada a cada execução. A API reutiliza o áudio salvo por ID do vídeo e a separação roda no servidor principal. A disponibilidade do áudio depende da resposta do YouTube à máquina que executa a API.

Para executar a API de áudio em outra máquina, configure `FAIXALAB_AUDIO_SOURCE_URL` e `FAIXALAB_AUDIO_SOURCE_KEY` conforme as [instruções de instalação](https://github.com/Marcelo-Preigschadt/FaixaLab/blob/main/online/README.md#api-de-%C3%A1udio-do-faixalab). O Codespace usará essa instância para obter o áudio.

Enquanto o FaixaLab estiver rodando no terminal do Codespace, ele informa o número de trabalhos na fila e em processamento a cada três minutos. O GitHub conta a saída do terminal como atividade. O [limite de 12 horas por sessão](https://docs.github.com/en/codespaces/about-codespaces/understanding-the-codespace-lifecycle#maximum-lifetime-of-a-codespace) continua aplicável.

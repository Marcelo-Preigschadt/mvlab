# FaixaLab no Codespaces

1. Abra o Codespace existente de `Marcelo-Preigschadt/mvlab` na branch `main`.
2. No Explorer do Codespaces, envie `FaixaLab_0_10_1_Windows.zip` para a raiz de `mvlab`. O ZIP contém o servidor e os pesos dos modelos. Deixe o arquivo compactado.
3. No terminal integrado, execute:

   ```bash
   cd /workspaces/mvlab && git pull --ff-only && bash iniciar-faixalab.sh
   ```

4. Quando o servidor iniciar, abra a porta `7860` na aba **Ports**. Mantenha a visibilidade **Private**.

A primeira execução confere o SHA-256 do ZIP, aplica os modelos ao código-fonte com a correção do player e instala o runtime CPU. Alguns modelos são baixados no primeiro processamento. Use o mesmo comando para retomar depois de parar o Codespace. Os projetos e os caches ficam em `/workspaces/.faixalab-data`.

## Link do YouTube com a instalação Windows

Instale o [GitHub CLI](https://cli.github.com/) se precisar. Na primeira configuração, execute `gh auth login --web --scopes codespace` com a conta que criou o Codespace. Em um PowerShell aberto na pasta do FaixaLab Windows que contém `INSTALAR.bat`, execute os dois comandos abaixo.

```powershell
Invoke-WebRequest -UseBasicParsing 'https://raw.githubusercontent.com/Marcelo-Preigschadt/FaixaLab/21bf7570ec5ee07862f684db966075dfab0cb9c6/app/cloud/conectar_codespace.py' -OutFile "$env:TEMP\conectar_codespace.py"
& '.\.venv\Scripts\python.exe' "$env:TEMP\conectar_codespace.py"
```

Quando aparecer `FaixaLab conectado`, cole o link na aba **Link do YouTube** do app. O extrator Windows entrega o áudio ao Codespace pelo túnel SSH privado. O Codespace executa a separação. Deixe o PC ligado e o PowerShell aberto enquanto estiver usando links. O script seleciona o Codespace de `mvlab` desta conta. Se houver mais de um em execução, passe `--codespace NOME` no segundo comando.

Para executar a API de áudio em outra máquina, configure `FAIXALAB_AUDIO_SOURCE_URL` e `FAIXALAB_AUDIO_SOURCE_KEY` conforme as [instruções de instalação](https://github.com/Marcelo-Preigschadt/FaixaLab/blob/main/online/README.md#api-de-%C3%A1udio-do-faixalab). O Codespace usará essa instância para obter o áudio.

Enquanto o FaixaLab estiver rodando no terminal do Codespace, ele informa o número de trabalhos na fila e em processamento a cada três minutos. O GitHub conta a saída do terminal como atividade. O [limite de 12 horas por sessão](https://docs.github.com/en/codespaces/about-codespaces/understanding-the-codespace-lifecycle#maximum-lifetime-of-a-codespace) continua aplicável.

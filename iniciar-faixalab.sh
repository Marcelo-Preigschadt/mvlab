#!/usr/bin/env bash
set -euo pipefail

root=$(cd -- "$(dirname -- "$0")" && pwd)
runtime="$root/.faixalab"
previous_revision=b02a77486eda28341da84d948c5f4a0cec22dcc6
interface_revision=9d402102d0befb6ec48e475190a0718ef820ab8f
origin_revision=c0c210ec5e0ac9c5b49e0eb60417749ce7b0262b
linked_audio_revision=02dd52c430119064a413cbcc250b9e39cdcbf18f
stemsplit_revision=e8e1ebca8d7b0d8a57835c8809c64ebb8a2beb62
source_api_revision=a1dc7e1f0520bf32f96c5fc11c8910c8265b70cc
windows_bridge_revision=21bf7570ec5ee07862f684db966075dfab0cb9c6
youtube_cookie_revision=92fcebf9148f1a0ccf908f27eaf09f3b33d28543
pages_relay_revision=c73f6eed5b43544c6c04f478a0fa0b168270870f
revision=3e12252ac6a449e14cd47471e3f41846d8d624e1
repository=https://github.com/Marcelo-Preigschadt/FaixaLab.git
# The installed virtual environment and model links depend on this path.
source="$runtime/source-$previous_revision"
archive=${1:-"$root/FaixaLab_0_10_1_Windows.zip"}
case "$archive" in /*) ;; *) archive="$PWD/$archive" ;; esac

if [[ ! -f "$source/.app/FaixaLab/.release-sha256" && ! -f "$archive" ]]; then
  printf 'Envie FaixaLab_0_10_1_Windows.zip para a raiz de mvlab e tente novamente.\n' >&2
  exit 1
fi

mkdir -p "$runtime"
(
  flock 8
  if [[ ! -d "$source" ]]; then
    stage=$(mktemp -d "$runtime/source.XXXXXXXX")
    trap 'rm -rf -- "$stage"' EXIT
    git -C "$stage" init -q
    git -C "$stage" fetch -q --depth=1 "$repository" "$revision"
    git -C "$stage" checkout -q --detach "$revision"
    mv -- "$stage" "$source"
    trap - EXIT
  else
    case "$(git -C "$source" rev-parse HEAD)" in
      "$revision") ;;
      "$previous_revision"|"$interface_revision"|"$origin_revision"|"$linked_audio_revision"|"$stemsplit_revision"|"$source_api_revision"|"$windows_bridge_revision"|"$youtube_cookie_revision"|"$pages_relay_revision")
        git -C "$source" fetch -q --depth=1 "$repository" "$revision"
        git -C "$source" checkout -q --detach "$revision"
        printf 'Código atualizado. Reinicie o servidor se ele já estiver em execução.\n'
        ;;
      *)
        printf 'A revisão do FaixaLab neste Codespace diverge da configuração de mvlab.\n' >&2
        exit 1
        ;;
    esac
  fi
) 8>"$runtime/source.lock"

exec 9>"$runtime/server.lock"
if ! flock -n 9; then
  printf 'O FaixaLab já está iniciando ou em execução neste Codespace.\n'
  exit 0
fi

if [[ ${CODESPACES:-} == true ]]; then
  export FAIXALAB_DATA_DIR="${FAIXALAB_DATA_DIR:-/workspaces/.faixalab-data}"
  host=0.0.0.0
else
  export FAIXALAB_DATA_DIR="${FAIXALAB_DATA_DIR:-$runtime/data}"
  host=127.0.0.1
fi
export PORT=7860
mkdir -p "$FAIXALAB_DATA_DIR"

cd "$source"
app_runtime="$source/app/.runtime"
python="$app_runtime/venv/bin/python"
if [[ ! -x "$python" || ! -f "$app_runtime/cloud-ready" ]]; then
  uv_bin=$(command -v uv || true)
  if [[ -z "$uv_bin" ]]; then
    uv_bin="$runtime/tools/bin/uv"
    if [[ ! -x "$uv_bin" ]]; then
      python3 -m venv "$runtime/tools"
      "$runtime/tools/bin/python" -m pip install uv
    fi
  fi
  if [[ ! -x "$python" ]]; then
    "$uv_bin" venv --python 3.12 "$app_runtime/venv"
  fi
  "$python" cloud/bootstrap.py --archive "$archive"
  "$python" cloud/link_models.py
  "$python" app/install_engine.py --python "$python" --uv "$uv_bin" --accelerator cpu --report "$app_runtime/engine.json"
  "$uv_bin" pip install --python "$python" -r app/requirements.txt
  "$uv_bin" pip check --python "$python"
  if ! "$python" app/prepare_youtube.py; then
    printf 'O runtime do YouTube não ficou pronto. A importação de arquivos locais continua disponível.\n' >&2
  fi
  printf '%s\n' "$revision" > "$app_runtime/cloud-ready"
fi

if [[ ${CODESPACES:-} == true ]]; then
  printf 'Abra a porta 7860 com visibilidade Private na aba Ports quando o servidor iniciar.\n'
fi
cd app

if [[ ${CODESPACES:-} == true ]]; then
  export FAIXALAB_PAGES_URL=https://marcelo-preigschadt.github.io/FaixaLab/
  export FAIXALAB_PAGES_KEY
  FAIXALAB_PAGES_KEY=$("$python" -c 'import secrets; print(secrets.token_urlsafe(32))')
  env -u FAIXALAB_YOUTUBE_COOKIES "$python" -m faixalab.pages_gateway >"$FAIXALAB_DATA_DIR/pages-gateway.log" 2>&1 9>&- &
  pages_gateway_pid=$!
  trap 'kill "$pages_gateway_pid" 2>/dev/null || true; wait "$pages_gateway_pid" 2>/dev/null || true' EXIT
  "$python" server.py --host "$host" --port "$PORT"
  exit
fi

exec "$python" server.py --host "$host" --port "$PORT"

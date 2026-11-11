#!/usr/bin/env bash
set -euo pipefail

root=$(cd -- "$(dirname -- "$0")" && pwd)
runtime="$root/.faixalab"
previous_revision=b02a77486eda28341da84d948c5f4a0cec22dcc6
revision=9d402102d0befb6ec48e475190a0718ef820ab8f
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
  elif [[ $(git -C "$source" rev-parse HEAD) == "$previous_revision" ]]; then
    # This revision changes only static assets and their test. The server
    # reads those assets from disk and can keep running during the update.
    git -C "$source" fetch -q --depth=1 "$repository" "$revision"
    git -C "$source" checkout -q --detach "$revision"
    printf 'Interface atualizada. Recarregue a página do FaixaLab.\n'
  fi

  if [[ $(git -C "$source" rev-parse HEAD) != "$revision" ]]; then
    printf 'A revisão do FaixaLab neste Codespace diverge da configuração de mvlab.\n' >&2
    exit 1
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
exec "$python" server.py --host "$host" --port "$PORT"

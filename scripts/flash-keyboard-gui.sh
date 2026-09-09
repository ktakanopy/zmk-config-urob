#!/usr/bin/env bash

set -u

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
download_script="$script_dir/download-latest-artifact.sh"
export PATH="$HOME/.local/bin:$PATH"

choice="$(kdialog \
    --title "Atualizar firmware do Corne" \
    --menu "Qual lado você deseja atualizar?" \
    left "Lado esquerdo" \
    right "Lado direito")" || exit 0

if [[ "$choice" == "left" ]]; then
    display_side="esquerdo"
else
    display_side="direito"
fi

kdialog \
    --title "Conecte o teclado" \
    --msgbox "Conecte o lado $display_side por USB e ative o modo bootloader. O aplicativo aguardará e montará a memória do teclado automaticamente."

log_file="$(mktemp)"
trap 'rm -f -- "$log_file"' EXIT

if "$download_script" "$choice" >"$log_file" 2>&1; then
    kdialog --title "Firmware atualizado" --msgbox "O firmware do lado $display_side foi copiado com sucesso. Aguarde o teclado reiniciar antes de desconectar o cabo."
else
    kdialog --title "Falha ao atualizar" --textbox "$log_file" 720 480
    exit 1
fi

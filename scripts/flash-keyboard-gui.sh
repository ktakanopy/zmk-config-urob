#!/usr/bin/env bash

set -u

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
root_dir="$(cd -- "$script_dir/.." && pwd)"
build_script="$script_dir/build-local-firmware.sh"
find_uf2_script="$script_dir/find-uf2-mount.sh"
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

log_file="$(mktemp)"
trap 'rm -f -- "$log_file"' EXIT

if ! git -C "$root_dir" pull --ff-only >"$log_file" 2>&1; then
    kdialog --title "Falha ao atualizar o projeto" --textbox "$log_file" 720 480
    exit 1
fi

if ! firmware_file="$($build_script "$choice" 2>>"$log_file")"; then
    kdialog --title "Falha ao compilar" --textbox "$log_file" 720 480
    exit 1
fi

kdialog \
    --title "Conecte o teclado" \
    --msgbox "A compilação terminou. Conecte o lado $display_side por USB e ative o bootloader pressionando reset duas vezes. O aplicativo aguardará e montará a memória automaticamente."

if mount_point="$($find_uf2_script 120 2>>"$log_file")" && cp -- "$firmware_file" "$mount_point/" >>"$log_file" 2>&1; then
    kdialog --title "Firmware atualizado" --msgbox "O firmware do lado $display_side foi copiado com sucesso. Aguarde o teclado reiniciar antes de desconectar o cabo."
else
    kdialog --title "Falha ao atualizar" --textbox "$log_file" 720 480
    exit 1
fi

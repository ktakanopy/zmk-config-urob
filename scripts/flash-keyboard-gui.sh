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

kdialog \
    --title "Conecte o teclado" \
    --msgbox "Conecte o lado $choice por USB e ative o modo bootloader. Pressione OK para procurar a memória do teclado."

mount_point=""
for _ in {1..120}; do
    mount_points=()
    for mount_root in /Volumes "/run/media/$USER" "/media/$USER"; do
        [[ -d "$mount_root" ]] || continue
        while IFS= read -r -d '' info_file; do
            mount_points+=("$(dirname -- "$info_file")")
        done < <(find "$mount_root" -maxdepth 2 -type f -name INFO_UF2.TXT -print0 2>/dev/null)
    done

    if [[ "${#mount_points[@]}" -eq 1 ]]; then
        mount_point="${mount_points[0]}"
        break
    fi

    if [[ "${#mount_points[@]}" -gt 1 ]]; then
        kdialog --error "Mais de um dispositivo UF2 foi encontrado. Desconecte os outros dispositivos e tente novamente."
        exit 1
    fi

    sleep 1
done

if [[ -z "$mount_point" ]]; then
    kdialog --error "A memória UF2 do teclado não apareceu em 120 segundos."
    exit 1
fi

log_file="$(mktemp)"
trap 'rm -f -- "$log_file"' EXIT

if "$download_script" "$choice" "$mount_point" >"$log_file" 2>&1; then
    kdialog --title "Firmware atualizado" --msgbox "O firmware do lado $choice foi copiado com sucesso. Aguarde o teclado reiniciar antes de desconectar o cabo."
else
    kdialog --title "Falha ao atualizar" --textbox "$log_file" 720 480
    exit 1
fi

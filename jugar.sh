#!/bin/sh
# Lanzador de TERMINOCHI para Linux (y macOS).
# Uso:  ./jugar.sh      (la primera vez: chmod +x jugar.sh)
#       sh jugar.sh     (funciona aunque no tenga permiso de ejecucion)

DIR=$(cd "$(dirname "$0")" && pwd)
cd "$DIR" || exit 1

# Si se abrio con doble clic (sin terminal), busca un emulador de terminal y se relanza ahi.
if [ ! -t 0 ] || [ ! -t 1 ]; then
    SELF="$DIR/jugar.sh"
    for term in x-terminal-emulator ptyxis kgx gnome-terminal konsole xfce4-terminal \
                mate-terminal lxterminal qterminal tilix terminator kitty alacritty \
                foot wezterm xterm; do
        command -v "$term" >/dev/null 2>&1 || continue
        case "$term" in
            gnome-terminal|ptyxis|kgx) exec "$term" -- sh "$SELF" ;;
            kitty|foot)                exec "$term" sh "$SELF" ;;
            wezterm)                   exec "$term" start -- sh "$SELF" ;;
            xterm)                     exec "$term" -geometry 104x30 -e sh "$SELF" ;;
            *)                         exec "$term" -e sh "$SELF" ;;
        esac
    done
    echo "No encontre una terminal. Abre una y ejecuta: sh \"$SELF\"" >&2
    exit 1
fi

# Busca Python 3.7 o superior.
PY=""
for cand in python3 python; do
    if command -v "$cand" >/dev/null 2>&1 &&
       "$cand" -c 'import sys; sys.exit(0 if sys.version_info >= (3, 7) else 1)' 2>/dev/null; then
        PY="$cand"
        break
    fi
done

if [ -z "$PY" ]; then
    echo "TERMINOCHI necesita Python 3. Instalalo con el gestor de tu distro, por ejemplo:"
    echo "  Debian/Ubuntu/Mint:  sudo apt install python3"
    echo "  Fedora:              sudo dnf install python3"
    echo "  Arch/Manjaro:        sudo pacman -S python"
    echo "  openSUSE:            sudo zypper install python3"
    printf "Presiona Enter para salir..."
    read -r _
    exit 1
fi

# Forzar UTF-8 para que se vean bien el ASCII art y los acentos.
export PYTHONIOENCODING=utf-8
case "${LANG:-}" in
    *UTF-8*|*utf8*|*UTF8*|*utf-8*) ;;
    *) export LANG=C.UTF-8 ;;
esac

"$PY" terminochi.py
status=$?

# Si fue con doble clic, espera para que no se cierre la ventana de golpe.
if [ "$status" -ne 0 ]; then
    printf "Presiona Enter para salir..."
    read -r _
fi
exit "$status"

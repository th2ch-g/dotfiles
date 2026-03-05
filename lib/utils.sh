# Shared utilities for dotfiles scripts.
# Source this file from install.sh and link.sh.

print_info()  { echo "[INFO] $1" >&1; }
print_warn()  { echo "[WARN] $1" >&2; }
print_error() { echo "[ERROR] $1" >&2; }

# Sets global OS variable to 'Mac', 'Linux', or 'Cygwin'.
# Exits with error if the platform is unsupported.
detect_os() {
    case "$(uname -s)" in
        Darwin)       OS='Mac'    ;;
        Linux*)       OS='Linux'  ;;
        MINGW32_NT*)  OS='Cygwin' ;;
        *)
            print_error "Your platform ($(uname -a)) is not supported."
            exit 1
            ;;
    esac
}

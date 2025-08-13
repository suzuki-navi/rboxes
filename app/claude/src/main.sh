
if [ -n "${RX_VERBOSE:-}" ]; then
    read -p "Press Enter to continue..."
fi
claude "$@"

# Zeek se instala desde el repositorio oficial bajo /opt/zeek.
# Este archivo se instala en /etc/profile.d/zeek.sh por el instalador.
case ":${PATH}:" in
    *:/opt/zeek/bin:*) ;;
    *) export PATH="/opt/zeek/bin:${PATH}" ;;
esac

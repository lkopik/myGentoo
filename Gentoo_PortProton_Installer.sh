#!/bin/bash

# Проверяем запуск от привилегированного пользователя
if [ "$EUID" -ne 0 ]
  then echo "Please run as root or sudo user"
  exit
fi

# Проверяем, установлен ли пакет eselect-repository, если нет, устанавливаем его
if ! command -v eselect repository &> /dev/null; then
  echo "Installing eselect-repository..."
  emerge -a app-eselect/eselect-repository
fi


# Проверка наличия подключенного репозитория "guru"
if eselect repository list -i | grep -q "guru"; then
  echo "The 'guru' repository is already connected."
else
  eselect repository enable guru
  emerge --sync
fi

# Задаем имя пакета, версию и путь к ebuild файлу
package="portproton"
ver="9999"
ebuild_path="/usr/local/portage/games-util/portproton"

mkdir -p $ebuild_path

# Задаем ACCEPT_KEYWORDS для тестовых пакетов на нашей архитектуре
tee /etc/portage/package.accept_keywords/portproton << EOF
games-util/portproton ~amd64
>=gnome-extra/yad-14.1 ~amd64

EOF

# Заполняем ebuild файл
cat << EOF > $package-${ver}.ebuild
# Copyright 2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
inherit git-r3

DESCRIPTION="Software for playing Microsoft Windows games and launchers"
HOMEPAGE="https://linux-gaming.ru/"
EGIT_REPO_URI="https://github.com/Castro-Fidel/PortProton_ALT"

KEYWORDS="~amd64"
LICENSE="MIT"
SLOT="0"

DEPEND="sys-apps/bubblewrap
		net-misc/wget
		app-arch/cabextract
		app-arch/tar
		dev-libs/openssl
		media-gfx/icoutils
		media-libs/mesa
		net-misc/curl
		sys-apps/inxi
		gnome-extra/zenity
		gnome-extra/yad
		sys-devel/bc
		x11-apps/xrandr"

RDEPEND="\${DEPEND}"

src_install() {
		install -Dm775 "\$WORKDIR/\${P}/\${PN}" "\${D}/usr/bin/\${PN}"
}

EOF

# Помещаем ebuild в наш локальный репозиторий и создаем манифесты
mv $package-$ver.ebuild $ebuild_path
ebuild $ebuild_path/$package-$ver.ebuild manifest

# Устанавливаем PortProton с указанием локального репозитория как источника
PORTDIR_OVERLAY="/usr/local/portage" emerge -av portproton

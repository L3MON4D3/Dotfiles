parse_add("skeleton", [[
pkgname=${1:name, or array (in parens) of names}
pkgver=1
pkgrel=1
pkgdesc='${2:succinct description}'
arch=('any')
source=('local-file')
sha256sums=('SKIP')
install=local-file

package() {
	install='install-server'
	depends=('l3mon-nfs-server' 'l3mon-nginx')

	cd \$srcdir
	install -dm644 "\${pkgdir}"/some/dir/
	install -Dm644 local-file "\${pkgdir}"/path/to/some/file

	install -Dm644 backup.sh "\$pkgdir"/home/simon/.local/share/l3mon-backup/backup-hooks/hooktype/pkgname.sh
	install -Dm644 forget.sh "\$pkgdir"/home/simon/.local/share/l3mon-backup/forget-hooks/pkgname.sh

	chown -R simon:simon "\$pkgdir"/home/simon
}
]])

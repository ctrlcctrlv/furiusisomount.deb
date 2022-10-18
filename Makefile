SHELL := /bin/bash
TARGETS_DEB := $(wildcard deb/*)
TARGETS := $(shell echo "${TARGETS_DEB}" | xargs basename --suffix .deb)

.ONESHELL:
pack-ar:
	[ -z "$$DIR" ] && exit 1; \
	cd "$$DIR"; \
	rm -f "$$DIR.deb" || true; \
	for f in debian-binary control.tar.xz data.tar.xz; do \
	echo $f; \
	ar qc "$$DIR.deb" $f; \
	done && \
	cp "$$DIR.deb" ..

unpack-ar:
	for DEB in ${TARGETS}; do \
		pushd .; \
		DIR=`basename --suffix .deb $$DEB`; \
		rm -rf "$$DIR"; \
		mkdir "$$DIR"; \
		cp $$DEB "$$DIR"; \
		cd "$$DIR"; \
		ar x $$DEB; \
		popd; \
	done

.ONESHELL:
get-orig-debs:
	rm -rf deb; \
	mkdir deb && \
	wget -P deb -c http://mirrors.kernel.org/debian/pool/main/f/furiusisomount/furiusisomount_0.11.3.1~repack1-1_all.deb; \
	wget -P deb -c http://mirrors.kernel.org/ubuntu/pool/universe/p/pygtk/python-glade2_2.24.0-5.1ubuntu2_amd64.deb; \
	wget -P deb -c http://mirrors.kernel.org/ubuntu/pool/universe/p/pygtk/python-gtk2_2.24.0-5.1ubuntu2_amd64.deb; \
	wget -P deb -c http://mirrors.kernel.org/ubuntu/pool/universe/p/pycairo/python-cairo_1.16.2-2ubuntu2_amd64.deb; \
	wget -P deb -c http://mirrors.kernel.org/ubuntu/pool/universe/p/pygobject-2/python-gobject-2_2.28.6-14ubuntu1_amd64.deb; \
	wget -P deb -c http://mirrors.kernel.org/ubuntu/pool/main/libf/libffi/libffi7_3.3-4_amd64.deb

.ONESHELL:
debdiff:
	for f in dist/*.deb; do debdiff "deb/`basename "$$f"`" "$$f" > "$${f}diff"; done || test $$? -eq 1; \
	for f in dist/*.debdiff; do \
		CMP="$$(cmp --silent "$$f" NULLDEBDIFF; echo $$?)"; \
		if [[ $$CMP -eq 0 ]]; then \
			rm "$$f"; \
		fi; \
	done

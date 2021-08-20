doc_sources = $(wildcard doc/*/*.md) $(wildcard doc/*.md)
outdoc_files = $(addprefix out/,$(doc_sources:.md=.html))

docassets = $(addprefix out/,$(wildcard doc/assets/*))

VERSION = $(shell node -e "console.log( require('./src/package.json').version )")
UNAME := $(shell uname -s)

ensure_marked_is_installed:
	set -eu; \
	hash npm; \
	if [ $(shell npm list --prefix src/bin/doc >/dev/null 2>/dev/null; echo $$?) -ne "0" ]; then \
		npm ci --prefix=src/bin/doc; \
	fi

docs: ensure_marked_is_installed $(outdoc_files) $(docassets)

out/doc/assets/%: doc/assets/%
	mkdir -p $(@D)
	cp $< $@

out/doc/%.html: doc/%.md
	mkdir -p $(@D)
	node src/bin/doc/generate.js --format=html --template=doc/template.html $< > $@
ifeq ($(UNAME),Darwin)
	sed -i '' 's/__VERSION__/${VERSION}/' $@
else
	sed -i 's/__VERSION__/${VERSION}/' $@
endif

clean:
	rm -rf out/

pingpong:
	bin/installDeps.sh
	npm install --no-save --legacy-peer-deps ep_disable_change_author_name ep_comments_page ep_who_did_what
	rsync -a pingpong_overwrite/ ./
	cd src/node_modules/languages4translatewiki ;\
       		sed -i '' 's,svenska,Svenska,g' *js *json ;\
		gzip -c -9 languages.json > language.json.gz ;\
		gzip -c -9 languages.min.js > languages.min.js.gz
	ls src/locales | grep -v sv.json | grep -v en.json | xargs rm
	printf done > node_modules/ep_disable_change_author_name/.ep_initialized
	printf done > src/.ep_initialized
	printf 'nmwh8EiZwdqrKldw7bM72Wh5AUnHNqUR' > APIKEY.txt
	printf '575cdbe2ee99477d066291fbbd5d66257ef433258c9cf7362b785573767841f6' > SESSIONKEY.txt
	touch settings.json
	tar cf - *KEY.txt doc node_modules settings.json* src tests var \
		| xz -9 > etherpad-`echo ${VERSION} | tr -d ' '`.tar.xz

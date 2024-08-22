pingpong:
	bin/installDeps.sh
	npm install --no-save --legacy-peer-deps ep_headings2 ep_disable_change_author_name ep_comments_page
	rsync -a pingpong_overwrite/ ./
	cd src/node_modules/languages4translatewiki ;\
		sed -i '' 's,svenska,Svenska,g' *js *json ;\
		gzip -c -9 languages.json > language.json.gz ;\
		gzip -c -9 languages.min.js > languages.min.js.gz
	cd src/locales && ls | grep -v sv.json | grep -v en.json | xargs rm
	printf done > node_modules/ep_headings2/.ep_initialized
	printf done > node_modules/ep_disable_change_author_name/.ep_initialized
	printf done > node_modules/ep_comments_page/.ep_initialized
	printf done > src/.ep_initialized
	printf 'nmwh8EiZwdqrKldw7bM72Wh5AUnHNqUR' > APIKEY.txt
	printf '575cdbe2ee99477d066291fbbd5d66257ef433258c9cf7362b785573767841f6' > SESSIONKEY.txt
	cp -p settings.json.template settings.json
	tar cf - *KEY.txt doc node_modules settings.json* credentials.json.template src tests var \
		| xz -9 > etherpad-`echo ${VERSION} | tr -d ' '`.tar.xz

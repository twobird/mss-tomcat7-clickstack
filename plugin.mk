all: pkg

clean: clean-deps clean-pkg

deps: $(deps)

clean-deps:
	@if [ ! "$(deps)" = "" ]; then \
	  echo "rm -rf $(deps)"; \
	  rm -rf $(deps); \
	fi

pkg: pkg_files-var plugin_name-var deps clean-pkg
	mkdir pkg
	cp -a $(pkg_files) pkg
	cd pkg; zip -r ../$(plugin_name).zip *

clean-pkg: plugin_name-var
	rm -rf pkg
	rm -f $(plugin_name).zip

publish: plugin_name-var publish_url-var pkg
	@if [ ! -e s3cfg ]; then \
	  echo "To publish to s3, copy s3cfg.in to s3cfg and edit" \
               "s3cfg specifying your AWS credentials for s3." | fold -s; \
	  exit 1; \
	fi
	@if [ "$$(which s3cmd)" = "" ]; then \
	  echo "To publish to s3, you must install s3cmd. If a system" \
	       "package isn't available, you can download the source from" \
	       "http://s3tools.org/s3cmd." | fold -s; \
	  exit 1; \
	fi
	s3cmd put -Pc s3cfg $(plugin_name).zip $(publish_url)

define check-val
  @if [ "$1" = "" ]; then \
    echo "Missing required Makefile variable $2"; \
    exit 1; \
  fi
endef

pkg_files-var:
	$(call check-val,$(pkg_files),pkg_files)

plugin_name-var:
	$(call check-val,$(plugin_name),plugin_name)

publish_url-var:
	$(call check-val,$(publish_url),publish_url)

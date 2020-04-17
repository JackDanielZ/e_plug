default: src/module.so

CFLAGS := -Wall -Wextra -Wshadow -Wno-type-limits -g3 -O0 -Wpointer-arith -fvisibility=hidden

prefix:=$(shell pkg-config --variable=prefix enlightenment)
release=$(shell pkg-config --variable=release enlightenment)
host_cpu=$(shell uname -m)
MODULE_ARCH="linux-gnu-$(host_cpu)-$(release)"


src/e_mod_main.o: src/e_mod_main.c
ifeq ($(APP_NAME),)
	@echo "APP_NAME not defined"
	@exit 1
endif
ifeq ($(ICON_PATH),)
	@echo "ICON_PATH not defined"
	@exit 1
endif
ifeq ($(BIN_CMD),)
	@echo "BIN_CMD not defined"
	@exit 1
endif
	gcc -fPIC -g -c src/e_mod_main.c $(CFLAGS) -DAPP_NAME=\"$(APP_NAME)\" -DICON_PATH=\"$(ICON_PATH)\" -DBIN_CMD=\"$(BIN_CMD)\" `pkg-config --cflags enlightenment elementary` -o src/e_mod_main.o

src/module.so: src/e_mod_main.o
	gcc -shared -fPIC -DPIC $^ `pkg-config --libs enlightenment elementary` -Wl,-soname -Wl,module.so -o $@

install: src/module.so
ifeq ($(APP_NAME),)
	@echo "APP_NAME not defined"
	@exit 1
endif
ifeq ($(prefix),)
	@echo "prefix not defined, use sudo with -E or check 'sudo pkg-config --variable=prefix enlightenment')"
	@exit 1
endif
	@mkdir -p $(prefix)'/lib/enlightenment/modules/$(APP_NAME)/'$(MODULE_ARCH)
	install -c src/module.so $(prefix)/lib/enlightenment/modules/$(APP_NAME)/$(MODULE_ARCH)/module.so
	install -c module.desktop $(prefix)/lib/enlightenment/modules/$(APP_NAME)/module.desktop
	sed -i -e "s/APP_NAME/$(APP_NAME)/g" $(prefix)/lib/enlightenment/modules/$(APP_NAME)/module.desktop

clean:
	rm -rf src/module.so src/e_mod_main.o

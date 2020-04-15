default: install

ifeq ($(APP_NAME),)
  $(error APP_NAME not defined)
endif

ifeq ($(ICON_PATH),)
  $(error ICON_PATH not defined)
endif

CFLAGS := -Wall -Wextra -Wshadow -Wno-type-limits -g3 -O0 -Wpointer-arith -fvisibility=hidden

CFLAGS += -DAPP_NAME=\"$(APP_NAME)\" -DICON_PATH=\"$(ICON_PATH)\"

prefix:=$(shell pkg-config --variable=prefix enlightenment)
release=$(shell pkg-config --variable=release enlightenment)
host_cpu=$(shell uname -m)
MODULE_ARCH="linux-gnu-$(host_cpu)-$(release)"

src/e_mod_main.o: src/e_mod_main.c
	gcc -fPIC -g -c src/e_mod_main.c $(CFLAGS) `pkg-config --cflags enlightenment elementary` -o src/e_mod_main.o

src/module.so: src/e_mod_main.o
	gcc -shared -fPIC -DPIC src/e_mod_main.o `pkg-config --libs enlightenment elementary` -Wl,-soname -Wl,module.so -o src/module.so

install: src/module.so
	sudo mkdir -p $(prefix)'/lib/enlightenment/modules/$(APP_NAME)/'$(MODULE_ARCH)
	sudo install -c src/module.so $(prefix)/lib/enlightenment/modules/$(APP_NAME)/$(MODULE_ARCH)/module.so
	sudo install -c module.desktop $(prefix)/lib/enlightenment/modules/$(APP_NAME)/module.desktop
	sudo sed -i -e "s/APP_NAME/$(APP_NAME)/g" $(prefix)/lib/enlightenment/modules/$(APP_NAME)/module.desktop

clean:
	rm -rf src/module.so src/e_mod_main.o

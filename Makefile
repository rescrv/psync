CFLAGS=`pkg-config --cflags libgpod-1.0 glib-2.0 python-3.5` -O0 -ggdb
LDFLAGS=`pkg-config --libs libgpod-1.0 glib-2.0 python-3.5`

psync/gpod.so: psync/gpod.o
	gcc -o $@ -fPIC -shared $(LDFLAGS) -lpython3.5m -lgpod $^

psync/gpod.o: psync/gpod.c
	gcc -c -o $@ -fPIC -shared $(CFLAGS) -lpython3.5m -lgpod $^

psync/gpod.c: psync/gpod.pyx
	cython psync/gpod.pyx

clobber:
	rm -f psync/gpod.c psync/gpod.so psync/*.o

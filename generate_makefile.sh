#!/bin/sh

cd $1

toplevel_dirs=org
interfaces=`find $toplevel_dirs -name "*.interface.yaml"`

for i in ${interfaces};
do
    iface_path=`dirname $i`/`basename $i .interface.yaml`
    iface=`echo $iface_path | sed 's/\//./g'`
    cat <<MAKEFILE

${i%.interface.yaml}/server.cpp: ${i} ${i%.interface.yaml}/server.hpp
	@mkdir -p \`dirname \$@\`
	\$(SDBUSPLUSPLUS) -r \$(srcdir) interface server-cpp ${iface} > \$@

${i%.interface.yaml}/server.hpp: ${i}
	@mkdir -p \`dirname \$@\`
	\$(SDBUSPLUSPLUS) -r \$(srcdir) interface server-header ${iface} > \$@

MAKEFILE

done

errors=`find $toplevel_dirs -name "*.errors.yaml"`

for e in ${errors};
do
    iface_path=`dirname $e`/`basename $e .errors.yaml`
    iface=`echo $iface_path | sed 's/\//./g'`
    cat <<MAKEFILE

${e%.errors.yaml}/error.cpp: ${e} ${e%.errors.yaml}/error.hpp
	@mkdir -p \`dirname \$@\`
	\$(SDBUSPLUSPLUS) -r \$(srcdir) error exception-cpp ${iface} > \$@

${e%.errors.yaml}/error.hpp: ${e}
	@mkdir -p \`dirname \$@\`
	\$(SDBUSPLUSPLUS) -r \$(srcdir) error exception-header ${iface} > \$@

MAKEFILE

done

echo "libopenpower_dbus_cpp_SOURCES = \\"
for i in ${interfaces};
do
    echo "	${i%.interface.yaml}/server.cpp \\"
done
for e in ${errors};
do
    echo "	${e%.errors.yaml}/error.cpp \\"
done
echo

echo "libopenpower_dbus_hpp_SOURCES = \\"
for i in ${interfaces};
do
    echo "	${i%.interface.yaml}/server.hpp \\"
done
for e in ${errors};
do
    echo "	${e%.errors.yaml}/error.hpp\\"
done

echo

cat << MAKEFILE
libopenpower_dbus.cpp:
	touch \$@

nobase_include_HEADERS = \$(libopenpower_dbus_hpp_SOURCES)

.PHONY: clean-dbus
clean-dbus:
	for i in \$(libopenpower_dbus_cpp_SOURCES) \\
	         \$(libopenpower_dbus_hpp_SOURCES); \\
	do \\
	    test -e \$\$i && rm \$\$i ; \\
	    test -d \`dirname \$\$i\` && rmdir -p \`dirname \$\$i\` ; \\
	    true; \\
	done
MAKEFILE

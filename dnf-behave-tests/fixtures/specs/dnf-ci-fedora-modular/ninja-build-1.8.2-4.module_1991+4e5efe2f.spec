%undefine _debuginfo_subpackages

Name:           ninja-build
Epoch:          0
Version:        1.8.2
Release:        4.module_1991+4e5efe2f

License:        ASL 2.0
URL:            http://martine.github.com/ninja/

Summary:        Ninja-build package

Provides:       ninja-build = 1.8.2-4.module_1991+4e5efe2f

Requires:       rtld(GNU_HASH)

%description
Description of ninja-build package.

%package debuginfo
Summary:        Debug information for package ninja-build

Provides:       debuginfo(build-id) = 4511ce9b50dd9e24dbbf23b1c18226dc5c25d96a
Provides:       ninja-build-debuginfo = 1.8.2-5.fc29
Provides:       ninja-build-debuginfo(x86-64) = 1.8.2-5.fc29

Recommends:     ninja-build-debugsource(x86-64) = 1.8.2-5.fc29

%description debuginfo
This package provides debug information for package ninja-build.
Debug information is useful when developing applications that use this
package or when debugging this package.

%package debugsource
Summary:        Debug sources for package ninja-build

Provides:       ninja-build-debugsource(x86-64) = 1.8.2-5.fc29
Provides:       ninja-build-debugsource = 1.8.2-5.fc29

%description debugsource
This package provides debug sources for package ninja-build.
Debug sources are useful when developing applications that use this
package or when debugging this package.

%files

%files debuginfo

%files debugsource

%changelog

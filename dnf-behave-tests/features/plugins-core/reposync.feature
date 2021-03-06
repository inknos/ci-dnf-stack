Feature: Tests for reposync command


Background:
  Given I enable plugin "reposync"


Scenario: Base functionality of reposync
  Given I use repository "dnf-ci-thirdparty-updates" as http
   When I execute dnf with args "reposync --download-path={context.dnf.tempdir}"
   Then the exit code is 0
    And stdout contains ": SuperRipper-1\.2-1\."
    And stdout contains ": SuperRipper-1\.3-1\."
    And the files "{context.dnf.tempdir}/dnf-ci-thirdparty-updates/x86_64/CQRlib-extension-1.6-2.x86_64.rpm" and "{context.dnf.fixturesdir}/repos/dnf-ci-thirdparty-updates/x86_64/CQRlib-extension-1.6-2.x86_64.rpm" do not differ


Scenario: Reposync with --newest-only option
  Given I use repository "dnf-ci-thirdparty-updates" as http
   When I execute dnf with args "reposync --download-path={context.dnf.tempdir} --newest-only"
   Then the exit code is 0
    And stdout contains ": SuperRipper-1\.3-1\."
    And stdout does not contain ": SuperRipper-1\.2-1\."


@bz1653126 @bz1676726
Scenario: Reposync with --downloadcomps option
  Given I use repository "dnf-ci-thirdparty-updates" as http
   When I execute dnf with args "reposync --download-path={context.dnf.tempdir} --downloadcomps"
   Then the exit code is 0
    And stdout contains "comps.xml for repository dnf-ci-thirdparty-updates saved"
    And the files "{context.dnf.tempdir}/dnf-ci-thirdparty-updates/comps.xml" and "{context.dnf.fixturesdir}/repos/dnf-ci-thirdparty-updates/repodata/comps.xml" do not differ
   When I execute "createrepo_c --no-database --simple-md-filenames --groupfile comps.xml ." in "{context.dnf.tempdir}/dnf-ci-thirdparty-updates"
   Then the exit code is 0
  Given I configure a new repository "testrepo" with
        | key             | value                                           |
        | baseurl         | {context.dnf.tempdir}/dnf-ci-thirdparty-updates |
    And I drop repository "dnf-ci-thirdparty-updates"
   When I execute dnf with args "group list"
   Then the exit code is 0
    And stdout is
   """
   <REPOSYNC>
   Available Groups:
      DNF-CI-Testgroup
   """


@bz1676726
Scenario: Reposync with --downloadcomps option (comps.xml in repo does not exist)
  Given I use repository "dnf-ci-rich" as http
   When I execute dnf with args "reposync --download-path={context.dnf.tempdir} --downloadcomps"
   Then the exit code is 0
    And stdout does not contain "comps.xml for repository dnf-ci-rich saved"


@bz1676726
Scenario: Reposync with --downloadcomps and --metadata-path options
  Given I use repository "dnf-ci-thirdparty-updates" as http
   When I execute dnf with args "reposync --download-path={context.dnf.tempdir} --metadata-path={context.dnf.tempdir}/downloadedmetadata --downloadcomps"
   Then the exit code is 0
    And stdout contains "comps.xml for repository dnf-ci-thirdparty-updates saved"
    And the files "{context.dnf.tempdir}/downloadedmetadata/dnf-ci-thirdparty-updates/comps.xml" and "{context.dnf.fixturesdir}/repos/dnf-ci-thirdparty-updates/repodata/comps.xml" do not differ


Scenario: Reposync with --download-metadata option
  Given I use repository "dnf-ci-thirdparty-updates" as http
   When I execute dnf with args "reposync --download-path={context.dnf.tempdir} --download-metadata"
   Then the exit code is 0
  Given I configure a new repository "testrepo" with
        | key             | value                                           |
        | baseurl         | {context.dnf.tempdir}/dnf-ci-thirdparty-updates |
    And I drop repository "dnf-ci-thirdparty-updates"
   When I execute dnf with args "group list"
   Then the exit code is 0
    And stdout contains lines
   """
   Available Groups:
   DNF-CI-Testgroup
   """


@bz1714788
Scenario: Reposync downloads packages from all streams of modular repository
  Given I use repository "dnf-ci-fedora-modular" as http
   When I execute dnf with args "reposync --download-path={context.dnf.tempdir}"
   Then the exit code is 0
    And file "//{context.dnf.tempdir}/dnf-ci-fedora-modular/x86_64/nodejs-8.11.4-1.module_2030+42747d40.x86_64.rpm" exists
    And file "//{context.dnf.tempdir}/dnf-ci-fedora-modular/x86_64/nodejs-10.11.0-1.module_2200+adbac02b.x86_64.rpm" exists
    And file "//{context.dnf.tempdir}/dnf-ci-fedora-modular/x86_64/nodejs-11.0.0-1.module_2311+8d497411.x86_64.rpm" exists


@bz1714788
Scenario: Reposync downloads packages from all streams of modular repository even if the module is disabled
  Given I use repository "dnf-ci-fedora-modular" as http
   When I execute dnf with args "module disable nodejs"
   Then the exit code is 0
   When I execute dnf with args "reposync --download-path={context.dnf.tempdir}"
   Then the exit code is 0
    And file "//{context.dnf.tempdir}/dnf-ci-fedora-modular/x86_64/nodejs-8.11.4-1.module_2030+42747d40.x86_64.rpm" exists
    And file "//{context.dnf.tempdir}/dnf-ci-fedora-modular/x86_64/nodejs-10.11.0-1.module_2200+adbac02b.x86_64.rpm" exists
    And file "//{context.dnf.tempdir}/dnf-ci-fedora-modular/x86_64/nodejs-11.0.0-1.module_2311+8d497411.x86_64.rpm" exists


@bz1750273
Scenario: Reposync respects excludes
  Given I use repository "dnf-ci-thirdparty-updates" as http
   When I execute dnf with args "reposync --download-path={context.dnf.tempdir} --excludepkgs=SuperRipper"
   Then the exit code is 0
    And stdout contains ": CQRlib-extension-1\.6-2\.src\.rpm"
    And stdout contains ": CQRlib-extension-1\.6-2\.x86_64\.rpm"
    And stdout does not contain "SuperRipper"
   When I execute "ls {context.dnf.tempdir}/dnf-ci-thirdparty-updates/x86_64/"
   Then stdout is
        """
        CQRlib-extension-1.6-2.x86_64.rpm
        """
   When I execute "ls {context.dnf.tempdir}/dnf-ci-thirdparty-updates/src/"
   Then stdout is
        """
        CQRlib-extension-1.6-2.src.rpm
        """


@bz1750273
Scenario: Reposync respects includes
  Given I use repository "dnf-ci-fedora" as http
  When I execute dnf with args "reposync --download-path={context.dnf.tempdir} --arch=noarch --setopt=includepkgs=abcde"
   Then the exit code is 0
    And stdout contains "abcde-2.9.2-1.fc29.noarch.rpm"
   When I execute "find" in "{context.dnf.tempdir}"
   Then stdout is
    """
    .
    ./dnf-ci-fedora
    ./dnf-ci-fedora/noarch
    ./dnf-ci-fedora/noarch/abcde-2.9.2-1.fc29.noarch.rpm
    """


Scenario: Reposync respects excludes, but not modular excludes
  Given I use repository "dnf-ci-fedora-modular" as http
   When I execute dnf with args "reposync --download-path={context.dnf.tempdir} --setopt=includepkgs=postgresql"
   Then the exit code is 0
    And stdout contains ": postgresql-6\.1-1\."
    And stdout contains ": postgresql-9\.6\.8-1\."
    And stdout does not contain "ninja"
    And stdout does not contain "nodejs"
   When I execute "ls {context.dnf.tempdir}/dnf-ci-fedora-modular/x86_64/"
   Then stdout is
        """
        postgresql-6.1-1.module_2514+aa9aadc5.x86_64.rpm
        postgresql-9.6.8-1.module_1710+b535a823.x86_64.rpm
        """
   When I execute "ls {context.dnf.tempdir}/dnf-ci-fedora-modular/src/"
   Then stdout is
        """
        postgresql-6.1-1.module_2514+aa9aadc5.src.rpm
        postgresql-9.6.8-1.module_1710+b535a823.src.rpm
        """


Scenario: Reposync downloads packages and removes packages that are not part of repo anymore
  Given I use repository "setopt.ext"
   When I execute dnf with args "reposync --download-path={context.dnf.tempdir}"
   Then the exit code is 0
    And file "//{context.dnf.tempdir}/setopt.ext/x86_64/wget-1.0-1.fc29.x86_64.rpm" exists
    And file "//{context.dnf.tempdir}/setopt.ext/src/wget-1.0-1.fc29.src.rpm" exists
    And file "//{context.dnf.tempdir}/setopt.ext/x86_64/flac-1.0-1.fc29.x86_64.rpm" exists
    And file "//{context.dnf.tempdir}/setopt.ext/src/flac-1.0-1.fc29.src.rpm" exists
    And file "//{context.dnf.tempdir}/setopt.ext/x86_64/flac-libs-1.0-1.fc29.x86_64.rpm" exists
  Given I configure repository "setopt.ext" with
        | key             | value                               |
        | baseurl         | {context.scenario.repos_location}/setopt |
    # The following two steps generate repodata for the repository without configuring it
    And I use repository "setopt"
    And I drop repository "setopt"
   When I execute dnf with args "reposync --download-path={context.dnf.tempdir} --refresh --delete"
   Then the exit code is 0
    And file "//{context.dnf.tempdir}/setopt.ext/x86_64/wget-1.0-1.fc29.x86_64.rpm" exists
    And file "//{context.dnf.tempdir}/setopt.ext/src/wget-1.0-1.fc29.src.rpm" exists
    And file "//{context.dnf.tempdir}/setopt.ext/x86_64/flac-1.0-1.fc29.x86_64.rpm" does not exist
    And file "//{context.dnf.tempdir}/setopt.ext/src/flac-1.0-1.fc29.src.rpm" does not exist
    And file "//{context.dnf.tempdir}/setopt.ext/x86_64/flac-libs-1.0-1.fc29.x86_64.rpm" does not exist


Scenario: Reposync preserves remote timestamps of packages
  Given I use repository "reposync" as http
   When I execute dnf with args "reposync --download-path={context.dnf.tempdir} --remote-time"
   Then the exit code is 0
    And stdout contains "\([12]/2\): wget-1\.0-1\.fc29\.x86_64\.rpm .*"
    And stdout contains "\([12]/2\): wget-1\.0-1\.fc29\.src\.rpm .*"
    And the files "{context.dnf.tempdir}/reposync/x86_64/wget-1.0-1.fc29.x86_64.rpm" and "{context.dnf.fixturesdir}/repos/reposync/x86_64/wget-1.0-1.fc29.x86_64.rpm" do not differ
    And timestamps of the files "{context.dnf.tempdir}/reposync/x86_64/wget-1.0-1.fc29.x86_64.rpm" and "{context.dnf.fixturesdir}/repos/reposync/x86_64/wget-1.0-1.fc29.x86_64.rpm" do not differ


Scenario: Reposync preserves remote timestamps of metadata files
  Given I use repository "reposync" as http
   When I execute dnf with args "reposync --download-path={context.dnf.tempdir} --download-metadata --remote-time"
   Then the exit code is 0
    And the files "{context.dnf.tempdir}/reposync/repodata/primary.xml.gz" and "{context.dnf.fixturesdir}/repos/reposync/repodata/primary.xml.gz" do not differ
    And timestamps of the files "{context.dnf.tempdir}/reposync/repodata/primary.xml.gz" and "{context.dnf.fixturesdir}/repos/reposync/repodata/primary.xml.gz" do not differ


@bz1686602
Scenario: Reposync --urls switch
  Given I use repository "dnf-ci-thirdparty-updates" as http
   When I execute dnf with args "reposync --urls"
   Then the exit code is 0
    And stdout matches line by line
    """
    <REPOSYNC>
    http://localhost:[0-9]+/src/CQRlib-extension-1\.6-2\.src\.rpm
    http://localhost:[0-9]+/x86_64/CQRlib-extension-1\.6-2\.x86_64\.rpm
    http://localhost:[0-9]+/src/SuperRipper-1\.2-1\.src\.rpm
    http://localhost:[0-9]+/x86_64/SuperRipper-1\.2-1\.x86_64\.rpm
    http://localhost:[0-9]+/src/SuperRipper-1\.3-1\.src\.rpm
    http://localhost:[0-9]+/x86_64/SuperRipper-1\.3-1\.x86_64\.rpm
    """


@bz1686602
Scenario: Reposync --urls and --download-metadata switches
  Given I use repository "dnf-ci-thirdparty-updates" as http
   When I execute dnf with args "reposync --urls --download-metadata"
   Then the exit code is 0
    And stdout matches line by line
    """
    <REPOSYNC>
    http://localhost:[0-9]+/repodata/primary.xml.gz
    http://localhost:[0-9]+/repodata/filelists.xml.gz
    http://localhost:[0-9]+/repodata/other.xml.gz
    http://localhost:[0-9]+/repodata/comps.xml
    http://localhost:[0-9]+/repodata/comps.xml.gz
    http://localhost:[0-9]+/src/CQRlib-extension-1\.6-2\.src\.rpm
    http://localhost:[0-9]+/x86_64/CQRlib-extension-1\.6-2\.x86_64\.rpm
    http://localhost:[0-9]+/src/SuperRipper-1\.2-1\.src\.rpm
    http://localhost:[0-9]+/x86_64/SuperRipper-1\.2-1\.x86_64\.rpm
    http://localhost:[0-9]+/src/SuperRipper-1\.3-1\.src\.rpm
    http://localhost:[0-9]+/x86_64/SuperRipper-1\.3-1\.x86_64\.rpm
    """


@bz1775434
Scenario: Reposync --newest-only downloads packages from all streams and latest context versions of modular repository and latest non-modular rpms
  Given I use repository "dnf-ci-multicontext-hybrid-multiversion-modular" as http
   When I execute dnf with args "reposync --newest-only --download-path={context.dnf.tempdir}"
   Then the exit code is 0
    And file "//{context.dnf.tempdir}/dnf-ci-multicontext-hybrid-multiversion-modular/x86_64/nodejs-5.4.1-2.module_2011+41787af1.x86_64.rpm" exists
    And file "//{context.dnf.tempdir}/dnf-ci-multicontext-hybrid-multiversion-modular/x86_64/nodejs-5.4.1-2.module_3012+41787ba4.x86_64.rpm" exists
    And file "//{context.dnf.tempdir}/dnf-ci-multicontext-hybrid-multiversion-modular/x86_64/nodejs-5.3.1-1.module_2011+41787af0.x86_64.rpm" does not exist
    And file "//{context.dnf.tempdir}/dnf-ci-multicontext-hybrid-multiversion-modular/x86_64/nodejs-5.3.1-1.module_3012+41787ba3.x86_64.rpm" does not exist
    And file "//{context.dnf.tempdir}/dnf-ci-multicontext-hybrid-multiversion-modular/x86_64/nodejs-5.12.1-1.fc29.x86_64.rpm" does not exist
    And file "//{context.dnf.tempdir}/dnf-ci-multicontext-hybrid-multiversion-modular/x86_64/nodejs-5.12.2-3.fc29.x86_64.rpm" exists
    And file "//{context.dnf.tempdir}/dnf-ci-multicontext-hybrid-multiversion-modular/x86_64/postgresql-9.6.8-1.module_1710+b535a823.x86_64.rpm" exists
    And file "//{context.dnf.tempdir}/dnf-ci-multicontext-hybrid-multiversion-modular/x86_64/postgresql-9.8.1-1.module_9790+c535b823.x86_64.rpm" exists

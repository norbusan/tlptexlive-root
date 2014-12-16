# This is an RPM 'spec' file, for use with the Redhat Package Manager
# to make packages for that distribution.

%define fontdir         %{_datadir}/fonts/freefont

Name:      freefont-ttf
Version:   20051206
Release:   1.pingo.1
Summary:   FreeFonts
Group:     User Interface/X
License:   GPL
URL:       http://www.nongnu.org/freefont/
Source:    freefont-ttf-%{version}.tar
BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-buildroot
BuildArch: noarch
Requires:  fontconfig

%description
Freefonts aim to provide a set of free high-quality outline (OpenType,
Truetype, Type 0) UCS fonts, under GNU GPL license.

All the fonts conform to MES-1 (Minimum European Subset) of
Unicode/ISO 10646.

%prep
%setup

%build

%install
/bin/rm -rf $RPM_BUILD_ROOT

#fonts
install -d -m 0755 $RPM_BUILD_ROOT%{fontdir}
install -m 0644 *.ttf  $RPM_BUILD_ROOT%{fontdir}
cd ..

# "touch" all files we've got flagged as %ghost  but which are not 
# present in the RPM_BUILD_ROOT when RPM looks for files
/bin/touch $RPM_BUILD_ROOT%{fontdir}/fonts.cache-1


%clean
/bin/rm -rf $RPM_BUILD_ROOT


%post
if [ -x %{_bindir}/fc-cache ] ; then 
  %{_bindir}/fc-cache %{_datadir}/fonts ; 
fi

%postun
if [ "$1" = "0" ]; then
   if [ -x %{_bindir}/fc-cache ] ; then 
     %{_bindir}/fc-cache %{_datadir}/fonts ; 
   fi
fi


%files
%defattr(0644,root,root,0755)
%doc README
%doc AUTHORS
%doc CREDITS
%doc COPYING
%doc ChangeLog
%dir %{fontdir}
%{fontdir}/*.ttf
%ghost %{fontdir}/fonts.cache-1

%changelog
* Fri Dec  9 2005 Primoz Peterlin <primoz.peterlin@biofiz.mf.uni-lj.si> 20051206-1.pingo.1
- renamed to freefont-ttf

* Tue Dec 06 2005 Rok Papez <rok.papez@lugos.si> 20051206-1.pingo.1
- Updated fonts to version 2005-12-06

* Fri Sep 09 2005 Rok Papez <rok.papez@lugos.si> 20050407-1.pingo.1
- Updated fonts to version 2005-04-07
- Rebuild for Fedora Core 4 / Pingo 4.0

* Sun Oct 06 2003 Rok Papez <rok.papez@lugos.si> 1.0-1
- Created the first release

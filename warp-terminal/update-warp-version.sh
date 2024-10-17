#!/bin/bash

# Fetch the download page for the Debian package
download_page=$(curl -s 'https://app.warp.dev/download?package=deb' -H 'User-Agent: Mozilla/5.0')

# Extract the download URL and version from the HTML response
download_url=$(echo "$download_page" | grep -oP 'https://releases\.warp\.dev/stable/[^"]+\.deb')
pkgver=$(echo "$download_url" | grep -oP '\d+\.\d+\.\d+\.\d+\.\d+' | head -n 1)

# Check if variables are extracted correctly
if [[ -z "$download_url" || -z "$pkgver" ]]; then
    echo "Failed to extract the download URL or package version."
    exit 1
fi

# Update PKGBUILD with the latest version and source URL
awk -v pkgver="$pkgver" -v download_url="$download_url" '
    BEGIN { replaced_pkgver = 0; replaced_source = 0 }
    /^pkgver=/ && !replaced_pkgver { print "pkgver=" pkgver; replaced_pkgver = 1; next }
    /^source=/ && !replaced_source { print "source=(\"" download_url "\")"; replaced_source = 1; next }
    { print }
' PKGBUILD > PKGBUILD.tmp && mv PKGBUILD.tmp PKGBUILD

echo "PKGBUILD updated to version ${pkgver} with source URL ${download_url}"

# Add this line at the end of the script
echo "::set-output name=pkgver::${pkgver}"

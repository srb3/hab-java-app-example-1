pkg_name=java-app
pkg_origin=srb3 # this would change to a your origin
pkg_version="1.0.0"
pkg_maintainer="Steve Brown"
pkg_license=("Apache-2.0")
pkg_deps=(srb3/openjdk11 core/busybox-static core/curl)
pkg_build_deps=()
pkg_source="https://<web-server>/java-app-${pkg_version}.tar.gz" # url to download from
pkg_shasum="b6d1fa76b0d0d82b0f7252a58f1cb341210485662ab336356d533ebaa9288a3b" # shasum to match the package
pkg_exposes=(port)
pkg_exports=(
  [port]=server.port
)

# custom variables for this plan
ext_index_version=1.0.0
ext_index_source=http://<web-server>/index-${ext_index_version}.tar.gz
ext_index_filename=index-${ext_index_version}.tar.gz
ext_index_shasum="b6d1fa76b0d0d82b0f7252a58f1cb341210485662ab336356d533ebaa9288a3b"

do_before() {
   ext_index_dirname="index-${ext_index_version}"
   ext_index_cache_path="$HAB_CACHE_SRC_PATH/${ext_index_dirname}"
}

# do our default download of $pkg_source, and then download our extra data file
do_download() {
  do_default_download
  download_file $ext_index_source $ext_index_filename $ext_index_shasum
}
  
# verify our main java app download, then verify the index file download 
do_verify() {
  do_default_verify
  verify_file $ext_index_filename $ext_index_shasum
}

# unpack the main java app. this function finds the app in the default download directroy
# then unpack the index data file, do_unpack works out if the file is zip, tar, tar.gz, xz or
# other. if your applications are not archived then just return 0 for the the do_unpack function
do_unpack() {
  do_default_unpack
  unpack_file $ext_index_filename
}  

# Once the plan has completed clean up the extracted archives in the src path
do_clean() {
  do_default_clean
  rm -rf "$ext_index_cache_path"
}

# we are not compiling in this example
do_build() {
  return 0
}

# move our app and data files into the package directory.
# this allows them to be packaged up into the hab package
# and gives them a usable handle in the run hook.
do_install() {
  mv ${ext_index_cache_path} ${pkg_prefix}/index.data
  mv $HAB_CACHE_SRC_PATH/${pkg_name}-${pkg_version}.jar ${pkg_prefix}/application.jar
}

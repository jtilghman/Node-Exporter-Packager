# Node-Exporter-Packager
Node_Exporter Build/Install/Test Ubuntu Packages

If you want to use node_exporter with Prometheus on Ubuntu, here is your answer.

The scripts are as follows:

build-node-exporter.sh 		- Build from source the node_exporter for use with Prometheus. To use this, make sure you have these packages installed:
														sudo apt update
														sudo apt install build-essential devscripts debhelper fakeroot
														Once this is run and built, your .deb package will be in the directory below the directory the tarball is in.

install-node-exporter.sh 	- This will install the node_exporter.deb package as well as make the user and the systemd files, and put it all in place.
														But you must copy this into the top level of the build directory.

test-node-exporter.sh 		- Once everything is built and installed, run this, and it will test the installation of the node_exporter package.

generate_prometheus_yaml.sh - And this is just a helper script that will generate the YAML code to be pasted into your prometheus.yml file.

I hope these are helpful and make using Prometheus and mode_exporter easier.

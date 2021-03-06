#!/bin/bash -e
# used pip packages
pip_packages="jupyter numpy matplotlib opencv-python"

pushd ../..
topdir=$(pwd)

# Install dependencies
# Note: glib-2.0 depends on python2, so reinstall the desired python afterward to make sure defaults are right
apt-get update
apt-get install -y --no-install-recommends glib-2.0
apt-get install -y --no-install-recommends --reinstall python$PYVER python$PYVER-dev

# attempt to run jupyter on all example notebooks
mkdir -p idx_files

cd docs/examples
count=$($topdir/qa/setup_packages.py -n -u $pip_packages)

for i in `seq 0 $count`;
do
    # install pacakges
    inst=$($topdir/qa/setup_packages.py -i $i -u $pip_packages)
    if [ -n "$inst" ]
    then
      pip install $inst
    fi
    # test code
    ls *.ipynb | xargs -i jupyter nbconvert \
                   --to notebook --execute \
                   --ExecutePreprocessor.kernel_name=python${PYVER:0:1} \
                   --ExecutePreprocessor.timeout=300 \
                   --output output.ipynb {}
    # remove pacakges
    remove=$($topdir/qa/setup_packages.py -r  -u $pip_packages)
    if [ -n "$remove" ]
    then
      pip uninstall -y $remove
    fi
done 

popd

./apply.sh 00
./apply.sh 01
./apply.sh 02
./apply.sh 03
./apply.sh 04
./apply.sh 05
./apply.sh 06
./apply.sh 07
./apply.sh 08
./apply.sh 09
./apply.sh 10
./apply.sh 11
./apply.sh 12

./update.sh

mkdir -p dist/
mv dist_tmp/* dist/
rm -rf dist_tmp
cp _redirects dist/
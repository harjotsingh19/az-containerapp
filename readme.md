### make Zip of HoganLovells

make blockchain instance to store Hoganlovells files

`(cd instance && ./instance-setup.sh)`

enter Hoganlovells machine and zip th new-org idrectory using commands:-

`cd $HOME/new-org && sudo zip -r ./hlf-org.zip ./`

download zip file of already created Hoganlovells files

enter blockchain instance container shell 

`(cd instance && ./instance-login.sh)`

`curl 'http://34.162.80.4:7005/download?filePath=$HOME/hlf-org.zip' --output hlf-org.zip`

`unzip hlf-org.zip -d ./hlf-org`

create volumes for certs and network directory

`(cd volume && ./create-volume.sh)`

Populate volumes with certs and network-data

 ### go to blockchain instance if not 

 `(cd instance && ./instance-login.sh)`
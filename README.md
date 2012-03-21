# build_scripts

This is a collection of scripts that does effectively:

     wget foo
     unzip foo
     cd foo
     ./configure --prefix=${HOME}/local
     make 
     make install

This is usually sufficient to install the latest version of software
on a system without root permission.
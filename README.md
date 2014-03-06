# Packagenator

####Description: 
   The intention of Packagenator is to provide a simple resource installer based on a few preconditions,these is still an early beta
   library with only support for offline directory linking as off now

####Commandline
  Packagenator commandline installer: 

  Type in your terminal:  
    dart {path to packagenator}/bin/pack install-pack <path-to-install-bin-file-to>

  e.g
    dart {path to packagenator}/bin/pack install-pack \$HOME/local/bin

  Pack provides sets of commands to perform different operations,such as:

    help: prints out this help information
    install: allows the use of pack.json for dependency management
    init: creates a pack.json file with defaults
    project: creates a default dart project folder with extra files
    install-pack: allows installation of the pack executable file into the supplied directory
    dir: for creating dir which gets automatically linked with the packages folder
    linkpackages: symlinks the packages directory into the supplied path
  
  Note: pack.json dependency management is a beta feature, unreliable as of now.
      
######ThanksGiving    
All gratitude to God alone!
---------------------------------------------------------------------------------------------------
http://github.com/influx6/packagenator

library packagenator.core;

import 'dart:io';
import 'dart:convert';
import 'dart:async';
import 'package:hub/hub.dart';
import 'package:streamable/streamable.dart' as streams;
import 'package:guardedfs/guardedfs.dart' as fs;
import 'package:path/path.dart' as paths;
import 'package:packagenator/src/commandator.dart';

export 'package:packagenator/src/commandator.dart';

part 'versionator.dart';
part 'linkator.dart';
part 'requestor.dart';
part 'updator.dart';
part 'packager.dart';
part 'promptenator.dart';

class Core{

	static RegExp _curlyBody = new RegExp(r'{([\w+\W\s\S\d\D\W]*)}');

	static Map _metaDefaults = {
		'name':"",
		"description":"",
		"version":"0.0.1",
		"license":"mit",
		"install_dir":"./packages",
		"depends":"#depends"
	};

	static Requestor _requests = Requestor.create();
	static Commandator _commander = Commandator.create();

	static Commandator getCommander(){

		var requests = Core._requests;
		var commander = Core._commander;

		requests.stream.on(print);
		
		commander.add('help');
		commander.add('init');
		commander.add('install');
		commander.add('install-pack');
		commander.add('project');
		commander.add('dir');
		commander.add('linkpackages');
    
		commander.on('help',(n){

			print("""
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
			""");

		});

    commander.on('project',(n){
        
        if(n.length < 1) return print("""
    pack-project allows the generation of the scaffold project folder structure for 
    a standard dart library and has this use format:

      pack project name_of_project 
      
      OR

      pack project name_of_project version_of_project 

      OR

      pack project name_of_project version_of_project desc
        """);

        var finder = Enums.nthFor(n);
        var name = finder(0);
        var desc = Funcs.switchUnless(finder(2),'');
        var version = Funcs.switchUnless(finder(1),'');

        if(Valids.notExist(name)){
          
          return print("""
      Error: supply a name atleast for the project ,like below:

      pack-project allows the generation of the scaffold project folder structure for 
      a standard dart library and has this use format:

        pack project name_of_project 
        
        OR

        pack project name_of_project version_of_project 

        OR

        pack project name_of_project version_of_project desc
          """);


        } 

        Packager.current.fsCheck(name).then((n){
            print('Dir $name already exists, exiting...!');
        }).catchError((n){
            
          Packager.current.Dir(name).then((dir){
              
              var license = dir.File('LICENSE');
              var spec = dir.File('pubspec.yaml');
              var pack = dir.File('pack.json');

              var pl = Packager.templates.File('license');
              var pp = Packager.templates.File('pubspec.yaml');
              var pj = Packager.templates.File('pack.json');

              pl.readAsString().then(license.writeAsString);

              pp.readAsString().then((d){
                  var r = d.replaceAll('@name',name)
                    .replaceAll('@description',desc)
                    .replaceAll('@version',version);
                pp.writeAsString(r);
              });

              pj.readAsString().then((d){
                  var r = d.replaceAll('@name',name)
                    .replaceAll('@description',desc)
                    .replaceAll('@version',version);
                pack.writeAsString(r);
              });
              
              dir.createNewDir(paths.join(dir.absolutePath,'packages')).then((p){
                commander.fire('dir',[paths.join(dir.absolutePath,'lib'),dir.absolutePath]);
                commander.fire('dir',[paths.join(dir.absolutePath,'specs'),dir.absolutePath]);
                commander.fire('dir',[paths.join(dir.absolutePath,'bin'),dir.absolutePath]);
                commander.fire('dir',[paths.join(dir.absolutePath,'web'),dir.absolutePath]);
              });

              
              print('$name project folder created!');
          });
            
        });

    });

    commander.on('dir',(n){
        
        if(n.length < 1) return print("""
            pack-dir helps in creating directorys and auto-linking the packages folder 
             
              eg 
                  pack dir tests
                  pack dir tests/shores/test
        """);

        var finder = Enums.nthFor(n);
        var name = finder(0);
        var base = Funcs.switchUnless(finder(1),'.');
        var links = name.split('/');

        var map = Enums.map(links,(e,i,o){
          return paths.normalize(o.sublist(0,i+1).join('/'));
        });
        
        Packager.current.Dir(name,true).then((dir){
            commander.fire('linkpackages',[name,base]);
        });

    });
    
    commander.on('linkpackages',(n){
      
        if(n.length < 1) return print(""" 
          linkpackages helps to symlink the package directory into the appropriate location,
          ensure to run the command either at the root of the directory or in the directory where the packages folder
          link exists.`

            eg pack linkpackages test
      """);
          
          var base = Funcs.switchUnless(Enums.second(n),'.');

          Packager.current.Dir(base).then((pack){
            
            pack.fsCheck('packages').then((path){
              
                pack.createNewDir('packages').then((pkg){
                  
                    var point = paths.normalize(paths.join(pack.absolutePath,Enums.first(n)));
                    pkg.linkTo(paths.join(point,'packages'));
                });

            }).catchError((e){

                print('please navigate to where the packages folder exist and run the command again!');
            });

          });

    });


		commander.on('install-pack',(n){

			var finger = Enums.nthFor(n);
			var script = Platform.script.toFilePath();
			

			if(Valids.notExist(finger(0))) 
				return print('Please specify an install path');
      
      
			var pack = fs.GuardedFile.create(paths.join(finger(0),(Platform.isWindows ? 'pack.bat': 'pack')),false);
			var dart_exec = Packager.penv('_');

      var handlefn = (d){
          var shell = d.replaceAll('@dart_path',dart_exec)
                      .replaceAll('@pack_path',script);
          pack.writeAsString(shell);

          print('pack executable script installed!');

          var loc = paths.join(finger(0),'pack');
          if(Platform.isLinux || Platform.isMacOSX)
            return Process.run('chmod',['-R','+x',loc]).then((p){
               if(p.exitCode == 1){
                 print('Failed to make $loc executable!');
                 print(p.stderr);
                 return null;
             } 
             print('$loc file made executable!');
          });
      };

			pack.exists().then((state){
				if(Platform.isWindows)
          Packager.templates.File('win.shell').readAsString().then(handlefn);

				if(Platform.isLinux) 
          Packager.templates.File('unix.shell').readAsString().then(handlefn);

			});

		});

		commander.on('install',(n){

			Packager.current.fsCheck('pack.json').then((n){
        
        Packager.current.Dir('packages').then((n){

          var file = Packager.current.File('pack.json');

          file.readAsString().then((data){
            requests.use(JSON.decode(data));
            requests.requestDependencies();
          });
        
        });

			}).catchError((e){
				print('pack.json file does not exists!');
			});

		});

		commander.on('init',(n){

			Packager.current.fsCheck('pack.json').then((n){
				print('pack.json file already exists!');
			}).catchError((e){

				var words = new RegExp(r'\w+_*-*\w*');
				var meta = new MapDecorator.from(Core._metaDefaults);
				var file = Packager.current.File('pack.json');
				var prompt = Prompter.create(stdin,(data){
					
					var finger = Enums.nthFor(data);
					meta.update('name',finger('Name'));
					meta.update('version',finger('Version'));
					meta.update('description',finger('Description'));
					meta.update('license',finger('License'));


					var depmeta = {},depends = finger('Depends').toLowerCase();

					var deps = depends.replaceAll(excessSpace,' ').split(excessSpace);

					if(deps.length > 0) 
						deps.forEach((d){
							if(!words.hasMatch(d)) return null;
							depmeta[d] = {
								'type':null,
								'url': null,
								'version': null
							};
						});
					
					meta.update('depends',depmeta);
					
					var enc = JSON.encode(meta.storage).split(',').join(',\n')
						.replaceAll('\\r','')
						.replaceAll('\\n','')
						.replaceAll(r'\t{','{')
						.replaceAll(r'}\t','}')
						.replaceAll('{','{\n ')
						.replaceAll('}','\n}')
						.replaceAll(',',',\n\t');

					var inside  = Core._curlyBody.firstMatch(enc).group(1);
					var body = Enums.map(inside.split('\n'),(e,i,o){
						return ['\t ',e].join('');
					}).join(' \n ');
						
					
					enc = enc.replaceAll(inside,body);
					
					file.writeAsString(enc).then((n){
						exit(0);
					});

				});


				prompt.reset();
				prompt.setOut(print);

				prompt.question('Name','name of library',(n){
					return words.hasMatch(n);
				});
				prompt.question('License','license of library',(n){
					return words.hasMatch(n);
				});
				prompt.question('Version','version of library',(n){
					return Versionator.validVersionNumber(n);
				},'format must be in Major.Minor.Minor i.e 0.0.1 or 2.51.3');
				prompt.optionalQuestion('Description','descript of library');
				prompt.optionalQuestion('Depends','Format: dep1 dep2 dep3');


				print('Answer the following!');

				prompt.boot();
			});

		});

		return Core._commander;
	}
}



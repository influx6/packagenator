library packagenator.core;

import 'dart:io';
import 'dart:convert';
import 'dart:async';
import 'package:hub/hub.dart';
import 'package:streamable/streamable.dart' as streams;
import 'package:guardedfs/guardedfs.dart' as fs;
import 'package:path/path.dart' as paths;
import 'package:ds/ds.dart' as ds;
import 'package:packagenator/src/commandator.dart';

export 'package:packagenator/src/commandator.dart';

part 'versionator.dart';
part 'linkator.dart';
part 'requestor.dart';
part 'updator.dart';
part 'packager.dart';
part 'promptenator.dart';

class Core{

	static Commandator _commander = Commandator.create();

	static Commandator getCommander(){

		Core._commander.add('verbose');
		Core._commander.add('install');

		Core._commander.on('verbose',(){
			print("""
					Packagenator commandline installer: 

						Type in your terminal:  

							dart ./bin/install <path-to-install-bin-file-to>

						e.g

							dart ./bin/install $HOME/local/bin

					A set of 3 files will be created within that directory {pack.bat,pack} with the assumption 
					you already have the dart executable already installed and properly setup in your system paths.
			""");
		});

		Core._commander.on('install',(){

			Packager.current.fsCheck('pack.json').then((n){

				var file = Packager.current.file('pack.json');



			}).catchError((e){
				print('pack.json file does not exists!')
			});

		});

		return Core._commander;
	}
}



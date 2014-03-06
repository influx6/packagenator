library packagenator.spec;

import 'package:hub/hub.dart';
import 'package:packagenator/packagenator.dart';

void main(List args){

	var command = Commandator.create();

	command.add('speak');
	command.add('kill');

	command.on('speak',(n){
		print('hello Commander $n!');
	});

	command.on('kill',(n){
		print('bye $n!');
	});

	command.analyze(args);
}
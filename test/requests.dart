library packagenator.spec;

import 'package:hub/hub.dart';
import 'package:packagenator/packagenator.dart';

void main(){

	var req = Requestor.create();

	req.use({
		'name':'requestor',
		'version':'0.0.1',
		"install_dir":'./packages/',
		'depends':{
			"socketire":{
				'type':'pub',
				'version': '> 0.1.2'
			},
			"ds":{
				'type':'http',
				'url': 'https://pub.dart.com/packages/ds',
				'version': '> 0.1.2'
			},
			'juk':{
				'type':'dartpath',
				'url': '../hub',
			},
			'groupobject':{
				'type': 'git',
				'url': 'http://github.com/influx6/groupobject.dart.git',
			}
		}
	});

	req.requestDependencies();
	req.stream.on(print);

}
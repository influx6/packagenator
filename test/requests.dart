library packagenator.spec;

import 'package:hub/hub.dart';
import 'package:packagenator/packagenator.dart';

void main(){

	var pack = Packager.create();
	var req = Requestor.create(pack);

	req.use({
		'name':'requestor',
		'version':'0.0.1',
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
			'hub':{
				'type':'path',
				'url': '../../hub',
			},
			'groupobject':{
				'type': 'git',
				'url': 'http://github.com/influx6/groupobject.dart.git',
			}
		}
	});

	req.requestDependencies();
}
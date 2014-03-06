library packagenator.spec;

import 'package:hub/hub.dart';
import 'package:packagenator/packagenator.dart';

void main(){


  var com = Core.getCommander();
  
  com.fire('dir',['buffer']);
  com.fire('dir',['buffer/slugger/stroll']);

  com.fire('project',['summerfold']);

}

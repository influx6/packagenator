library packagenator.spec;

import 'dart:io';
import 'dart:isolate';
import 'dart:async';
import 'package:hub/hub.dart';
import 'package:packagenator/packagenator.dart';

void initCom(port){


	var rc = new ReceivePort();
	rc.listen((m){

		print('remote got $m');

		if(m is num){
			if(m == 10){
				rc.close();
				port.send(0);
				return null;
			}
			port.send(m += 1);
		}
	});

	port.send(rc.sendPort);
}

void main(){

	print('Isolates run till the death!');
	var rc = new ReceivePort();
	var wait = new Completer();
	var sp = wait.future;
	var subs = rc.asBroadcastStream();

	subs.listen((msg){
		if(wait.isCompleted) return null;
		if(msg is SendPort) wait.complete(msg);
	});

	var ise = Isolate.spawn(initCom,rc.sendPort).then((ice){

		var rootSend = rc.sendPort;

		sp.then((remoteSend){

			subs.listen((msg){

				print('root got $msg');

				if(msg is num){
					if(msg == 0) return rc.close();
					remoteSend.send(msg += 1);
				}
			});

			rootSend.send(1);
		});
	});


}